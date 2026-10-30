import 'course_detail.dart';
import 'instructor.dart';

class Course {
  final int id;
  final String title;
  final String? slug;
  final String? thumbnail;
  final double? price;
  final double? discountedPrice;
  final double? rating;
  final int reviewsCount;
  final int lessonsCount;
  final String? instructorName;
  final String? categoryName;
  final String? description;
  final String? objectives;
  final String? requirements;
  final String? status;
  final String? difficulty;
  final String? language;
  final int? maxStudents;
  final List<dynamic>? topics;
  final Instructor? instructor;
  final List<CourseReview>? reviews;
  final int? studentsCount;
  final String? introVideo;
  final String? introVideoUrl;

  Course({
    required this.id,
    required this.title,
    this.slug,
    this.thumbnail,
    this.price,
    this.discountedPrice,
    this.rating,
    this.reviewsCount = 0,
    this.lessonsCount = 0,
    this.instructorName,
    this.categoryName,
    this.description,
    this.objectives,
    this.requirements,
    this.status,
    this.difficulty,
    this.language,
    this.maxStudents,
    this.topics,
    this.instructor,
    this.reviews,
    this.studentsCount,
    this.introVideo,
    this.introVideoUrl,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
      price: _parseDouble(json['price'] ?? json['price_avg']),
      discountedPrice: _parseDouble(json['discounted_price']),
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(
        json['reviews_count'] ?? json['enrollments_count'],
      ),
      lessonsCount: _parseInt(json['lessons_count']),
      instructorName: json['instructor']?['name']?.toString(),
      categoryName: json['category_relation']?['name']?.toString(),
      description: json['description']?.toString(),
      objectives: json['objectives']?.toString(),
      requirements: json['requirements']?.toString(),
      status: json['status']?.toString(),
      difficulty: json['difficulty']?.toString(),
      language: json['language']?.toString(),
      maxStudents: json['max_students'] != null
          ? _parseInt(json['max_students'])
          : null,
      topics: json['topics'],
      instructor: json['instructor'] != null
          ? Instructor.fromJson(json['instructor'])
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
                .map((r) => CourseReview.fromJson(r))
                .toList()
          : null,
      studentsCount: json['students_count'] != null
          ? _parseInt(json['students_count'])
          : null,
      introVideo: json['intro_video']?.toString(),
      introVideoUrl: json['intro_video_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'thumbnail': thumbnail,
      'price': price,
      'discounted_price': discountedPrice,
      'rating': rating,
      'reviews_count': reviewsCount,
      'lessons_count': lessonsCount,
      'instructor': instructor?.toJson(),
      'category_relation': categoryName != null ? {'name': categoryName} : null,
      'description': description,
      'objectives': objectives,
      'requirements': requirements,
      'status': status,
      'difficulty': difficulty,
      'language': language,
      'max_students': maxStudents,
      'topics': topics,
      'reviews': reviews?.map((r) => r.toJson()).toList(),
      'students_count': studentsCount,
      'intro_video': introVideo,
      'intro_video_url': introVideoUrl,
    };
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
