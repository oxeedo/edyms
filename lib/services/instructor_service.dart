import 'package:http/http.dart' as http;
import '../config/config.dart';

class InstructorService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<http.Response> fetchInstructors() async {
    final url = Uri.parse('$baseUrl/instructors');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> fetchInstructorDetails(int id) async {
    final url = Uri.parse('$baseUrl/instructors/$id');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
