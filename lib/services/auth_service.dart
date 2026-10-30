import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_service.dart';

class AuthService extends BaseService {
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('${BaseService.baseUrl}/auth/login');
    return await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  Future<http.Response> verifyOtp(String email, String code) async {
    final url = Uri.parse('${BaseService.baseUrl}/auth/login/otp/verify');
    return await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode({'email': email, 'code': code}),
    );
  }

  Future<http.Response> resendOtp(String email) async {
    final url = Uri.parse('${BaseService.baseUrl}/auth/login/otp/resend');
    return await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode({'email': email}),
    );
  }

  Future<http.Response> register(Map<String, dynamic> data) async {
    final url = Uri.parse('${BaseService.baseUrl}/auth/register');
    return await http.post(
      url,
      headers: await getHeaders(),
      body: jsonEncode(data),
    );
  }

  Future<http.Response> logout() async {
    final url = Uri.parse('${BaseService.baseUrl}/logout');
    return await http.post(url, headers: await getHeaders());
  }

  Future<http.Response> getUser() async {
    final url = Uri.parse('${BaseService.baseUrl}/user');
    return await http.get(url, headers: await getHeaders());
  }
}
