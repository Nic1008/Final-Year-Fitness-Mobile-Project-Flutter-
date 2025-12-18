// lib/models/meal_plan_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'meal.dart';

enum MealCategory { breakfast, lunch, dinner }

class MealPlanManager {
  MealPlanManager._internal();
  static final MealPlanManager _instance = MealPlanManager._internal();
  factory MealPlanManager() => _instance;

  bool _loaded = false;

  String? _activeUserKey;

  // ------------------------------------------------------------
  //  GET UNIQUE USER KEY (uses saved email from SharedPreferences)
  // ------------------------------------------------------------
  Future<String> _getUserKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email") ?? "guest";
  }

  // --------------------- DAILY PLAN DATA -----------------------
  final List<Meal> _breakfastPlan = [];
  final List<Meal> _lunchPlan = [];
  final List<Meal> _dinnerPlan = [];

  List<Meal> get breakfastPlan => List.unmodifiable(_breakfastPlan);
  List<Meal> get lunchPlan => List.unmodifiable(_lunchPlan);
  List<Meal> get dinnerPlan => List.unmodifiable(_dinnerPlan);

  // --------------------- CUSTOM MEALS --------------------------
  final List<Meal> _customMeals = [];
  List<Meal> get customMeals => List.unmodifiable(_customMeals);

  // --------------------- DAILY GOALS ---------------------------
  double dailyCalorieGoal = 2500;
  double proteinGoal = 120;
  double fatGoal = 80;

  // ------------------------------------------------------------
  //                         LOAD DATA
  // ------------------------------------------------------------
  Future<void> load() async {
  final prefs = await SharedPreferences.getInstance();
  final key = await _getUserKey();

  // 🔑 If user changed, reset everything
  if (_activeUserKey != key) {
    resetForNewUser();
    _activeUserKey = key;
    _loaded = false;
  }

  if (_loaded) return;

  _breakfastPlan.addAll(
      Meal.decodeList(prefs.getString("plan_breakfast_$key")));

  _lunchPlan.addAll(
      Meal.decodeList(prefs.getString("plan_lunch_$key")));

  _dinnerPlan.addAll(
      Meal.decodeList(prefs.getString("plan_dinner_$key")));

  _customMeals.addAll(
      Meal.decodeList(prefs.getString("lib_custom_meals_$key")));

  dailyCalorieGoal =
      prefs.getDouble("dailyCalorieGoal_$key") ?? dailyCalorieGoal;

  proteinGoal =
      prefs.getDouble("proteinGoal_$key") ?? proteinGoal;

  fatGoal =
      prefs.getDouble("fatGoal_$key") ?? fatGoal;

  _loaded = true;
}


  // ------------------------------------------------------------
  //                         SAVE DATA
  // ------------------------------------------------------------
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getUserKey();

    await prefs.setString(
        "plan_breakfast_$key", Meal.encodeList(_breakfastPlan));

    await prefs.setString(
        "plan_lunch_$key", Meal.encodeList(_lunchPlan));

    await prefs.setString(
        "plan_dinner_$key", Meal.encodeList(_dinnerPlan));

    await prefs.setString(
        "lib_custom_meals_$key", Meal.encodeList(_customMeals));

    await prefs.setDouble("dailyCalorieGoal_$key", dailyCalorieGoal);
    await prefs.setDouble("proteinGoal_$key", proteinGoal);
    await prefs.setDouble("fatGoal_$key", fatGoal);
  }

  // ------------------------------------------------------------
  //   UPDATE GOALS FROM USER INPUT (HEIGHT / WEIGHT / AGE / GENDER)
  // ------------------------------------------------------------
  void updateGoals({
    required double heightCm,
    required double weightKg,
    required int age,
    required String gender, // "Male" | "Female" | "Other"
    double activityMultiplier = 1.55, // Moderate activity default
  }) {
    // ----- BMR -----
    double bmr;

    if (gender == "Male") {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    } else if (gender == "Female") {
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
    } else {
      // Neutral baseline (midpoint)
      bmr = 10 * weightKg + 6.25 * heightCm - 5 * age - 80;
    }

    // ----- Total daily expenditure -----
    double tdee = bmr * activityMultiplier;

    // ----- Surplus for lean bulk -----
    dailyCalorieGoal = tdee + 300;

    // ----- Protein (muscle growth target) -----
    proteinGoal = weightKg * 1.8;

    // ----- Fat (25% of calories) -----
    fatGoal = (dailyCalorieGoal * 0.25) / 9;

    _save();
  }

  // ------------------------------------------------------------
  //                 RESET WHEN USER CHANGES
  // ------------------------------------------------------------
  void resetForNewUser() {
    _loaded = false;

    _breakfastPlan.clear();
    _lunchPlan.clear();
    _dinnerPlan.clear();
    _customMeals.clear();
  }

  // ------------------------------------------------------------
  //               CLEAR DATA FOR CURRENT USER ONLY
  // ------------------------------------------------------------
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _getUserKey();

    await prefs.remove("plan_breakfast_$key");
    await prefs.remove("plan_lunch_$key");
    await prefs.remove("plan_dinner_$key");
    await prefs.remove("lib_custom_meals_$key");

    await prefs.remove("dailyCalorieGoal_$key");
    await prefs.remove("proteinGoal_$key");
    await prefs.remove("fatGoal_$key");

    resetForNewUser();
  }

  // ------------------------------------------------------------
  //                     ADD / REMOVE MEALS
  // ------------------------------------------------------------
  void addToPlan(MealCategory category, Meal meal) {
    final copy = meal.copyWith();

    switch (category) {
      case MealCategory.breakfast:
        _breakfastPlan.add(copy);
        break;
      case MealCategory.lunch:
        _lunchPlan.add(copy);
        break;
      case MealCategory.dinner:
        _dinnerPlan.add(copy);
        break;
    }

    _save();
  }

  void removeFromPlan(MealCategory category, int index) {
    switch (category) {
      case MealCategory.breakfast:
        if (index < _breakfastPlan.length) _breakfastPlan.removeAt(index);
        break;

      case MealCategory.lunch:
        if (index < _lunchPlan.length) _lunchPlan.removeAt(index);
        break;

      case MealCategory.dinner:
        if (index < _dinnerPlan.length) _dinnerPlan.removeAt(index);
        break;
    }

    _save();
  }

  void clearAll() {
    _breakfastPlan.clear();
    _lunchPlan.clear();
    _dinnerPlan.clear();
    _save();
  }

  // ------------------------------------------------------------
  //                      CUSTOM MEALS
  // ------------------------------------------------------------
  void addCustomMeal(Meal meal) {
    _customMeals.add(meal);
    _save();
  }

  void removeCustomMeal(String mealId) {
    _customMeals.removeWhere((m) => m.id == mealId);
    _save();
  }

  // ------------------------------------------------------------
  //                    TOTAL MACROS
  // ------------------------------------------------------------
  List<Meal> get _allPlan =>
      [..._breakfastPlan, ..._lunchPlan, ..._dinnerPlan];

  int get totalCalories =>
      _allPlan.fold(0, (sum, m) => sum + m.calories);

  int get totalProtein =>
      _allPlan.fold(0, (sum, m) => sum + m.protein);

  int get totalFats =>
      _allPlan.fold(0, (sum, m) => sum + m.fats);
}


