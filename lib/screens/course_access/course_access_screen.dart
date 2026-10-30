import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

import 'dart:convert';

import 'package:hugeicons/hugeicons.dart';
import '../../router/app_router.dart';
import '../../services/student_course_service.dart';
import '../../theme/app_theme.dart';
import 'quiz_attempt_screen.dart';
import 'assignment_submit_screen.dart';

class CourseAccessScreen extends StatefulWidget {
  final int courseId;
  final String courseTitle;

  const CourseAccessScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseAccessScreen> createState() => _CourseAccessScreenState();
}

class _CourseAccessScreenState extends State<CourseAccessScreen> {
  final StudentCourseService _studentCourseService = StudentCourseService();

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _currentLesson;
  List<dynamic> _topics = [];

  // Video Controllers
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubePlayerController;
  String? _vimeoVideoId;

  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    // Block screenshots & screen recording to protect course content
    NoScreenshot.instance.screenshotOff();
    _fetchCourseCurriculum();
  }

  @override
  void dispose() {
    // Re-enable screenshots when leaving the protected screen
    NoScreenshot.instance.screenshotOn();
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubePlayerController?.dispose();
    _videoPlayerController = null;
    _chewieController = null;
    _youtubePlayerController = null;
    _vimeoVideoId = null;
  }

  Future<void> _fetchCourseCurriculum() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _studentCourseService.getCourseCurriculum(
        widget.courseId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            _topics = data['data']['topics'] ?? [];
            _isLoading = false;
          });

          // Load current item if available
          if (data['data']['current_item'] != null) {
            final currentItem = data['data']['current_item'];
            if (currentItem['type'] == 'lesson') {
              // Wait for UI build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadLesson(currentItem['id']);
              });
            }
          }
        } else {
          setState(() {
            _error = data['message'] ?? 'Failed to load course data';
            _isLoading = false;
          });
        }
      } else {
        if (response.statusCode == 403) {
          setState(() {
            _error = 'Access Denied. You are not enrolled in this course.';
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'Failed to load course. Status: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLesson(int lessonId) async {
    setState(() {
      _isVideoLoading = true;
    });

    // Pause existing players
    _disposeVideoControllers();

    try {
      final response = await _studentCourseService.loadLesson(
        widget.courseId,
        lessonId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;
          setState(() {
            _currentLesson = data['data'];
          });
          _initializeVideoPlayer(data['data']['video']);
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lesson: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      // debugPrint('Error loading lesson: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isVideoLoading = false;
        });
      }
    }
  }

  void _initializeVideoPlayer(Map<String, dynamic> videoData) {
    if (videoData['is_youtube'] == true && videoData['video_id'] != null) {
      _youtubePlayerController = YoutubePlayerController(
        initialVideoId: videoData['video_id'],
        flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
      );
      setState(() {
        _isVideoLoading = false;
      });
    } else if (videoData['is_vimeo'] == true && videoData['video_id'] != null) {
      setState(() {
        _vimeoVideoId = videoData['video_id'];
        _isVideoLoading = false;
      });
    } else if (videoData['url'] != null) {
      // debugPrint('Initializing video with URL: ${videoData['url']}');
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoData['url']),
      );
      _videoPlayerController!
          .initialize()
          .then((_) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoPlayerController!,
                autoPlay: true,
                looping: false,
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                deviceOrientationsOnEnterFullScreen: const [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ],
                deviceOrientationsAfterFullScreen: const [
                  DeviceOrientation.portraitUp,
                ],
                systemOverlaysOnEnterFullScreen: const [],
                systemOverlaysAfterFullScreen: SystemUiOverlay.values,
                errorBuilder: (context, errorMessage) {
                  return Center(
                    child: Text(
                      'Error playing video: $errorMessage',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              );
              _isVideoLoading = false;
            });
          })
          .catchError((error) {
            setState(() {
              _isVideoLoading = false;
              _error = 'Failed to load video: $error. URL: ${videoData['url']}';
            });
            // debugPrint('Video initialization error: $error');
          });
    } else {
      setState(() {
        _isVideoLoading = false;
      });
    }
  }

  Future<void> _markComplete() async {
    if (_currentLesson == null) return;

    try {
      final lessonId = _currentLesson!['lesson']['id'];
      final response = await _studentCourseService.markLessonComplete(
        widget.courseId,
        lessonId,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lesson Completed!')));

          // Refresh curriculum to show checkmark
          _fetchCourseCurriculum();

          // Auto-advance if next item exists
          if (data['next_item'] != null) {
            final next = data['next_item'];
            if (next['type'] == 'lesson') {
              _loadLesson(next['id']);
            }
          }
        }
      }
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  List<dynamic> _getFlattenedItems() {
    final List<dynamic> items = [];
    for (var topic in _topics) {
      if (topic['items'] != null) {
        items.addAll(topic['items']);
      }
    }
    return items;
  }

  int _getCurrentIndex() {
    if (_currentLesson == null) return -1;
    final allItems = _getFlattenedItems();
    final currentId = _currentLesson!['lesson']['id'];
    return allItems.indexWhere(
      (item) => item['id'] == currentId && item['type'] == 'lesson',
    );
  }

  bool _hasPreviousItem() {
    final index = _getCurrentIndex();
    return index > 0;
  }

  bool _hasNextItem() {
    final index = _getCurrentIndex();
    final allItems = _getFlattenedItems();
    // Check if next item exists and is accessible
    if (index >= 0 && index < allItems.length - 1) {
      // Find next lesson (skip non-lessons if needed, but for now navigate all)
      // Assuming we only navigate lessons here or handle types in load
      return true;
    }
    return false;
  }

  void _goToPrevious() {
    final index = _getCurrentIndex();
    if (index > 0) {
      final allItems = _getFlattenedItems();
      final prevItem = allItems[index - 1];
      if (prevItem['type'] == 'lesson') {
        _loadLesson(prevItem['id']);
      }
    }
  }

  void _goToNext() {
    final index = _getCurrentIndex();
    final allItems = _getFlattenedItems();
    if (index >= 0 && index < allItems.length - 1) {
      final nextItem = allItems[index + 1];

      if (nextItem['is_accessible'] == false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Next lesson is locked. Complete the current one first.',
            ),
          ),
        );
        return;
      }

      if (nextItem['type'] == 'lesson') {
        _loadLesson(nextItem['id']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_youtubePlayerController != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _youtubePlayerController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: AppTheme.primary,
        ),
        builder: (context, player) {
          return _buildScaffold(context, player);
        },
      );
    }
    return _buildScaffold(context, null);
  }

  Widget _buildScaffold(BuildContext context, Widget? youtubePlayer) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.aiChat);
        },
        backgroundColor: AppTheme.primary,
        child: const HugeIcon(
          icon: HugeIcons.strokeRoundedAiChat02,
          size: 24,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            )
          : Column(
              children: [
                // Video Player Section
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: _isVideoLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : (youtubePlayer ?? _buildVideoPlayer()),
                  ),
                ),

                // Lesson Title & Controls
                if (_currentLesson != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: _hasPreviousItem()
                                  ? _goToPrevious
                                  : null,
                              icon: const Icon(Icons.arrow_back_ios),
                              tooltip: 'Previous Lesson',
                            ),
                            Expanded(
                              child: Text(
                                _currentLesson!['lesson']['title'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            IconButton(
                              onPressed: _hasNextItem() ? _goToNext : null,
                              icon: const Icon(Icons.arrow_forward_ios),
                              tooltip: 'Next Lesson',
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _markComplete,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Mark Complete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.getPrimaryColor(
                                  context,
                                ),
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 1),

                // Curriculum List
                Expanded(
                  child: ListView.builder(
                    itemCount: _topics.length,
                    itemBuilder: (context, index) {
                      final topic = _topics[index];
                      final items = topic['items'] as List<dynamic>;

                      return ExpansionTile(
                        title: Text(topic['title']),
                        initiallyExpanded: index == 0,
                        children: items.map((item) {
                          final isLesson = item['type'] == 'lesson';
                          final isCompleted = item['is_completed'] == true;
                          final isLocked = item['is_accessible'] == false;
                          final isCurrent =
                              _currentLesson != null &&
                              _currentLesson!['lesson']['id'] == item['id'] &&
                              item['type'] == 'lesson';

                          return ListTile(
                            leading: Icon(
                              isLocked
                                  ? Icons.lock
                                  : (isLesson
                                        ? Icons.play_circle_outline
                                        : Icons.quiz),
                              color: isLocked
                                  ? Colors.grey
                                  : (isCurrent
                                        ? AppTheme.getPrimaryColor(context)
                                        : null),
                            ),
                            title: Text(
                              item['title'],
                              style: TextStyle(
                                color: isCurrent
                                    ? AppTheme.getPrimaryColor(context)
                                    : null,
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: isCompleted
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : null,
                            onTap: isLocked
                                ? null
                                : () {
                                    if (isLesson) {
                                      _loadLesson(item['id']);
                                    } else if (item['type'] == 'quiz') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QuizAttemptScreen(
                                                courseId: widget.courseId,
                                                quizId: item['id'],
                                                quizTitle: item['title'],
                                                showAppBar: true,
                                              ),
                                        ),
                                      ).then(
                                        (_) => _fetchCourseCurriculum(),
                                      ); // Refresh on return
                                    } else if (item['type'] == 'assignment') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AssignmentSubmitScreen(
                                                courseId: widget.courseId,
                                                assignmentId: item['id'],
                                                assignmentTitle: item['title'],
                                                showAppBar: true,
                                              ),
                                        ),
                                      ).then(
                                        (_) => _fetchCourseCurriculum(),
                                      ); // Refresh on return
                                    } else {
                                      // Handle unknown types
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Item type not supported yet.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_youtubePlayerController != null) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    } else if (_vimeoVideoId != null) {
      return VimeoVideoPlayer(videoId: _vimeoVideoId!);
    } else if (_chewieController != null &&
        _videoPlayerController != null &&
        _videoPlayerController!.value.isInitialized) {
      return Chewie(controller: _chewieController!);
    } else {
      if (_error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return const Center(
        child: Text(
          'Select a lesson to start playing',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }
}
