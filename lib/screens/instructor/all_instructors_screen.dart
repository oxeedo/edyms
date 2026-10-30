import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../services/instructor_service.dart';
import '../../models/instructor.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../instructor/instructor_profile_screen.dart';
import '../../config/config.dart';

class AllInstructorsScreen extends StatefulWidget {
  const AllInstructorsScreen({super.key});

  @override
  State<AllInstructorsScreen> createState() => _AllInstructorsScreenState();
}

class _AllInstructorsScreenState extends State<AllInstructorsScreen> {
  final InstructorService _instructorService = InstructorService();
  List<Instructor> _instructors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInstructors();
  }

  Future<void> _fetchInstructors() async {
    try {
      final response = await _instructorService.fetchInstructors();
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          if (mounted) {
            setState(() {
              _instructors = data
                  .map((json) => Instructor.fromJson(json))
                  .toList();
              _isLoading = false;
            });
          }
        } else {
          _handleError('Failed to load instructors');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              Brightness.dark, // Black icons for light mode
          statusBarBrightness: Brightness.light, // For iOS
        ),
        title: Text(
          'Instructors',
          style: TextStyle(
            color: AppTheme.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const _InstructorsSkeleton()
          : _error != null
          ? _buildErrorState()
          : _buildMainContent(),
      bottomNavigationBar: const AppBottomNavBar(
        currentTab: BottomNavTab.instructors,
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.getTextColor(context)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchInstructors();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_instructors.isEmpty) {
      return Center(
        child: Text(
          'No instructors found',
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchInstructors,
      color: AppTheme.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75, // Adjusted for the new card design
        ),
        itemCount: _instructors.length,
        itemBuilder: (context, index) {
          final instructor = _instructors[index];
          return _InstructorGridCard(instructor: instructor);
        },
      ),
    );
  }
}

class _InstructorGridCard extends StatelessWidget {
  final Instructor instructor;

  const _InstructorGridCard({required this.instructor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                InstructorProfileScreen(instructorId: instructor.id),
          ),
        );
      },
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.getMint100(context),
                    ),
                    child: instructor.image != null
                        ? Image.network(
                            AppConfig.getImageUrl(instructor.image!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.person,
                              color: AppTheme.getPrimaryColor(context),
                              size: 40,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            color: AppTheme.getPrimaryColor(context),
                            size: 40,
                          ),
                  ),
                ],
              ),
            ),
            // Info Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${instructor.coursesCount ?? 0} Courses',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star_rounded,
                            color:
                                index < (instructor.averageRating ?? 0).floor()
                                ? Colors.amber
                                : AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.3),
                            size: 16,
                          );
                        }),
                      ),
                      Text(
                        instructor.averageRating?.toStringAsFixed(1) ?? '0.0',
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Bottom Instructor row
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: instructor.image != null
                              ? DecorationImage(
                                  image: NetworkImage(
                                    AppConfig.getImageUrl(instructor.image!),
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: instructor.image == null
                            ? Icon(
                                Icons.person,
                                size: 12,
                                color: AppTheme.getPrimaryColor(context),
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          instructor.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.7),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }
}

class _InstructorsSkeleton extends StatelessWidget {
  const _InstructorsSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
          ),
        );
      },
    );
  }
}
