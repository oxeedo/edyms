import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primary = Color(0xFF004F44);
  static const Color splashBackground = Color(0xFFE7F1F6);
  static const Color mint100 = Color(0xFFE6F3F0);
  static const Color mint200 = Color(0xFFCCE7E1);
  static const Color mint300 = Color(0xFFB3DBD2);
  static const Color mint400 = Color(0xFF99CFC3);
  static const Color softOrange800 = Color.fromARGB(255, 241, 155, 80);
  static const Color softOrange900 = Color.fromARGB(255, 241, 155, 80);
  static const Color softBlue800 = Color.fromARGB(255, 76, 135, 238);
  static const Color softBlue900 = Color.fromARGB(255, 102, 153, 255);
  static const Color softGray150 = Color.fromARGB(255, 251, 252, 252);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF1A3A36);
  static const Color backgroundDark = Color(0xFF0E1616);
  static const Color surfaceDark = Color(0xFF16201F);
  static const Color mint100Dark = Color(0xFF14423C);
  static const Color mint200Dark = Color(0xFF1E5A52);
  static const Color mint300Dark = Color(0xFF267064);
  static const Color mint400Dark = Color(0xFF2E8777);

  static const TextTheme textTheme = TextTheme(
    displaySmall: TextStyle(
      color: primary,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    bodyMedium: TextStyle(color: primary),
  );

  static const TextTheme darkTextTheme = TextTheme(
    displaySmall: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
    bodyMedium: TextStyle(color: Colors.white),
  );

  static final ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: primary,
    primary: primary,
    secondary: primary,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    brightness: Brightness.light,
  );

  static final ColorScheme darkColorScheme = ColorScheme.fromSeed(
    seedColor: primaryDark,
    primary: primaryDark,
    secondary: primaryDark,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    brightness: Brightness.dark,
    surface: surfaceDark,
  );

  static ThemeData get theme {
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: 'Montserrat',
      textTheme: textTheme,
      scaffoldBackgroundColor: splashBackground,
      cardColor: Colors.white,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: darkColorScheme,
      useMaterial3: true,
      fontFamily: 'Montserrat',
      textTheme: darkTextTheme,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: surfaceDark,
    );
  }

  // Helper methods to get theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? backgroundDark : splashBackground;
  }

  static Color getCardColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? surfaceDark : Colors.white;
  }

  static Color getMint100(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? mint100Dark : mint100;
  }

  static Color getMint200(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? mint200Dark : mint200;
  }

  static Color getSoftGray150(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? surfaceDark : softGray150;
  }

  static Color getPrimaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? primaryDark : primary;
  }

  static Color getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : primary;
  }
}
