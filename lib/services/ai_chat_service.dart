import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';

class AiChatService extends BaseService {
  Future<http.Response> getChatHistory() async {
    final token = await getToken();
    final url = Uri.parse('${BaseService.baseUrl}/ai-chat');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<http.Response> sendMessage(String message) async {
    final token = await getToken();
    final url = Uri.parse('${BaseService.baseUrl}/ai-chat/send');
    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'message': message}),
    );
  }
}
