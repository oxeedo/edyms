import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/category.dart';
import '../../models/course.dart';
import '../course_detail/course_detail_screen.dart';

import 'package:provider/provider.dart';
import '../../providers/ai_suggestions_provider.dart';
import '../../providers/settings_provider.dart';

class AiSuggestionsScreen extends StatefulWidget {
  const AiSuggestionsScreen({super.key});

  @override
  State<AiSuggestionsScreen> createState() => _AiSuggestionsScreenState();
}

class _AiSuggestionsScreenState extends State<AiSuggestionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _processingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  final List<String> _skillLevels = <String>[
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> _goals = <String>[
    'Career Change',
    'Skill Enhancement',
    'Personal Interest',
    'Certification',
    'Freelancing',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch categories on init if not already loaded (or refreshes)
    // Using simple Future.microtask to avoid build conflicts
    Future.microtask(() {
      if (!mounted) return;
      Provider.of<AiSuggestionsProvider>(
        context,
        listen: false,
      ).fetchCategories();
    });

    _processingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _processingController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _processingController, curve: Curves.linear),
    );
    _processingController.repeat();
  }

  @override
  void dispose() {
    _processingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Consumer<AiSuggestionsProvider>(
          builder: (context, provider, child) {
            return Column(
              children: <Widget>[
                // Header
                _AiSuggestionsHeader(
                  hasPreferences: provider.hasPreferences,
                  onUpdatePreferences: provider.updatePreferences,
                ),
                // Content
                Expanded(
                  child: provider.isProcessing
                      ? _ProcessingAnimation(
                          pulseAnimation: _pulseAnimation,
                          rotationAnimation: _rotationAnimation,
                        )
                      : provider.hasPreferences
                      ? _SuggestionsContent(courses: provider.suggestedCourses)
                      : _PreferencesForm(
                          interests: provider.interests,
                          isLoading: provider.isLoadingCategories,
                          error: provider.categoryError,
                          selectedCategoryIds: provider.selectedCategoryIds,
                          skillLevels: _skillLevels,
                          selectedSkillLevel: provider.selectedSkillLevel,
                          goals: _goals,
                          selectedGoal: provider.selectedGoal,
                          onInterestToggle: provider.toggleInterest,
                          onSkillLevelSelect: provider.setSkillLevel,
                          onGoalSelect: provider.setGoal,
                          onGetSuggestions: provider.getSuggestions,
                          canGetSuggestions: provider.canGetSuggestions,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.offset, required this.animation});

  final double offset;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        double value = (animation.value + offset) % 1.0;
        final double opacity = value < 0.5
            ? 0.3 + (value * 1.4)
            : 1.0 - ((value - 0.5) * 1.4);
        return Opacity(
          opacity: opacity.clamp(0.3, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _ProcessingAnimation extends StatelessWidget {
  const _ProcessingAnimation({
    required this.pulseAnimation,
    required this.rotationAnimation,
  });

  final Animation<double> pulseAnimation;
  final Animation<double> rotationAnimation;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (BuildContext context, Widget? child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: rotationAnimation,
                      builder: (BuildContext context, Widget? child) {
                        return Transform.rotate(
                          angle: rotationAnimation.value * 2 * 3.14159,
                          child: Icon(
                            Icons.auto_awesome,
                            size: 60,
                            color: AppTheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            'Analyzing your preferences...',
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Finding perfect courses for you',
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.getTextColor(
                  context,
                ).withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Pulsing dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _PulsingDot(offset: 0.0, animation: rotationAnimation),
              const SizedBox(width: 8),
              _PulsingDot(offset: 0.33, animation: rotationAnimation),
              const SizedBox(width: 8),
              _PulsingDot(offset: 0.66, animation: rotationAnimation),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiSuggestionsHeader extends StatelessWidget {
  const _AiSuggestionsHeader({
    required this.hasPreferences,
    required this.onUpdatePreferences,
  });

  final bool hasPreferences;
  final VoidCallback onUpdatePreferences;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(color: AppTheme.getBackgroundColor(context)),
      child: Row(
        children: <Widget>[
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 20,
              color: AppTheme.getTextColor(context),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Text(
              context.l10n.aiSuggestions,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Update Preferences Button
          if (hasPreferences)
            GestureDetector(
              onTap: onUpdatePreferences,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.tune,
                      size: 16,
                      color: AppTheme.getTextColor(context),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PreferencesForm extends StatelessWidget {
  const _PreferencesForm({
    required this.interests,
    required this.isLoading,
    this.error,
    required this.selectedCategoryIds,
    required this.skillLevels,
    required this.selectedSkillLevel,
    required this.goals,
    required this.selectedGoal,
    required this.onInterestToggle,
    required this.onSkillLevelSelect,
    required this.onGoalSelect,
    required this.onGetSuggestions,
    required this.canGetSuggestions,
  });

  final List<Category> interests;
  final bool isLoading;
  final String? error;
  final Set<int> selectedCategoryIds;
  final List<String> skillLevels;
  final String? selectedSkillLevel;
  final List<String> goals;
  final String? selectedGoal;
  final ValueChanged<int> onInterestToggle;
  final ValueChanged<String> onSkillLevelSelect;
  final ValueChanged<String> onGoalSelect;
  final VoidCallback onGetSuggestions;
  final bool canGetSuggestions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24),
          // Title
          Text(
            context.l10n.tellUsAboutYourself,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 32),
          // Interests Section
          Text(
            context.l10n.whatAreYourInterests,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: interests.map((Category category) {
                final bool isSelected = selectedCategoryIds.contains(
                  category.id,
                );
                return GestureDetector(
                  onTap: () => onInterestToggle(category.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
          // Skill Level Section
          Text(
            context.l10n.whatIsYourSkillLevel,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: skillLevels.map((String level) {
              final bool isSelected = selectedSkillLevel == level;
              return GestureDetector(
                onTap: () => onSkillLevelSelect(level),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.getTextColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Goals Section
          Text(
            context.l10n.whatAreYourGoals,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: goals.map((String goal) {
              final bool isSelected = selectedGoal == goal;
              return GestureDetector(
                onTap: () => onGoalSelect(goal),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.getTextColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        goal,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.getTextColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Get Suggestions Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canGetSuggestions ? onGetSuggestions : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(Icons.auto_awesome, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.getPersonalizedCourses,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }
}

class _SuggestionsContent extends StatelessWidget {
  const _SuggestionsContent({required this.courses});

  final List<Course> courses;

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Center(
        child: Text(
          'No courses found matching your preferences.',
          style: TextStyle(color: AppTheme.getTextColor(context)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.auto_awesome, color: AppTheme.primary, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.recommendedForYou,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.basedOnYourPreferences,
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.length,
            itemBuilder: (BuildContext context, int index) {
              final Course course = courses[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AiSuggestedCourseCard(course: course),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AiSuggestedCourseCard extends StatelessWidget {
  const _AiSuggestedCourseCard({required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Determine image logic: use thumbnail if available, otherwise asset placeholder
    final bool hasThumbnail =
        course.thumbnail != null && course.thumbnail!.isNotEmpty;

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
          color: AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Course Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.mint200,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      hasThumbnail
                          ? Image.network(
                              course.thumbnail!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: Colors.grey[300]);
                              },
                            )
                          : Container(
                              color: Colors.grey[300],
                            ), // TODO: Placeholder
                      // AI Badge
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.auto_awesome,
                                size: 10,
                                color: Colors.white,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'AI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 4),
                      Text(
                        course.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.1,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Rating & Reviews
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (course.rating ?? 0.0).toStringAsFixed(1),
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${course.reviewsCount} ${context.l10n.reviews})',
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
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          // Lessons
                          Row(
                            children: <Widget>[
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedPlayList,
                                size: 14,
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${course.lessonsCount} Lessons',
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
                          const Spacer(),
                          Text(
                            settingsProvider.formatPrice(
                              course.discountedPrice ?? course.price,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF00C853),
                              fontSize: 16,
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
            // Match Reason Badge
            Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Recommended for you',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
