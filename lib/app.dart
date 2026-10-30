import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/config.dart';
import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';
import 'router/app_router.dart';
import 'screens/splash/splash_wrapper.dart';
import 'theme/app_theme.dart';

/// Root widget of the application
class EduExApp extends StatelessWidget {
  const EduExApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Set status bar style based on dark mode
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: settingsProvider.isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: settingsProvider.isDarkMode
            ? Brightness.dark
            : Brightness.light,
      ),
    );

    if (settingsProvider.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsProvider.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        home: Scaffold(
          backgroundColor: settingsProvider.isDarkMode
              ? AppTheme.backgroundDark
              : AppTheme.splashBackground,
          body: Center(
            child: CircularProgressIndicator(
              color: settingsProvider.isDarkMode
                  ? AppTheme.primaryDark
                  : AppTheme.primary,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: settingsProvider.settings?.siteName ?? AppConfig.appTitle,
      theme: AppTheme.theme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: settingsProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashWrapper(),
      onGenerateRoute: AppRouter.onGenerateRoute,
      builder: (BuildContext context, Widget? child) {
        // Set status bar style based on theme mode
        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
            statusBarBrightness: isDarkMode
                ? Brightness.dark
                : Brightness.light,
          ),
        );
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(
              context,
            ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
          ),
          child: child!,
        );
      },
    );
  }
}
