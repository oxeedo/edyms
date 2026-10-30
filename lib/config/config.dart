class AppConfig {
  const AppConfig._();

  /// Global app title
  static const String appTitle = 'Edmys';

  /// App version
  static const String appVersion = '1.0.0';

  /// Support email
  static const String supportEmail = 'support@example.com';

  /// Support phone number
  static const String supportPhone = '+1234567890';

  /// Base URL of the backend
  static const String baseUrl = 'https://edmys.com';

  /// API Base URL
  static const String apiBaseUrl = '$baseUrl/api';

  /// Helper to get full image URL
  static String getImageUrl(String? path) {
    if (path == null) return '';
    if (path.startsWith('http')) return path;
    return '$baseUrl/storage/$path';
  }
}
