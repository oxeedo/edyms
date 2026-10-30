import 'course.dart';

class Instructor {
  final int id;
  final String name;
  final String? image;
  final String? bio;
  final String? professionalTitle;
  final int? coursesCount;
  final double? averageRating;
  final int? studentsCount;
  final int? reviewsCount;
  final List<Course>? courses;
  final List<dynamic>? latestReviews;
  final Map<String, String?>? socialLinks;

  Instructor({
    required this.id,
    required this.name,
    this.image,
    this.bio,
    this.professionalTitle,
    this.coursesCount,
    this.averageRating,
    this.studentsCount,
    this.reviewsCount,
    this.courses,
    this.latestReviews,
    this.socialLinks,
  });

  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? json['profile_photo'],
      bio: json['bio'],
      professionalTitle: json['professional_title'] ?? json['specialization'],
      coursesCount: (json['courses_count'] as num?)?.toInt(),
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      studentsCount: (json['students_count'] as num?)?.toInt(),
      reviewsCount: (json['reviews_count'] as num?)?.toInt(),
      courses: json['courses'] != null
          ? (json['courses'] as List).map((i) => Course.fromJson(i)).toList()
          : null,
      latestReviews: json['latest_reviews'],
      socialLinks: json['social_links'] != null
          ? Map<String, String?>.from(json['social_links'])
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'bio': bio,
      'professional_title': professionalTitle,
      'courses_count': coursesCount,
      'average_rating': averageRating,
    };
  }
}
