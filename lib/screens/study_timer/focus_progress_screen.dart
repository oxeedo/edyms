import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import 'task_breakdown_screen.dart';

import '../../services/focus_service.dart';

class FocusProgressScreen extends StatefulWidget {
  const FocusProgressScreen({super.key});

  @override
  State<FocusProgressScreen> createState() => _FocusProgressScreenState();
}

class _FocusProgressScreenState extends State<FocusProgressScreen> {
  final FocusService _focusService = FocusService();
  bool _isLoading = true;
  double _totalHours = 0;
  double _averageHours = 0;
  int _streak = 0;
  double _maxHours = 0;
  List<_DailyProgressData> _dailyProgress = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _focusService.getStats();
      if (mounted) {
        setState(() {
          _totalHours = (data['total_focus_hours'] as num).toDouble();
          _averageHours = (data['daily_average_hours'] as num).toDouble();
          _streak = data['streak'];

          final List<dynamic> weeklyData = data['weekly_progress'];
          _dailyProgress = weeklyData
              .map(
                (item) => _DailyProgressData(
                  day: item['day'],
                  hours: (item['hours'] as num).toDouble(),
                ),
              )
              .toList();

          if (_dailyProgress.isNotEmpty) {
            _maxHours = _dailyProgress
                .map((d) => d.hours)
                .reduce((a, b) => a > b ? a : b);
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress: $e');
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
                      context.l10n.focusProgress,
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
                      Icons.assignment_outlined,
                      size: 24,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.getPrimaryColor(context),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const TaskBreakdownScreen(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Summary Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer,
                      value: '${_totalHours.toStringAsFixed(1)}h',
                      label: context.l10n.totalFocusTime,
                      color: AppTheme.getPrimaryColor(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up,
                      value: '${_averageHours.toStringAsFixed(1)}h',
                      label: context.l10n.dailyAverage,
                      color: AppTheme.softBlue800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      value: '$_streak',
                      label: context.l10n.dayStreak,
                      color: AppTheme.softOrange800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Weekly Chart Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: <Widget>[
                  Text(
                    context.l10n.weeklyProgress,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.thisWeek,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Weekly Chart
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 200,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: _dailyProgress
                                      .map(
                                        (data) => Expanded(
                                          child: _BarChartItem(
                                            day: data.day,
                                            hours: data.hours,
                                            maxHours: _maxHours,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: AppTheme.getPrimaryColor(context),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.l10n.focusHours,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Daily Details
                    Text(
                      context.l10n.dailyDetails,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._dailyProgress.map((data) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DailyDetailCard(progress: data),
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

class _DailyProgressData {
  const _DailyProgressData({required this.day, required this.hours});

  final String day;
  final double hours;
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              fontFamily: 'Montserrat',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _BarChartItem extends StatelessWidget {
  const _BarChartItem({
    required this.day,
    required this.hours,
    required this.maxHours,
  });

  final String day;
  final double hours;
  final double maxHours;

  @override
  Widget build(BuildContext context) {
    final double height = maxHours > 0 ? (hours / maxHours) * 160 : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Text(
              hours.toStringAsFixed(1),
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            flex: 10,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minHeight: height > 0 ? height : 4,
                maxHeight: 160,
              ),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              day,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyDetailCard extends StatelessWidget {
  const _DailyDetailCard({required this.progress});

  final _DailyProgressData progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.getMint100(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                progress.day,
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${progress.hours.toStringAsFixed(1)} ${context.l10n.hours}',
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.focusTime,
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
          Icon(
            Icons.check_circle,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : AppTheme.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }
}
