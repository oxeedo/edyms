import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  // Settings aligned with web
  bool _emailNotifications = true;
  bool _courseReminders = true;
  bool _progressReports = true;
  bool _marketingEmails = true;

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    try {
      final settings = await _notificationService.getNotificationSettings();
      if (mounted) {
        setState(() {
          _emailNotifications = settings['email_notifications'] ?? true;
          _courseReminders = settings['course_reminders'] ?? true;
          _progressReports = settings['progress_reports'] ?? true;
          _marketingEmails = settings['marketing_emails'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load settings: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateSettings() async {
    try {
      await _notificationService.updateNotificationSettings({
        'email_notifications': _emailNotifications,
        'course_reminders': _courseReminders,
        'progress_reports': _progressReports,
        'marketing_emails': _marketingEmails,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update settings: $e')),
        );
        // Re-fetch to reset state on failure
        _fetchSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: <Widget>[
          // Background decorative shapes
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.25,
            child: CustomPaint(
              painter: _BackgroundPainter(
                color1: AppTheme.getMint100(context),
                color2: AppTheme.getMint200(context),
              ),
              child: Container(),
            ),
          ),
          // Main content
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                // App Bar
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
                          context.l10n.notifications,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40), // Balance for back button
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Account Settings Header
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    'Account Settings',
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getCardColor(context),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      _NotificationToggleItem(
                                        icon: HugeIcons.strokeRoundedMail01,
                                        title: 'Email Notifications',
                                        subtitle:
                                            'Receive important announcements about your courses and enrollments',
                                        value: _emailNotifications,
                                        onChanged: (value) {
                                          setState(
                                            () => _emailNotifications = value,
                                          );
                                          _updateSettings();
                                        },
                                      ),
                                      _NotificationToggleItem(
                                        icon: HugeIcons.strokeRoundedClock01,
                                        title: 'Course Reminders',
                                        subtitle:
                                            'Get reminders about upcoming lessons, quizzes, and deadlines',
                                        value: _courseReminders,
                                        onChanged: (value) {
                                          setState(
                                            () => _courseReminders = value,
                                          );
                                          _updateSettings();
                                        },
                                      ),
                                      _NotificationToggleItem(
                                        icon:
                                            HugeIcons.strokeRoundedAnalytics01,
                                        title: 'Progress Reports',
                                        subtitle:
                                            'Receive weekly summaries of your course progress and achievements',
                                        value: _progressReports,
                                        onChanged: (value) {
                                          setState(
                                            () => _progressReports = value,
                                          );
                                          _updateSettings();
                                        },
                                      ),
                                      _NotificationToggleItem(
                                        icon: HugeIcons.strokeRoundedTag01,
                                        title: 'Marketing Emails',
                                        subtitle:
                                            'Receive tips, exclusive offers, and new course recommendations',
                                        value: _marketingEmails,
                                        onChanged: (value) {
                                          setState(
                                            () => _marketingEmails = value,
                                          );
                                          _updateSettings();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 100), // Space for bottom
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  _BackgroundPainter({required this.color1, required this.color2});

  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final Path path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.4,
        size.width * 0.6,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.6,
        size.width,
        size.height * 0.4,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);

    final Paint paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    final Path path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.7,
        size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width,
        size.height * 0.7,
        size.width,
        size.height * 0.5,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificationToggleItem extends StatelessWidget {
  const _NotificationToggleItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final dynamic icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.getMint100(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                size: 20,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.getPrimaryColor(context),
          ),
        ],
      ),
    );
  }
}
