import 'package:cloud_firestore/cloud_firestore.dart';

class RequestStatusHistoryModel {
  final String id;
  final String status;
  final String message;
  final String changedBy;
  final String changedByRole;
  final Timestamp? createdAt;

  RequestStatusHistoryModel({
    required this.id,
    required this.status,
    required this.message,
    required this.changedBy,
    required this.changedByRole,
    this.createdAt,
  });

  factory RequestStatusHistoryModel.fromMap(Map<String, dynamic> map, String id) {
    Timestamp? parseTimestamp(dynamic value) {
      if (value is Timestamp) return value;
      if (value is int) return Timestamp.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return Timestamp.fromDate(parsed);
      }
      return null;
    }

    return RequestStatusHistoryModel(
      id: id,
      status: map['status']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      changedBy: map['changedBy']?.toString() ?? '',
      changedByRole: map['changedByRole']?.toString() ?? '',
      createdAt: parseTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'message': message,
      'changedBy': changedBy,
      'changedByRole': changedByRole,
      'createdAt': createdAt,
    };
  }
}
