import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/base_service.dart';

class ProfileService extends BaseService {
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? bio,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'bio': bio,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update profile: ${response.body}');
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/user/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Failed to update password');
    }
  }

  Future<void> submitDeleteRequest() async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('${BaseService.baseUrl}/user/delete-request'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to submit delete request: ${response.body}');
    }
  }

  Future<Map<String, dynamic>?> getDeleteRequestStatus() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('${BaseService.baseUrl}/user/delete-request'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      return null;
    }
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    final token = await getToken();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${BaseService.baseUrl}/user/profile-photo'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.files.add(await http.MultipartFile.fromPath('photo', filePath));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['photo_url'];
    } else {
      throw Exception('Failed to upload photo: ${response.body}');
    }
  }
}
