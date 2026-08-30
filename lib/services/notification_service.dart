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

const String kAdminNotificationsCollection = 'admin_notifications';
const String kLegacyNotificationsCollection = 'notifications';

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
    this.firestoreCollection = kAdminNotificationsCollection,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic> data;
  final String? messageId;
  final String firestoreCollection;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      data: data,
      messageId: messageId,
      firestoreCollection: firestoreCollection,
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
        'firestoreCollection': firestoreCollection,
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
      firestoreCollection: json['firestoreCollection'] as String? ??
          kAdminNotificationsCollection,
    );
  }

  factory AppNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String collection = kAdminNotificationsCollection,
  }) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'];
    final notificationData =
        Map<String, dynamic>.from(data['data'] as Map? ?? {});
    if (data['requestId'] != null) {
      notificationData['requestId'] = data['requestId'];
    }
    if (data['type'] != null) {
      notificationData['type'] = data['type'];
    }

    return AppNotification(
      id: doc.id,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? data['message'] as String? ?? '',
      createdAt: createdAt is Timestamp
          ? createdAt.toDate()
          : DateTime.tryParse(createdAt?.toString() ?? '') ?? DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      data: notificationData,
      messageId: data['messageId'] as String?,
      firestoreCollection: collection,
    );
  }
}

/// FCM + Firestore notification history for the admin dashboard.
class NotificationService extends GetxService {
  static const adminNotificationsCollection = kAdminNotificationsCollection;
  static const legacyNotificationsCollection = kLegacyNotificationsCollection;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxnString fcmToken = RxnString();
  final RxBool isPanelOpen = false.obs;
  final RxBool isInitialized = false.obs;

  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _adminNotificationsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _legacyNotificationsSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  static const _localCacheKey = 'notification_history_cache';
  static const _notificationLimit = 50;

  List<AppNotification> _adminNotificationItems = [];
  List<AppNotification> _legacyNotificationItems = [];
  var _adminNotificationsReady = false;
  var _legacyNotificationsReady = false;
  var _adminNotificationsPrimed = false;
  var _legacyNotificationsPrimed = false;

  Future<NotificationService> init() async {
    if (isInitialized.value) return this;

    await _loadLocalCache();
    await requestPermission();
    await _bindMessagingListeners();

    _authSub = _auth.authStateChanges().listen((user) async {
      await _cancelNotificationStreams();

      if (user == null) {
        notifications.clear();
        unreadCount.value = 0;
        fcmToken.value = null;
        _resetNotificationBuffers();
        return;
      }

      await retrieveAndPersistToken();
      _listenAdminNotifications();
      _listenLegacyNotifications(user.uid);
    });

    final current = _auth.currentUser;
    if (current != null) {
      await retrieveAndPersistToken();
      _listenAdminNotifications();
      _listenLegacyNotifications(current.uid);
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

  Future<void> _cancelNotificationStreams() async {
    await _adminNotificationsSub?.cancel();
    await _legacyNotificationsSub?.cancel();
    _adminNotificationsSub = null;
    _legacyNotificationsSub = null;
    _resetNotificationBuffers();
  }

  void _resetNotificationBuffers() {
    _adminNotificationItems = [];
    _legacyNotificationItems = [];
    _adminNotificationsReady = false;
    _legacyNotificationsReady = false;
    _adminNotificationsPrimed = false;
    _legacyNotificationsPrimed = false;
  }

  void _listenAdminNotifications() {
    _adminNotificationsSub = _firestore
        .collection(adminNotificationsCollection)
        .orderBy('createdAt', descending: true)
        .limit(_notificationLimit)
        .snapshots()
        .listen(
      (snapshot) {
        _adminNotificationItems = snapshot.docs
            .where((doc) => doc.data()['isBroadcastLog'] != true)
            .map(
              (doc) => AppNotification.fromFirestore(
                doc,
                collection: adminNotificationsCollection,
              ),
            )
            .toList(growable: false);

        if (_adminNotificationsPrimed) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;

            final data = change.doc.data();
            if (data == null || data['isBroadcastLog'] == true) continue;

            final notification = AppNotification.fromFirestore(
              change.doc,
              collection: adminNotificationsCollection,
            );
            if (!notification.isRead) {
              _showInAppAlert(notification);
            }
          }
        } else {
          _adminNotificationsPrimed = true;
        }

        _adminNotificationsReady = true;
        _publishMergedNotifications();
      },
      onError: (Object e) {
        debugPrint(
          'NotificationService: admin_notifications stream error: $e',
        );
      },
    );
  }

