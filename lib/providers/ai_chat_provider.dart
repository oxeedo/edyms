import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/ai_chat_message.dart';
import '../services/ai_chat_service.dart';

class AiChatProvider with ChangeNotifier {
  final AiChatService _aiChatService = AiChatService();

  List<AiChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;

  List<AiChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _aiChatService.getChatHistory();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> messagesJson = data['data'];
          _messages = messagesJson
              .map((json) => AiChatMessage.fromJson(json))
              .toList();
        } else {
          _error = data['message'] ?? 'Failed to load history';
        }
      } else {
        _error = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _aiChatService.sendMessage(text);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Backend returns user_message and ai_message
        if (data['user_message'] != null) {
          _messages.add(AiChatMessage.fromJson(data['user_message']));
        }
        if (data['ai_message'] != null) {
          _messages.add(AiChatMessage.fromJson(data['ai_message']));
        }
      } else {
        _error = 'Failed to send message: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
