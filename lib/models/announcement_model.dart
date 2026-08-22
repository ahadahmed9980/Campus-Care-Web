import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String? id;
  final String title;
  final String description;
  final String category;
  final String? imageUrl;
  final String priority;
  final DateTime? expiresAt;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AnnouncementModel({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    this.imageUrl,
    required this.priority,
    this.expiresAt,
    required this.isPublished,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'priority': priority,
      'expiresAt':
          expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isPublished': isPublished,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory AnnouncementModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return AnnouncementModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      priority: map['priority'] ?? '',
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as Timestamp).toDate()
          : null,
      isPublished: map['isPublished'] ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }
}