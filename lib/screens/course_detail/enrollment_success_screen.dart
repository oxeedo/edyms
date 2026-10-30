import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/course.dart';

class EnrollmentSuccessScreen extends StatelessWidget {
  final int? enrollmentId;
  final Course? course;
  /// Optional list of bundle courses — provided when it was a bundle purchase
  final List<Course>? bundleCourses;
  final String? bundleTitle;

  const EnrollmentSuccessScreen({
    super.key,
    this.enrollmentId,
    this.course,
    this.bundleCourses,
    this.bundleTitle,
  });

  bool get isBundle => bundleCourses != null && bundleCourses!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Stack(
        children: <Widget>[
          // Background decorative shapes
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.4,
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
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        padding: EdgeInsets.zero,
                      ),
                      Expanded(
                        child: Text(
                          'Enrollment Success',
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 40),
                          // Success Icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.mint100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Image.asset(
                                    'assets/img/icons/check-mark.png',
                                    width: 50,
                                    height: 50,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Success Title
                          Text(
                            'Enrollment Successful!',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // Success Message
                          Text(
                            isBundle
                                ? 'Congratulations! You have successfully enrolled in all courses of the ${bundleTitle ?? 'bundle'}.'
                                : 'Congratulations! You have successfully\nenrolled in the course.',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),

                          // =============================================
                          // BUNDLE: list of all courses
                          // =============================================
                          if (isBundle) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.getCardColor(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.getMint100(context),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: HugeIcon(
                                            icon: HugeIcons.strokeRoundedBook01,
                                            size: 18,
                                            color: AppTheme.getPrimaryColor(context),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Courses in This Bundle',
                                        style: TextStyle(
                                          color: AppTheme.getTextColor(context),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  ...bundleCourses!.asMap().entries.map((entry) {
                                    final idx = entry.key;
                                    final c = entry.value;
                                    return Column(
                                      children: [
                                        if (idx > 0)
                                          Divider(
                                            height: 1,
                                            thickness: 1,
                                            color: AppTheme.getTextColor(context)
                                                .withValues(alpha: 0.08),
                                          ),
                                        if (idx > 0) const SizedBox(height: 12),
                                        _BundleCourseRow(course: c, settingsProvider: settingsProvider),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ]
                          // =============================================
                          // SINGLE COURSE: original details card
                          // =============================================
                          else ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.getCardColor(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Course Details',
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // Course Thumbnail
                                      Container(
                                        width: 100,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: <Color>[
                                              Color(0xFFFF6B35),
                                              Color(0xFFFF4500),
                                            ],
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: course?.thumbnail != null
                                              ? Image.network(
                                                  course!.thumbnail!,
                                                  fit: BoxFit.cover,
                                                )
                                              : Image.asset(
                                                  'assets/img/courses/course5.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Course Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              course?.title ?? 'Enrolled Course',
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: const BoxDecoration(
                                                    color: AppTheme.softOrange800,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedStar,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${course?.rating?.toStringAsFixed(1) ?? '0.0'} (${course?.reviewsCount ?? 0} reviews)',
                                                  style: TextStyle(
                                                    color: AppTheme.getTextColor(
                                                      context,
                                                    ).withValues(alpha: 0.7),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: <Widget>[
                                                Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedAiUser,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  '${course?.studentsCount ?? 0} Students',
                                                  style: TextStyle(
                                                    color: AppTheme.getTextColor(
                                                      context,
                                                    ).withValues(alpha: 0.7),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.1),
                                  ),
                                  const SizedBox(height: 20),
                                  // What's Included
                                  Text(
                                    'What\'s Included',
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(context),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  _FeatureItem(
                                    icon: HugeIcons.strokeRoundedAiVideo,
                                    title: '30 Video Lessons',
                                  ),
                                  const SizedBox(height: 16),
                                  _FeatureItem(
                                    icon: HugeIcons.strokeRoundedBook01,
                                    title: 'Lifetime Access',
                                  ),
                                  const SizedBox(height: 16),
                                  _FeatureItem(
                                    icon: HugeIcons.strokeRoundedAssignments,
                                    title: 'Assignments & Quizzes',
                                  ),
                                  const SizedBox(height: 16),
                                  _FeatureItem(
                                    icon: HugeIcons.strokeRoundedCertificate01,
                                    title: 'Certificate of Completion',
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 100), // Space for bottom button
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom fixed button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    AppTheme.getCardColor(context).withValues(alpha: 0.0),
                    AppTheme.getCardColor(context).withValues(alpha: 0.5),
                    AppTheme.getCardColor(context),
                  ],
                  stops: const <double>[0.0, 0.5, 1.0],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.mint100,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Start Learning',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bundle Course Row ────────────────────────────────────────────────────────

class _BundleCourseRow extends StatelessWidget {
  const _BundleCourseRow({
    required this.course,
    required this.settingsProvider,
  });

  final Course course;
  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Thumbnail
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: course.thumbnail != null
              ? Image.network(
                  course.thumbnail!,
                  width: 64,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, st) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: 14),
        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (course.instructorName != null) ...[
                const SizedBox(height: 4),
                Text(
                  course.instructorName!,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Enrolled badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.getMint100(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                size: 12,
                color: AppTheme.getPrimaryColor(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Enrolled',
                style: TextStyle(
                  color: AppTheme.getPrimaryColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.play_circle_outline, color: Colors.white, size: 24),
    );
  }
}

// ─── Background Painter ───────────────────────────────────────────────────────

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

// ─── Feature Item (single-course mode) ───────────────────────────────────────

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.title});

  final dynamic icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.getMint100(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 20,
              color: AppTheme.getPrimaryColor(context),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
