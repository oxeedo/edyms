import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../services/student_course_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class QuizAttemptScreen extends StatefulWidget {
  const QuizAttemptScreen({
    super.key,
    required this.courseId,
    required this.quizId,
    this.quizTitle = 'Quiz',
    this.showAppBar = true,
  });

  final int courseId;
  final int quizId;
  final String quizTitle;
  final bool showAppBar;

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen>
    with WidgetsBindingObserver {
  final StudentCourseService _studentCourseService = StudentCourseService();
  bool _isLoading = true;
  String? _error;

  int _currentQuestionIndex = 0;
  final Map<int, int?> _selectedAnswers = <int, int?>{};
  bool _isSubmitted = false;
  int _score = 0;
  bool _passed = false;

  // Quiz Data
  Map<String, dynamic>? _quizData;
  List<dynamic> _questions = [];

  // Timer variables
  Timer? _timer;
  int _timeRemaining = 1800; // Default fallback
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadQuiz({bool retake = false}) async {
    if (retake) {
      setState(() {
        _isLoading = true;
        _isSubmitted = false;
        _passed = false;
        _score = 0;
        _selectedAnswers.clear();
        _currentQuestionIndex = 0;
        _timer?.cancel();
        _isTimeUp = false;
        _error = null;
      });
    }

    try {
      final response = await _studentCourseService.loadQuiz(
        widget.courseId,
        widget.quizId,
        retake: retake,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final quiz = data['data']['quiz'];
          final isCompleted = data['data']['is_completed'] ?? false;
          final lastAttempt = data['data']['last_attempt'];

          setState(() {
            _quizData = quiz;
            _questions = quiz['questions'] ?? [];

            // Set time based on quiz duration (minutes) if available, else default 30m
            final durationMinutes = quiz['duration'] != null
                ? int.tryParse(quiz['duration'].toString()) ?? 30
                : 30;
            _timeRemaining = durationMinutes * 60;

            _isLoading = false;
          });

          if (isCompleted && lastAttempt != null) {
            _handleAlreadyCompleted(lastAttempt);
          } else {
            _startTimer();
          }
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load quiz';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to load quiz (Status: ${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading quiz: $e';
        _isLoading = false;
      });
    }
  }

  void _handleAlreadyCompleted(dynamic attempt) {
    setState(() {
      _isSubmitted = true;
      _score = attempt['score']; // Assuming API returns computed score or raw
      _passed = attempt['passed'] == 1 || attempt['passed'] == true;
      // Reconstruct answers if needed or just show summary.
      // For simplicity, we just show the results dialog/screen state.
    });
    // Delay to let build finish then show results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResults(isInitialLoad: true);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_timeRemaining > 0 && !_isSubmitted && !_isTimeUp) {
        setState(() {
          _timeRemaining--;
        });
      } else if (_timeRemaining == 0 && !_isSubmitted && !_isTimeUp) {
        _isTimeUp = true;
        _timer?.cancel();
        _autoSubmitQuiz();
      }
    });
  }

  Future<void> _autoSubmitQuiz() async {
    if (!_isSubmitted) {
      await _submitQuiz();
    }
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int answerIndex) {
    if (!_isSubmitted) {
      setState(() {
        _selectedAnswers[_currentQuestionIndex] = answerIndex;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();

    // Prepare answers payload
    List<Map<String, dynamic>> answersPayload = [];
    _selectedAnswers.forEach((qIndex, aIndex) {
      if (qIndex < _questions.length) {
        final question = _questions[qIndex];
        // Access OPTIONS to find the selected value?
        // The API expects 'selected_answer' index (0-based) based on the options array order?
        // "selected_answer" in my API implementation is expected to be the index if the question stores correct_answer as index.
        // Let's assume options are ordered and index matches.
        answersPayload.add({
          'question_id': question['id'],
          'selected_answer': aIndex,
        });
      }
    });

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(child: CircularProgressIndicator()),
      );

      final response = await _studentCourseService
          .submitQuiz(widget.courseId, widget.quizId, {
            'time_taken': (_quizData != null && _quizData!['duration'] != null
                ? (int.parse(_quizData!['duration'].toString()) * 60) -
                      _timeRemaining
                : 1800 - _timeRemaining),
            'answers': answersPayload,
          });

      if (!mounted) return;
      Navigator.pop(context); // Remove loader

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final resultData = data['data'];
          setState(() {
            _isSubmitted = true;
            _score =
                resultData['score']; // Getting score from backend (it calculates it)
            _passed = resultData['passed'];
          });
          _showResults();
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
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showResults({bool isInitialLoad = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: _passed
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('🎉 ', style: TextStyle(fontSize: 32)),
                  Text(
                    context.l10n.passed,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(' 🎉', style: TextStyle(fontSize: 32)),
                ],
              )
            : Text(
                context.l10n.failed,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_passed)
              Column(
                children: <Widget>[
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.green.shade300,
                          Colors.green.shade500,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text('🎊', style: TextStyle(fontSize: 60)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${context.l10n.score}: $_score%', // Backend returns percentage score
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('🌟 ', style: TextStyle(fontSize: 20)),
                        Text(
                          'Excellent Work!',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(' 🌟', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Congratulations! You passed the quiz.\nKeep up the amazing work! 🚀',
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            else
              Column(
                children: <Widget>[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.cancel, size: 60, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${context.l10n.score}: $_score%',
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You need passing score to complete. Try again!',
                    style: TextStyle(
                      color: AppTheme.getTextColor(
                        context,
                      ).withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
          ],
        ),
        actions: <Widget>[
          if (_passed)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _loadQuiz(retake: true); // Reload quiz as retake
              },
              child: Text(
                'Retake',
                style: TextStyle(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (!isInitialLoad) {
                Navigator.of(
                  context,
                ).pop(); // Close quiz screen if just finished
              }
            },
            child: Text(
              context.l10n.ok,
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
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

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.getBackgroundColor(context),
        appBar: widget.showAppBar
            ? AppBar(backgroundColor: Colors.transparent, elevation: 0)
            : null,
        body: const Center(child: Text('No questions found for this quiz.')),
      );
    }

    final Map<String, dynamic> currentQuestion =
        _questions[_currentQuestionIndex];
    final int? selectedAnswer = _selectedAnswers[_currentQuestionIndex];
    // Parsing options. API might return "options" as a list of strings or objects.
    // Assuming backend returns simple array of strings for options.
    final List<dynamic> options = currentQuestion['options'] ?? [];

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
                widget.quizTitle,
                style: TextStyle(
                  color: AppTheme.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // Progress indicator and title (when no app bar)
              if (!widget.showAppBar)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          widget.quizTitle,
                          style: TextStyle(
                            color: AppTheme.getTextColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        'Question ${_currentQuestionIndex + 1}/${_questions.length}',
                        style: TextStyle(
                          color: AppTheme.getTextColor(
                            context,
                          ).withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              // Progress indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentQuestionIndex + 1) / _questions.length,
                    backgroundColor: AppTheme.getSoftGray150(context),
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    minHeight: 8,
                  ),
                ),
              ),
              // Question and options
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Question
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.getCardColor(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.getMint100(context),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  '${_currentQuestionIndex + 1}',
                                  style: TextStyle(
                                    color: AppTheme.getTextColor(context),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                currentQuestion['question'] as String,
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Options
                      ...List<Widget>.generate(
                        options.length,
                        (int index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: _isSubmitted
                                ? null
                                : () => _selectAnswer(index),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: selectedAnswer == index
                                    ? AppTheme.primary.withValues(alpha: 0.1)
                                    : AppTheme.getCardColor(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedAnswer == index
                                      ? AppTheme.primary
                                      : AppTheme.getSoftGray150(context),
                                  width: selectedAnswer == index ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: selectedAnswer == index
                                            ? AppTheme.primary
                                            : AppTheme.getTextColor(
                                                context,
                                              ).withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                      color: selectedAnswer == index
                                          ? AppTheme.primary
                                          : Colors.transparent,
                                    ),
                                    child: selectedAnswer == index
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      options[index].toString(),
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 16,
                                        fontWeight: selectedAnswer == index
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.getCardColor(context),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    if (_currentQuestionIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousQuestion,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: AppTheme.primary,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Previous',
                            style: TextStyle(
                              color: AppTheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: _currentQuestionIndex == 0 ? 1 : 1,
                      child: ElevatedButton(
                        onPressed: _isSubmitted
                            ? (_currentQuestionIndex < _questions.length - 1
                                  ? _nextQuestion
                                  : () => Navigator.pop(context))
                            : (_currentQuestionIndex < _questions.length - 1
                                  ? _nextQuestion
                                  : () {
                                      _submitQuiz();
                                    }),
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
                          _isSubmitted
                              ? (_currentQuestionIndex < _questions.length - 1
                                    ? 'Next'
                                    : 'Close')
                              : (_currentQuestionIndex < _questions.length - 1
                                    ? 'Next'
                                    : 'Submit Quiz'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Floating Timer
          if (!_isSubmitted && !_isTimeUp)
            Positioned(
              top: widget.showAppBar
                  ? 8
                  : MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _timeRemaining <= 60 ? Colors.red : AppTheme.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.timer, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(_timeRemaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
