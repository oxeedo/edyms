import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/auth/auth_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/dashboard/my_courses_screen.dart';
import '../screens/dashboard/my_assignments_screen.dart';
import '../screens/dashboard/my_quiz_attempts_screen.dart';
import '../screens/dashboard/certificates_screen.dart';
import '../screens/dashboard/my_ticket_bookings_screen.dart';
import '../screens/dashboard/payments_screen.dart';
import '../screens/study_timer/pomodoro_timer_screen.dart';
import '../screens/study_timer/focus_progress_screen.dart';
import '../screens/habit_tracker/weekly_review_screen.dart';
import '../screens/ai_chat/ai_chat_screen.dart';
import '../screens/ai_suggestions/ai_suggestions_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/profile/notification_settings_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/change_password_screen.dart';
import '../screens/profile/payment_history_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/community/qa_room_screen.dart';
import '../screens/ai_learning_path/ai_learning_path_screen.dart';
import '../screens/chat/conversations_screen.dart';
import '../screens/chat/chat_screen.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String aiChat = '/ai-chat';
  static const String myCourses = '/my-courses';
  static const String myAssignments = '/my-assignments';
  static const String myQuizAttempts = '/my-quizzes';
  static const String certificates = '/certificates';
  static const String myTicketBookings = '/bookings';
  static const String payments = '/payments';
  static const String editProfile = '/edit-profile';
  static const String changePassword = '/change-password';
  static const String paymentHistory = '/payment-history';
  static const String notifications = '/notifications';
  static const String wishlist = '/wishlist';
  static const String qaRoom = '/qa-room';
  static const String aiLearningPath = '/ai-learning-path';
  static const String studyTimer = '/study-timer';
  static const String focusProgress = '/focus-progress';
  static const String weeklyReview = '/weekly-review';
  static const String aiSuggestions = '/ai-suggestions';
  static const String settings = '/settings';
  static const String notificationSettings = '/notification-settings';
  static const String messages = '/messages';
  static const String chatScreen = '/messages/chat';

  // List of routes that require authentication
  static final List<String> _protectedRoutes = [
    dashboard,
    profile,
    myCourses,
    myAssignments,
    myQuizAttempts,
    certificates,
    myTicketBookings,
    payments,
    editProfile,
    changePassword,
    paymentHistory,
    notifications,
    wishlist,
    qaRoom,
    aiLearningPath,
    aiChat,
    messages,
    chatScreen,
  ];

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final String? routeName = settings.name;

    // Check if the route is protected
    if (_protectedRoutes.contains(routeName)) {
      return MaterialPageRoute(
        builder: (context) =>
            AuthGuard(child: _buildScreen(routeName, settings.arguments)),
      );
    }

    return MaterialPageRoute(
      builder: (context) => _buildScreen(routeName, settings.arguments),
    );
  }

  static Widget _buildScreen(String? routeName, dynamic arguments) {
    switch (routeName) {
      case onboarding:
        return const OnboardingScreen();
      case auth:
        return const AuthScreen();
      case dashboard:
        return const DashboardScreen();
      case profile:
        return const ProfileScreen();
      case aiChat:
        return const AiChatScreen();
      case home:
        return const HomeScreen();
      case myCourses:
        return const MyCoursesScreen();
      case myAssignments:
        return const MyAssignmentsScreen();
      case myQuizAttempts:
        return const MyQuizAttemptsScreen();
      case certificates:
        return const CertificatesScreen();
      case myTicketBookings:
        return const MyTicketBookingsScreen();
      case payments:
        return const PaymentsScreen();
      case editProfile:
        return const EditProfileScreen();
      case changePassword:
        return const ChangePasswordScreen();
      case paymentHistory:
        return const PaymentHistoryScreen();
      case notifications:
        return const NotificationsScreen();
      case wishlist:
        return const WishlistScreen();
      case qaRoom:
        return const QaRoomScreen();
      case aiLearningPath:
        return const AiLearningPathScreen();
      case studyTimer:
        return const PomodoroTimerScreen();
      case focusProgress:
        return const FocusProgressScreen();
      case weeklyReview:
        return const WeeklyReviewScreen();
      case aiSuggestions:
        return const AiSuggestionsScreen();
      case settings:
        return const SettingsScreen();
      case messages:
        return const ConversationsScreen();
      case chatScreen:
        final args = arguments as Map<String, dynamic>;
        return ChatScreen(
          conversationId: args['conversationId'] as int?,
          instructorId: args['instructorId'] as int?,
          instructorName: args['instructorName'] as String?,
        );
      case notificationSettings:
        return const NotificationSettingsScreen();
      default:
        // Default to onboarding or an error screen
        return const OnboardingScreen();
    }
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isAuthenticated) {
          return child;
        } else {
          // Redirect to login if not authenticated
          return const AuthScreen();
        }
      },
    );
  }
}
