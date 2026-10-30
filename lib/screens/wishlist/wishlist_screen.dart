import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/course.dart';
import '../../providers/wishlist_provider.dart';
import '../course_detail/course_detail_screen.dart';
import '../../providers/settings_provider.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _sortBy = 'recent'; // 'recent', 'price', 'rating', 'name'

  List<Course> get _sortedCourses {
    final provider = context.read<WishlistProvider>();
    List<Course> items = List.from(provider.items);

    switch (_sortBy) {
      case 'price':
        items.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
        break;
      case 'rating':
        items.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case 'name':
        items.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'recent':
      default:
        // Assuming provider list is already in order or we don't have addedDate in Course model yet for sorting by added date locally unless we wrapper it.
        // For now, keep as is (insertion order usually).
        break;
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: Consumer<WishlistProvider>(
        builder: (context, provider, child) {
          final courses = _sortedCourses;
          final settingsProvider = Provider.of<SettingsProvider>(context);

          return Stack(
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
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // AppBar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.getCardColor(context),
                              padding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            context.l10n.wishlist,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (courses.isNotEmpty)
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            _SortOption(
                              title: 'Recently Added',
                              value: 'recent',
                              selectedValue: _sortBy,
                              onTap: () => setState(() => _sortBy = 'recent'),
                            ),
                            _SortOption(
                              title: 'Price: Low to High',
                              value: 'price',
                              selectedValue: _sortBy,
                              onTap: () => setState(() => _sortBy = 'price'),
                            ),
                            _SortOption(
                              title: 'Rating: High to Low',
                              value: 'rating',
                              selectedValue: _sortBy,
                              onTap: () => setState(() => _sortBy = 'rating'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: courses.isEmpty
                          ? _buildEmptyState(context)
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: courses.length,
                              itemBuilder: (context, index) {
                                final course = courses[index];
                                return _buildCourseItem(
                                  context,
                                  course,
                                  provider,
                                  settingsProvider,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCourseItem(
    BuildContext context,
    Course course,
    WishlistProvider provider,
    SettingsProvider settingsProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CourseDetailScreen(courseId: course.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: course.thumbnail != null
                          ? Image.network(
                              course.thumbnail!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                            ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              course.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => provider.toggleWishlist(course),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.red,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        course.instructor?.name ?? 'Instructor',
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (course.rating ?? 0).toStringAsFixed(1),
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${course.reviewsCount})',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          if (course.discountedPrice != null &&
                              course.discountedPrice! <
                                  (course.price ?? 0)) ...[
                            Text(
                              settingsProvider.formatPrice(
                                course.discountedPrice,
                              ),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              settingsProvider.formatPrice(course.price),
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.5),
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ] else
                            Text(
                              settingsProvider.formatPrice(course.price ?? 0),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const HugeIcon(
              icon: HugeIcons.strokeRoundedFavourite,
              size: 48,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your wishlist is empty',
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start adding courses to save them for later',
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Browse Courses'),
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

class _SortOption extends StatelessWidget {
  const _SortOption({
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  final String title;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedValue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getMint100(context)
              : AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                size: 24,
                color: AppTheme.getTextColor(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
