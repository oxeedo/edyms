import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../router/app_router.dart';
import '../../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingContent> _pages = const [
    _OnboardingContent(
      titleLeading: 'Discover',
      titleAccent: ' courses',
      titleTrailing: '\nthat fit your goals',
      description:
          'Browse thousands of courses across multiple categories. From programming to design, find the perfect course to advance your career.',
      illustration: _IllustrationType.discover,
    ),
    _OnboardingContent(
      titleLeading: 'Learn at your',
      titleAccent: ' own pace',
      titleTrailing: '\nwith expert guidance',
      description:
          'Access high-quality video lessons, interactive content, and expert instructors. Learn whenever and wherever you want.',
      illustration: _IllustrationType.learn,
    ),
    _OnboardingContent(
      titleLeading: 'Track your',
      titleAccent: ' progress',
      titleTrailing: '\nand unlock achievements',
      description:
          'Monitor your learning journey with AI-powered insights, personalized recommendations, and celebrate milestones as you grow.',
      illustration: _IllustrationType.track,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  physics: const PageScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final content = _pages[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _OnboardingTitle(content: content),
                        const SizedBox(height: 28),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: _Illustration(type: content.illustration),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          content.description,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Indicator(length: _pages.length, activeIndex: _currentIndex),
                  GestureDetector(
                    onTap: _handleNext,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.getPrimaryColor(context),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingTitle extends StatelessWidget {
  const _OnboardingTitle({required this.content});

  final _OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return RichText(
      text: TextSpan(
        style: textTheme.headlineLarge?.copyWith(
          color: AppTheme.getTextColor(context),
        ),
        children: [
          TextSpan(text: content.titleLeading),
          if (content.titleAccent != null)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: _AccentTextWithUnderline(
                text: content.titleAccent!,
                style:
                    textTheme.headlineLarge?.copyWith(
                      color: AppTheme.getTextColor(context),
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ) ??
                    const TextStyle(),
              ),
            ),
          if (content.titleTrailing != null)
            TextSpan(text: content.titleTrailing),
        ],
      ),
    );
  }
}

class _AccentTextWithUnderline extends StatelessWidget {
  const _AccentTextWithUnderline({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(text, style: style),
        Positioned(
          left: 0,
          right: 0,
          top: style.fontSize! * 1.1,
          child: SizedBox(
            height: 5,
            child: CustomPaint(
              painter: _WavyUnderlinePainter(context: context),
            ),
          ),
        ),
      ],
    );
  }
}

class _WavyUnderlinePainter extends CustomPainter {
  const _WavyUnderlinePainter({required this.context});

  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final baseY = size.height / 2;
    final waveCount = 5;
    final waveLength = size.width / waveCount;

    path.moveTo(0, baseY);

    for (int i = 0; i < waveCount; i++) {
      final progress = i / (waveCount - 1);
      final amplitude = 1.5 + (progress * 4.5);
      final x1 = i * waveLength + waveLength * 0.25;
      final x2 = i * waveLength + waveLength * 0.75;
      final midX = i * waveLength + waveLength * 0.5;

      path.quadraticBezierTo(x1, baseY - amplitude, midX, baseY);
      path.quadraticBezierTo(
        x2,
        baseY + amplitude,
        (i + 1) * waveLength,
        baseY,
      );
    }

    final primaryColor = AppTheme.getPrimaryColor(context);
    final gradient = LinearGradient(
      colors: [
        primaryColor.withValues(alpha: 0.7),
        primaryColor.withValues(alpha: 0.9),
        primaryColor,
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    paint.shader = gradient.createShader(rect);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavyUnderlinePainter oldDelegate) =>
      oldDelegate.context != context;
}

class _Indicator extends StatelessWidget {
  const _Indicator({required this.length, required this.activeIndex});

  final int length;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(length, (index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(right: 8),
          height: 8,
          width: isActive ? 20 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.getPrimaryColor(context)
                : AppTheme.getMint200(context),
            borderRadius: BorderRadius.circular(100),
          ),
        );
      }),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.titleLeading,
    this.titleAccent,
    this.titleTrailing,
    required this.description,
    required this.illustration,
  });

  final String titleLeading;
  final String? titleAccent;
  final String? titleTrailing;
  final String description;
  final _IllustrationType illustration;
}

enum _IllustrationType { discover, learn, track }

class _Illustration extends StatelessWidget {
  const _Illustration({required this.type});

  final _IllustrationType type;

  String get _assetPath {
    return switch (type) {
      _IllustrationType.discover => 'assets/img/onboarding/onboarding_1.png',
      _IllustrationType.learn => 'assets/img/onboarding/onboarding_2.png',
      _IllustrationType.track => 'assets/img/onboarding/onboarding_3.png',
    };
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}
