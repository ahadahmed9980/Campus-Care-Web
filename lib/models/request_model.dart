
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String categoryId;
  final String location;
  final String priority;
  final String imageUrl;
  final String status;
  final String assignedDepartmentId;
  final String resolutionInfo;
  final String resolvedBy;
  final Timestamp? resolvedAt;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  RequestModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.location,
    required this.priority,
    required this.imageUrl,
    required this.status,
    required this.assignedDepartmentId,
    required this.resolutionInfo,
    required this.resolvedBy,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
  });

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value;
    }
    if (value is int) {
      return Timestamp.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return Timestamp.fromDate(parsed);
      }
    }
    return null;
  }

  factory RequestModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return RequestModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      location: map['location']?.toString() ?? '',
      priority: map['priority']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      assignedDepartmentId: map['assignedDepartmentId']?.toString() ?? '',
      resolutionInfo: map['resolutionInfo']?.toString() ?? '',
      resolvedBy: map['resolvedBy']?.toString() ?? '',
      resolvedAt: _parseTimestamp(map['resolvedAt']),
      createdAt: _parseTimestamp(map['createdAt']),
      updatedAt: _parseTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'location': location,
      'priority': priority,
      'imageUrl': imageUrl,
      'status': status,
      'assignedDepartmentId': assignedDepartmentId,
      'resolutionInfo': resolutionInfo,
      'resolvedBy': resolvedBy,
      'resolvedAt': resolvedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}