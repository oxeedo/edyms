import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/config.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/course_detail.dart';
import '../../services/course_service.dart';
import '../instructor/instructor_profile_screen.dart';
import 'checkout_screen.dart';
import 'course_detail_skeletons.dart';
import '../course_access/course_access_screen.dart';
import '../../widgets/course_card.dart';

class CourseDetailScreen extends StatefulWidget {
  final int courseId;
  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _selectedTab = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final Map<int, bool> _topicExpandedState = <int, bool>{};
  bool _isDescriptionExpanded = false;

  final CourseService _courseService = CourseService();
  CourseDetailData? _courseDetail;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchCourseDetail();
  }

  Future<void> _fetchCourseDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _courseService.fetchCourseDetail(widget.courseId);
      if (response.statusCode == 200) {
        final detailResponse = CourseDetailResponse.fromJson(
          jsonDecode(response.body),
        );
        setState(() {
          _courseDetail = detailResponse.data;
          _isLoading = false;
          // Initialize first topic as expanded
          if (_courseDetail!.course.topics != null &&
              _courseDetail!.course.topics!.isNotEmpty) {
            _topicExpandedState[0] = true;
          }
        });
      } else {
        setState(() {
          _error = 'Failed to load course details';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    final double threshold = 20.0;
    final bool shouldHide = _scrollController.offset > threshold;
    if (_isScrolled != shouldHide) {
      setState(() {
        _isScrolled = shouldHide;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showShareSheet(BuildContext context) async {
    if (_courseDetail == null) return;

    // Construct URL using base URL from config
    final String url = '${AppConfig.baseUrl}/courses/${widget.courseId}';

    await SharePlus.instance.share(
      ShareParams(
        text: 'Check out this course: ${_courseDetail!.course.title}\n$url',
      ),
    );
  }

  void _showVideoPreview(
    BuildContext context, {
    Lesson? lesson,
    String? lessonTitle,
    String? videoUrl,
    String? videoType,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => VideoPreviewSheet(
        lesson: lesson,
        lessonTitle: lessonTitle,
        videoUrl: videoUrl,
        videoType: videoType,
      ),
    );
  }

  List<Widget> _buildPlaylistItems(BuildContext context) {
    final List<Topic> topicsData = _courseDetail!.course.topics != null
        ? _courseDetail!.course.topics!.map((t) => Topic.fromJson(t)).toList()
        : [];

    final List<Widget> items = <Widget>[];
    for (int topicIndex = 0; topicIndex < topicsData.length; topicIndex++) {
      final Topic topic = topicsData[topicIndex];
      final List<Lesson> lessons = topic.lessons;
      final List<Quiz> quizzes = topic.quizzes;
      final List<Assignment> assignments = topic.assignments;

      // Topic header with expand/collapse
      final bool isExpanded = _topicExpandedState[topicIndex] ?? false;
      items.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.getSoftGray150(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _topicExpandedState[topicIndex] = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      topic.title,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowDown01,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Lessons under this topic (collapsible with animation)
      items.add(
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: AppTheme.getSoftGray150(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: <Widget>[
                      for (int i = 0; i < lessons.length; i++) ...[
                        _PlaylistItem(
                          number: i + 1,
                          title: lessons[i].title,
                          duration: '${lessons[i].duration ?? 0} mins',
                          type: 'video',
                          isUnlocked:
                              lessons[i].isPreview || _courseDetail!.isEnrolled,
                          isPreview: lessons[i].isPreview,
                          onTap:
                              (lessons[i].isPreview ||
                                  _courseDetail!.isEnrolled)
                              ? () {
                                  if (lessons[i].isPreview &&
                                      !_courseDetail!.isEnrolled) {
                                    _showVideoPreview(
                                      context,
                                      lesson: lessons[i],
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CourseAccessScreen(
                                              courseId: widget.courseId,
                                              courseTitle:
                                                  _courseDetail!.course.title,
                                            ),
                                      ),
                                    );
                                  }
                                }
                              : null,
                        ),
                        if (i < lessons.length - 1 ||
                            quizzes.isNotEmpty ||
                            assignments.isNotEmpty)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.primary.withValues(alpha: 0.1),
                          ),
                      ],
                      for (int i = 0; i < quizzes.length; i++) ...[
                        _PlaylistItem(
                          number: lessons.length + i + 1,
                          title: quizzes[i].title,
                          duration: '${quizzes[i].timeLimit ?? 0} mins',
                          type: 'quiz',
                          isUnlocked: _courseDetail!.isEnrolled,
                          onTap: _courseDetail!.isEnrolled
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseAccessScreen(
                                        courseId: widget.courseId,
                                        courseTitle:
                                            _courseDetail!.course.title,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        if (i < quizzes.length - 1 || assignments.isNotEmpty)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.primary.withValues(alpha: 0.1),
                          ),
                      ],
                      for (int i = 0; i < assignments.length; i++) ...[
                        _PlaylistItem(
                          number: lessons.length + quizzes.length + i + 1,
                          title: assignments[i].title,
                          duration: '${assignments[i].filesCount} files',
                          type: 'assignment',
                          isUnlocked: _courseDetail!.isEnrolled,
                          onTap: _courseDetail!.isEnrolled
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CourseAccessScreen(
                                        courseId: widget.courseId,
                                        courseTitle:
                                            _courseDetail!.course.title,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        ),
                        if (i < assignments.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: AppTheme.primary.withValues(alpha: 0.1),
                          ),
                      ],
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      );

      // Add spacing between topics
      if (topicIndex < topicsData.length - 1) {
        items.add(const SizedBox(height: 4));
      }
    }
    return items;
  }

  List<Widget> _buildReviewItems(BuildContext context) {
    final List<CourseReview> reviewsData = _courseDetail!.course.reviews ?? [];

    // Calculate rating distribution
    final Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviewsData) {
      if (ratingCounts.containsKey(review.rating)) {
        ratingCounts[review.rating] = ratingCounts[review.rating]! + 1;
      }
    }

    final int totalReviews = reviewsData.length;
    final double averageRating = _courseDetail!.averageRating;

    final List<Widget> items = <Widget>[
      // Review Stats Section
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                // Average Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List<Widget>.generate(
                        5,
                        (int index) => Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedStar,
                            size: 16,
                            color: index < averageRating.round()
                                ? Colors.amber
                                : AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews ${context.l10n.reviews}',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                // Rating Distribution
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (int i = 5; i >= 1; i--) ...[
                        Row(
                          children: <Widget>[
                            Text(
                              '$i',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedStar,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: totalReviews == 0
                                      ? 0
                                      : ratingCounts[i]! / totalReviews,
                                  backgroundColor: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.amber,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${ratingCounts[i]}',
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
                        if (i > 1) const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
    ];

    for (int i = 0; i < reviewsData.length; i++) {
      items.add(
        _ReviewItem(
          userName: reviewsData[i].user.name,
          rating: reviewsData[i].rating,
          comment: reviewsData[i].comment ?? '',
          date: reviewsData[i].createdAt,
          avatar: reviewsData[i].user.name.substring(0, 1).toUpperCase(),
        ),
      );
      if (i < reviewsData.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: AppTheme.primary.withValues(alpha: 0),
          ),
        );
      }
    }
    return items;
  }

  Widget _buildInstructorCard(BuildContext context) {
    final instructor = _courseDetail!.course.instructor;
    if (instructor == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.getSoftGray150(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.l10n.instructor,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Instructor Avatar
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: instructor.image != null
                      ? Image.network(
                          instructor.image!,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/img/default-profile.png',
                                fit: BoxFit.cover,
                              ),
                        )
                      : Image.asset(
                          'assets/img/default-profile.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 16),
              // Instructor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      instructor.name,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      instructor.professionalTitle ?? 'Instructor',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedStar,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          instructor.averageRating?.toStringAsFixed(1) ?? '0.0',
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBook01,
                          size: 16,
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${instructor.coursesCount ?? 0} ${context.l10n.courses}',
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.7),
                            fontSize: 14,
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
          const SizedBox(height: 12),
          if (instructor.bio != null)
            Text(
              instructor.bio!,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      InstructorProfileScreen(instructorId: instructor.id),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              context.l10n.viewProfile,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedCourses(BuildContext context) {
    final relatedCourses = _courseDetail!.relatedCourses;
    if (relatedCourses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Related Courses',
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 270,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: relatedCourses.length,
            itemBuilder: (context, index) {
              final course = relatedCourses[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: CourseCard(course: course, width: 220),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: const CourseDetailSkeletons(),
      );
    }

    if (_error != null || _courseDetail == null) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'An unknown error occurred'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchCourseDetail,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final course = _courseDetail!.course;
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
                // App Bar - hidden when scrolled
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: _isScrolled ? 0 : 64,
                  child: ClipRect(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isScrolled ? 0.0 : 1.0,
                      child: Padding(
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
                                context.l10n.courseDetails,
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
                                icon: HugeIcons.strokeRoundedShare01,
                                size: 20,
                                color: AppTheme.getTextColor(context),
                              ),
                              onPressed: () => _showShareSheet(context),
                              padding: EdgeInsets.zero,
                            ),
                            Consumer<WishlistProvider>(
                              builder: (context, wishlistProvider, child) {
                                final isWishlisted = wishlistProvider
                                    .isInWishlist(course.id);
                                return IconButton(
                                  icon: Icon(
                                    isWishlisted
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    size: 20,
                                    color: isWishlisted
                                        ? Colors.red
                                        : AppTheme.getTextColor(context),
                                  ),
                                  onPressed: () {
                                    wishlistProvider.toggleWishlist(course);
                                  },
                                  padding: EdgeInsets.zero,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Single unified card containing everything
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 0),
                          decoration: BoxDecoration(
                            color: AppTheme.getBackgroundColor(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Course Image
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: SizedBox(
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: course.thumbnail != null
                                              ? Image.network(
                                                  course.thumbnail!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Container(
                                                        color: Colors.grey[300],
                                                      ),
                                                )
                                              : Container(
                                                  color: Colors.grey[300],
                                                ),
                                        ),
                                      ),
                                      if (course.introVideo != null)
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              _showVideoPreview(
                                                context,
                                                lessonTitle: "Intro Video",
                                                videoUrl: course.introVideoUrl,
                                                videoType:
                                                    "hosted", // Default for intro video
                                              );
                                            },
                                            child: Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(
                                                  alpha: 0.5,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        ),

                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Row(
                                          children: [
                                            if (course.language != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedGlobe,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      course.language!,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            if (course.difficulty != null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.6),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedSorting01,
                                                      size: 12,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      course.difficulty!
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        letterSpacing: 0.5,
                                                      ),
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
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  12,
                                  20,
                                  20,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Course Title
                                    Text(
                                      course.title,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Rating and Students Count in same row
                                    Row(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: AppTheme.softOrange800,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedStar,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${_courseDetail!.averageRating} (${_courseDetail!.totalReviews} ${context.l10n.reviews})',
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ).withValues(alpha: 0.7),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Row(
                                          children: <Widget>[
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: HugeIcon(
                                                  icon: HugeIcons
                                                      .strokeRoundedAiUser,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${course.studentsCount ?? 0} ${context.l10n.students}',
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ).withValues(alpha: 0.7),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    // About This Course Section
                                    Text(
                                      context.l10n.aboutThisCourse,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          AnimatedSize(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            alignment: Alignment.topCenter,
                                            curve: Curves.easeInOut,
                                            child: Container(
                                              clipBehavior: Clip.hardEdge,
                                              decoration: const BoxDecoration(),
                                              constraints:
                                                  _isDescriptionExpanded
                                                  ? const BoxConstraints()
                                                  : const BoxConstraints(
                                                      maxHeight: 100,
                                                    ),
                                              child: ShaderMask(
                                                shaderCallback: (rect) {
                                                  if (_isDescriptionExpanded) {
                                                    return const LinearGradient(
                                                      colors: [
                                                        Colors.black,
                                                        Colors.black,
                                                      ],
                                                    ).createShader(rect);
                                                  }
                                                  return const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.black,
                                                      Colors.transparent,
                                                    ],
                                                    stops: [0.5, 1.0],
                                                  ).createShader(rect);
                                                },
                                                blendMode: BlendMode.dstIn,
                                                child: SingleChildScrollView(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  child: HtmlWidget(
                                                    course.description ??
                                                        'No description available.',
                                                    textStyle: TextStyle(
                                                      color:
                                                          AppTheme.getTextColor(
                                                            context,
                                                          ).withValues(
                                                            alpha: 0.7,
                                                          ),
                                                      fontSize: 14,
                                                      height: 1.5,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _isDescriptionExpanded =
                                                    !_isDescriptionExpanded;
                                              });
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    _isDescriptionExpanded
                                                        ? 'View Less'
                                                        : 'View More',
                                                    style: TextStyle(
                                                      color: AppTheme.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    _isDescriptionExpanded
                                                        ? Icons
                                                              .keyboard_arrow_up_rounded
                                                        : Icons
                                                              .keyboard_arrow_down_rounded,
                                                    color: AppTheme.primary,
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (course.objectives != null &&
                                              course
                                                  .objectives!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 24),
                                            Text(
                                              "What you'll learn in this course?",
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            HtmlWidget(
                                              course.objectives!,
                                              textStyle: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ).withValues(alpha: 0.7),
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                          if (course.requirements != null &&
                                              course
                                                  .requirements!
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 24),
                                            Text(
                                              "Requirements",
                                              style: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            HtmlWidget(
                                              course.requirements!,
                                              textStyle: TextStyle(
                                                color: AppTheme.getTextColor(
                                                  context,
                                                ).withValues(alpha: 0.7),
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // Tabs with sliding background
                                    _SlidingTabBar(
                                      selectedIndex: _selectedTab,
                                      lessonCount: course.topics?.length ?? 0,
                                      onTabChanged: (int index) {
                                        setState(() {
                                          _selectedTab = index;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    // Playlist Content
                                    if (_selectedTab == 0) ...[
                                      Column(
                                        children: _buildPlaylistItems(context),
                                      ),
                                      const SizedBox(height: 20),
                                      // Instructor Card
                                      _buildInstructorCard(context),
                                    ],
                                    // Review Content
                                    if (_selectedTab == 1) ...[
                                      Column(
                                        children: _buildReviewItems(context),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildRelatedCourses(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom fixed bar with price and enroll button
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
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A5F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            settingsProvider.formatPrice(
                              course.discountedPrice ?? course.price ?? 0.0,
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CheckoutScreen(course: course),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          context.l10n.enrollCourse,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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

class _SlidingTabBar extends StatelessWidget {
  const _SlidingTabBar({
    required this.selectedIndex,
    required this.lessonCount,
    required this.onTabChanged,
  });

  final int selectedIndex;
  final int lessonCount;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double tabWidth = constraints.maxWidth / 2;
        return Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: <Widget>[
              // Sliding background indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: selectedIndex == 0 ? 0 : tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  width: tabWidth,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // Tab buttons
              Row(
                children: <Widget>[
                  Expanded(
                    child: InkWell(
                      onTap: () => onTabChanged(0),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              context.l10n.curriculums,
                              style: TextStyle(
                                color: selectedIndex == 0
                                    ? Colors.white
                                    : AppTheme.getTextColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: selectedIndex == 0
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$lessonCount',
                                style: TextStyle(
                                  color: selectedIndex == 0
                                      ? Colors.white
                                      : AppTheme.getTextColor(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => onTabChanged(1),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              context.l10n.review,
                              style: TextStyle(
                                color: selectedIndex == 1
                                    ? Colors.white
                                    : AppTheme.getTextColor(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedStar,
                              size: 14,
                              color: selectedIndex == 1
                                  ? Colors.white
                                  : AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PlaylistItem extends StatelessWidget {
  const _PlaylistItem({
    required this.number,
    required this.title,
    required this.duration,
    required this.type,
    required this.isUnlocked,
    this.isPreview = false,
    this.onTap,
  });

  final int number;
  final String title;
  final String duration;
  final String type; // 'video', 'quiz', 'assignment'
  final bool isUnlocked;
  final bool isPreview;
  final VoidCallback? onTap;

  dynamic _getTypeIcon() {
    switch (type) {
      case 'video':
        return HugeIcons.strokeRoundedAiVideo;
      case 'quiz':
        return HugeIcons.strokeRoundedBulb;
      case 'assignment':
        return HugeIcons.strokeRoundedAssignments;
      default:
        return HugeIcons.strokeRoundedAiVideo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUnlocked ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: <Widget>[
            // Type icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: HugeIcon(
                  icon: _getTypeIcon(),
                  size: 16,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Title and duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                      color: isUnlocked
                          ? AppTheme.getTextColor(context)
                          : AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isPreview) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.mint100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Preview',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Play or lock icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isUnlocked
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedPlay,
                        size: 16,
                        color: AppTheme.getTextColor(context),
                      )
                    : HugeIcon(
                        icon: HugeIcons.strokeRoundedAiLock,
                        size: 16,
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.avatar,
  });

  final String userName;
  final int rating;
  final String comment;
  final String date;
  final String avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSoftGray150(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // User name and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      userName,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Rating stars
              Row(
                children: List<Widget>.generate(
                  5,
                  (int index) => Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedStar,
                      size: 16,
                      color: index < rating
                          ? Colors.amber
                          : AppTheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Comment
          Text(
            comment,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPreviewSheet extends StatelessWidget {
  final Lesson? lesson;
  final String? lessonTitle;
  final String? videoUrl;
  final String? videoType;

  const VideoPreviewSheet({
    super.key,
    this.lesson,
    this.lessonTitle,
    this.videoUrl,
    this.videoType,
  });

  @override
  Widget build(BuildContext context) {
    final title = lesson?.title ?? lessonTitle ?? 'Video Preview';
    String? rawUrl = lesson?.videoUrl ?? lesson?.videoPath ?? videoUrl;
    final type = lesson?.videoType ?? videoType ?? 'hosted';

    String? url = rawUrl;
    if (url != null && !url.startsWith('http')) {
      url = '${AppConfig.baseUrl}/storage/$url';
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: url != null && url.isNotEmpty
                ? Center(
                    child: VideoPreviewPlayer(url: url, type: type),
                  )
                : const Center(
                    child: Text(
                      'No video URL available',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class VideoPreviewPlayer extends StatefulWidget {
  final String url;
  final String type;

  const VideoPreviewPlayer({super.key, required this.url, required this.type});

  @override
  State<VideoPreviewPlayer> createState() => _VideoPreviewPlayerState();
}

class _VideoPreviewPlayerState extends State<VideoPreviewPlayer> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVimeo = false;
  String? _vimeoId;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final lowerUrl = widget.url.toLowerCase();
    if (widget.type == 'youtube' ||
        lowerUrl.contains('youtube.com') ||
        lowerUrl.contains('youtu.be')) {
      final videoId = YoutubePlayer.convertUrlToId(widget.url);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
        );
      }
    } else if (widget.type == 'vimeo' || lowerUrl.contains('vimeo.com')) {
      _isVimeo = true;
      try {
        final uri = Uri.parse(widget.url);
        _vimeoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      } catch (e) {
        // Handle error
      }
      setState(() {});
    } else {
      try {
        final uri = Uri.parse(widget.url);
        _videoController = VideoPlayerController.networkUrl(uri);
        _videoController!
            .initialize()
            .then((_) {
              if (mounted) {
                _chewieController = ChewieController(
                  videoPlayerController: _videoController!,
                  autoPlay: true,
                  looping: false,
                  aspectRatio: _videoController!.value.aspectRatio,
                  deviceOrientationsOnEnterFullScreen: const [
                    DeviceOrientation.landscapeLeft,
                    DeviceOrientation.landscapeRight,
                  ],
                  deviceOrientationsAfterFullScreen: const [
                    DeviceOrientation.portraitUp,
                  ],
                  systemOverlaysOnEnterFullScreen: const [],
                  systemOverlaysAfterFullScreen: SystemUiOverlay.values,
                  autoInitialize: true,
                  placeholder: Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  ),
                  errorBuilder: (context, errorMessage) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.white,
                            size: 42,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                );
                setState(() {});
              }
            })
            .catchError((error) {
              if (mounted) {
                setState(() {});
              }
            });
      } catch (e) {
        // Silent catch or handle error state
      }
    }
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubeController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubeController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.primary,
          onReady: () {
            _youtubeController?.play();
          },
        ),
        builder: (context, player) {
          return player;
        },
      );
    } else if (_isVimeo && _vimeoId != null) {
      return VimeoVideoPlayer(videoId: _vimeoId!);
    } else if (_chewieController != null &&
        _chewieController!.videoPlayerController.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else if (_videoController != null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    } else {
      return const Center(
        child: Text(
          'Video format not supported',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
