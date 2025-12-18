import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'package:fitnessapp/models/meal.dart';
import 'package:fitnessapp/models/meal_plan_manager.dart';
import 'daily_meal_plan_screen.dart';
import 'add_custom_meal_sheet.dart';
import '../widgets/safe_meal_image.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final MealPlanManager _mgr = MealPlanManager();
  int _selectedCategoryIndex = 0;
  int? _expandedIndex;
  bool _loading = true;

  late final List<Meal> _breakfastMeals;
  late final List<Meal> _lunchMeals;
  late final List<Meal> _dinnerMeals;

  List<String> get _categoryTitles => ["Breakfast", "Lunch", "Dinner"];

  MealCategory get _activeCategory {
    switch (_selectedCategoryIndex) {
      case 0:
        return MealCategory.breakfast;
      case 1:
        return MealCategory.lunch;
      default:
        return MealCategory.dinner;
    }
  }

  List<Meal> get _activeRecommended {
    switch (_activeCategory) {
      case MealCategory.breakfast:
        return _breakfastMeals;
      case MealCategory.lunch:
        return _lunchMeals;
      default:
        return _dinnerMeals;
    }
  }

  @override
  void initState() {
    super.initState();
    _initMeals();
    _loadManager();
  }

  // ---------------- LOAD MEALS ----------------
  Future<void> _refreshMealPlan() async {
    await _mgr.load();
    setState(() {});
  }

  void _initMeals() {
    _breakfastMeals = [
      Meal(
        id: "b1",
        title: "Salad & Egg",
        calories: 540,
        protein: 25,
        fats: 16,
        imageUrl:
            "https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=800",
        description:
            "High-protein salad with eggs and leafy greens. Great lighter breakfast option.",
        prepTime: "20 min prep",
        isCustom: false,
      ),
      Meal(
        id: "b2",
        title: "Banana Oat Pancakes",
        calories: 430,
        protein: 22,
        fats: 12,
        imageUrl:
            "https://shivanilovesfood.com/wp-content/uploads/2022/07/Banana-Oat-Pancakes-4.jpg",
        description:
            "Fluffy pancakes made from oats and banana, ideal as a pre-workout meal.",
        prepTime: "15 min prep",
        isCustom: false,
      ),
      Meal(
        id: "b3",
        title: "Greek Yogurt Parfait",
        calories: 420,
        protein: 28,
        fats: 8,
        imageUrl:
            "https://spicecravings.com/wp-content/uploads/2023/09/Greek-Yogurt-Parfait-6.jpg",
        description:
            "Greek yogurt layered with berries, granola and a drizzle of honey.",
        prepTime: "5 min prep",
        isCustom: false,
      ),
    ];

    _lunchMeals = [
      Meal(
        id: "l1",
        title: "Chicken & Rice Bowl",
        calories: 560,
        protein: 38,
        fats: 12,
        imageUrl:
            "https://www.skinnytaste.com/wp-content/uploads/2024/05/Coconut-Chicken-Rice-Bowls-10-500x500.jpg",
        description:
            "Grilled chicken with rice and vegetables. Classic bodybuilding lunch.",
        prepTime: "25 min prep",
        isCustom: false,
      ),
      Meal(
        id: "l2",
        title: "Tuna Pasta Salad",
        calories: 600,
        protein: 36,
        fats: 14,
        imageUrl:
            "https://images.unsplash.com/photo-1562967914-608f82629710?w=800",
        description: "Wholegrain pasta with tuna, olives and cherry tomatoes.",
        prepTime: "20 min prep",
        isCustom: false,
      ),
      Meal(
        id: "l3",
        title: "Salmon Poke Bowl",
        calories: 620,
        protein: 34,
        fats: 20,
        imageUrl:
            "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800",
        description: "Fresh salmon over rice with vegetables and sesame.",
        prepTime: "20 min prep",
        isCustom: false,
      ),
    ];

    _dinnerMeals = [
      Meal(
        id: "d1",
        title: "Fish & Vegetables",
        calories: 325,
        protein: 30,
        fats: 10,
        imageUrl:
            "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800",
        description:
            "Light grilled fish with roasted vegetables, good for late evenings.",
        prepTime: "20 min prep",
        isCustom: false,
      ),
      Meal(
        id: "d2",
        title: "Chicken Stir-fry",
        calories: 520,
        protein: 40,
        fats: 12,
        imageUrl:
            "https://images.unsplash.com/photo-1512058564366-18510be2db19?w=800",
        description:
            "Quick stir-fry with chicken breast, broccoli and peppers.",
        prepTime: "18 min prep",
        isCustom: false,
      ),
      Meal(
        id: "d3",
        title: "Steak & Sweet Potato",
        calories: 700,
        protein: 45,
        fats: 25,
        imageUrl:
            "https://images.unsplash.com/photo-1601315576609-588e6247e232?w=800",
        description:
            "Grilled steak with sweet potato mash and a side of greens.",
        prepTime: "45 min prep",
        isCustom: false,
      ),
    ];
  }

  Future<void> _loadManager() async {
    await _mgr.load();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _addCustomMealToDaily(Meal meal) async {
    final selected = await showModalBottomSheet<MealCategory>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Add to daily plan as...",
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ListTile(
                title: const Text("Breakfast"),
                onTap: () => Navigator.pop(ctx, MealCategory.breakfast),
              ),
              ListTile(
                title: const Text("Lunch"),
                onTap: () => Navigator.pop(ctx, MealCategory.lunch),
              ),
              ListTile(
                title: const Text("Dinner"),
                onTap: () => Navigator.pop(ctx, MealCategory.dinner),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) {
      _mgr.addToPlan(selected, meal);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Added to ${selected.name[0].toUpperCase()}${selected.name.substring(1)} plan",
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 1),
        ),
      );

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customMeals = _mgr.customMeals;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: theme.appBarTheme.elevation,
        title: Text(
          "MEAL PLAN",
          style: GoogleFonts.poppins(
            color: theme.appBarTheme.foregroundColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "My Meal Plan",
            icon: Icon(Icons.list_alt_outlined,
                color: theme.appBarTheme.foregroundColor),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DailyMealPlanScreen(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),

      // ------------------ REFRESH INDICATOR + LISTVIEW ------------------
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: _refreshMealPlan,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _calorieTracker(theme),
                  const SizedBox(height: 24),
                  _macroRow(theme),
                  const SizedBox(height: 24),
                  _categoryTabs(theme),
                  const SizedBox(height: 18),

                  // Recommended Meals
                  ..._activeRecommended.asMap().entries.map(
                        (e) => _mealCard(theme, e.value, e.key),
                      ),

                  const SizedBox(height: 24),

                  // Saved Meals Header
                  Text(
                    "Your Saved Meals",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Saved Meals
                  if (customMeals.isEmpty)
                    Text(
                      "No meals saved yet. Tap + to add your custom meal.",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    )
                  else
                    ...customMeals.map((m) => _customMealTile(theme, m)),

                  const SizedBox(height: 24),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: theme.cardColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) => const AddCustomMealSheet(),
          );

          if (result == true) setState(() {});
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------- CALORIE RING ----------
  Widget _calorieTracker(ThemeData theme) {
    final goal = _mgr.dailyCalorieGoal;
    final total = _mgr.totalCalories.toDouble();
    final pct = goal <= 0 ? 0.0 : (total / goal).clamp(0.0, 1.0);

    return Center(
      child: CircularPercentIndicator(
        radius: 80,
        lineWidth: 10,
        percent: pct,
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: theme.dividerColor.withOpacity(0.4),
        progressColor: theme.colorScheme.primary,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${_mgr.totalCalories} kcal",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "of ${goal.toStringAsFixed(0)} kcal",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- MACRO ROW ----------
  Widget _macroRow(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _macroCard(
          theme,
          "Protein",
          "${_mgr.totalProtein} g",
          _mgr.proteinGoal == 0
              ? 0
              : (_mgr.totalProtein / _mgr.proteinGoal).clamp(0.0, 1.0),
          theme.colorScheme.secondary,
        ),
        _macroCard(
          theme,
          "Fats",
          "${_mgr.totalFats} g",
          _mgr.fatGoal == 0
              ? 0
              : (_mgr.totalFats / _mgr.fatGoal).clamp(0.0, 1.0),
          theme.colorScheme.tertiary,
        ),
      ],
    );
  }

  Widget _macroCard(
      ThemeData theme, String title, String value, double progress, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (theme.brightness == Brightness.light)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: color,
                backgroundColor: theme.dividerColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                color: theme.textTheme.bodySmall?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- CATEGORY TABS ----------
  Widget _categoryTabs(ThemeData theme) {
    return Row(
      children: List.generate(_categoryTitles.length, (index) {
        final isSelected = index == _selectedCategoryIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
                _expandedIndex = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: EdgeInsets.only(
                right: index == _categoryTitles.length - 1 ? 0 : 8,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  _categoryTitles[index],
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ---------- MEAL CARD ----------
  Widget _mealCard(ThemeData theme, Meal meal, int index) {
    final isExpanded = _expandedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _expandedIndex = isExpanded ? null : index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // HEADER ROW
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: safeMealImage(meal, size: 70),
                  ),
                  const SizedBox(width: 12),

                  // TITLE + MACROS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meal.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${meal.calories} kcal • ${meal.protein} g protein • ${meal.fats} g fats",
                          style: GoogleFonts.poppins(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meal.prepTime,
                          style: GoogleFonts.poppins(
                            color: theme.textTheme.bodySmall
                                ?.color
                                ?.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // EXPAND ICON
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ],
              ),

              // EXPANDED CONTENT
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.description,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            _mgr.addToPlan(_activeCategory, meal);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Added to ${_categoryTitles[_selectedCategoryIndex]} plan",
                                  style: GoogleFonts.poppins(),
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                            setState(() {});
                          },
                          child: Text(
                            "Add to ${_categoryTitles[_selectedCategoryIndex]}",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- CUSTOM MEAL TILE ----------
  Widget _customMealTile(ThemeData theme, Meal meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (theme.brightness == Brightness.light)
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: safeMealImage(meal, size: 52),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${meal.calories} kcal • ${meal.protein} g protein",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: "Add to daily plan",
                icon: Icon(Icons.add_circle_outline,
                    color: theme.iconTheme.color),
                onPressed: () => _addCustomMealToDaily(meal),
              ),
              IconButton(
                tooltip: "Remove saved meal",
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  _mgr.removeCustomMeal(meal.id);
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

