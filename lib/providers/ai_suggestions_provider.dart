import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/course.dart';
import '../services/course_service.dart';

class AiSuggestionsProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();

  // State Variables
  List<Category> _interests = [];
  final Set<int> _selectedCategoryIds = <int>{};
  String? _selectedSkillLevel;
  String? _selectedGoal;
  List<Course> _suggestedCourses = [];

  bool _isLoadingCategories = true;
  bool _isProcessing = false;
  bool _hasPreferences = false;
  String? _categoryError;

  // Getters
  List<Category> get interests => _interests;
  Set<int> get selectedCategoryIds => _selectedCategoryIds;
  String? get selectedSkillLevel => _selectedSkillLevel;
  String? get selectedGoal => _selectedGoal;
  List<Course> get suggestedCourses => _suggestedCourses;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isProcessing => _isProcessing;
  bool get hasPreferences => _hasPreferences;
  String? get categoryError => _categoryError;

  bool get canGetSuggestions =>
      _selectedCategoryIds.isNotEmpty &&
      _selectedSkillLevel != null &&
      _selectedGoal != null;

  // Constructor
  AiSuggestionsProvider() {
    fetchCategories();
  }

  // Actions
  Future<void> fetchCategories() async {
    _isLoadingCategories = true;
    _categoryError = null;
    notifyListeners();

    try {
      final response = await _courseService.fetchCategories();
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          _interests = data.map((json) => Category.fromJson(json)).toList();
        } else {
          _categoryError = 'Failed to load interests';
        }
      } else {
        _categoryError = 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      _categoryError = 'Connection error: $e';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  void toggleInterest(int id) {
    if (_selectedCategoryIds.contains(id)) {
      _selectedCategoryIds.remove(id);
    } else {
      _selectedCategoryIds.add(id);
    }
    notifyListeners();
  }

  void setSkillLevel(String level) {
    _selectedSkillLevel = level;
    notifyListeners();
  }

  void setGoal(String goal) {
    _selectedGoal = goal;
    notifyListeners();
  }

  Future<void> getSuggestions() async {
    if (!canGetSuggestions) return;

    _isProcessing = true;
    notifyListeners();

    try {
      final apiCall = _courseService.fetchCourses(
        categoryIds: _selectedCategoryIds.toList(),
      );

      // Ensure at least 2 seconds delay for the animation
      final results = await Future.wait<dynamic>([
        apiCall,
        Future.delayed(const Duration(seconds: 2)),
      ]);

      final response = results[0];

      if (response.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(response.body);
        List<dynamic>? coursesList;

        if (decodedBody is Map<String, dynamic>) {
          // Check for standard Laravel pagination (root has 'data')
          // or our custom wrapper (root has 'success': true and 'data')
          if (decodedBody.containsKey('success') &&
              decodedBody['success'] == true) {
            final data = decodedBody['data'];
            if (data is Map && data.containsKey('data')) {
              coursesList = data['data'];
            } else if (data is List) {
              coursesList = data;
            }
          } else if (decodedBody.containsKey('data') &&
              decodedBody['data'] is List) {
            // Standard Laravel pagination response
            coursesList = decodedBody['data'];
          }
        }

        if (coursesList != null) {
          _suggestedCourses = coursesList
              .map((json) => Course.fromJson(json))
              .toList();
          _hasPreferences = true;
        } else {
          // Handle empty or error
          _suggestedCourses = [];
        }
      } else {
        // Handle error
        _suggestedCourses = [];
      }
    } catch (e) {
      // Handle error
      _suggestedCourses = [];
      debugPrint('Error getting suggestions: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void updatePreferences() {
    _hasPreferences = false;
    _isProcessing = false;
    _selectedCategoryIds.clear();
    _selectedSkillLevel = null;
    _selectedGoal = null;
    _suggestedCourses.clear();
    notifyListeners();
  }
}
