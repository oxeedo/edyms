import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';

class StudentCourseService extends BaseService {
  Future<http.Response> getCourseCurriculum(int courseId) async {
    final uri = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/learn',
    );
    return await http.get(uri, headers: await getHeaders());
  }

  Future<http.Response> loadLesson(int courseId, int lessonId) async {
    final uri = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/lessons/$lessonId',
    );
    return await http.get(uri, headers: await getHeaders());
  }

  Future<http.Response> markLessonComplete(int courseId, int lessonId) async {
    final token = await getToken();
    final url = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/lessons/$lessonId/complete',
    );

    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  // Quiz Methods
  Future<http.Response> loadQuiz(
    int courseId,
    int quizId, {
    bool retake = false,
  }) async {
    final token = await getToken();
    var url = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/quizzes/$quizId',
    );
    if (retake) {
      url = url.replace(queryParameters: {'retake': 'true'});
    }
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<http.Response> submitQuiz(
    int courseId,
    int quizId,
    Map<String, dynamic> data,
  ) async {
    final token = await getToken();
    final url = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/quizzes/$quizId/submit',
    );
    return await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  // Assignment Methods
  Future<http.Response> loadAssignment(int courseId, int assignmentId) async {
    final token = await getToken();
    final url = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/assignments/$assignmentId',
    );
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<http.Response> submitAssignment(
    int courseId,
    int assignmentId,
    String text, {
    String? filePath,
  }) async {
    final token = await getToken();
    final url = Uri.parse(
      '${BaseService.baseUrl}/user/courses/$courseId/assignments/$assignmentId/submit',
    );

    var request = http.MultipartRequest('POST', url);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['submission_text'] = text;

    if (filePath != null && filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    }

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> getMyAssignments() async {
    final token = await getToken();
    final url = Uri.parse('${BaseService.baseUrl}/user/assignments');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<http.Response> getMyQuizAttempts() async {
    final token = await getToken();
    final url = Uri.parse('${BaseService.baseUrl}/user/quizzes');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

  Future<http.Response> getCertificates() async {
    final token = await getToken();
    final url = Uri.parse('${BaseService.baseUrl}/user/certificates');
    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }
}
