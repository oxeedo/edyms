import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../models/conversation.dart';
import '../models/chat_message_model.dart';

class ChatService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Get inbox conversations (accepted)
  Future<List<Conversation>> getConversations({int page = 1}) async {
    final url = '${AppConfig.apiBaseUrl}/messages?page=$page';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  /// Get sent requests (pending)
  Future<List<Conversation>> getRequests({int page = 1}) async {
    final url = '${AppConfig.apiBaseUrl}/messages/requests?page=$page';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data'] as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load requests');
    }
  }

  /// Get unread message count
  Future<int> getUnreadCount() async {
    final url = '${AppConfig.apiBaseUrl}/messages/unread-count';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['count'] ?? 0;
    }
    return 0;
  }

  /// Search instructors
  Future<List<ChatUser>> searchInstructors(String query) async {
    final url =
        '${AppConfig.apiBaseUrl}/messages/instructors/search?q=$query';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data as List).map((json) => ChatUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search instructors');
    }
  }

  /// Start or get a conversation
  Future<Conversation> startConversation(int instructorId, {String? message}) async {
    final url = '${AppConfig.apiBaseUrl}/messages/start';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({
        'instructor_id': instructorId,
        // ignore: use_null_aware_elements
        if (message != null) 'message': message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Conversation.fromJson(data['conversation']);
    } else {
      throw Exception('Failed to start conversation');
    }
  }

  /// Get messages for a conversation
  Future<Map<String, dynamic>> getMessages(int conversationId) async {
    final url = '${AppConfig.apiBaseUrl}/messages/$conversationId';
    final response = await http.get(Uri.parse(url), headers: await _getHeaders());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final messages = (data['messages'] as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
      final conversation = Conversation.fromJson(data['conversation']);
      return {
        'conversation': conversation,
        'messages': messages,
      };
    } else {
      throw Exception('Failed to load messages');
    }
  }

  /// Send a text message
  Future<ChatMessage> sendTextMessage(int conversationId, String message) async {
    final url = '${AppConfig.apiBaseUrl}/messages/$conversationId/send';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({'message': message}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ChatMessage.fromJson(data['message']);
    } else {
      throw Exception('Failed to send message');
    }
  }

  /// Send a message with file attachments
  Future<ChatMessage> sendMessageWithFiles(
    int conversationId, {
    String? message,
    required List<String> filePaths,
  }) async {
    final url = '${AppConfig.apiBaseUrl}/messages/$conversationId/send';
    final token = await _getToken();

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Accept'] = 'application/json';
    if (token != null) request.headers['Authorization'] = 'Bearer $token';

    if (message != null && message.isNotEmpty) {
      request.fields['message'] = message;
    }

    for (final path in filePaths) {
      final fileName = path.split('/').last;
      final ext = fileName.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream';
      if (['jpg', 'jpeg'].contains(ext)) mimeType = 'image/jpeg';
      if (ext == 'png') mimeType = 'image/png';
      if (ext == 'gif') mimeType = 'image/gif';
      if (ext == 'webp') mimeType = 'image/webp';
      if (ext == 'pdf') mimeType = 'application/pdf';

      final parts = mimeType.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'files[]',
        path,
        contentType: MediaType(parts[0], parts[1]),
      ));
    }

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return ChatMessage.fromJson(data['message']);
    } else {
      throw Exception('Failed to send message');
    }
  }

  /// Poll for new messages
  Future<List<ChatMessage>> pollMessages(int conversationId, int lastId) async {
    final url =
        '${AppConfig.apiBaseUrl}/messages/$conversationId/poll?last_id=$lastId';
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    ).timeout(const Duration(seconds: 35));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['messages'] as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to poll messages');
    }
  }
}
