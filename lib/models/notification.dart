class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? image;
  final String? url;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.image,
    this.url,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return NotificationModel(
      id: json['id'],
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'text',
      image: data['image'],
      url: data['url'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isRead => readAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': {
        'title': title,
        'message': message,
        'type': type,
        'image': image,
        'url': url,
      },
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class NotificationResponse {
  final List<NotificationModel> notifications;
  final int currentPage;
  final int lastPage;
  final int total;

  NotificationResponse({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final list = data['data'] as List<dynamic>;

    return NotificationResponse(
      notifications: list.map((e) => NotificationModel.fromJson(e)).toList(),
      currentPage: data['current_page'] ?? 1,
      lastPage: data['last_page'] ?? 1,
      total: data['total'] ?? 0,
    );
  }
}
