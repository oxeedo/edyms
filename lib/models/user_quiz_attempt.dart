class UserQuizAttempt {
  final int id;
  final String title;
  final String courseTitle;
  final int score;
  final int maxScore;
  final bool passed;
  final String date;
  final int attempts;

  UserQuizAttempt({
    required this.id,
    required this.title,
    required this.courseTitle,
    required this.score,
    required this.maxScore,
    required this.passed,
    required this.date,
    required this.attempts,
  });

  factory UserQuizAttempt.fromJson(Map<String, dynamic> json) {
    return UserQuizAttempt(
      id: _parseInt(json['id']),
      title: json['title']?.toString() ?? '',
      courseTitle: json['course_title']?.toString() ?? '',
      score: _parseInt(json['score']),
      maxScore: _parseInt(json['max_score']),
      passed: _parseBool(json['passed']),
      date: json['date']?.toString() ?? '',
      attempts: _parseInt(json['attempts']),
    );
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true' || value == '1';
  return false;
}
