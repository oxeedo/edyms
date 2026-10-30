import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../widgets/community/vote_widget.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/community_service.dart';
import '../../models/community_question.dart';
import 'question_detail_screen.dart';

class QaRoomScreen extends StatefulWidget {
  const QaRoomScreen({super.key});

  @override
  State<QaRoomScreen> createState() => _QaRoomScreenState();
}

class _QaRoomScreenState extends State<QaRoomScreen> {
  final CommunityService _service = CommunityService();
  String _selectedFilter = 'All';
  List<CommunityQuestion> _questions = [];
  bool _isLoading = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions(refresh: true);
  }

  Future<void> _fetchQuestions({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      setState(() {
        _page = 1;
        _questions = [];
        _hasMore = true;
      });
    }
    if (!_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final filter = _selectedFilter == 'All'
          ? 'all'
          : (_selectedFilter == 'Unanswered' ? 'unanswered' : 'my_questions');
      final newQuestions = await _service.getQuestions(
        page: _page,
        filter: filter,
      );

      if (mounted) {
        setState(() {
          _questions.addAll(newQuestions);
          _isLoading = false;
          if (newQuestions.length < 10) {
            _hasMore = false;
          } else {
            _page++;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading questions: $e')));
      }
    }
  }

  void _showAskQuestionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _AskQuestionSheet(
          onPosted: () {
            _fetchQuestions(refresh: true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: Theme.of(context).brightness == Brightness.dark
            ? Brightness.dark
            : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.qaRoom,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      size: 28,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.getPrimaryColor(context),
                    ),
                    onPressed: () {
                      _showAskQuestionSheet(context);
                    },
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _FilterTab(
                      label: context.l10n.all,
                      isSelected: _selectedFilter == 'All',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'All';
                        });
                        _fetchQuestions(refresh: true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterTab(
                      label: context.l10n.unanswered,
                      isSelected: _selectedFilter == 'Unanswered',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'Unanswered';
                        });
                        _fetchQuestions(refresh: true);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FilterTab(
                      label: context.l10n.myQuestions,
                      isSelected: _selectedFilter == 'My Questions',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'My Questions';
                        });
                        _fetchQuestions(refresh: true);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Questions List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchQuestions(refresh: true),
                color: AppTheme.getPrimaryColor(context),
                child: _isLoading && _questions.isEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 5,
                        itemBuilder: (context, index) => const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: _QuestionSkeleton(),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _questions.length + (_hasMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == _questions.length) {
                            if (_hasMore) {
                              _fetchQuestions();
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else {
                              return const SizedBox(height: 32);
                            }
                          }
                          final CommunityQuestion question = _questions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => QuestionDetailScreen(
                                      questionId: question.id,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _fetchQuestions(refresh: true);
                                }
                              },
                              child: _QuestionCard(question: question),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getTextColor(context).withValues(alpha: 0.1),
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.getTextColor(context),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({required this.question});

  final CommunityQuestion question;

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnswered = question.isAnswered;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: isAnswered
            ? Border.all(
                color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.3),
                width: 2,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (isAnswered)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getMint100(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.getPrimaryColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.answered,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : AppTheme.getPrimaryColor(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                ),
              if (isAnswered) const Spacer(),
              Text(
                _getTimeAgo(question.createdAt),
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question.title,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.description,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
              fontFamily: 'Montserrat',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Tags
          if (question.tags != null && question.tags!.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: question.tags!.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackgroundColor(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
          // Footer
          Row(
            children: <Widget>[
              // Author & Views
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppTheme.getMint100(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          question.userName.isNotEmpty
                              ? question.userName.substring(0, 1).toUpperCase()
                              : '?',
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        question.userName,
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${question.views} views',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Votes
              VoteWidget(
                type: 'question',
                id: question.id,
                initialVotes: question.votesSum,
                initialUserVote: question.userVote,
              ),
              const SizedBox(width: 12),
              // Answers Count
              Row(
                children: <Widget>[
                  Icon(
                    Icons.comment_outlined,
                    size: 16,
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${question.answersCount}',
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AskQuestionSheet extends StatefulWidget {
  final VoidCallback onPosted;

  const _AskQuestionSheet({required this.onPosted});

  @override
  State<_AskQuestionSheet> createState() => _AskQuestionSheetState();
}

class _AskQuestionSheetState extends State<_AskQuestionSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];
  bool _isPosting = false;
  final CommunityService _service = CommunityService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Ask Question',
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Question title...',
                        hintStyle: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        hintText: 'Add tags (press Enter)...',
                        hintStyle: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                        prefixIcon: Icon(
                          Icons.local_offer_outlined,
                          size: 20,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && !_tags.contains(value)) {
                          setState(() {
                            _tags.add(value);
                            _tagController.clear();
                          });
                        }
                      },
                    ),
                    if (_tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: _tags
                              .map(
                                (tag) => Chip(
                                  label: Text(
                                    tag,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                    ),
                                  ),
                                  onDeleted: () {
                                    setState(() {
                                      _tags.remove(tag);
                                    });
                                  },
                                  deleteIconColor: Colors.red,
                                  backgroundColor: AppTheme.getMint100(context),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Describe your question in detail...',
                        hintStyle: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.2),
                          ),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPosting
                            ? null
                            : () async {
                                if (_titleController.text.isEmpty ||
                                    _descriptionController.text.isEmpty) {
                                  return;
                                }
                                setState(() => _isPosting = true);
                                try {
                                  await _service.postQuestion(
                                    _titleController.text,
                                    _descriptionController.text,
                                    _tags,
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    widget.onPosted();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Question posted successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    setState(() => _isPosting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to post question: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(context),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isPosting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Ask Question',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionSkeleton extends StatelessWidget {
  const _QuestionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.getCardColor(context),
      highlightColor: AppTheme.getBackgroundColor(context),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
