import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../theme/app_theme.dart';

class AiLearningPathScreen extends StatefulWidget {
  const AiLearningPathScreen({super.key});

  @override
  State<AiLearningPathScreen> createState() => _AiLearningPathScreenState();
}

class _AiLearningPathScreenState extends State<AiLearningPathScreen> {
  String? _selectedCareer;
  bool _isGenerating = false;
  bool _hasGenerated = false;

  // Hard-coded career options
  final List<Map<String, dynamic>> _careerOptions = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'ui_ux_designer',
      'title': 'UI/UX Designer',
      'icon': HugeIcons.strokeRoundedBook01,
      'color': AppTheme.primary,
    },
    <String, dynamic>{
      'id': 'frontend_developer',
      'title': 'Frontend Developer',
      'icon': HugeIcons.strokeRoundedAiUser,
      'color': AppTheme.softBlue800,
    },
    <String, dynamic>{
      'id': 'backend_developer',
      'title': 'Backend Developer',
      'icon': HugeIcons.strokeRoundedAiUser,
      'color': AppTheme.softOrange800,
    },
    <String, dynamic>{
      'id': 'fullstack_developer',
      'title': 'Full Stack Developer',
      'icon': HugeIcons.strokeRoundedAiUser,
      'color': Colors.purple,
    },
    <String, dynamic>{
      'id': 'data_scientist',
      'title': 'Data Scientist',
      'icon': HugeIcons.strokeRoundedStar,
      'color': Colors.teal,
    },
    <String, dynamic>{
      'id': 'mobile_developer',
      'title': 'Mobile Developer',
      'icon': HugeIcons.strokeRoundedAiUser,
      'color': Colors.indigo,
    },
  ];

  // Hard-coded learning path data
  final List<Map<String, dynamic>> _learningPath = <Map<String, dynamic>>[
    <String, dynamic>{
      'step': 1,
      'title': 'Foundation: Design Principles',
      'duration': '2 weeks',
      'courses': <String>[
        'Introduction to UI Design',
        'Color Theory Basics',
        'Typography Fundamentals',
      ],
      'progress': 0.3,
      'completed': false,
    },
    <String, dynamic>{
      'step': 2,
      'title': 'Design Tools & Software',
      'duration': '3 weeks',
      'courses': <String>[
        'Figma Masterclass',
        'Adobe XD Essentials',
        'Prototyping Techniques',
      ],
      'progress': 0.0,
      'completed': false,
    },
    <String, dynamic>{
      'step': 3,
      'title': 'User Research & Testing',
      'duration': '2 weeks',
      'courses': <String>[
        'User Research Methods',
        'Usability Testing',
        'User Personas',
      ],
      'progress': 0.0,
      'completed': false,
    },
    <String, dynamic>{
      'step': 4,
      'title': 'Advanced Design Patterns',
      'duration': '4 weeks',
      'courses': <String>[
        'Design Systems',
        'Responsive Design',
        'Accessibility in Design',
      ],
      'progress': 0.0,
      'completed': false,
    },
    <String, dynamic>{
      'step': 5,
      'title': 'Portfolio Development',
      'duration': '3 weeks',
      'courses': <String>[
        'Building Your Portfolio',
        'Case Study Creation',
        'Presentation Skills',
      ],
      'progress': 0.0,
      'completed': false,
    },
  ];

  void _selectCareer(String careerId) {
    setState(() {
      _selectedCareer = careerId;
      _hasGenerated = false;
    });
  }

  Future<void> _generateLearningPath() async {
    if (_selectedCareer == null) return;

    setState(() {
      _isGenerating = true;
    });

    // Simulate AI generation delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
      _hasGenerated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppTheme.getBackgroundColor(context),
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft01,
            size: 20,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI Learning Path Generator',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Header Section
            Text(
              'Choose Your Career Goal',
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a career path and AI will generate a personalized learning roadmap for you',
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            // Career Options Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: _careerOptions.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> career = _careerOptions[index];
                final bool isSelected = _selectedCareer == career['id'];
                return GestureDetector(
                  onTap: () => _selectCareer(career['id'] as String),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (career['color'] as Color).withValues(alpha: 0.1)
                          : AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? career['color'] as Color
                            : AppTheme.getSoftGray150(context),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (career['color'] as Color).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: HugeIcon(
                              icon: career['icon'] as dynamic,
                              size: 24,
                              color: career['color'] as Color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          career['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Generate Button
            if (_selectedCareer != null && !_hasGenerated)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateLearningPath,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedAiUser,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Generate Learning Path',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            // Learning Path Timeline
            if (_hasGenerated) ...<Widget>[
              const SizedBox(height: 32),
              Text(
                'Your Learning Roadmap',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              ..._learningPath.asMap().entries.map((entry) {
                final int index = entry.key;
                final Map<String, dynamic> step = entry.value;
                final bool isLast = index == _learningPath.length - 1;
                return _buildTimelineStep(step, isLast, index);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    Map<String, dynamic> step,
    bool isLast,
    int index,
  ) {
    final bool isCompleted = step['completed'] as bool;
    final double progress = step['progress'] as double;
    final int stepNumber = step['step'] as int;
    final String title = step['title'] as String;
    final String duration = step['duration'] as String;
    final List<String> courses = step['courses'] as List<String>;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Timeline Line & Circle
        Column(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.primary
                    : progress > 0
                        ? AppTheme.primary.withValues(alpha: 0.3)
                        : AppTheme.getMint100(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted || progress > 0
                      ? AppTheme.primary
                      : AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      )
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          color: progress > 0
                              ? AppTheme.primary
                              : AppTheme.getTextColor(context).withValues(alpha: 0.6),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 120,
                color: AppTheme.getTextColor(context).withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Step Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getMint100(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Progress Indicator
              if (progress > 0 || isCompleted)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: isCompleted ? 1.0 : progress,
                        backgroundColor: AppTheme.getSoftGray150(context),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isCompleted
                          ? 'Completed'
                          : '${(progress * 100).toInt()}% Complete',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              // Recommended Courses
              Text(
                'Recommended Courses:',
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...courses.map((course) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