  void _listenLegacyNotifications(String adminId) {
    _legacyNotificationsSub = _firestore
        .collection(legacyNotificationsCollection)
        .where('adminId', isEqualTo: adminId)
        .orderBy('createdAt', descending: true)
        .limit(_notificationLimit)
        .snapshots()
        .listen(
      (snapshot) {
        _legacyNotificationItems = snapshot.docs
            .where((doc) => doc.data()['isBroadcastLog'] != true)
            .map(
              (doc) => AppNotification.fromFirestore(
                doc,
                collection: legacyNotificationsCollection,
              ),
            )
            .toList(growable: false);

        if (_legacyNotificationsPrimed) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;

            final data = change.doc.data();
            if (data == null || data['isBroadcastLog'] == true) continue;
            if (data['sentBy'] == adminId) continue;

            final notification = AppNotification.fromFirestore(
              change.doc,
              collection: legacyNotificationsCollection,
            );
            if (!notification.isRead) {
              _showInAppAlert(notification);
            }
          }
        } else {
          _legacyNotificationsPrimed = true;
        }

        _legacyNotificationsReady = true;
        _publishMergedNotifications();
      },
      onError: (Object e) {
        debugPrint('NotificationService: notifications stream error: $e');
      },
    );
  }

  void _publishMergedNotifications() {
    if (!_adminNotificationsReady || !_legacyNotificationsReady) return;

    final merged = [..._adminNotificationItems, ..._legacyNotificationItems]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    notifications.assignAll(merged.take(_notificationLimit).toList());
    unreadCount.value = notifications.where((n) => !n.isRead).length;
    unawaited(_persistLocalCache());
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
          .collection(legacyNotificationsCollection)
          .where('adminId', isEqualTo: uid)
          .where('messageId', isEqualTo: messageId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return AppNotification.fromFirestore(
          existing.docs.first,
          collection: legacyNotificationsCollection,
        );
      }
    }

    final doc = _firestore.collection(legacyNotificationsCollection).doc();
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
      firestoreCollection: legacyNotificationsCollection,
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
                unawaited(
                  markAsRead(
                    notification.id,
                    collection: notification.firestoreCollection,
                  ),
                );
              }
            },
          ),
        ),
      );
  }

  Future<void> markAsRead(String id, {String? collection}) async {
    final targetCollection =
        collection ?? _collectionForNotificationId(id) ?? kAdminNotificationsCollection;

    try {
      await _firestore.collection(targetCollection).doc(id).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('NotificationService: markAsRead failed: $e');
    }
  }

  String? _collectionForNotificationId(String id) {
    for (final notification in notifications) {
      if (notification.id == id) {
        return notification.firestoreCollection;
      }
    }
    return null;
  }

  Future<void> markAllAsRead() async {
    final unreadAdmin = await _firestore
        .collection(adminNotificationsCollection)
        .where('isRead', isEqualTo: false)
        .get();

    final uid = _auth.currentUser?.uid;
    QuerySnapshot<Map<String, dynamic>>? unreadLegacy;
    if (uid != null) {
      unreadLegacy = await _firestore
          .collection(legacyNotificationsCollection)
          .where('adminId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();
    }

    if (unreadAdmin.docs.isEmpty &&
        (unreadLegacy == null || unreadLegacy.docs.isEmpty)) {
      return;
    }

    final batch = _firestore.batch();
    for (final doc in unreadAdmin.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    for (final doc in unreadLegacy?.docs ?? const []) {
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
    _adminNotificationsSub?.cancel();
    _legacyNotificationsSub?.cancel();
    _tokenRefreshSub?.cancel();
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    super.onClose();
  }
}
