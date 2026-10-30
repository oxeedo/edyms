import 'package:flutter/material.dart';
import '../../models/bundle.dart';
import '../../theme/app_theme.dart';
import '../course_detail/course_detail_screen.dart';
import '../course_detail/checkout_screen.dart';
import '../../models/course.dart';
import '../../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class BundleDetailScreen extends StatelessWidget {
  final Bundle bundle;
  const BundleDetailScreen({super.key, required this.bundle});


  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final courses = bundle.courses ?? [];
    final totalStudents = courses.fold<int>(
      0,
      (sum, c) => sum + (c.studentsCount ?? 0),
    );

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // ── Hero Image with SliverAppBar ──
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.getCardColor(context),
            foregroundColor: AppTheme.getTextColor(context),
            flexibleSpace: FlexibleSpaceBar(
              background: bundle.image != null
                  ? Image.network(
                      bundle.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, st) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.layers_outlined, color: Colors.grey.shade400, size: 48),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: Icon(Icons.layers_outlined, color: Colors.grey.shade400, size: 48),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title + Price + Stats ──
                Container(
                  color: AppTheme.getCardColor(context),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course count badge
                      if (courses.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3C00).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${courses.length} Courses Included',
                            style: const TextStyle(
                              color: Color(0xFFFF3C00),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      // Title
                      Text(
                        bundle.title,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Price
                      Text(
                        settingsProvider.formatPrice(bundle.price),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'One-time payment · Lifetime access',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 16),
                      // Stats row
                      Row(
                        children: [
                          _statChip(Icons.book_outlined, '${courses.length} Courses'),
                          const SizedBox(width: 12),
                          _statChip(Icons.people_outline, '${totalStudents > 0 ? totalStudents : 0} Students'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── What's Included ──
                Container(
                  color: AppTheme.getCardColor(context),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What\'s Included',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _includedItem('Full lifetime access to all courses'),
                      _includedItem('Access on mobile and desktop'),
                      _includedItem('Certificate of completion'),
                      _includedItem('Download resources'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ── Description ──
                if (bundle.description != null && bundle.description!.trim().isNotEmpty)
                  Container(
                    color: AppTheme.getCardColor(context),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About this Bundle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          bundle.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getTextColor(context).withValues(alpha: 0.75),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // ── Courses in Bundle ──
                if (courses.isNotEmpty)
                  Container(
                    color: AppTheme.getCardColor(context),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Courses in this Bundle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...courses.asMap().entries.map((entry) {
                          final i = entry.key;
                          final course = entry.value;
                          return Column(
                            children: [
                              _CourseRow(course: course),
                              if (i < courses.length - 1)
                                Divider(height: 1, color: Colors.grey.shade200),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                // Bottom padding for FAB
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ── Enroll Button ──
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settingsProvider.formatPrice(bundle.price),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    Text(
                      '${courses.length} courses',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final dummyCourse = Course(
                      id: bundle.id,
                      title: bundle.title,
                      thumbnail: bundle.image,
                      price: bundle.price,
                      discountedPrice: bundle.price,
                      rating: 0.0,
                      studentsCount: totalStudents,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(course: dummyCourse, isBundle: true),
                      ),
                    );
                  },
                  child: const Text(
                    'Enroll in Bundle',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Builder(builder: (context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    ));
  }

  Widget _includedItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course;
  const _CourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CourseDetailScreen(courseId: course.id)),
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: course.thumbnail != null
                  ? Image.network(
                      course.thumbnail!,
                      width: 64,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, st) => _imgPlaceholder(),
                    )
                  : _imgPlaceholder(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                  if (course.instructorName != null && course.instructorName!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      course.instructorName!,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _imgPlaceholder() => Container(
        width: 64,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.play_circle_outline, color: Colors.grey.shade400, size: 24),
      );
}
