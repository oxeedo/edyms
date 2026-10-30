import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

import '../../models/user_assignment.dart';

class AssignmentDetailScreen extends StatefulWidget {
  const AssignmentDetailScreen({required this.assignment, super.key});

  final UserAssignment assignment;

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final List<String> _attachedFiles = <String>[];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showSubmitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return _SubmitAssignmentSheet(
          commentController: _commentController,
          attachedFiles: _attachedFiles,
          assignmentTitle: widget.assignment.title,
          onFileAdded: (String fileName) {
            setState(() {
              _attachedFiles.add(fileName);
            });
          },
          onFileRemoved: (String fileName) {
            setState(() {
              _attachedFiles.remove(fileName);
            });
          },
          onSubmit: () {
            Navigator.of(context).pop();
            // Handle submission logic here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.assignmentSubmittedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.assignment.title;
    final String course = widget.assignment.courseTitle;
    final String dueDate = widget.assignment.dueDate;
    final String status = widget.assignment.status;
    final int? grade = widget.assignment.grade;
    final bool submitted = status == 'submitted' || status == 'graded';

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
                      context.l10n.assignmentDetails,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          statusIcon is IconData
                              ? Icon(statusIcon, size: 16, color: statusColor)
                              : HugeIcon(
                                  icon: statusIcon,
                                  size: 16,
                                  color: statusColor,
                                ),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Course
                    Text(
                      course,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: <Widget>[
                          _InfoRow(
                            icon: Icons.access_time,
                            label: context.l10n.dueDate,
                            value: dueDate,
                          ),
                          if (submitted) ...[
                            const SizedBox(height: 16),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.check_circle,
                              label: context.l10n.submittedDate,
                              value: 'December 15, 2024',
                            ),
                          ],
                          if (grade != null) ...[
                            const SizedBox(height: 16),
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.1),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.grade,
                                      size: 20,
                                      color: AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.6),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      context.l10n.score,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$grade%',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Description Section
                    Text(
                      context.l10n.assignmentDescription,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _getAssignmentDescription(title),
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Requirements Section
                    Text(
                      context.l10n.requirements,
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(context),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: _getRequirements(title).map((requirement) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.only(
                                    top: 6,
                                    right: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getPrimaryColor(context),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    requirement,
                                    style: TextStyle(
                                      color: AppTheme.getTextColor(
                                        context,
                                      ).withValues(alpha: 0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Action Button
                    if (status == 'pending')
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showSubmitSheet(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.getPrimaryColor(context),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            context.l10n.submitAssignment,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAssignmentDescription(String title) {
    return 'This assignment requires you to demonstrate your understanding and practical application of the concepts covered in this course. You will need to complete all the requirements listed below and submit your work before the due date. Make sure to review your submission carefully before submitting.';
  }

  List<String> _getRequirements(String title) {
    return <String>[
      'Complete all required tasks and deliverables',
      'Follow the design guidelines and best practices',
      'Include proper documentation and comments',
      'Submit all files in the required format',
      'Ensure your work is original and properly cited',
    ];
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: 20,
          color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            color: AppTheme.getTextColor(context).withValues(alpha: 0.6),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.getTextColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitAssignmentSheet extends StatefulWidget {
  const _SubmitAssignmentSheet({
    required this.commentController,
    required this.attachedFiles,
    required this.assignmentTitle,
    required this.onFileAdded,
    required this.onFileRemoved,
    required this.onSubmit,
  });

  final TextEditingController commentController;
  final List<String> attachedFiles;
  final String assignmentTitle;
  final Function(String) onFileAdded;
  final Function(String) onFileRemoved;
  final VoidCallback onSubmit;

  @override
  State<_SubmitAssignmentSheet> createState() => _SubmitAssignmentSheetState();
}

class _SubmitAssignmentSheetState extends State<_SubmitAssignmentSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          context.l10n.submitAssignment,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.assignmentTitle,
                          style: TextStyle(
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 24,
                      color: AppTheme.getTextColor(context),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Attach Files Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.attachFiles,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Attached Files List
                  if (widget.attachedFiles.isNotEmpty)
                    ...widget.attachedFiles.map((fileName) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.getSoftGray150(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.getMint100(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedFile01,
                                  size: 20,
                                  color: AppTheme.getPrimaryColor(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fileName,
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                widget.onFileRemoved(fileName);
                                setState(() {});
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    }),
                  // Add File Button
                  GestureDetector(
                    onTap: () {
                      // Simulate file picker - in real app, use file_picker package
                      final String fileName =
                          'assignment_file_${widget.attachedFiles.length + 1}.pdf';
                      widget.onFileAdded(fileName);
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.getSoftGray150(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.getPrimaryColor(
                            context,
                          ).withValues(alpha: 0.3),
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAddCircle,
                            size: 20,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.addFile,
                            style: TextStyle(
                              color: AppTheme.getPrimaryColor(context),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Comments Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    context.l10n.comments,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: context.l10n.addComments,
                      hintStyle: TextStyle(
                        color: AppTheme.getTextColor(context).withValues(alpha: 0.4),
                      ),
                      filled: true,
                      fillColor: AppTheme.getSoftGray150(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Submit Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.getPrimaryColor(context),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    context.l10n.submit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
