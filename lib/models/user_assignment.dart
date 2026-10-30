class UserAssignment {
  final int id;
  final String title;
  final String courseTitle;
  final String dueDate;
  final String status;
  final int? grade;

  UserAssignment({
    required this.id,
    required this.title,
    required this.courseTitle,
    required this.dueDate,
    required this.status,
    this.grade,
  });

  factory UserAssignment.fromJson(Map<String, dynamic> json) {
    return UserAssignment(
      id: json['id'],
      title: json['title'],
      courseTitle: json['course_title'],
      dueDate: json['due_date'],
      status: json['status'],
      grade: json['grade'],
    );
  }
}
