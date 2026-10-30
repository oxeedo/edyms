import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

import '../../models/course.dart';
import '../../services/course_service.dart';

import '../courses/courses_skeletons.dart';
import '../../widgets/course_card.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final int categoryId;
  final String categoryName;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final CourseService _courseService = CourseService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Course> _courses = [];
  bool _isLoading = true;
  bool _isMoreLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _error;
  bool _isSearchExpanded = false;

  // Search query state
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isMoreLoading &&
        _hasMore) {
      _loadMoreCourses();
    }
  }

  void _onSearchChanged() {
    // Simple debounce logic
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
          _resetAndFetch();
        });
      }
    });
  }

  Future<void> _resetAndFetch() async {
    setState(() {
      _currentPage = 1;
      _courses.clear();
      _isLoading = true;
      _hasMore = true;
      _error = null;
    });
    await _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      // API call with category filter
      final response = await _courseService.fetchCourses(
        page: _currentPage,
        search: _searchQuery,
        categoryIds: [widget.categoryId],
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> courseList = data['data'];
        final List<Course> newCourses = courseList
            .map((json) => Course.fromJson(json))
            .toList();

        setState(() {
          if (_currentPage == 1) {
            _courses = newCourses;
          } else {
            _courses.addAll(newCourses);
          }
          _isLoading = false;
          _isMoreLoading = false;

          if (data['next_page_url'] == null) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _error = 'Failed to load courses';
          _isLoading = false;
          _isMoreLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isMoreLoading = false;
      });
    }
  }

  Future<void> _loadMoreCourses() async {
    if (_isMoreLoading || !_hasMore) return;
    setState(() {
      _isMoreLoading = true;
      _currentPage++;
    });
    await _fetchCourses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 12),
            // App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isSearchExpanded
                          ? SizedBox(
                              key: const ValueKey('search'),
                              height:
                                  40, // Increased height for better touch target
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: '${context.l10n.search}...',
                                  hintStyle: TextStyle(
                                    color: AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            )
                          : Text(
                              widget.categoryName,
                              key: const ValueKey('title'),
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: HugeIcon(
                        icon: _isSearchExpanded
                            ? HugeIcons.strokeRoundedCancel01
                            : HugeIcons.strokeRoundedSearch01,
                        size: 20,
                        color: AppTheme.getTextColor(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                          if (!_isSearchExpanded) {
                            _searchController.clear();
                            // Reset search only if it wasn't empty
                            if (_searchQuery.isNotEmpty) {
                              _searchQuery = '';
                              _resetAndFetch();
                            }
                          }
                        });
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Courses Grid
            Expanded(
              child: _isLoading && _courses.isEmpty
                  ? const CoursesSkeleton()
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _error!,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchCourses,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : _courses.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.noCoursesFound,
                        style: TextStyle(color: AppTheme.getTextColor(context)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _resetAndFetch,
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            sliver: SliverGrid.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 0.60,
                                  ),
                              itemCount: _courses.length,
                              itemBuilder: (BuildContext context, int index) {
                                final course = _courses[index];
                                return CourseCard(course: course);
                              },
                            ),
                          ),
                          if (_isMoreLoading)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: CircularProgressIndicator(),
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
