import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<String> _orbitImages = const [
    'assets/img/profile/profile_1.jpg',
    'assets/img/profile/profile_2.jpg',
    'assets/img/profile/profile_3.jpg',
    'assets/img/profile/profile_4.jpg',
    'assets/img/profile/profile_5.jpg',
    'assets/img/profile/profile_6.jpg',
    'assets/img/profile/profile_7.jpg',
    'assets/img/profile/profile_8.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Navigation is handled by SplashWrapper in main.dart
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _OrbitDial(controller: _controller, orbitImages: _orbitImages),
              const SizedBox(height: 48),
              Text(
                'Transform your future\nthrough education',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.getTextColor(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Access thousands of courses, learn from expert instructors, and unlock your potential with AI-powered learning paths.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                  fontSize: 15,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitDial extends StatelessWidget {
  const _OrbitDial({required this.controller, required this.orbitImages});

  final AnimationController controller;
  final List<String> orbitImages;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double diameter = constraints.maxWidth;
          const double avatarSize = 64;
          final double orbitRadius = diameter / 2 - avatarSize * 0.6;
          final double coreSize = diameter * 0.45;

          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: coreSize,
                height: coreSize,
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.getMint200(context),
                    width: 1.4,
                  ),
                ),
                child: ClipOval(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset(
                      'assets/img/splash.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  return Stack(
                    children: List.generate(orbitImages.length, (index) {
                      final angle =
                          (2 * math.pi / orbitImages.length) * index +
                          controller.value * 2 * math.pi;
                      final double center = diameter / 2;
                      final double x =
                          center +
                          orbitRadius * math.cos(angle) -
                          avatarSize / 2;
                      final double y =
                          center +
                          orbitRadius * math.sin(angle) -
                          avatarSize / 2;

                      return Positioned(
                        left: x,
                        top: y,
                        child: SizedBox(
                          width: avatarSize,
                          height: avatarSize,
                          child: _OrbitAvatar(imagePath: orbitImages[index]),
                        ),
                      );
                    }),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrbitAvatar extends StatelessWidget {
  const _OrbitAvatar({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.getCardColor(context),
      ),
      padding: const EdgeInsets.all(4),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppTheme.getMint200(context),
              child: Icon(
                Icons.school,
                color: AppTheme.getPrimaryColor(context),
              ),
            );
          },
        ),
      ),
    );
  }
}
