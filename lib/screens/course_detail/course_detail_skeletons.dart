import 'package:flutter/material.dart';
import '../../widgets/home_skeletons.dart';

class CourseDetailSkeletons extends StatelessWidget {
  const CourseDetailSkeletons({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ImageSkeleton(),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TextSkeleton(height: 24, width: 250),
                SizedBox(height: 12),
                _TextSkeleton(height: 16, width: double.infinity),
                SizedBox(height: 8),
                _TextSkeleton(height: 16, width: 200),
                SizedBox(height: 24),
                _StatsRowSkeleton(),
                SizedBox(height: 32),
                _TabBarSkeleton(),
                SizedBox(height: 24),
                _InstructorCardSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageSkeleton extends StatelessWidget {
  const _ImageSkeleton();

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        height: 250,
        width: double.infinity,
        color: Colors.white,
      ),
    );
  }
}

class _TextSkeleton extends StatelessWidget {
  final double height;
  final double width;

  const _TextSkeleton({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        3,
        (index) => BaseShimmer(
          child: Container(
            height: 60,
            width: (MediaQuery.of(context).size.width - 60) / 3,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabBarSkeleton extends StatelessWidget {
  const _TabBarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(right: 16),
          child: BaseShimmer(
            child: Container(
              height: 40,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InstructorCardSkeleton extends StatelessWidget {
  const _InstructorCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return BaseShimmer(
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
