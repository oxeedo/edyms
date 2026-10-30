class Conversation {
  final int id;
  final int studentId;
  final int instructorId;
  final bool isAccepted;
  final String? lastMessageAt;
  final int unreadCount;
  final ChatUser? instructor;
  final LatestMessage? latestMessage;

  Conversation({
    required this.id,
    required this.studentId,
    required this.instructorId,
    required this.isAccepted,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.instructor,
    this.latestMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      instructorId: json['instructor_id'] ?? 0,
      isAccepted: json['is_accepted'] == true || json['is_accepted'] == 1,
      lastMessageAt: json['last_message_at'],
      unreadCount: json['unread_count'] ?? 0,
      instructor: json['instructor'] != null
          ? ChatUser.fromJson(json['instructor'])
          : null,
      latestMessage: json['latest_message'] != null
          ? LatestMessage.fromJson(json['latest_message'])
          : null,
    );
  }
}

class ChatUser {
  final int id;
  final String name;
  final String? profilePhoto;
  final String? specialization;

  ChatUser({
    required this.id,
    required this.name,
    this.profilePhoto,
    this.specialization,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo'],
      specialization: json['specialization'],
    );
  }
}

class LatestMessage {
  final int id;
  final String? body;
  final int senderId;
  final String createdAt;

  LatestMessage({
    required this.id,
    this.body,
    required this.senderId,
    required this.createdAt,
  });

  factory LatestMessage.fromJson(Map<String, dynamic> json) {
    return LatestMessage(
      id: json['id'] ?? 0,
      body: json['body'],
      senderId: json['sender_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
