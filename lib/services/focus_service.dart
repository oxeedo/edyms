import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'auth_service.dart';

class FocusService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> saveSession({
    required int duration,
    required String type,
    required String status,
    required DateTime startTime,
    DateTime? endTime,
  }) async {
    final url = Uri.parse('${BaseService.baseUrl}/focus/session');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'duration': duration,
      'type': type,
      'status': status,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception('Failed to save session');
      }
    } else {
      throw Exception('Failed to save session: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    final url = Uri.parse('${BaseService.baseUrl}/focus/stats');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception('Failed to load stats');
      }
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }
}
