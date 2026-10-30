import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../services/student_course_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AssignmentSubmitScreen extends StatefulWidget {
  const AssignmentSubmitScreen({
    super.key,
    required this.courseId,
    required this.assignmentId,
    this.assignmentTitle = 'Assignment',
    this.showAppBar = true,
  });

  final int courseId;
  final int assignmentId;
  final String assignmentTitle;
  final bool showAppBar;

  @override
  State<AssignmentSubmitScreen> createState() => _AssignmentSubmitScreenState();
}

class _AssignmentSubmitScreenState extends State<AssignmentSubmitScreen> {
  final StudentCourseService _studentCourseService = StudentCourseService();
  final TextEditingController _commentsController = TextEditingController();

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _assignmentData;
  Map<String, dynamic>? _submissionData;

  String? _attachedFilePath;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadAssignment();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  Future<void> _loadAssignment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _studentCourseService.loadAssignment(
        widget.courseId,
        widget.assignmentId,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _assignmentData = data['data']['assignment'];
            _submissionData = data['data']['submission'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load assignment';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load assignment (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading assignment: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _attachFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'zip'],
    );

    if (result != null) {
      setState(() {
        _attachedFilePath = result.files.single.path;
      });
    }
  }

  void _removeFile() {
    setState(() {
      _attachedFilePath = null;
    });
  }

  Future<void> _submitAssignment() async {
    if (_attachedFilePath == null && _commentsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please attach a file or write a comment.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await _studentCourseService.submitAssignment(
        widget.courseId,
        widget.assignmentId,
        _commentsController.text,
        filePath: _attachedFilePath,
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Reload to show submission status
          setState(() {
            _attachedFilePath = null;
            _commentsController.clear();
          });
          _loadAssignment();
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Submission failed')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Submission failed')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 50,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.assignmentSubmittedSuccessfully,
              style: TextStyle(
                color: AppTheme.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.assignmentSubmittedSuccessMessage,
              style: TextStyle(
                color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: <Widget>[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                context.l10n.ok,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: widget.showAppBar
            ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
            : null,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: widget.showAppBar
            ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
            : null,
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final assignment = _assignmentData!;
    final bool isSubmitted = _submissionData != null;
    final String? status = isSubmitted
        ? (_submissionData!['status'] ?? 'pending')
        : null;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: widget.showAppBar
          ? AppBar(
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
                widget.assignmentTitle,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, widget.showAppBar ? 20 : 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Title header (when no app bar)
            if (!widget.showAppBar)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.assignmentTitle,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

            // Submission Status Card (if submitted)
            if (isSubmitted)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: status == 'graded'
                      ? Colors.green.withValues(alpha: 0.1)
                      : status == 'returned'
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: status == 'graded'
                        ? Colors.green
                        : status == 'returned'
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          status == 'graded'
                              ? Icons.check_circle
                              : status == 'returned'
                              ? Icons.error_outline
                              : Icons.hourglass_bottom,
                          color: status == 'graded'
                              ? Colors.green
                              : status == 'returned'
                              ? Colors.red
                              : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            status == 'graded'
                                ? 'Assignment Graded'
                                : status == 'returned'
                                ? 'Assignment Returned'
                                : 'Submitted (Pending Grade)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status == 'graded'
                                  ? Colors.green[800]
                                  : status == 'returned'
                                  ? Colors.red[800]
                                  : Colors.orange[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((status == 'returned' || status == 'graded') &&
                        (_submissionData!['instructor_notes'] != null ||
                            _submissionData!['grade'] != null)) ...[
                      const SizedBox(height: 12),
                      if (_submissionData!['grade'] != null) ...[
                        Text(
                          'Grade: ${_submissionData!['grade']}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: status == 'graded'
                                ? Colors.green[800]
                                : AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (_submissionData!['instructor_notes'] != null) ...[
                        Text(
                          'Instructor Notes:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _submissionData!['instructor_notes'],
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.getTextColor(
                              context,
                            ).withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                      if (status == 'returned') ...[
                        const SizedBox(height: 12),
                        Text(
                          'Please review the notes and submit a new version below.',
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.red[800],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

            // Assignment Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAssignments,
                            size: 24,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              assignment['title'] ?? widget.assignmentTitle,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Due: ${assignment['due_date'] ?? 'No Due Date'}',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Assignment Description
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                assignment['description'] ?? 'No description available',
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (!isSubmitted || status == 'returned') ...[
              // Attach Files Section
              Text(
                context.l10n.attachFiles,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              // File attachment button
              GestureDetector(
                onTap: _attachFile,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.getCardColor(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.getMint100(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedAddCircle,
                            size: 24,
                            color: AppTheme.getTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              context.l10n.addFile,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'PDF, PNG, JPG (Max 10MB)',
                              style: TextStyle(
                                color: AppTheme.getTextColor(
                                  context,
                                ).withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Attached files list
              if (_attachedFilePath != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
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
                              color: AppTheme.getTextColor(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                File(_attachedFilePath!).uri.pathSegments.last,
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              FutureBuilder<int?>(
                                future: File(_attachedFilePath!).length(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      '${(snapshot.data! / 1024 / 1024).toStringAsFixed(2)} MB',
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(
                                          context,
                                        ).withValues(alpha: 0.6),
                                        fontSize: 12,
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedDelete01,
                            size: 20,
                            color: Colors.red,
                          ),
                          onPressed: _removeFile,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Comments Section
              Text(
                context.l10n.comments,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _commentsController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: context.l10n.addComments,
                    hintStyle: TextStyle(
                      color: AppTheme.getTextColor(context).withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.getCardColor(context),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAssignment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          context.l10n.submit,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ] else if (isSubmitted) ...[
              // Submitted Content
              Text(
                'Your Submission',
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.getSoftGray150(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _submissionData!['submission_text'] ??
                          'No text submission',
                      style: TextStyle(
                        color: AppTheme.getTextColor(context),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
