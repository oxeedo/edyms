class DashboardData {
  final DashboardStats stats;
  final List<DashboardActivity> activity;
  final List<ContinueLearningCourse> continueLearning;

  DashboardData({
    required this.stats,
    required this.activity,
    required this.continueLearning,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      stats: DashboardStats.fromJson(json['stats']),
      activity: (json['activity'] as List)
          .map((e) => DashboardActivity.fromJson(e))
          .toList(),
      continueLearning: (json['continue_learning'] as List)
          .map((e) => ContinueLearningCourse.fromJson(e))
          .toList(),
    );
  }
}

class DashboardStats {
  final int totalCourses;
  final int completedCourses;
  final int inProgressCourses;
  final String totalSpent;

  DashboardStats({
    required this.totalCourses,
    required this.completedCourses,
    required this.inProgressCourses,
    required this.totalSpent,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCourses: _parseInt(json['total_courses']),
      completedCourses: _parseInt(json['completed_courses']),
      inProgressCourses: _parseInt(json['in_progress_courses']),
      totalSpent: json['total_spent']?.toString() ?? '0',
    );
  }
}

class DashboardActivity {
  final String label;
  final int lessons;

  DashboardActivity({required this.label, required this.lessons});

  factory DashboardActivity.fromJson(Map<String, dynamic> json) {
    return DashboardActivity(
      label: json['month']?.toString() ?? '',
      lessons: _parseInt(json['hours']),
    );
  }
}

class ContinueLearningCourse {
  final int courseId;
  final String title;
  final double progress;
  final String? image;
  final String nextLesson;

  ContinueLearningCourse({
    required this.courseId,
    required this.title,
    required this.progress,
    this.image,
    required this.nextLesson,
  });

  factory ContinueLearningCourse.fromJson(Map<String, dynamic> json) {
    return ContinueLearningCourse(
      courseId: _parseInt(json['course_id']),
      title: json['title']?.toString() ?? '',
      progress: _parseDouble(json['progress']),
      image: json['image'],
      nextLesson: json['next_lesson']?.toString() ?? '',
    );
  }
}

/// Safely parse a value to int (handles both int and String from API)
int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

/// Safely parse a value to double (handles both num and String from API)
double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
