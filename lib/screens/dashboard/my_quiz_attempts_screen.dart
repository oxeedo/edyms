import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_quiz_attempt.dart';
import '../../services/student_course_service.dart';

class MyQuizAttemptsScreen extends StatefulWidget {
  const MyQuizAttemptsScreen({super.key});

  @override
  State<MyQuizAttemptsScreen> createState() => _MyQuizAttemptsScreenState();
}

class _MyQuizAttemptsScreenState extends State<MyQuizAttemptsScreen> {
  String _selectedFilter = 'all'; // all, passed, failed
  final StudentCourseService _courseService = StudentCourseService();
  List<UserQuizAttempt> _quizAttempts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizAttempts();
  }

  Future<void> _fetchQuizAttempts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _courseService.getMyQuizAttempts();
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'];
          if (mounted) {
            setState(() {
              _quizAttempts = list
                  .map((e) => UserQuizAttempt.fromJson(e))
                  .toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<UserQuizAttempt> get _filteredQuizAttempts {
    if (_selectedFilter == 'all') {
      return _quizAttempts;
    } else if (_selectedFilter == 'passed') {
      return _quizAttempts.where((quiz) => quiz.passed == true).toList();
    } else {
      return _quizAttempts.where((quiz) => quiz.passed == false).toList();
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
                      context.l10n.myQuizAttempts,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: _fetchQuizAttempts,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _FilterChip(
                      label: context.l10n.all,
                      isSelected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: context.l10n.passed,
                      isSelected: _selectedFilter == 'passed',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'passed';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: context.l10n.failed,
                      isSelected: _selectedFilter == 'failed',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'failed';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredQuizAttempts.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _fetchQuizAttempts,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _EmptyState(
                              icon: HugeIcons.strokeRoundedNote01,
                              message: context.l10n.noQuizAttempts,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchQuizAttempts,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredQuizAttempts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final UserQuizAttempt quiz =
                              _filteredQuizAttempts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _QuizAttemptCard(quiz: quiz),
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

class _QuizAttemptCard extends StatelessWidget {
  const _QuizAttemptCard({required this.quiz});

  final UserQuizAttempt quiz;

  @override
  Widget build(BuildContext context) {
    final String title = quiz.title;
    final String course = quiz.courseTitle;
    final String date = quiz.date;
    final int score = quiz.score;
    final int maxScore = quiz.maxScore;
    final int attempts = quiz.attempts;
    final bool passed = quiz.passed;

    final double percentage = (score / maxScore) * 100;
    final Color scoreColor = passed ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.quiz,
                    size: 24,
                    color: AppTheme.getPrimaryColor(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course,
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '$score',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '/$maxScore',
                      style: TextStyle(
                        color: scoreColor.withValues(alpha: 0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: AppTheme.getSoftGray150(context),
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${context.l10n.attempts}: $attempts',
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final dynamic icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.getMint100(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                size: 40,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
