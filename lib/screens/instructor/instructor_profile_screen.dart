import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/instructor_service.dart';
import '../../models/instructor.dart';
import '../../config/config.dart';
import '../course_detail/course_detail_screen.dart';
import '../../router/app_router.dart';

class InstructorProfileScreen extends StatefulWidget {
  const InstructorProfileScreen({super.key, required this.instructorId});

  final int instructorId;

  @override
  State<InstructorProfileScreen> createState() =>
      _InstructorProfileScreenState();
}

class _InstructorProfileScreenState extends State<InstructorProfileScreen> {
  final InstructorService _instructorService = InstructorService();
  Instructor? _instructor;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInstructorDetails();
  }

  Future<void> _fetchInstructorDetails() async {
    try {
      final response = await _instructorService.fetchInstructorDetails(
        widget.instructorId,
      );
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          if (mounted) {
            setState(() {
              _instructor = Instructor.fromJson(jsonResponse['data']);
              _isLoading = false;
            });
          }
        } else {
          _handleError('Failed to load instructor data');
        }
      } else {
        _handleError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _handleError('Connection error: $e');
    }
  }

  void _handleError(String message) {
    if (mounted) {
      setState(() {
        _error = message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorState()
          : _buildMainContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(_error ?? 'Something went wrong'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _fetchInstructorDetails();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_instructor == null) return const SizedBox.shrink();

    return CustomScrollView(
      slivers: <Widget>[
        // App Bar
        SliverAppBar(
          backgroundColor: AppTheme.getBackgroundColor(context),
          elevation: 0,
          pinned: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          leading: IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 22,
              color: AppTheme.getTextColor(context),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 8),
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      // Avatar
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.getMint100(context),
                          image: _instructor!.image != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    AppConfig.getImageUrl(_instructor!.image!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _instructor!.image == null
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: AppTheme.primary,
                              )
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Name
                      Text(
                        _instructor!.name,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        _instructor!.professionalTitle ?? 'Instructor',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Rating Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: List<Widget>.generate(
                              5,
                              (int index) => Padding(
                                padding: const EdgeInsets.only(right: 2),
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color:
                                      index <
                                          (_instructor!.averageRating ?? 0)
                                              .floor()
                                      ? Colors.amber
                                      : Colors.grey.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _instructor!.averageRating?.toStringAsFixed(1) ?? '0.0',
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${_instructor!.reviewsCount ?? 0} reviews)',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          _StatItem(
                            value: '${_instructor!.coursesCount ?? 0}',
                            label: 'Courses',
                            icon: HugeIcons.strokeRoundedBook01,
                          ),
                          _StatItem(
                            value: '${_instructor!.studentsCount ?? 0}',
                            label: 'Students',
                            icon: HugeIcons.strokeRoundedAiUser,
                          ),
                          _StatItem(
                            value: '${_instructor!.reviewsCount ?? 0}',
                            label: 'Rating',
                            icon: HugeIcons.strokeRoundedStar,
                          ),
                          _StatItem(
                            value:
                                _instructor!.averageRating?.toStringAsFixed(1) ?? '0.0',
                            label: 'Avg Reviews',
                            icon: HugeIcons.strokeRoundedStar,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Message Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              AppRouter.chatScreen,
                              arguments: {
                                'instructorId': _instructor!.id,
                                'instructorName': _instructor!.name,
                              },
                            );
                          },
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedBubbleChat,
                            size: 18,
                            color: Colors.white,
                          ),
                          label: const Text('Send Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Social Links
                if (_instructor!.socialLinks != null &&
                    _instructor!.socialLinks!.values.any((v) => v != null)) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_instructor!.socialLinks!['facebook'] != null)
                        _SocialIcon(icon: HugeIcons.strokeRoundedFacebook01),
                      if (_instructor!.socialLinks!['twitter'] != null)
                        _SocialIcon(icon: HugeIcons.strokeRoundedTwitter),
                      if (_instructor!.socialLinks!['linkedin'] != null)
                        _SocialIcon(icon: HugeIcons.strokeRoundedLinkedin01),
                      if (_instructor!.socialLinks!['youtube'] != null)
                        _SocialIcon(icon: HugeIcons.strokeRoundedYoutube),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
                // About Section
                Text(
                  'About',
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _instructor!.bio ?? 'No bio available.',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context).withValues(alpha: 0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Courses Section
                if (_instructor!.courses != null &&
                    _instructor!.courses!.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Courses',
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _instructor!.courses!.length,
                    itemBuilder: (BuildContext context, int index) {
                      final course = _instructor!.courses![index];
                      return _CourseCard(course: course);
                    },
                  ),
                  const SizedBox(height: 32),
                ],
                // Reviews Section
                if (_instructor!.latestReviews != null &&
                    _instructor!.latestReviews!.isNotEmpty) ...[
                  Text(
                    'Reviews',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._instructor!.latestReviews!.map((review) {
                    return _ReviewCard(review: review);
                  }),
                  const SizedBox(height: 32),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final dynamic icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.getMint100(context),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(
              icon: icon,
              size: 20,
              color: AppTheme.getTextColor(context),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final dynamic icon;
  const _SocialIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.getMint100(context),
        shape: BoxShape.circle,
      ),
      child: HugeIcon(
        icon: icon,
        size: 20,
        color: AppTheme.getTextColor(context),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final user = review['user'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
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
                  shape: BoxShape.circle,
                  color: AppTheme.getMint100(context),
                  image: user != null && user['profile_photo'] != null
                      ? DecorationImage(
                          image: NetworkImage(
                            AppConfig.getImageUrl(user['profile_photo']),
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user == null || user['profile_photo'] == null
                    ? Center(
                        child: Icon(
                          Icons.person,
                          size: 20,
                          color: AppTheme.getTextColor(context),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user?['name'] ?? 'Anonymous',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        ...List<Widget>.generate(
                          5,
                          (int index) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: index < (review['rating'] as num).toInt()
                                  ? Colors.amber
                                  : AppTheme.getTextColor(
                                      context,
                                    ).withValues(alpha: 0.2),
                            ),
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
          Text(
            review['comment'] ?? '',
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final dynamic course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(courseId: course.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                AppConfig.getImageUrl(course.thumbnail ?? ''),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  color: AppTheme.getMint100(context),
                  child: Center(
                    child: Icon(
                      Icons.book,
                      color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    course.title ?? '',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${course.rating?.toStringAsFixed(1) ?? '0.0'}',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (course.discountedPrice != null &&
                          course.discountedPrice! < (course.price ?? 0))
                        Row(
                          children: [
                            Text(
                              settingsProvider.formatPrice(
                                course.discountedPrice,
                              ),
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              settingsProvider.formatPrice(course.price),
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.4),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          course.price != null && course.price! > 0
                              ? settingsProvider.formatPrice(course.price)
                              : 'Free',
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
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
