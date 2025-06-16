import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get apiUrl => dotenv.env['API_URL'] ?? 'http://192.168.198.117:8000/api';
  static String get appName => dotenv.env['APP_NAME'] ?? 'PayDiddy';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'development';

  // API Endpoints
  static String get loginEndpoint => '/login';
  static String get registerEndpoint => '/register';
  static String get logoutEndpoint => '/logout';
  static String get userEndpoint => '/user';

  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String roleKey = 'role';
  static const String nameKey = 'name';

  // App Theme Colors
  static const String primaryColorHex = '#0D47A1'; // Dark Blue
  static const String secondaryColorHex = '#1976D2'; // Blue
  static const String accentColorHex = '#4CAF50'; // Green
  static const String warningColorHex = '#FF9800'; // Orange
  static const String errorColorHex = '#F44336'; // Red
  static const String successColorHex = '#4CAF50'; // Green
}