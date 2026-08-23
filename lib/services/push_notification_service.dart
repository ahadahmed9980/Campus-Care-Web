import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum PushTarget { users, admins, all }

class SendNotificationResult {
  const SendNotificationResult({
    required this.broadcastId,
    required this.recipientCount,
  });

  final String broadcastId;
  final int recipientCount;
}

class _Recipient {
  const _Recipient({required this.id, required this.type});

  final String id;
  final String type; // 'admin' | 'user'
}

/// Writes notification documents directly to Firestore (Spark-plan friendly).
/// Recipients see updates in real time via the in-app notification center.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static String targetLabel(PushTarget target) {
    switch (target) {
      case PushTarget.users:
        return 'All Users';
      case PushTarget.admins:
        return 'All Admins';
      case PushTarget.all:
        return 'Everyone';
    }
  }

  static String targetValue(PushTarget target) {
    switch (target) {
      case PushTarget.users:
        return 'users';
      case PushTarget.admins:
        return 'admins';
      case PushTarget.all:
        return 'all';
    }
  }

  Future<List<_Recipient>> _collectRecipients(PushTarget target) async {
    final recipients = <_Recipient>[];
    final seen = <String>{};

    Future<void> addFromCollection(String collection, String type) async {
      final snapshot = await _firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        if (seen.add(doc.id)) {
          recipients.add(_Recipient(id: doc.id, type: type));
        }
      }
    }

    if (target == PushTarget.users || target == PushTarget.all) {
      await addFromCollection('users', 'user');
    }
    if (target == PushTarget.admins || target == PushTarget.all) {
      await addFromCollection('admins', 'admin');
    }

    return recipients;
  }

  /// Creates one notification document per recipient plus a broadcast log entry.
  Future<SendNotificationResult> sendBroadcast({
    required String title,
    required String body,
    required PushTarget target,
  }) async {
    final senderUid = _auth.currentUser?.uid;
    if (senderUid == null) {
      throw Exception('You must be signed in to send notifications.');
    }

    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();
    if (trimmedTitle.isEmpty || trimmedBody.isEmpty) {
      throw Exception('Title and message are required.');
    }

    final recipients = await _collectRecipients(target);
    if (recipients.isEmpty) {
      throw Exception(
        'No recipients found for the selected audience. '
        'Ensure users/admins exist in Firestore.',
      );
    }

    final broadcastId = _firestore.collection('notifications').doc().id;
    const batchLimit = 500;

    for (var i = 0; i < recipients.length; i += batchLimit) {
      final chunk = recipients.skip(i).take(batchLimit).toList();
      final batch = _firestore.batch();

      for (final recipient in chunk) {
        final ref = _firestore.collection('notifications').doc();
        batch.set(ref, {
          if (recipient.type == 'admin') 'adminId': recipient.id,
          if (recipient.type == 'user') 'userId': recipient.id,
          'title': trimmedTitle,
          'body': trimmedBody,
          'isRead': false,
          'createdAt': FieldValue.serverTimestamp(),
          'source': 'admin_broadcast',
          'sentBy': senderUid,
          'broadcastId': broadcastId,
          'target': targetValue(target),
        });
      }

      await batch.commit();
    }

    await _firestore.collection('notifications').doc().set({
      'adminId': senderUid,
      'sentBy': senderUid,
      'isBroadcastLog': true,
      'title': trimmedTitle,
      'body': trimmedBody,
      'target': targetValue(target),
      'recipientCount': recipients.length,
      'broadcastId': broadcastId,
      'isRead': true,
      'createdAt': FieldValue.serverTimestamp(),
      'source': 'admin_broadcast',
    });

    debugPrint(
      'PushNotificationService: broadcast $broadcastId sent to '
      '${recipients.length} recipient(s)',
    );

    return SendNotificationResult(
      broadcastId: broadcastId,
      recipientCount: recipients.length,
    );
  }
}
