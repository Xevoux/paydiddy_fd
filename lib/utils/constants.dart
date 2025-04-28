import 'package:flutter/material.dart';

class AppConstants {
  // Colors
  static final Color primaryColor = Colors.blue[900]!;
  static final Color secondaryColor = Colors.blue[700]!;
  static final Color accentColor = Colors.green;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color successColor = Colors.green;

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  // Padding & Margin
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultBorderRadius = 10.0;
  static const double largeBorderRadius = 20.0;
  static const double roundedBorderRadius = 30.0;

  // Durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 3);

  // Game Categories
  static const List<String> gameCategories = [
    'MOBA',
    'Battle Royale',
    'RPG',
    'FPS',
    'Casual',
    'Simulation',
    'Strategy',
    'Sports',
  ];

  // Transaction Status Colors
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Transaction Status Icons
  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'processing':
        return Icons.sync;
      case 'success':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      case 'cancelled':
        return Icons.cancel;
      case 'refunded':
        return Icons.replay;
      default:
        return Icons.help;
    }
  }

  // Shared Preferences Keys
  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String roleKey = 'role';
  static const String nameKey = 'name';
  static const String emailKey = 'email';

  // Error Messages
  static const String networkErrorMessage = 'Terjadi kesalahan saat menghubungi server. Silakan periksa koneksi internet Anda.';
  static const String generalErrorMessage = 'Terjadi kesalahan. Silakan coba lagi nanti.';
  static const String sessionExpiredMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
}