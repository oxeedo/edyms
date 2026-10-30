import '../config/config.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? profilePhoto;
  final bool isApproved;
  final String? phone;
  final String? bio;

  String? get profilePhotoUrl =>
      profilePhoto != null ? AppConfig.getImageUrl(profilePhoto) : null;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePhoto,
    required this.isApproved,
    this.phone,
    this.bio,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profilePhoto: json['profile_photo'],
      isApproved: json['is_approved'] == 1 || json['is_approved'] == true,
      phone: json['phone'],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_photo': profilePhoto,
      'is_approved': isApproved,
      'phone': phone,
      'bio': bio,
    };
  }
}
