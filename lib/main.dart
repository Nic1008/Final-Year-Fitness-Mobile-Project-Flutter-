import 'package:fitnessapp/screens/greeting_screen.dart';

import 'screens/main_tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'package:fitnessapp/debug_check_prefs.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'package:fitnessapp/screens/profile_screen.dart';
import 'package:fitnessapp/screens/Notification_screen.dart';
import 'screens/greeting_onboarding_screen.dart';
// ignore: unused_import
import 'screens/home_main_page.dart';
import 'screens/recommended_workout_page.dart';
import 'theme/app_theme.dart';

import 'screens/meal_plan_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/cardio_progress_screen.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeManager(),
      child: const FitnessApp(),
    ),
  );
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
  title: 'Fitness App',
  debugShowCheckedModeBanner: false,
  navigatorObservers: [routeObserver],

  initialRoute: '/',

  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: themeManager.isDarkMode ? ThemeMode.dark : ThemeMode.light,

  routes: {
    '/': (_) => const GreetingScreen(),
    '/login': (_) => const LoginScreen(),
    '/signup': (_) => const SignupScreen(),
    '/greeting': (_) => const GreetingOnboardingScreen(),
    '/home': (_) => const MainTabs(),
    '/recommended': (_) => const RecommendedWorkoutPage(),
    '/debug': (_) => const DebugCheckPrefs(),
    '/profile': (_) => const ProfileScreen(),
    '/notifications': (_) => const NotificationsScreen(),
    '/mealplan': (_) => const MealPlanScreen(),
    '/progress': (_) => const ProgressScreen(),
    '/cardio': (_) => const CardioProgressScreen(),
  },
);
  }
}
