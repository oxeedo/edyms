import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/community_service.dart';
import '../../models/community_question.dart';
import '../../widgets/community/vote_widget.dart';
import '../../providers/auth_provider.dart';

class QuestionDetailScreen extends StatefulWidget {
  const QuestionDetailScreen({super.key, required this.questionId});

  final int questionId;

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final CommunityService _service = CommunityService();
  final TextEditingController _answerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  CommunityQuestion? _question;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestionDetails();
  }

  Future<void> _fetchQuestionDetails() async {
    setState(() => _isLoading = true);
    try {
      final question = await _service.getQuestionDetails(widget.questionId);
      setState(() {
        _question = question;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading question: $e')));
      }
    }
  }

  Future<void> _postAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    try {
      await _service.postAnswer(
        widget.questionId,
        _answerController.text.trim(),
      );
      _answerController.clear();
      _fetchQuestionDetails(); // Refresh to see new answer
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post answer: $e')));
      }
    }
  }

  Future<void> _acceptAnswer(int answerId) async {
    try {
      await _service.acceptAnswer(answerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Answer marked as accepted')),
        );
        _fetchQuestionDetails(); // Refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
  }

  @override
  void dispose() {
    _answerController.dispose();
    _scrollController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
                      context.l10n.question,
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
                ],
              ),
            ),
            // Question Card
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_question == null)
                      Center(
                        child: Text(
                          'Question not found',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      )
                    else ...[
                      // Question Header
                      if (_question!.isAnswered)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.getMint100(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.answered,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppTheme.getPrimaryColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Question Title
                      Text(
                        _question!.title,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Question Meta
                      Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.getMint100(context),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _question!.userName.isNotEmpty
                                    ? _question!.userName
                                          .substring(0, 1)
                                          .toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : AppTheme.getPrimaryColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _question!.userName,
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                Text(
                                  _getTimeAgo(_question!.createdAt),
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Votes
                          VoteWidget(
                            type: 'question',
                            id: _question!.id,
                            initialVotes: _question!.votesSum,
                            initialUserVote: _question!.userVote,
                          ),
                          const SizedBox(width: 16),
                          // View count
                          Row(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 20,
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_question!.views}',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Question Description
                      Text(
                        _question!.description,
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.8),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          height: 1.6,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Tags
                      if (_question!.tags != null &&
                          _question!.tags!.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _question!.tags!.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 32),
                      // Answers Section
                      Row(
                        children: <Widget>[
                          Text(
                            '${_question!.answers.length} ${context.l10n.answers}',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Answers List
                      ..._question!.answers.map((answer) {
                        final authProvider = context.watch<AuthProvider>();
                        final currentUser = authProvider.user;
                        final isQuestionOwner =
                            currentUser?.id == _question?.userId;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _AnswerCard(
                            answer: answer,
                            canAccept: isQuestionOwner,
                            onAccept: () => _acceptAnswer(answer.id),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            // Answer Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                border: Border(
                  top: BorderSide(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: context.l10n.writeAnswer,
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
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Montserrat',
                        ),
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _postAnswer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(context),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          context.l10n.postAnswer,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.answer,
    this.canAccept = false,
    this.onAccept,
  });

  final CommunityAnswer answer;
  final bool canAccept;
  final VoidCallback? onAccept;

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: answer.isAccepted
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    answer.userName.isNotEmpty
                        ? answer.userName.substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.getPrimaryColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            answer.userName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                        if (answer.isAccepted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getMint100(context),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              context.l10n.accepted,
                              style: TextStyle(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.getPrimaryColor(context),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _getTimeAgo(answer.createdAt),
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              VoteWidget(
                type: 'answer',
                id: answer.id,
                initialVotes: answer.votesSum,
                initialUserVote: answer.userVote,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            answer.content,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontFamily: 'Montserrat',
            ),
          ),
          if (canAccept && !answer.isAccepted) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onAccept,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppTheme.getPrimaryColor(context)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  context.l10n.accept,
                  style: TextStyle(
                    color: AppTheme.getPrimaryColor(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
