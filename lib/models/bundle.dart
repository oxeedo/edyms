import 'course.dart';

class Bundle {
  final int id;
  final String title;
  final String? slug;
  final String? description;
  final String? image;
  final double? price;
  final String? status;
  final String? approvalStatus;
  final List<Course>? courses;

  Bundle({
    required this.id,
    required this.title,
    this.slug,
    this.description,
    this.image,
    this.price,
    this.status,
    this.approvalStatus,
    this.courses,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) {
    return Bundle(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      price: _parseDouble(json['price']),
      status: json['status']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      courses: json['courses'] != null
          ? (json['courses'] as List).map((c) => Course.fromJson(c)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'image': image,
      'price': price,
      'status': status,
      'approval_status': approvalStatus,
      'courses': courses?.map((c) => c.toJson()).toList(),
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
