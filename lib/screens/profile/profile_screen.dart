import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/config.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../app.dart';
import '../../providers/settings_provider.dart';
import '../common/webview_screen.dart';
import '../../router/app_router.dart';

class _LanguageData {
  const _LanguageData({
    required this.locale,
    required this.name,
    required this.iconPath,
  });

  final Locale locale;
  final String name;
  final String iconPath;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<_LanguageData> get _availableLanguages {
    return AppLocalizations.supportedLocales.map((locale) {
      String name;
      String iconPath;
      switch (locale.languageCode) {
        case 'en':
          name = 'English';
          iconPath = 'assets/img/icons/en.png';
          break;
        case 'es':
          name = 'Spanish';
          iconPath = 'assets/img/icons/es.png';
          break;
        case 'bn':
          name = 'বাংলা';
          iconPath = 'assets/img/icons/bn.png';
          break;
        case 'hi':
          name = 'हिन्दी';
          iconPath = 'assets/img/icons/hi.png';
          break;
        case 'fr':
          name = 'Français';
          iconPath = 'assets/img/icons/fr.png';
          break;
        default:
          name = locale.languageCode.toUpperCase();
          iconPath = 'assets/img/icons/en.png';
      }
      return _LanguageData(locale: locale, name: name, iconPath: iconPath);
    }).toList();
  }

  String get _currentLanguageName {
    final currentLocale = Localizations.localeOf(context);
    return _availableLanguages
        .firstWhere(
          (lang) => lang.locale.languageCode == currentLocale.languageCode,
          orElse: () => _availableLanguages.first,
        )
        .name;
  }

  bool get _isDarkMode {
    return Theme.of(context).brightness == Brightness.dark;
  }

  void _toggleDarkMode(bool value) {
    Provider.of<SettingsProvider>(context, listen: false).setDarkMode(value);
  }

