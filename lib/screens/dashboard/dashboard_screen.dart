import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_data.dart';
import '../../config/config.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../course_access/course_access_screen.dart';
import '../../router/app_router.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    await dashboardProvider.loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, DashboardProvider>(
      builder: (context, auth, dashboard, child) {
        if (!auth.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRouter.auth);
          });
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (dashboard.isLoading && dashboard.dashboardData == null) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (dashboard.error != null && dashboard.dashboardData == null) {
          return Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${dashboard.error}'),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = dashboard.dashboardData;
        final stats = dashboard.dashboardData?.stats;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
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
                          context.l10n.dashboard,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Stats Cards - Horizontal Scroll
                          SizedBox(
                            height: 140,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: _StatCard(
                                    title: context.l10n.totalCourses,
                                    value:
                                        stats?.totalCourses.toString() ?? '0',
                                    icon: HugeIcons.strokeRoundedBook01,
                                    color: AppTheme.primary,
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed(AppRouter.myCourses);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    title: context.l10n.completedCourses,
                                    value:
                                        stats?.completedCourses.toString() ??
                                        '0',
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                    onTap: () {
                                      Navigator.of(
                                        context,
                                      ).pushNamed(AppRouter.myCourses);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          const SizedBox(height: 32),
                          // Learning Activity Chart
                          Text(
                            context.l10n.learningActivity,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _LearningActivityChart(
                            activity: data?.activity ?? [],
                          ),
                          const SizedBox(height: 32),
                          // Quick Access Section
                          Text(
                            context.l10n.quickAccess,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _QuickAccessGrid(
                            items: <_QuickAccessItem>[
                              _QuickAccessItem(
                                title: context.l10n.myAssignments,
                                icon: HugeIcons.strokeRoundedAssignments,
                                route: AppRouter.myAssignments,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.myQuizAttempts,
                                icon: Icons.quiz,
                                route: AppRouter.myQuizAttempts,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.certificates,
                                icon: HugeIcons.strokeRoundedCertificate01,
                                route: AppRouter.certificates,
                              ),
                              _QuickAccessItem(
                                title: 'Bookings',
                                icon: HugeIcons.strokeRoundedTicket01,
                                route: AppRouter.myTicketBookings,
                              ),
                              _QuickAccessItem(
                                title: context.l10n.studyTimer,
                                icon: Icons.timer,
                                route: AppRouter.studyTimer,
                              ),
                              _QuickAccessItem(
                                title: 'Messages',
                                icon: HugeIcons.strokeRoundedBubbleChat,
                                route: AppRouter.messages,
                              ),
                            ],
                          ),
                          if (data != null &&
                              data.continueLearning.isNotEmpty) ...[
                            const SizedBox(height: 32),
                            // Continue Learning Section
                            Text(
                              context.l10n.continueLearning,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: data.continueLearning.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final course = data.continueLearning[index];
                                return _ContinueLearningCard(
                                  courseId: course.courseId,
                                  courseTitle: course.title,
                                  progress: course.progress,
                                  nextLesson: course.nextLesson,
                                  imageUrl: course.image,
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final dynamic icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: icon is IconData
                    ? Icon(
                        icon as IconData,
                        size: 20,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : color,
                      )
                    : HugeIcon(
                        icon: icon,
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
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  const _QuickAccessItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final dynamic icon;
  final String route;
}

class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.items});

  final List<_QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        final _QuickAccessItem item = items[index];
        return GestureDetector(
          onTap: () {
            if (item.route.startsWith('/')) {
              Navigator.of(context).pushNamed(item.route);
            } else {
              // Handle other cases or throw error
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.getCardColor(context),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.getMint100(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: item.icon is IconData
                        ? Icon(
                            item.icon as IconData,
                            size: 24,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          )
                        : HugeIcon(
                            icon: item.icon,
                            size: 24,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppTheme.getPrimaryColor(context),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard({
    required this.courseId,
    required this.courseTitle,
    required this.progress,
    required this.nextLesson,
    required this.imageUrl,
  });

  final int courseId;
  final String courseTitle;
  final double progress;
  final String nextLesson;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseAccessScreen(
              courseId: courseId,
              courseTitle: courseTitle,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.mint200,
              ),
              clipBehavior: Clip.antiAlias,
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? Image.network(
                      AppConfig.getImageUrl(imageUrl),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/img/banner.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  : Image.asset('assets/img/banner.png', fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    courseTitle,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextLesson,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.getSoftGray150(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}% Complete',
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
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

class _LearningActivityChart extends StatelessWidget {
  const _LearningActivityChart({required this.activity});

  final List<DashboardActivity> activity;

  @override
  Widget build(BuildContext context) {
    if (activity.isEmpty) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Text(
          'No activity data available',
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
            fontSize: 14,
          ),
        ),
      );
    }

    final int maxCompleted = activity.fold<int>(
      0,
      (max, e) => e.lessons > max ? e.lessons : max,
    );

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Lessons Completed',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getMint100(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${activity.fold<int>(0, (sum, e) => sum + e.lessons)} Total',
                  style: TextStyle(
                    color: AppTheme.getPrimaryColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: activity.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final DashboardActivity data = entry.value;
                  final double barHeight = maxCompleted > 0
                      ? (data.lessons / maxCompleted) * 120
                      : 4;

                  // Show labels every 5 days or if it's the last day
                  final bool showLabel =
                      index % 5 == 0 || index == activity.length - 1;

                  return Container(
                    width: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        if (data.lessons > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${data.lessons}',
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Bar
                        Container(
                          height: barHeight.clamp(6, 120),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.getPrimaryColor(context),
                                AppTheme.getPrimaryColor(
                                  context,
                                ).withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Label
                        SizedBox(
                          height: 24,
                          child: showLabel
                              ? Text(
                                  data.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.6),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
