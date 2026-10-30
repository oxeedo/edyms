import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../config/config.dart';
import '../../models/conversation.dart';
import '../../providers/chat_provider.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ChatProvider>();
      provider.fetchConversations();
      provider.fetchRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 20,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Messages',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor:
              AppTheme.getTextColor(context).withValues(alpha: 0.5),
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          tabs: [
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                final count = provider.conversations.fold<int>(
                  0,
                  (sum, c) => sum + c.unreadCount,
                );
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Inbox'),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            Consumer<ChatProvider>(
              builder: (context, provider, _) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Sent Requests'),
                      if (provider.requests.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${provider.requests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConversationList(isInbox: true),
          _buildConversationList(isInbox: false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewMessageSheet(),
        backgroundColor: AppTheme.primary,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedEdit02,
          size: 22,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildConversationList({required bool isInbox}) {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = isInbox ? provider.conversations : provider.requests;

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedBubbleChat,
                  size: 56,
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  isInbox ? 'No conversations yet' : 'No pending requests',
                  style: TextStyle(
                    color:
                        AppTheme.getTextColor(context).withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
                if (isInbox) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to message an instructor',
                    style: TextStyle(
                      color:
                          AppTheme.getTextColor(context).withValues(alpha: 0.4),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (isInbox) {
              await provider.fetchConversations();
            } else {
              await provider.fetchRequests();
            }
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, idx) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _ConversationTile(
                conversation: list[index],
                isInbox: isInbox,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRouter.chatScreen,
                    arguments: {'conversationId': list[index].id},
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showNewMessageSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NewMessageSheet(
        onConversationStarted: (conversationId) {
          Navigator.pop(ctx);
          Navigator.pushNamed(
            context,
            AppRouter.chatScreen,
            arguments: {'conversationId': conversationId},
          );
        },
      ),
    );
  }
}

/// Single conversation tile
class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isInbox;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.isInbox,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final instructor = conversation.instructor;
    final lastMsg = conversation.latestMessage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
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
                        fontSize: 18,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Name + last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instructor?.name ?? 'Instructor',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontWeight: conversation.unreadCount > 0
                          ? FontWeight.bold
                          : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg?.body ?? (isInbox ? '' : 'Awaiting response...'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context)
                          .withValues(alpha: 0.6),
                      fontSize: 13,
                      fontWeight: conversation.unreadCount > 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Time + badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (conversation.lastMessageAt != null)
                  Text(
                    _formatTime(conversation.lastMessageAt!),
                    style: TextStyle(
                      color: AppTheme.getTextColor(context)
                          .withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                const SizedBox(height: 6),
                if (conversation.unreadCount > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${conversation.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (!isInbox)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Pending',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inDays == 0) {
        return DateFormat('hh:mm a').format(date);
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return DateFormat('EEE').format(date);
      } else {
        return DateFormat('MMM d').format(date);
      }
    } catch (_) {
      return '';
    }
  }
}

/// Bottom sheet for starting a new conversation
class _NewMessageSheet extends StatefulWidget {
  final Function(int conversationId) onConversationStarted;

  const _NewMessageSheet({required this.onConversationStarted});

  @override
  State<_NewMessageSheet> createState() => _NewMessageSheetState();
}

class _NewMessageSheetState extends State<_NewMessageSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<ChatUser> _results = [];
  bool _isSearching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.length < 2) {
        setState(() => _results = []);
        return;
      }

      setState(() => _isSearching = true);
      final results =
          await context.read<ChatProvider>().searchInstructors(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color:
                  AppTheme.getTextColor(context).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'New Message',
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getBackgroundColor(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: TextStyle(color: AppTheme.getTextColor(context)),
                decoration: InputDecoration(
                  hintText: 'Search instructors...',
                  hintStyle: TextStyle(
                    color:
                        AppTheme.getTextColor(context).withValues(alpha: 0.4),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color:
                        AppTheme.getTextColor(context).withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Results
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          _searchCtrl.text.length < 2
                              ? 'Type to search for instructors'
                              : 'No instructors found',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context)
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final instructor = _results[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.getMint100(context),
                              backgroundImage: instructor.profilePhoto != null
                                  ? NetworkImage(AppConfig.getImageUrl(
                                      instructor.profilePhoto))
                                  : null,
                              child: instructor.profilePhoto == null
                                  ? Text(
                                      instructor.name[0].toUpperCase(),
                                      style: TextStyle(
                                        color: AppTheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                            title: Text(
                              instructor.name,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: instructor.specialization != null
                                ? Text(
                                    instructor.specialization!,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context)
                                          .withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppTheme.getTextColor(context)
                                  .withValues(alpha: 0.3),
                            ),
                            onTap: () async {
                              final conversation = await context
                                  .read<ChatProvider>()
                                  .startConversation(instructor.id);
                              if (conversation != null) {
                                widget
                                    .onConversationStarted(conversation.id);
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