  void _showLanguageSheet(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.getCardColor(context),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.getTextColor(context).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text(
                  context.l10n.language,
                  style: TextStyle(
                    color: AppTheme.getTextColor(context),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              // Language options
              ..._availableLanguages.map((language) {
                final isSelected =
                    language.locale.languageCode == currentLocale.languageCode;
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _changeLanguage(context, language.locale);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.getMint100(context)
                          : AppTheme.getSoftGray150(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.getTextColor(context)
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              language.iconPath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppTheme.getMint100(context),
                                  child: Center(
                                    child: HugeIcon(
                                      icon:
                                          HugeIcons.strokeRoundedLanguageCircle,
                                      size: 20,
                                      color: AppTheme.getTextColor(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            language.name,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                            size: 24,
                            color: AppTheme.getTextColor(context),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _changeLanguage(BuildContext context, Locale locale) {
    Provider.of<SettingsProvider>(context, listen: false).setLocale(locale);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final user = auth.user;
        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(context),
          body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
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
                            context.l10n.profile,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.getTextColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  // Profile Header Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: <Widget>[
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child:
                                (user?.profilePhoto != null &&
                                    user!.profilePhoto!.isNotEmpty)
                                ? Image.network(
                                    AppConfig.getImageUrl(user.profilePhoto),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                              'assets/img/default-profile.png',
                                              fit: BoxFit.cover,
                                            ),
                                  )
                                : Image.asset(
                                    'assets/img/default-profile.png',
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // Name
                              Text(
                                user?.name ?? 'Guest User',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(context),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Level Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.getMint100(context),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${context.l10n.level}: ${context.l10n.levelValue}',
                                  style: TextStyle(
                                    color: AppTheme.getPrimaryColor(context),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Email
                              Text(
                                user?.email ?? '',
                                style: TextStyle(
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.6),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 1: Learning & Progress
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Learning & Progress',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItemWithCustomIcon(
                          icon: Icons.dashboard,
                          title: context.l10n.dashboard,
                          subtitle: 'View your learning overview',
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.dashboard);
                          },
                        ),
                        // _MenuItemWithCustomIcon(
                        //   icon: Icons.home,
                        //   title: 'Home 2',
                        //   subtitle: 'Alternative home screen',
                        //   onTap: () {
                        //     Navigator.of(context).push(
                        //       MaterialPageRoute(
                        //         builder: (context) => const Home2Screen(),
                        //       ),
                        //     );
                        //   },
                        // ),
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedBook01,
                          title: context.l10n.myCourses,
                          subtitle: context.l10n.myCoursesSubtitle,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.myCourses);
                          },
                        ),
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedAssignments,
                          title: context.l10n.myAssignments,
                          subtitle: 'View your assignments',
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.myAssignments);
                          },
                        ),
                        _MenuItemWithCustomIcon(
                          icon: Icons.quiz,
                          title: context.l10n.myQuizAttempts,
                          subtitle: context.l10n.quizHistory,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.myQuizAttempts);
                          },
                        ),
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedCertificate01,
                          title: context.l10n.certificates,
                          subtitle: context.l10n.earnedCertificates,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.certificates);
                          },
                        ),
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedTicket01,
                          title: context.l10n.myTicketBookings,
                          subtitle: context.l10n.ticketBookings,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.myTicketBookings);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 2: Productivity & Tracking
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Productivity & Tracking',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItemWithCustomIcon(
                          icon: Icons.timer_outlined,
                          title: 'Study Timer',
                          subtitle: 'Pomodoro timer for focused study sessions',
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.studyTimer);
                          },
                        ),
                        _MenuItemWithCustomIcon(
                          icon: Icons.trending_up,
                          title: 'Focus Progress',
                          subtitle: 'Track your study sessions and progress',
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.focusProgress);
                          },
                        ),
                        _MenuItemWithCustomIcon(
                          icon: Icons.calendar_today,
                          title: 'Weekly Review',
                          subtitle:
                              'Review your weekly progress and achievements',
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.weeklyReview);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 3: AI Tools
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'AI Tools',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedAiChat02,
                          title: 'Nova - AI Assistant',
                          subtitle: 'Chat with our AI powered assistant',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.aiChat);
                          },
                        ),
                        _MenuItemWithCustomIcon(
                          icon: Icons.auto_awesome,
                          title: context.l10n.aiPreferences,
                          subtitle: context.l10n.aiPreferencesSubtitle,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.aiSuggestions);
                          },
                        ),
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedAiUser,
                          title: 'AI Learning Path Generator',
                          subtitle: 'Generate personalized learning roadmap',
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.aiLearningPath);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 4: Community
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Community',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItemWithCustomIcon(
                          icon: Icons.question_answer_outlined,
                          title: context.l10n.qaRoom,
                          subtitle: context.l10n.askAndAnswerQuestions,
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.qaRoom);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 5: Account & Payments
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Account & Payments',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItemWithCustomIcon(
                          icon: Icons.payment,
                          title: context.l10n.payments,
                          subtitle: context.l10n.paymentHistory,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.paymentHistory);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 6: Settings & Preferences
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Settings & Preferences',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedSettings01,
                          title: context.l10n.settings,
                          subtitle: context.l10n.settingsSubtitle,
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.settings);
                          },
                        ),
                        _MenuItem(
                          icon: HugeIcons.strokeRoundedNotification01,
                          title: context.l10n.notifications,
                          subtitle: context.l10n.notificationsSubtitle,
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(AppRouter.notificationSettings);
                          },
                        ),
                        // Dark Mode Toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.getMint100(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedMoon01,
                                    size: 20,
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
                                      context.l10n.darkMode,
                                      style: TextStyle(
                                        color: AppTheme.getTextColor(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      context.l10n.darkModeSubtitle,
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
                              Switch(
                                value: _isDarkMode,
                                onChanged: _toggleDarkMode,
                                activeThumbColor: AppTheme.getTextColor(
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Language Switcher
                        GestureDetector(
                          onTap: () => _showLanguageSheet(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppTheme.getMint100(context),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: HugeIcon(
                                      icon:
                                          HugeIcons.strokeRoundedLanguageCircle,
                                      size: 20,
                                      color: AppTheme.getTextColor(context),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        context.l10n.language,
                                        style: TextStyle(
                                          color: AppTheme.getTextColor(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _currentLanguageName,
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
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedArrowDown01,
                                  size: 20,
                                  color: AppTheme.getTextColor(
                                    context,
                                  ).withValues(alpha: 0.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Group 7: Support & Info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Support & Info',
                      style: TextStyle(
                        color: AppTheme.getTextColor(
                          context,
                        ).withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.getCardColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: <Widget>[
                        _MenuItemWithCustomIcon(
                          icon: Icons.help_outline,
                          title: context.l10n.helpSupport,
                          subtitle: context.l10n.helpSupportSubtitle,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  url: '${AppConfig.baseUrl}/contact',
                                  title: context.l10n.helpSupport,
                                ),
                              ),
                            );
                          },
                        ),
                        _MenuItemWithCustomIcon(
                          icon: Icons.info_outline,
                          title: context.l10n.about,
                          subtitle: context.l10n.aboutSubtitle,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => WebViewScreen(
                                  url: '${AppConfig.baseUrl}/about',
                                  title: context.l10n.about,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  // Login Button - only show if NOT authenticated
                  if (!auth.isAuthenticated) ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.auth);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLogin01,
                              size: 20,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.login,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Logout Button - only show if authenticated
                  if (auth.isAuthenticated) ...[
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.logout();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.logout),
                              backgroundColor: AppTheme.primary,
                            ),
                          );
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const EduExApp(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLogout01,
                              size: 20,
                              color: AppTheme.getTextColor(
                                context,
                              ).withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.l10n.logout,
                              style: TextStyle(
                                color: AppTheme.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final dynamic icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: HugeIcon(
                  icon: icon,
                  size: 20,
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
                    title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 20,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemWithCustomIcon extends StatelessWidget {
  const _MenuItemWithCustomIcon({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.getMint100(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
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
                    title,
                    style: TextStyle(
                      color: AppTheme.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
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
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 20,
              color: AppTheme.getTextColor(context).withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
