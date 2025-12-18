import 'package:flutter/material.dart';
import 'home_main_page.dart';
import 'recommended_workout_page.dart';
import 'meal_plan_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});

  @override
  State<MainTabs> createState() => _MainTabsState();
}


class _MainTabsState extends State<MainTabs> {
  int _index = 0;

  final GlobalKey<HomeMainPageState> _homeKey =
    GlobalKey<HomeMainPageState>();


  void _changeTab(int index) {
    setState(() => _index = index);

    if (index == 0) {
      _homeKey.currentState?.loadWeeklySummary();
  }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeMainPage(onTabChange: _changeTab),
      const RecommendedWorkoutPage(),
      const MealPlanScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _index,
        onTap: _changeTab,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu_rounded), label: 'Meals'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

