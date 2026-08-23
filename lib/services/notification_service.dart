import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/app_keys.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Paste the Web Push certificate key from:
/// Firebase Console → Project settings → Cloud Messaging → Web Push certificates
/// Or pass at build time: `--dart-define=FCM_VAPID_KEY=BKag...`
const String kFcmVapidKey = String.fromEnvironment(
  'FCM_VAPID_KEY',
  defaultValue: '',
);

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.data = const {},
    this.messageId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> data;
  final String? messageId;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
      messageId: messageId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'isRead': isRead,
        'data': data,
        'messageId': messageId,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
      messageId: json['messageId'] as String?,
    );
  }

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    return AppNotification(
      id: doc.id,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      data: Map<String, dynamic>.from(data['data'] as Map? ?? {}),
      messageId: data['messageId'] as String?,
    );
  }
}

/// FCM + Firestore notification history for the admin dashboard.
class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxnString fcmToken = RxnString();
  final RxBool isPanelOpen = false.obs;
  final RxBool isInitialized = false.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historySub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  static const _localCacheKey = 'notification_history_cache';

  Future<NotificationService> init() async {
    if (isInitialized.value) return this;

    await _loadLocalCache();
    await requestPermission();
    await _bindMessagingListeners();

    _authSub = _auth.authStateChanges().listen((user) async {
      await _historySub?.cancel();
      _historySub = null;

      if (user == null) {
        notifications.clear();
        unreadCount.value = 0;
        fcmToken.value = null;
        return;
      }

      await retrieveAndPersistToken();
      _listenHistory(user.uid);
    });

    final current = _auth.currentUser;
    if (current != null) {
      await retrieveAndPersistToken();
      _listenHistory(current.uid);
    }

    isInitialized.value = true;
    return this;
  }

  Future<NotificationSettings> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint(
      'NotificationService: permission=${settings.authorizationStatus}',
    );
    return settings;
  }

  Future<String?> retrieveAndPersistToken() async {
    try {
      if (kIsWeb && kFcmVapidKey.isEmpty) {
        debugPrint(
          'NotificationService: set FCM_VAPID_KEY (Web Push certificate) '
          'to retrieve an FCM web token.',
        );
      }

      final token = kIsWeb
          ? await _messaging.getToken(
              vapidKey: kFcmVapidKey.isEmpty ? null : kFcmVapidKey,
            )
          : await _messaging.getToken();

      fcmToken.value = token;
      debugPrint('NotificationService: FCM token=$token');

      final uid = _auth.currentUser?.uid;
      if (uid != null && token != null && token.isNotEmpty) {
        await _firestore.collection('admins').doc(uid).set(
          {
            'fcmToken': token,
            'fcmTokens': FieldValue.arrayUnion([token]),
            'fcmUpdatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      return token;
    } catch (e, st) {
      debugPrint('NotificationService: getToken failed: $e\n$st');
      return null;
    }
  }

  Future<void> _bindMessagingListeners() async {
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
    await _tokenRefreshSub?.cancel();

    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForeground);
    _openedAppSub =
        FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedMessage);
    _tokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
      fcmToken.value = token;
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      await _firestore.collection('admins').doc(uid).set(
        {
          'fcmToken': token,
          'fcmTokens': FieldValue.arrayUnion([token]),
          'fcmUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  void _listenHistory(String adminId) {
    var isFirstSnapshot = true;

    _historySub = _firestore
        .collection('notifications')
        .where('adminId', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs
            .where((doc) => doc.data()['isBroadcastLog'] != true)
            .map(AppNotification.fromFirestore)
            .toList(growable: false);

        if (!isFirstSnapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;

            final data = change.doc.data();
            if (data == null || data['isBroadcastLog'] == true) continue;
            if (data['sentBy'] == adminId) continue;

            final notification = AppNotification.fromFirestore(change.doc);
            if (!notification.isRead) {
              _showInAppAlert(notification);
            }
          }
        } else {
          isFirstSnapshot = false;
        }

        notifications.assignAll(items);
        unreadCount.value = items.where((n) => !n.isRead).length;
        unawaited(_persistLocalCache());
      },
      onError: (Object e) {
        debugPrint('NotificationService: history stream error: $e');
      },
    );
  }

  Future<void> _handleForeground(RemoteMessage message) async {
    final saved = await _persistIncomingMessage(message);
    if (saved != null) {
      _showInAppAlert(saved);
    }
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    final saved = await _persistIncomingMessage(message);
    if (saved != null && !saved.isRead) {
      await markAsRead(saved.id);
    }
  }

  Future<AppNotification?> _persistIncomingMessage(
    RemoteMessage message,
  ) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'Campus Care';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        '';
    final messageId = message.messageId;

    if (messageId != null && messageId.isNotEmpty) {
      final existing = await _firestore
          .collection('notifications')
          .where('adminId', isEqualTo: uid)
          .where('messageId', isEqualTo: messageId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return AppNotification.fromFirestore(existing.docs.first);
      }
    }

    final doc = _firestore.collection('notifications').doc();
    final payload = <String, dynamic>{
      'adminId': uid,
      'title': title,
      'body': body,
      'data': message.data,
      'messageId': messageId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'source': 'fcm',
    };

    await doc.set(payload);

    return AppNotification(
      id: doc.id,
      title: title,
      body: body,
      createdAt: DateTime.now(),
      isRead: false,
      data: message.data,
      messageId: messageId,
    );
  }

  void _showInAppAlert(AppNotification notification) {
    final messenger = rootScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (notification.body.isNotEmpty)
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                  ],
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              isPanelOpen.value = true;
              if (!notification.isRead) {
                unawaited(markAsRead(notification.id));
              }
            },
          ),
        ),
      );
  }

  Future<void> markAsRead(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService: markAsRead failed: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final unread = await _firestore
        .collection('notifications')
        .where('adminId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (unread.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localCacheKey);
      if (raw == null || raw.isEmpty) return;

      final list = (jsonDecode(raw) as List)
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList();
      if (notifications.isEmpty) {
        notifications.assignAll(list);
        unreadCount.value = list.where((n) => !n.isRead).length;
      }
    } catch (e) {
      debugPrint('NotificationService: local cache load failed: $e');
    }
  }

  Future<void> _persistLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        notifications.take(50).map((n) => n.toJson()).toList(),
      );
      await prefs.setString(_localCacheKey, encoded);
    } catch (e) {
      debugPrint('NotificationService: local cache save failed: $e');
    }
  }

  void togglePanel() => isPanelOpen.value = !isPanelOpen.value;

  void closePanel() => isPanelOpen.value = false;

  @override
  void onClose() {
    _authSub?.cancel();
    _historySub?.cancel();
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    super.onClose();
  }
}
