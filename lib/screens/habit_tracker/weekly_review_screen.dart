import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

import '../../services/habit_service.dart';

class WeeklyReviewScreen extends StatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  final HabitService _habitService = HabitService();
  bool _isLoading = true;
  int _weeklyCompletionRate = 0;
  int _totalCompletedDays = 0;
  int _missedDays = 0;
  List<_WeekDayData> _weekData = [];
  List<_WeeklyHabitData> _weeklyHabits = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _habitService.getWeeklyReview();
      if (mounted) {
        setState(() {
          _weeklyCompletionRate = data['weekly_completion_rate'];
          _totalCompletedDays = data['total_completed_days'];
          _missedDays = data['missed_days'];

          final List<dynamic> calendar = data['week_calendar'];
          _weekData = calendar
              .map(
                (item) => _WeekDayData(
                  day: item['day'],
                  date: item['date'],
                  isCompleted: item['is_completed'],
                  fullDate: item['full_date'], // Add fullDate to _WeekDayData
                ),
              )
              .toList();

          final List<dynamic> habits = data['habits_summary'];
          _weeklyHabits = habits
              .map(
                (item) => _WeeklyHabitData(
                  name: item['name'],
                  completionCount: item['completion_count'],
                  totalDays: item['total_days'],
                  trend: item['trend'],
                ),
              )
              .toList();

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading review: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                      context.l10n.weeklyReview,
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
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Week Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      AppTheme.getPrimaryColor(context),
                      AppTheme.getPrimaryColor(context).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      context.l10n.thisWeek,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_weeklyCompletionRate%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      context.l10n.completionRate,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              '$_totalCompletedDays',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              context.l10n.completedDays,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        Column(
                          children: <Widget>[
                            Text(
                              '$_missedDays',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            Text(
                              context.l10n.missedDays,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Week Calendar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _weekData.map((dayData) {
                  return Expanded(child: _DayCard(dayData: dayData));
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            // Weekly Habits List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.habitsThisWeek,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._weeklyHabits.map((habit) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _WeeklyHabitCard(habit: habit),
                      );
                    }),
                    const SizedBox(height: 24),
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

class _WeekDayData {
  const _WeekDayData({
    required this.day,
    required this.date,
    required this.isCompleted,
    required this.fullDate,
  });

  final String day;
  final String date;
  final bool isCompleted;
  final String fullDate;
}

class _DayCard extends StatelessWidget {
  const _DayCard({required this.dayData});

  final _WeekDayData dayData;

  @override
  Widget build(BuildContext context) {
    final String today = DateTime.now().toString().substring(0, 10);
    final bool isToday = dayData.fullDate == today;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.getPrimaryColor(context)
            : dayData.isCompleted
            ? AppTheme.getMint100(context)
            : AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: <Widget>[
          Text(
            dayData.day,
            style: TextStyle(
              color: isToday
                  ? Colors.white
                  : dayData.isCompleted
                  ? AppTheme.getPrimaryColor(context)
                  : AppTheme.getTextColor(context).withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dayData.date,
            style: TextStyle(
              color: isToday ? Colors.white : AppTheme.getTextColor(context),
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dayData.isCompleted
                  ? (isToday ? Colors.white : AppTheme.getPrimaryColor(context))
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyHabitData {
  const _WeeklyHabitData({
    required this.name,
    required this.completionCount,
    required this.totalDays,
    required this.trend,
  });

  final String name;
  final int completionCount;
  final int totalDays;
  final String trend;
}

class _WeeklyHabitCard extends StatelessWidget {
  const _WeeklyHabitCard({required this.habit});

  final _WeeklyHabitData habit;

  @override
  Widget build(BuildContext context) {
    final double completionRate = habit.completionCount / habit.totalDays;
    final bool isPositiveTrend = habit.trend.startsWith('+');
    final bool isNegativeTrend = habit.trend.startsWith('-');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  habit.name,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositiveTrend
                      ? AppTheme.getMint100(context)
                      : isNegativeTrend
                      ? Colors.red.withValues(alpha: 0.1)
                      : AppTheme.getBackgroundColor(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      isPositiveTrend
                          ? Icons.trending_up
                          : isNegativeTrend
                          ? Icons.trending_down
                          : Icons.trending_flat,
                      size: 12,
                      color: isPositiveTrend
                          ? (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context))
                          : isNegativeTrend
                          ? Colors.red
                          : AppTheme.getTextColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      habit.trend,
                      style: TextStyle(
                        color: isPositiveTrend
                            ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : AppTheme.getPrimaryColor(context))
                            : isNegativeTrend
                            ? Colors.red
                            : AppTheme.getTextColor(context),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: completionRate,
                    backgroundColor: AppTheme.getBackgroundColor(context),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.getPrimaryColor(context),
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${habit.completionCount}/${habit.totalDays}',
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
    );
  }
}
