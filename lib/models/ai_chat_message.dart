class AiChatMessage {
  final int id;
  final int userId;
  final String message;
  final bool isAi;
  final DateTime createdAt;

  AiChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isAi,
    required this.createdAt,
  });

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.parse(json['user_id'].toString()),
      message: json['message'] ?? '',
      isAi: json['is_ai'] == 1 || json['is_ai'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'is_ai': isAi ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
