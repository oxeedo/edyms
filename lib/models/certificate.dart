class Certificate {
  final int id;
  final int courseId;
  final String title;
  final String issuedDate;
  final DateTime issuedAt;
  final String certificateId;
  final String? courseImage;
  final String instructorName;
  final String downloadUrl;

  Certificate({
    required this.id,
    required this.courseId,
    required this.title,
    required this.issuedDate,
    required this.issuedAt,
    required this.certificateId,
    this.courseImage,
    required this.instructorName,
    required this.downloadUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as int,
      courseId: json['course_id'] as int,
      title: json['title'] as String,
      issuedDate: json['issued_date'] as String,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      certificateId: json['certificate_id'] as String,
      courseImage: json['course_image'] as String?,
      instructorName: json['instructor_name'] as String,
      downloadUrl: json['download_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'course_id': courseId,
      'title': title,
      'issued_date': issuedDate,
      'issued_at': issuedAt.toIso8601String(),
      'certificate_id': certificateId,
      'course_image': courseImage,
      'instructor_name': instructorName,
      'download_url': downloadUrl,
    };
  }
}
