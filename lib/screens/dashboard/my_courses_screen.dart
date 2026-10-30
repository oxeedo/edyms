import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../course_access/course_access_screen.dart';
import '../../services/course_service.dart';
import '../../services/base_service.dart';
import 'dart:convert';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  int _selectedTab = 0; // 0 = Ongoing, 1 = Completed
  bool _isLoading = true;
  bool _isMoreLoading = false;
  List<dynamic> _courses = [];
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchCourses();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        !_isMoreLoading &&
        _hasMore) {
      _fetchCourses(isLoadMore: true);
    }
  }

  Future<void> _onRefresh() async {
    await _fetchCourses(isRefresh: true);
  }

  Future<void> _fetchCourses({
    bool isLoadMore = false,
    bool isRefresh = false,
  }) async {
    if (isLoadMore) {
      setState(() {
        _isMoreLoading = true;
      });
    } else if (isRefresh) {
      // Don't set isLoading, just let RefreshIndicator spin
      setState(() {
        _error = null;
      });
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final status = _selectedTab == 0 ? 'inProgress' : 'completed';
      final pageToFetch = isRefresh ? 1 : _currentPage;

      final response = await CourseService().fetchMyCourses(
        status: status,
        page: pageToFetch,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> newCourses = data['data']['data'];
        final Map<String, dynamic> pagination = data['data'];

        if (!mounted) return;

        setState(() {
          if (isLoadMore) {
            _courses.addAll(newCourses);
          } else {
            // isRefresh or initial load
            _courses = newCourses;
            _currentPage = 1; // Reset to 1, then increment
          }

          _currentPage++;
          _hasMore = pagination['next_page_url'] != null;
          _isLoading = false;
          _isMoreLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Failed to load courses';
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isMoreLoading = false;
      });
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() {
        _selectedTab = index;
        _courses = [];
        _currentPage = 1;
        _hasMore = true;
        _isLoading = true;
      });
      _fetchCourses();
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
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                      context.l10n.myCourses,
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
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.getSoftGray150(context),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabChanged(0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? AppTheme.getPrimaryColor(context)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.ongoing,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 0
                                  ? Colors.white
                                  : AppTheme.getTextColor(context),
                              fontSize: 14,
                              fontWeight: _selectedTab == 0
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabChanged(1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? AppTheme.getPrimaryColor(context)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            context.l10n.completed,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _selectedTab == 1
                                  ? Colors.white
                                  : AppTheme.getTextColor(context),
                              fontSize: 14,
                              fontWeight: _selectedTab == 1
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Content with animation
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0.1, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeInOut,
                          ),
                        ),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppTheme.getPrimaryColor(context),
                  child: _isLoading && _courses.isEmpty
                      ? _buildSkeletonLoader(context)
                      : _error != null
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red[400],
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () => _fetchCourses(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.getPrimaryColor(
                                        context,
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : _courses.isEmpty
                      ? SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _EmptyState(
                              key: ValueKey<int>(_selectedTab),
                              icon: HugeIcons.strokeRoundedBook01,
                              message: _selectedTab == 0
                                  ? context.l10n.noOngoingCourses
                                  : context.l10n.noCompletedCourses,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          key: ValueKey<int>(_selectedTab),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _courses.length + (_hasMore ? 1 : 0),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == _courses.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final course = _courses[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _EnrolledCourseCard(course: course),
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: AppTheme.getSoftGray150(context),
            highlightColor: AppTheme.getBackgroundColor(context),
            child: Container(
              height: 120, // Approximate height of course card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnrolledCourseCard extends StatelessWidget {
  const _EnrolledCourseCard({required this.course});

  final Map<String, dynamic> course;

  @override
  Widget build(BuildContext context) {
    final String title = course['title']?.toString() ?? 'Untitled Course';
    final double progress = _parseDouble(course['progress']);
    final int lessonsCompleted = _parseInt(course['lessonsCompleted']);
    final int totalLessons = _parseInt(course['totalLessons']);
    final String duration = course['duration']?.toString() ?? 'N/A';
    final String? imageThumb = course['imageAsset'];

    ImageProvider imageProvider;
    if (imageThumb != null && imageThumb.startsWith('http')) {
      imageProvider = NetworkImage(imageThumb);
    } else if (imageThumb != null && imageThumb.isNotEmpty) {
      if (!imageThumb.startsWith('assets/')) {
        imageProvider = NetworkImage(
          '${BaseService.baseUrl}/storage/$imageThumb'.replaceAll(
            '/api/storage',
            '/storage',
          ),
        );
      } else {
        imageProvider = AssetImage(imageThumb);
      }
    } else {
      imageProvider = const AssetImage('assets/img/courses/course1.jpg');
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseAccessScreen(
              courseId: _parseInt(course['id']),
              courseTitle: title,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppTheme.mint200,
              ),
              clipBehavior: Clip.antiAlias,
              child: imageThumb == null || imageThumb.startsWith('assets/')
                  ? Image(image: imageProvider, fit: BoxFit.cover)
                  : FadeInImage(
                      placeholder: const AssetImage('assets/img/loader.gif'),
                      image: imageProvider,
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/img/courses/course1.jpg',
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
            const SizedBox(width: 14),
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
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Text(
                        '$totalLessons ${context.l10n.lessons}',
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        duration,
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
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppTheme.getSoftGray150(context),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$lessonsCompleted/$totalLessons',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key, required this.icon, required this.message});

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

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
