import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentModel {
  final String? id;
  final String? name;
  final String? code;
  final String? description;
  final String? phone;
  final String? email;
  final String? website;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DepartmentModel({
    this.id,
    this.name,
    this.code,
    this.description,
    this.phone,
    this.email,
    this.website,
    this.isActive = false,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    return DepartmentModel(
      id: docId ?? map['id']?.toString(),
      name: map['name']?.toString(),
      code: map['code']?.toString(),
      description: map['description']?.toString(),
      phone: map['phone']?.toString(),
      email: map['email']?.toString(),
      website: map['website']?.toString(),
      isActive: map['isActive'] is bool ? map['isActive'] : false,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (website != null) 'website': website,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }

  DepartmentModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? phone,
    String? email,
    String? website,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}