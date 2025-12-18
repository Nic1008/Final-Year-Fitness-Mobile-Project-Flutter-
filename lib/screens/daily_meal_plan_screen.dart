import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fitnessapp/models/meal.dart';
import 'package:fitnessapp/models/meal_plan_manager.dart';
import '../widgets/safe_meal_image.dart';

class DailyMealPlanScreen extends StatefulWidget {
  const DailyMealPlanScreen({super.key});

  @override
  State<DailyMealPlanScreen> createState() => _DailyMealPlanScreenState();
}

class _DailyMealPlanScreenState extends State<DailyMealPlanScreen> {
  final MealPlanManager _mgr = MealPlanManager();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    await _mgr.load();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    await _mgr.load();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Today's Meal Plan",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _summaryHeader(theme),
                  const SizedBox(height: 24),

                  // Breakfast section
                  _sectionHeader(
                    theme,
                    title: "Breakfast",
                    subtitle: "Kickstart your day strong.",
                    color: Colors.amber,
                  ),
                  const SizedBox(height: 8),
                  if (_mgr.breakfastPlan.isEmpty)
                    _emptySectionText(theme, "No breakfast planned yet.")
                  else
                    ..._mgr.breakfastPlan.asMap().entries.map(
                          (e) => _mealTile(
                            theme: theme,
                            meal: e.value,
                            category: MealCategory.breakfast,
                            index: e.key,
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Lunch section
                  _sectionHeader(
                    theme,
                    title: "Lunch",
                    subtitle: "Refuel for the rest of the day.",
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 8),
                  if (_mgr.lunchPlan.isEmpty)
                    _emptySectionText(theme, "No lunch planned yet.")
                  else
                    ..._mgr.lunchPlan.asMap().entries.map(
                          (e) => _mealTile(
                            theme: theme,
                            meal: e.value,
                            category: MealCategory.lunch,
                            index: e.key,
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Dinner section
                  _sectionHeader(
                    theme,
                    title: "Dinner",
                    subtitle: "Recover and wind down.",
                    color: Colors.deepPurpleAccent,
                  ),
                  const SizedBox(height: 8),
                  if (_mgr.dinnerPlan.isEmpty)
                    _emptySectionText(theme, "No dinner planned yet.")
                  else
                    ..._mgr.dinnerPlan.asMap().entries.map(
                          (e) => _mealTile(
                            theme: theme,
                            meal: e.value,
                            category: MealCategory.dinner,
                            index: e.key,
                          ),
                        ),

                  const SizedBox(height: 32),
                  _footerHint(theme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  // ===================== SUMMARY HEADER =====================

  Widget _summaryHeader(ThemeData theme) {
    final totalCalories = _mgr.totalCalories;
    final totalProtein = _mgr.totalProtein;
    final totalFats = _mgr.totalFats;

    final calorieGoal = _mgr.dailyCalorieGoal;
    final proteinGoal = _mgr.proteinGoal;
    final fatGoal = _mgr.fatGoal;

    final pctCal = calorieGoal <= 0
        ? 0.0
        : (totalCalories / calorieGoal).clamp(0.0, 1.5); // allow >100%
    final pctProtein = proteinGoal <= 0
        ? 0.0
        : (totalProtein / proteinGoal).clamp(0.0, 1.5);
    final pctFats =
        fatGoal <= 0 ? 0.0 : (totalFats / fatGoal).clamp(0.0, 1.5);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF111827),
                  Color(0xFF1F2933),
                ]
              : const [
                  Color(0xFFFFB36C),
                  Color(0xFFFF7A5C),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.orange.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Daily summary",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Track if you are fueling enough for muscle gain.",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),

          // Big calories row
          Row(
            children: [
              Expanded(
                child: Text(
                  "$totalCalories kcal",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "Goal: ${calorieGoal.toStringAsFixed(0)} kcal",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Macro mini bars
          _macroSummaryRow(
            label: "Protein",
            value: "$totalProtein g",
            goal: "${proteinGoal.toStringAsFixed(0)} g",
            pct: pctProtein,
          ),
          const SizedBox(height: 6),
          _macroSummaryRow(
            label: "Fats",
            value: "$totalFats g",
            goal: "${fatGoal.toStringAsFixed(0)} g",
            pct: pctFats,
          ),
          const SizedBox(height: 6),
          _macroSummaryRow(
            label: "Calories",
            value: "$totalCalories kcal",
            goal: "${calorieGoal.toStringAsFixed(0)} kcal",
            pct: pctCal,
          ),
        ],
      ),
    );
  }

  Widget _macroSummaryRow({
    required String label,
    required String value,
    required String goal,
    required double pct,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              "$value • goal $goal",
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: pct > 1.0 ? 1.0 : pct,
            minHeight: 6,
            backgroundColor: Colors.white.withOpacity(0.18),
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ===================== SECTION HEADER =====================

  Widget _sectionHeader(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark
        ? color.withOpacity(0.16)
        : color.withOpacity(0.08);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? Colors.white : Colors.black.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptySectionText(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  // ===================== MEAL TILE =====================

  Widget _mealTile({
    required ThemeData theme,
    required Meal meal,
    required MealCategory category,
    required int index,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    
    return Dismissible(
      key: ValueKey("${meal.id}_${index}_${category.name}"),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        _mgr.removeFromPlan(category, index);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Removed ${meal.title} from ${category.name}",
              style: GoogleFonts.poppins(),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isDark)
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
                    "${meal.calories} kcal • ${meal.protein} g protein • ${meal.fats} g fats",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    meal.prepTime,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color:
                          theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== FOOTER HINT =====================

  Widget _footerHint(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
        ),
      ),
      child: Text(
        "Tip: Add or customise meals from the Meal Plan screen. This page will always show your latest daily plan.",
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}
