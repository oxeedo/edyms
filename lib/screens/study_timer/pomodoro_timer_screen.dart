import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/focus_service.dart';
import 'focus_progress_screen.dart';

class PomodoroTimerScreen extends StatefulWidget {
  const PomodoroTimerScreen({super.key});

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  int _totalSeconds = 25 * 60; // 25 minutes default
  int _initialSeconds = 25 * 60; // Store initial time for reset
  bool _isRunning = false;
  bool _isPaused = false;
  String _currentPhase = 'Focus'; // Focus, Short Break, Long Break, Custom

  late AnimationController _pulseController;
  final FocusService _focusService = FocusService();
  int _sessionsToday = 0;
  int _completedToday = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _focusService.getStats();
      if (mounted) {
        setState(() {
          _sessionsToday = stats['sessions_today'];
          _completedToday = stats['completed_today'];
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
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
    _timer?.cancel();
    _pulseController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        _onTimerComplete();
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
    });
    _timer?.cancel();
  }

  void _resumeTimer() {
    setState(() {
      _isPaused = false;
    });
    _startTimer();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _totalSeconds = _initialSeconds;
    });
    _timer?.cancel();
  }

  void _showCustomTimeDialog() {
    int customMinutes = _initialSeconds ~/ 60;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppTheme.getCardColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                context.l10n.setCustomTime,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      context.l10n.customTimeDescription,
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (customMinutes > 1) {
                                  setDialogState(() {
                                    customMinutes--;
                                  });
                                }
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.getMint100(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.remove,
                                    size: 24,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppTheme.getPrimaryColor(context),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.getBackgroundColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$customMinutes ${context.l10n.minutes}',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                if (customMinutes < 120) {
                                  setDialogState(() {
                                    customMinutes++;
                                  });
                                }
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppTheme.getMint100(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 24,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppTheme.getPrimaryColor(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    context.l10n.cancel,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPhase = 'Custom';
                      _initialSeconds = customMinutes * 60;
                      _totalSeconds = customMinutes * 60;
                      _resetTimer();
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.set,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _onTimerComplete() async {
    // Save session
    try {
      await _focusService.saveSession(
        duration: (_initialSeconds / 60).round(),
        type: _currentPhase.toLowerCase().replaceAll(' ', '_'),
        status: 'completed',
        startTime: DateTime.now().subtract(Duration(seconds: _initialSeconds)),
        endTime: DateTime.now(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // SnackBar(content: Text(context.l10n.sessionSaved)),
          SnackBar(content: Text('Session saved successfully')),
        );
        _loadStats(); // Refresh stats
      }
    } catch (e) {
      debugPrint('Error saving session: $e');
    }

    // Show completion dialog or navigate
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          // title: Text(context.l10n.congratulations),
          title: Text('Congratulations!'),
          content: Text('You completed a $_currentPhase session!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.ok),
            ),
          ],
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _initialSeconds > 0
        ? 1.0 - (_totalSeconds / _initialSeconds)
        : 0.0;

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
                      context.l10n.studyTimer,
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
                      Icons.analytics_outlined,
                      size: 24,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppTheme.getPrimaryColor(context),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const FocusProgressScreen(),
                        ),
                      );
                    },
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Timer Phase Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _PhaseButton(
                          label: context.l10n.focus,
                          isSelected: _currentPhase == 'Focus',
                          onTap: () {
                            setState(() {
                              _currentPhase = 'Focus';
                              _initialSeconds = 25 * 60;
                              _totalSeconds = 25 * 60;
                              _resetTimer();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PhaseButton(
                          label: context.l10n.shortBreak,
                          isSelected: _currentPhase == 'Short Break',
                          onTap: () {
                            setState(() {
                              _currentPhase = 'Short Break';
                              _initialSeconds = 5 * 60;
                              _totalSeconds = 5 * 60;
                              _resetTimer();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PhaseButton(
                          label: context.l10n.longBreak,
                          isSelected: _currentPhase == 'Long Break',
                          onTap: () {
                            setState(() {
                              _currentPhase = 'Long Break';
                              _initialSeconds = 15 * 60;
                              _totalSeconds = 15 * 60;
                              _resetTimer();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: _PhaseButton(
                      label: context.l10n.custom,
                      isSelected: _currentPhase == 'Custom',
                      onTap: _showCustomTimeDialog,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Main Timer Display
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Circular Progress Indicator
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        // Background Circle
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.getCardColor(context),
                          ),
                        ),
                        // Progress Circle
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 8,
                            backgroundColor: AppTheme.getBackgroundColor(
                              context,
                            ),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.getPrimaryColor(context),
                            ),
                          ),
                        ),
                        // Timer Text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _isRunning
                                      ? 0.7 + (_pulseController.value * 0.3)
                                      : 1.0,
                                  child: Text(
                                    _formatTime(_totalSeconds),
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 56,
                                      fontWeight: FontWeight.w800,
                                      fontFamily: 'Montserrat',
                                      letterSpacing: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.l10n.minutes,
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Control Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      if (!_isRunning && !_isPaused)
                        _ControlButton(
                          icon: Icons.play_arrow,
                          label: context.l10n.start,
                          onTap: _startTimer,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      if (_isRunning && !_isPaused)
                        _ControlButton(
                          icon: Icons.pause,
                          label: context.l10n.pause,
                          onTap: _pauseTimer,
                          color: AppTheme.softOrange800,
                        ),
                      if (_isPaused) ...[
                        _ControlButton(
                          icon: Icons.play_arrow,
                          label: context.l10n.resume,
                          onTap: _resumeTimer,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                        const SizedBox(width: 16),
                        _ControlButton(
                          icon: Icons.stop,
                          label: context.l10n.reset,
                          onTap: _resetTimer,
                          color: AppTheme.softBlue800,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Session Info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        _SessionStat(
                          icon: Icons.local_fire_department,
                          value: '$_sessionsToday',
                          label: context.l10n.sessionsToday,
                          color: AppTheme.softOrange800,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.1),
                        ),
                        _SessionStat(
                          icon: Icons.check_circle,
                          value: '$_completedToday',
                          label: context.l10n.completed,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhaseButton extends StatelessWidget {
  const _PhaseButton({
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

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Montserrat',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  const _SessionStat({
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
    return Column(
      children: <Widget>[
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
