import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';
import 'auth_service.dart';

class HabitService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _authService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getHabits() async {
    final url = Uri.parse('${BaseService.baseUrl}/habits');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception('Failed to load habits');
      }
    } else {
      throw Exception('Failed to load habits: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createHabit(String name, int targetDays) async {
    final url = Uri.parse('${BaseService.baseUrl}/habits');
    final headers = await _getHeaders();
    final body = jsonEncode({'name': name, 'target_days_per_week': targetDays});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception('Failed to create habit');
      }
    } else {
      throw Exception('Failed to create habit: ${response.statusCode}');
    }
  }

  Future<void> logHabit(int habitId, DateTime date) async {
    final url = Uri.parse('${BaseService.baseUrl}/habits/$habitId/log');
    final headers = await _getHeaders();
    final body = jsonEncode({'date': date.toIso8601String()});

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to log habit: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getWeeklyReview() async {
    final url = Uri.parse('${BaseService.baseUrl}/habits/weekly-review');
    final headers = await _getHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception('Failed to load weekly review');
      }
    } else {
      throw Exception('Failed to load weekly review: ${response.statusCode}');
    }
  }
}
