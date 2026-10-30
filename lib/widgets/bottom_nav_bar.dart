import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
import '../screens/home/home_screen.dart';
import '../screens/courses/courses_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/instructor/all_instructors_screen.dart';
import '../screens/events/events_screen.dart';

enum BottomNavTab { home, instructors, courses, events, profile }

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentTab});

  final BottomNavTab currentTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _BottomNavItem(
            label: context.l10n.home,
            icon: HugeIcons.strokeRoundedHome01,
            isActive: currentTab == BottomNavTab.home,
            onTap: () {
              if (currentTab != BottomNavTab.home) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                );
              }
            },
          ),
          _BottomNavItem(
            label: 'Instructors',
            icon: HugeIcons.strokeRoundedUserGroup,
            isActive: currentTab == BottomNavTab.instructors,
            onTap: () {
              if (currentTab != BottomNavTab.instructors) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AllInstructorsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                );
              }
            },
          ),
          _BottomNavItem(
            label: context.l10n.courses,
            icon: HugeIcons.strokeRoundedBook01,
            isActive: currentTab == BottomNavTab.courses,
            onTap: () {
              if (currentTab != BottomNavTab.courses) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const CoursesScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                );
              }
            },
          ),
          _BottomNavItem(
            label: context.l10n.events,
            icon: HugeIcons.strokeRoundedCalendar01,
            isActive: currentTab == BottomNavTab.events,
            onTap: () {
              if (currentTab != BottomNavTab.events) {
                Navigator.of(context).pushReplacement(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const EventsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                    transitionDuration: const Duration(milliseconds: 200),
                  ),
                );
              }
            },
          ),
          _BottomNavItem(
            label: context.l10n.profile,
            icon: HugeIcons.strokeRoundedProfile,
            isActive: currentTab == BottomNavTab.profile,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final dynamic icon;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = AppTheme.getTextColor(context);
    final Color color = isActive ? textColor : textColor.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border(top: BorderSide(color: textColor, width: 2))
                  : null,
            ),
            child: HugeIcon(icon: icon, size: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
