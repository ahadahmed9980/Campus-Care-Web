class CampusInformationModel {
  String? id;
  String? title;
  String? description;
  String? category;

  String? phone;
  String? email;
  String? website;

  String? building;
  String? floor;
  String? room;

  Map<String, dynamic>? timings;

  bool isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  CampusInformationModel({
    this.id,
    this.title,
    this.description,
    this.category,
    this.phone,
    this.email,
    this.website,
    this.building,
    this.floor,
    this.room,
    this.timings,
    this.isActive = false, // Default false set kar diya
    this.createdAt,
    this.updatedAt,
  });

  factory CampusInformationModel.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) {
    return CampusInformationModel(
      id: docId,
      title: map['title'],
      description: map['description'],
      category: map['category'],

      phone: map['contact']?['phone'],
      email: map['contact']?['email'],
      website: map['contact']?['website'],

      building: map['location']?['building'],
      floor: map['location']?['floor'],
      room: map['location']?['room'],

      timings: map['timings'] != null
          ? Map<String, dynamic>.from(map['timings'])
          : null,

      isActive: map['isActive'] ?? false, // Null hone par false lega

      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,

      'contact': {
        'phone': phone,
        'email': email,
        'website': website,
      },

      'location': {
        'building': building,
        'floor': floor,
        'room': room,
      },

      'timings': timings,

      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}