import 'package:flutter/material.dart';
import 'package:paydiddy/models/game.dart';
import 'package:paydiddy/models/game_package.dart';
import 'package:paydiddy/models/transaction.dart';
import 'package:paydiddy/screens/auth/login_screen.dart';
import 'package:paydiddy/screens/auth/register_screen.dart';
import 'package:paydiddy/screens/customer/customer_home_screen.dart';
import 'package:paydiddy/screens/admin/admin_home_screen.dart';
import 'package:paydiddy/screens/customer/transaction_history_screen.dart';
import 'package:paydiddy/screens/customer/transaction_detail_screen.dart';
import 'package:paydiddy/screens/customer/transaction_success_screen.dart';
import 'package:paydiddy/screens/customer/game_detail_screen.dart';
import 'package:paydiddy/screens/customer/game_list_screen.dart';
import 'package:paydiddy/screens/customer/top_up_screen.dart';
import 'package:paydiddy/screens/customer/customer_settings_screen.dart';
import 'package:paydiddy/screens/admin/admin_settings_screen.dart';
import 'package:paydiddy/screens/splash_screen.dart';
import 'package:paydiddy/screens/customer/edit_profile_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String customerHome = '/customer/home';
  static const String adminHome = '/admin/home';
  static const String gameList = '/customer/games';
  static const String gameDetail = '/customer/games/detail';
  static const String topUp = '/customer/topup';
  static const String transactionHistory = '/customer/transactions';
  static const String transactionDetail = '/customer/transactions/detail';
  static const String transactionSuccess = '/customer/transactions/success';
  static const String customerSettings = '/customer/settings';
  static const String adminSettings = '/admin/settings';
  static const String editProfile = '/customer/edit-profile';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case customerHome:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());

      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());

      case gameList:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => GameListScreen(
            category: args?['category'],
            title: args?['title'] ?? 'Daftar Game',
          ),
        );

      case gameDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GameDetailScreen(
            gameId: args['gameId'],
            gameName: args['gameName'],
            gameImage: args['gameImage'],
          ),
        );

      case topUp:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TopUpScreen(
            game: args['game'],
            package: args['package'],
            gameUserId: args['gameUserId'],
            gameUsername: args['gameUsername'],
          ),
        );

      case transactionHistory:
        return MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());

      case transactionDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(
            transaction: args['transaction'],
          ),
        );

      case transactionSuccess:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TransactionSuccessScreen(
            transaction: args['transaction'],
          ),
        );

      case customerSettings:
        return MaterialPageRoute(builder: (_) => const CustomerSettingsScreen());

      case adminSettings:
        return MaterialPageRoute(builder: (_) => const AdminSettingsScreen());

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      default:
      // If the route is not found, return a 404 page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: const Center(child: Text('Page not found')),
          ),
        );
    }
  }

  // Navigation helper methods
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void navigateToRegister(BuildContext context) {
    Navigator.pushNamed(context, register);
  }

  static void navigateToCustomerHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, customerHome, (route) => false);
  }

  static void navigateToAdminHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, adminHome, (route) => false);
  }

  static void navigateToGameList(BuildContext context, {String? category, String? title}) {
    Navigator.pushNamed(
      context,
      gameList,
      arguments: {
        'category': category,
        'title': title ?? (category != null ? 'Game $category' : 'Semua Game'),
      },
    );
  }

  static void navigateToGameDetail(BuildContext context, {
    required int gameId,
    required String gameName,
    String? gameImage,
  }) {
    Navigator.pushNamed(
      context,
      gameDetail,
      arguments: {
        'gameId': gameId,
        'gameName': gameName,
        'gameImage': gameImage,
      },
    );
  }

  static void navigateToTopUp(BuildContext context, {
    required Game game,
    required GamePackage package,
    required String gameUserId,
    required String gameUsername,
  }) {
    Navigator.pushNamed(
      context,
      topUp,
      arguments: {
        'game': game,
        'package': package,
        'gameUserId': gameUserId,
        'gameUsername': gameUsername,
      },
    );
  }

  static void navigateToTransactionHistory(BuildContext context) {
    Navigator.pushNamed(context, transactionHistory);
  }

  static void navigateToTransactionDetail(BuildContext context, Transaction transaction) {
    Navigator.pushNamed(
      context,
      transactionDetail,
      arguments: {
        'transaction': transaction,
      },
    );
  }

  static void navigateToTransactionSuccess(BuildContext context, Transaction transaction) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      transactionSuccess,
          (route) => false,
      arguments: {
        'transaction': transaction,
      },
    );
  }

  static void navigateToCustomerSettings(BuildContext context) {
    Navigator.pushNamed(context, customerSettings);
  }

  static void navigateToAdminSettings(BuildContext context) {
    Navigator.pushNamed(context, adminSettings);
  }

  static void navigateToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, editProfile);
  }
}