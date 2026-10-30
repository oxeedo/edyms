import 'course.dart';

class CourseDetailResponse {
  final bool success;
  final CourseDetailData data;

  CourseDetailResponse({required this.success, required this.data});

  factory CourseDetailResponse.fromJson(Map<String, dynamic> json) {
    return CourseDetailResponse(
      success: json['success'] ?? false,
      data: CourseDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class CourseDetailData {
  final Course course;
  final int lessonCount;
  final int totalDuration;
  final String? courseStartDate;
  final bool isEnrolled;
  final bool canReview;
  final dynamic userReview;
  final int totalReviews;
  final double averageRating;
  final Map<int, int> ratingDistribution;
  final List<Course> relatedCourses;

  CourseDetailData({
    required this.course,
    required this.lessonCount,
    required this.totalDuration,
    this.courseStartDate,
    required this.isEnrolled,
    required this.canReview,
    this.userReview,
    required this.totalReviews,
    required this.averageRating,
    required this.ratingDistribution,
    required this.relatedCourses,
  });

  factory CourseDetailData.fromJson(Map<String, dynamic> json) {
    return CourseDetailData(
      course: Course.fromJson(json['course'] ?? {}),
      lessonCount: (json['lesson_count'] as num?)?.toInt() ?? 0,
      totalDuration: (json['total_duration'] as num?)?.toInt() ?? 0,
      courseStartDate: json['course_start_date'],
      isEnrolled: json['is_enrolled'] ?? false,
      canReview: json['can_review'] ?? false,
      userReview: json['user_review'],
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingDistribution:
          (json['rating_distribution'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(int.parse(key), (value as num).toInt()),
          ) ??
          {},
      relatedCourses:
          (json['related_courses'] as List?)
              ?.map((c) => Course.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class Topic {
  final int id;
  final String title;
  final List<Lesson> lessons;
  final List<Quiz> quizzes;
  final List<Assignment> assignments;

  Topic({
    required this.id,
    required this.title,
    required this.lessons,
    required this.quizzes,
    required this.assignments,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      lessons:
          (json['lessons'] as List?)?.map((l) => Lesson.fromJson(l)).toList() ??
          [],
      quizzes:
          (json['quizzes'] as List?)?.map((q) => Quiz.fromJson(q)).toList() ??
          [],
      assignments:
          (json['assignments'] as List?)
              ?.map((a) => Assignment.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'quizzes': quizzes.map((q) => q.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
    };
  }
}

class Lesson {
  final int id;
  final String title;
  final int? duration;
  final bool isPreview;
  final String? videoType;
  final String? videoUrl;
  final String? videoPath;

  Lesson({
    required this.id,
    required this.title,
    this.duration,
    required this.isPreview,
    this.videoType,
    this.videoUrl,
    this.videoPath,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      duration: (json['duration'] as num?)?.toInt(),
      isPreview: json['is_preview'] == 1 || json['is_preview'] == true,
      videoType: json['video_type'],
      videoUrl: json['video_url'],
      videoPath: json['video_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'duration': duration,
      'is_preview': isPreview,
      'video_type': videoType,
      'video_url': videoUrl,
      'video_path': videoPath,
    };
  }
}

class Quiz {
  final int id;
  final String title;
  final int? timeLimit;

  Quiz({required this.id, required this.title, this.timeLimit});

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      timeLimit: (json['time_limit'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'time_limit': timeLimit};
  }
}

class Assignment {
  final int id;
  final String title;
  final int filesCount;

  Assignment({required this.id, required this.title, required this.filesCount});

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] ?? '',
      filesCount: (json['files_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'files_count': filesCount};
  }
}

class CourseReview {
  final int id;
  final int rating;
  final String? comment;
  final String createdAt;
  final ReviewUser user;
  final List<ReviewReply> replies;

  CourseReview({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.user,
    required this.replies,
  });

  factory CourseReview.fromJson(Map<String, dynamic> json) {
    return CourseReview(
      id: (json['id'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'],
      createdAt: json['created_at'] ?? '',
      user: ReviewUser.fromJson(json['user'] ?? {}),
      replies:
          (json['replies'] as List?)
              ?.map((r) => ReviewReply.fromJson(r))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt,
      'user': user.toJson(),
      'replies': replies.map((r) => r.toJson()).toList(),
    };
  }
}

class ReviewUser {
  final int id;
  final String name;
  final String? profilePhoto;

  ReviewUser({required this.id, required this.name, this.profilePhoto});

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'profile_photo': profilePhoto};
  }
}

class ReviewReply {
  final int id;
  final String reply;
  final bool isInstructor;
  final String createdAt;

  ReviewReply({
    required this.id,
    required this.reply,
    required this.isInstructor,
    required this.createdAt,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reply: json['reply'] ?? '',
      isInstructor: json['is_instructor'] == 1 || json['is_instructor'] == true,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reply': reply,
      'is_instructor': isInstructor,
      'created_at': createdAt,
    };
  }
}
