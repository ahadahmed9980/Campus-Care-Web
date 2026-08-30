import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Writes in-app notifications to a student's Firestore subcollection.
class StudentNotificationService {
  StudentNotificationService._();

  static final StudentNotificationService instance =
      StudentNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Notifies the student that their request was resolved.
  Future<void> notifyRequestResolved({
    required String userId,
    required String requestId,
    required String requestTitle,
    String? resolutionMessage,
  }) async {
    if (userId.isEmpty) {
      debugPrint(
        'StudentNotificationService: skipped notification — empty userId',
      );
      return;
    }

    final trimmedTitle = requestTitle.trim();
    final displayTitle =
        trimmedTitle.isNotEmpty ? trimmedTitle : requestId;

    final message = resolutionMessage?.trim().isNotEmpty == true
        ? 'Your request "$displayTitle" has been resolved. ${resolutionMessage!.trim()}'
        : 'Your request "$displayTitle" has been resolved.';

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add({
      'title': 'Request Resolved',
      'message': message,
      'requestId': requestId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': null,
      'type': 'request_resolved',
    });

    debugPrint(
      'StudentNotificationService: request resolved notification sent to '
      'users/$userId/notifications for $requestId',
    );
  }
}
