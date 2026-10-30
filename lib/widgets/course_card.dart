import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../theme/app_theme.dart';
import '../models/course.dart';
import '../l10n/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../screens/course_detail/course_detail_screen.dart';
import 'package:provider/provider.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, this.width, this.height});

  final Course course;
  final double? width;
  final double? height;

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
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(18),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Course Image
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    color: AppTheme.mint200,
                    child: course.thumbnail != null
                        ? Image.network(
                            course.thumbnail!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppTheme.getSoftGray150(context),
                                  child: const Center(child: Icon(Icons.error)),
                                ),
                          )
                        : Container(color: AppTheme.getSoftGray150(context)),
                  ),
                  // Bookmark icon
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedBookmark01,
                          size: 14,
                          color: AppTheme.getTextColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Course Details
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.title,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.instructor?.name ?? 'Instructor',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedPlay,
                          size: 11,
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${course.lessonsCount} ${context.l10n.lessons}',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Text('⭐', style: TextStyle(fontSize: 10)),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${(course.rating ?? 0.0).toStringAsFixed(1)} (${course.reviewsCount})',
                            style: TextStyle(
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.5),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        if (course.discountedPrice != null &&
                            course.discountedPrice! < (course.price ?? 0)) ...[
                          Text(
                            settingsProvider.formatPrice(
                              course.discountedPrice,
                            ),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 15,
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
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            settingsProvider.formatPrice(course.price),
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
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
