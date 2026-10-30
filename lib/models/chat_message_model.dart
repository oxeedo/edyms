class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String? body;
  final String createdAt;
  final bool isRead;
  final ChatSender? sender;
  final List<ChatAttachment> attachments;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.body,
    required this.createdAt,
    this.isRead = false,
    this.sender,
    this.attachments = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      body: json['body'],
      createdAt: json['created_at'] ?? '',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      sender:
          json['sender'] != null ? ChatSender.fromJson(json['sender']) : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => ChatAttachment.fromJson(a))
              .toList()
          : [],
    );
  }
}

class ChatSender {
  final int id;
  final String name;
  final String? profilePhoto;

  ChatSender({required this.id, required this.name, this.profilePhoto});

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePhoto: json['profile_photo'],
    );
  }
}

class ChatAttachment {
  final int id;
  final String fileName;
  final String filePath;
  final String? fileType;
  final int? fileSize;

  ChatAttachment({
    required this.id,
    required this.fileName,
    required this.filePath,
    this.fileType,
    this.fileSize,
  });

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'] ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
      fileType: json['file_type'],
      fileSize: json['file_size'],
    );
  }

  bool get isImage {
    return fileType != null && fileType!.startsWith('image/');
  }
}
