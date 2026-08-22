import 'package:cloud_firestore/cloud_firestore.dart';

class RequestCategoryModel {
  final String? id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RequestCategoryModel({
    this.id,
    required this.name,
    required this.description,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RequestCategoryModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    return RequestCategoryModel(
      id: docId ?? map['id']?.toString(),
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      isActive: map['isActive'] is bool
          ? map['isActive'] as bool
          : map['isActive']?.toString().toLowerCase() == 'true',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
