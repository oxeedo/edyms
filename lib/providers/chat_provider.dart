import 'dart:async';
import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/chat_message_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  // Conversations state
  List<Conversation> _conversations = [];
  List<Conversation> _requests = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  // Chat screen state
  List<ChatMessage> _messages = [];
  Conversation? _activeConversation;
  bool _isSending = false;
  Timer? _pollTimer;
  bool _isPolling = false;

  // Getters
  List<Conversation> get conversations => _conversations;
  List<Conversation> get requests => _requests;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatMessage> get messages => _messages;
  Conversation? get activeConversation => _activeConversation;
  bool get isSending => _isSending;

  /// Fetch inbox conversations
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _chatService.getConversations();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch request conversations
  Future<void> fetchRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _requests = await _chatService.getRequests();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch unread count (for badge)
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _chatService.getUnreadCount();
      notifyListeners();
    } catch (_) {}
  }

  /// Search instructors
  Future<List<ChatUser>> searchInstructors(String query) async {
    if (query.length < 2) return [];
    try {
      return await _chatService.searchInstructors(query);
    } catch (_) {
      return [];
    }
  }

  /// Start a new conversation (or find existing one) and load messages
  Future<Conversation?> startConversation(int instructorId, {String? message}) async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();

    try {
      final conversation = await _chatService.startConversation(
        instructorId,
        message: message,
      );
      // Load messages for this conversation
      await loadMessages(conversation.id);
      return conversation;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(int conversationId) async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();

    try {
      final data = await _chatService.getMessages(conversationId);
      _activeConversation = data['conversation'] as Conversation;
      _messages = data['messages'] as List<ChatMessage>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();

    // Start polling
    _startPolling(conversationId);
  }

  /// Send a text message
  Future<void> sendMessage(String text) async {
    if (_activeConversation == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final msg = await _chatService.sendTextMessage(
        _activeConversation!.id,
        text,
      );
      // Add only if not already present (from polling)
      if (!_messages.any((m) => m.id == msg.id)) {
        _messages.add(msg);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isSending = false;
    notifyListeners();
  }

  /// Send a message with file attachments
  Future<void> sendMessageWithFiles({
    String? message,
    required List<String> filePaths,
  }) async {
    if (_activeConversation == null) return;

    _isSending = true;
    notifyListeners();

    try {
      final msg = await _chatService.sendMessageWithFiles(
        _activeConversation!.id,
        message: message,
        filePaths: filePaths,
      );
      if (!_messages.any((m) => m.id == msg.id)) {
        _messages.add(msg);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isSending = false;
    notifyListeners();
  }

  /// Start short polling for new messages
  void _startPolling(int conversationId) {
    stopPolling();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isPolling) return;
      _isPolling = true;

      try {
        final lastId = _messages.isNotEmpty ? _messages.last.id : 0;
        final newMessages = await _chatService.pollMessages(
          conversationId,
          lastId,
        );
        if (newMessages.isNotEmpty) {
          for (final msg in newMessages) {
            if (!_messages.any((m) => m.id == msg.id)) {
              _messages.add(msg);
            }
          }
          notifyListeners();
        }
      } catch (_) {}

      _isPolling = false;
    });
  }

  /// Stop polling
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
  }

  /// Clean up when leaving chat
  void clearChat() {
    stopPolling();
    _messages = [];
    _activeConversation = null;
    _error = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
