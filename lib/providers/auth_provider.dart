import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  Map<String, dynamic>? _deletionRequestStatus;

  User? get user => _user;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get deletionRequestStatus => _deletionRequestStatus;
  bool get isAuthenticated => _user != null;

  Future<void> loadUser() async {
    final token = await _authService.getToken();
    if (token == null) return;

    try {
      final response = await _authService.getUser();
      if (response.statusCode == 200) {
        _user = User.fromJson(jsonDecode(response.body));
        await checkDeletionRequestStatus();
      } else {
        await _authService.clearToken();
      }
    } catch (e) {
      // Handle connection errors appropriately
      debugPrint('Error loading user: $e');
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['otp_required'] == true) {
          return {
            'success': true,
            'otp_required': true,
            'message': data['message'] ?? 'OTP sent to email',
            'email': data['email'] ?? email,
          };
        }

        final token = data['token'];
        _user = User.fromJson(data['user']);
        await _authService.saveToken(token);
        return {
          'success': true,
          'otp_required': false,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(email, code);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['token'];
        _user = User.fromJson(data['user']);
        await _authService.saveToken(token);
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Invalid OTP'};
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final response = await _authService.resendOtp(email);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authService.register(userData);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final token = data['token'];
        _user = User.fromJson(data['user']);
        await _authService.saveToken(token);
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Registration failed',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'An error occurred: $e'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkDeletionRequestStatus() async {
    try {
      _deletionRequestStatus = await ProfileService().getDeleteRequestStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking deletion status: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Ignore network errors on logout
    }
    await _authService.clearToken();
    _user = null;
    notifyListeners();
  }
}
