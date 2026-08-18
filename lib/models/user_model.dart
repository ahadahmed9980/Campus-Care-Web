class UserModel {
  final String? id;
  final String? name;
  final String? studentId;
  final String? email;
  final String? department;
  final int? semester;
  final String? status;

  UserModel({
    this.id,
    this.name,
    this.studentId,
    this.email,
    this.department,
    this.semester,
    this.status,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    return UserModel(
      id: docId ?? map['id'] as String?,
      name: map['fullName'] as String?,
      studentId: map['studentId'] as String?,
      email: map['email'] as String?,
      department: map['department'] as String?,
      semester: map['semester'] is int
          ? map['semester'] as int
          : int.tryParse(map['semester']?.toString() ?? ''),
      status: map['status'] as String? ?? 'Active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': name,
      'studentId': studentId,
      'email': email,
      'department': department,
      'semester': semester,
      'status': status,
    };
  }
}