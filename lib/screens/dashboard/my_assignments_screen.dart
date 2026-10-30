import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_assignment.dart';
import '../../services/student_course_service.dart';
import 'assignment_detail_screen.dart';

class MyAssignmentsScreen extends StatefulWidget {
  const MyAssignmentsScreen({super.key});

  @override
  State<MyAssignmentsScreen> createState() => _MyAssignmentsScreenState();
}

class _MyAssignmentsScreenState extends State<MyAssignmentsScreen> {
  String _selectedFilter = 'all'; // all, pending, submitted, graded
  final StudentCourseService _courseService = StudentCourseService();
  List<UserAssignment> _assignments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _courseService.getMyAssignments();
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'];
          if (mounted) {
            setState(() {
              _assignments = list
                  .map((e) => UserAssignment.fromJson(e))
                  .toList();
              _isLoading = false;
            });
          }
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<UserAssignment> get _filteredAssignments {
    if (_selectedFilter == 'all') {
      return _assignments;
    }
    return _assignments
        .where((assignment) => assignment.status == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowLeft01,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Text(
                      context.l10n.myAssignments,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      size: 20,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: _fetchAssignments,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _FilterChip(
                      label: context.l10n.all,
                      isSelected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: context.l10n.pending,
                      isSelected: _selectedFilter == 'pending',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'pending';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: context.l10n.submitted,
                      isSelected: _selectedFilter == 'submitted',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'submitted';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: context.l10n.graded,
                      isSelected: _selectedFilter == 'graded',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'graded';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAssignments.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _fetchAssignments,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _EmptyState(
                              icon: HugeIcons.strokeRoundedAssignments,
                              message: context.l10n.noAssignments,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchAssignments,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filteredAssignments.length,
                        itemBuilder: (BuildContext context, int index) {
                          final UserAssignment assignment =
                              _filteredAssignments[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AssignmentCard(
                              assignment: assignment,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AssignmentDetailScreen(
                                          assignment: assignment,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment, this.onTap});

  final UserAssignment assignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final String title = assignment.title;
    final String course = assignment.courseTitle;
    final String dueDate = assignment.dueDate;
    final String status = assignment.status;
    final int? grade = assignment.grade;

    Color statusColor;
    String statusText;
    dynamic statusIcon;

    switch (status) {
      case 'graded':
        statusColor = Colors.green;
        statusText = context.l10n.graded;
        statusIcon = Icons.check_circle;
        break;
      case 'submitted':
        statusColor = AppTheme.softBlue800;
        statusText = context.l10n.submitted;
        statusIcon = Icons.access_time;
        break;
      default:
        statusColor = AppTheme.softOrange800;
        statusText = context.l10n.pending;
        statusIcon = Icons.warning_rounded;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.getMint100(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAssignments,
                      size: 24,
                      color: AppTheme.getPrimaryColor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: AppTheme.getTextColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course,
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
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      statusIcon is IconData
                          ? Icon(statusIcon, size: 12, color: statusColor)
                          : HugeIcon(
                              icon: statusIcon,
                              size: 12,
                              color: statusColor,
                            ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(
              height: 1,
              thickness: 1,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.1),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  '${context.l10n.dueDate}: $dueDate',
                  style: TextStyle(
                    color: AppTheme.getTextColor(
                      context,
                    ).withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (grade != null) ...[
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$grade%',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(context)
              : AppTheme.getSoftGray150(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.getTextColor(context),
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final dynamic icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.getMint100(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                size: 40,
                color: AppTheme.getPrimaryColor(context),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
