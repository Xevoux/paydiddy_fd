import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:paydiddy/providers/user_provider.dart';
import 'package:paydiddy/providers/game_provider.dart';
import 'package:paydiddy/providers/transaction_provider.dart';
import 'config/app_routes.dart';
import 'package:paydiddy/utils/constants.dart';
import 'package:provider/provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayDiddy - Top Up Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppConstants.primaryColor,
        fontFamily: 'Poppins',
        appBarTheme: AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            side: BorderSide(color: AppConstants.primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppConstants.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16
          ),
          prefixIconColor: Colors.grey,
          suffixIconColor: Colors.grey,
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: 2,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: Colors.grey,
        ),
      ),
      // Use the route generator from AppRoutes
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}