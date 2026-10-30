import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../config/config.dart';
import '../../models/chat_message_model.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final int? conversationId;
  final int? instructorId;
  final String? instructorName;

  const ChatScreen({
    super.key,
    this.conversationId,
    this.instructorId,
    this.instructorName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<File> _selectedFiles = [];
  late final ChatProvider _chatProvider;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.conversationId != null) {
        _chatProvider.loadMessages(widget.conversationId!);
      } else if (widget.instructorId != null) {
        _chatProvider.startConversation(widget.instructorId!);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatProvider.clearChat();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _pickFiles() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCamera01,
                  size: 22,
                  color: AppTheme.primary,
                ),
              ),
              title: Text('Camera',
                  style: TextStyle(color: AppTheme.getTextColor(context))),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final photo =
                    await picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  setState(() => _selectedFiles.add(File(photo.path)));
                }
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedImage01,
                  size: 22,
                  color: AppTheme.primary,
                ),
              ),
              title: Text('Gallery',
                  style: TextStyle(color: AppTheme.getTextColor(context))),
              onTap: () async {
                Navigator.pop(ctx);
                final picker = ImagePicker();
                final images = await picker.pickMultiImage();
                setState(() {
                  for (final img in images) {
                    _selectedFiles.add(File(img.path));
                  }
                });
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedAttachment01,
                  size: 22,
                  color: AppTheme.primary,
                ),
              ),
              title: Text('File',
                  style: TextStyle(color: AppTheme.getTextColor(context))),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                  type: FileType.custom,
                  allowedExtensions: [
                    'jpg',
                    'jpeg',
                    'png',
                    'gif',
                    'webp',
                    'pdf',
                    'doc',
                    'docx',
                    'xls',
                    'xlsx',
                    'zip',
                  ],
                );
                if (result != null) {
                  setState(() {
                    for (final file in result.files) {
                      if (file.path != null) {
                        _selectedFiles.add(File(file.path!));
                      }
                    }
                  });
                }
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedFiles.isEmpty) return;

    _messageController.clear();
    final files = List<File>.from(_selectedFiles);
    setState(() => _selectedFiles.clear());

    final provider = context.read<ChatProvider>();

    if (files.isNotEmpty) {
      await provider.sendMessageWithFiles(
        message: text.isNotEmpty ? text : null,
        filePaths: files.map((f) => f.path).toList(),
      );
    } else {
      await provider.sendMessage(text);
    }

    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthProvider>().user;
    final currentUserId = authUser?.id ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Failed to load messages',
                          style: TextStyle(
                              color: AppTheme.getTextColor(context)),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                              if (widget.conversationId != null) {
                                provider.loadMessages(widget.conversationId!);
                              } else if (widget.instructorId != null) {
                                provider.startConversation(widget.instructorId!);
                              }
                            },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _scrollToBottom());

                if (provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBubbleChat,
                          size: 56,
                          color: AppTheme.getTextColor(context)
                              .withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Start the conversation!',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context)
                                .withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final msg = provider.messages[index];
                    final isMe = msg.senderId == currentUserId;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
            ),
          ),
          // File preview
          if (_selectedFiles.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.getCardColor(context),
              child: SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedFiles.length,
                  separatorBuilder: (_, idx) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final file = _selectedFiles[index];
                    final isImage = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
                        .any((ext) => file.path.toLowerCase().endsWith(ext));
                    return Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppTheme.getBackgroundColor(context),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: isImage
                              ? Image.file(file, fit: BoxFit.cover)
                              : Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedFile02,
                                    size: 24,
                                    color: AppTheme.getTextColor(context)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _selectedFiles.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          // Input area
          _buildInputArea(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.getCardColor(context),
      elevation: 0.5,
      leading: IconButton(
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowLeft01,
          size: 20,
          color: AppTheme.getTextColor(context),
        ),
        onPressed: () {
          context.read<ChatProvider>().clearChat();
          Navigator.of(context).pop();
        },
      ),
      title: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          final instructor = provider.activeConversation?.instructor;
          return Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.getMint100(context),
                backgroundImage: instructor?.profilePhoto != null
                    ? NetworkImage(
                        AppConfig.getImageUrl(instructor!.profilePhoto))
                    : null,
                child: instructor?.profilePhoto == null
                    ? Text(
                        (instructor?.name ?? '?')[0].toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor?.name ?? 'Instructor',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Instructor',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context)
                            .withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Attach button
          GestureDetector(
            onTap: _pickFiles,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedAttachment01,
                size: 20,
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Text field
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                    color: AppTheme.getTextColor(context), fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color:
                        AppTheme.getTextColor(context).withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          Consumer<ChatProvider>(
            builder: (context, provider, _) {
              return GestureDetector(
                onTap: provider.isSending ? null : _sendMessage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        provider.isSending ? Colors.grey : AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: provider.isSending
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const HugeIcon(
                          icon: HugeIcons.strokeRoundedSent,
                          size: 20,
                          color: Colors.white,
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual message bubble
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Attachments
            if (message.attachments.isNotEmpty)
              ...message.attachments.map((att) => _buildAttachment(
                    context,
                    att,
                  )),
            // Text bubble
            if (message.body != null && message.body!.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppTheme.primary
                      : AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  message.body!,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppTheme.getTextColor(context),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            // Time
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTime(message.createdAt),
                style: TextStyle(
                  color:
                      AppTheme.getTextColor(context).withValues(alpha: 0.4),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(BuildContext context, ChatAttachment att) {
    if (att.isImage) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: const BoxConstraints(maxWidth: 240, maxHeight: 200),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.network(
          '${AppConfig.baseUrl}/storage/${att.filePath}',
          fit: BoxFit.cover,
          errorBuilder: (_, e, st) => Container(
            height: 100,
            color: Colors.grey[200],
            child: const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isMe
            ? Colors.white.withValues(alpha: 0.15)
            : AppTheme.getBackgroundColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedFile02,
            size: 18,
            color: isMe ? Colors.white : AppTheme.getTextColor(context),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              att.fileName,
              style: TextStyle(
                color: isMe ? Colors.white : AppTheme.getTextColor(context),
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('hh:mm a').format(date);
    } catch (_) {
      return '';
    }
  }
}
