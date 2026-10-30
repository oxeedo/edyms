import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/community_question.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunityService {
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<CommunityQuestion>> getQuestions({
    int page = 1,
    String filter = 'all',
    String? search,
  }) async {
    String url =
        '${AppConfig.apiBaseUrl}/community/questions?page=$page&filter=$filter';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['data']['data'] as List)
          .map((json) => CommunityQuestion.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }

  Future<CommunityQuestion> getQuestionDetails(int id) async {
    final url = '${AppConfig.apiBaseUrl}/community/questions/$id';
    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CommunityQuestion.fromJson(data['data']);
    } else {
      throw Exception('Failed to load question details');
    }
  }

  Future<void> postQuestion(
    String title,
    String description,
    List<String> tags,
  ) async {
    final url = '${AppConfig.apiBaseUrl}/community/questions';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({
        'title': title,
        'description': description,
        'tags': tags,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post question');
    }
  }

  Future<void> postAnswer(int questionId, String content) async {
    final url =
        '${AppConfig.apiBaseUrl}/community/questions/$questionId/answers';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to post answer');
    }
  }

  Future<void> acceptAnswer(int answerId) async {
    final url = '${AppConfig.apiBaseUrl}/community/answers/$answerId/accept';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to accept answer');
    }
  }

  Future<void> vote(String type, int id, int voteValue) async {
    final url = '${AppConfig.apiBaseUrl}/community/vote/$type/$id';
    final response = await http.post(
      Uri.parse(url),
      headers: await _getHeaders(),
      body: jsonEncode({'vote': voteValue}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to record vote');
    }
  }
}
