import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/progress_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Theme helpers (runtime, NOT const)
  Color get onSurface => Theme.of(context).colorScheme.onSurface;
  Color get surface => Theme.of(context).colorScheme.surface;
  Color get primary => Theme.of(context).colorScheme.primary;
  Color get outline => Theme.of(context).colorScheme.outline;

  // Workout check-in
  final List<String> _dayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  Map<String, bool> _checkin = {
    'mon': false,
    'tue': false,
    'wed': false,
    'thu': false,
    'fri': false,
    'sat': false,
    'sun': false,
  };

  // Cardio
  int todaySteps = 0;
  List<int> weeklySteps = List.filled(7, 0);
  double distanceKm = 0.0;
  double calories = 0.0;
  final double userWeight = 70.0;
  final int dailyGoal = 6000;

  bool loading = true;

  int get todayIndex => DateTime.now().weekday - 1; // 0 = Mon

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
  }

  // =====================================================
  //            SUCCESS POPUP (SLIDE + FADE)
  // =====================================================

  void _showSuccessPopup() {
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 110,
        left: 24,
        right: 24,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: -20, end: 0),
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, value),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: 1,
                child: child,
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Successfully checked in! Keep going!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(milliseconds: 1800), () {
      overlayEntry?.remove();
    });
  }

  // =====================================================
  //                LOAD PROGRESS
  // =====================================================

  Future<void> _loadFromBackend() async {
    setState(() => loading = true);

    try {
      final data = await ProgressService.getProgress();

      // Workout check-in
      final daily = await ProgressService.getDailyCheckins();

      setState(() {
      _checkin = daily;
      });

      // Cardio
      final List<dynamic> ws = data['weekly_steps'] ?? List.filled(7, 0);
      final int ds = data['daily_steps'] ?? 0;

      setState(() {
        _checkin = daily;
        weeklySteps = ws.map((e) => (e as num).toInt()).toList();
        todaySteps = ds;
        distanceKm = todaySteps * 0.0008;
        calories = todaySteps * 0.04 * (userWeight / 70.0);
        loading = false;
      });
    } catch (e) {
      debugPrint('Error loading /progress: $e');
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load progress from server')),
        );
      }
    }
  }

  // =====================================================
  //                TOGGLE CHECK-IN
  // =====================================================

  Future<void> _toggleCheckin(int index) async {
  // Only today is allowed
  if (index != todayIndex) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only check in for today")),
      );
    }
    return;
  }

  // Prevent double logging
  if (_checkin[_dayKeys[index]] == true) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Workout already logged today")),
      );
    }
    return;
  }

  try {
    await ProgressService.logWorkout();

    // Re-sync from backend
    final daily = await ProgressService.getDailyCheckins();

    setState(() {
      _checkin = daily;
    });

    _showSuccessPopup();
  } catch (e) {
    debugPrint("Workout log error: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to log workout")),
      );
    }
  }
}


  // =====================================================
  //                 UI (build)
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final double progress = min(todaySteps / dailyGoal, 1.0);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        // ✅ FIX 1: gradient must be NULL in dark mode (otherwise it overrides color)
        decoration: BoxDecoration(
          gradient: isDark
              ? null
              : const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 216, 236, 174),
                    Color.fromARGB(255, 180, 221, 231),
                    Color.fromARGB(255, 243, 225, 225),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
          color: isDark ? const Color(0xFF0F0F0F) : null,
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadFromBackend,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildWeekSection(),
                      const SizedBox(height: 20),
                      _buildCardioSection(progress),
                      const SizedBox(height: 20),
                      _buildWeeklyStepsSection(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // =====================================================
  //                 SECTIONS (cards)
  // =====================================================

  Widget _buildWeekSection() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ FIX 2: disable gradient in dark mode
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFE7F9ED), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? const Color(0xFF1A1A1A) : null,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                'This Week',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: _buildWeekRow(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardioSection(double progress) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ FIX 2: disable gradient in dark mode
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFEAF3FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? const Color(0xFF1A1A1A) : null,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_run_rounded, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Cardio Today',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Center(child: _buildTodayRing(progress)),
                const SizedBox(height: 16),
                _buildCardioStatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStepsSection() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isDark
            ? null
            : const LinearGradient(
                colors: [Color(0xFFEFF5FF), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDark ? const Color(0xFF1A1A1A) : null,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Weekly Steps',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: _buildWeeklyStepsChart(),
          ),
        ],
      ),
    );
  }

  // =====================================================
  //                 UI HELPERS
  // =====================================================

  Widget _buildWeekRow() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_dayKeys.length, (index) {
        final String label = _dayLabels[index];
        final String key = _dayKeys[index];
        final bool checked = _checkin[key] ?? false;
        final bool isToday = index == todayIndex;

        // Text hierarchy colors (Home page style)
        final Color primaryText = isDark ? Colors.white : onSurface;
        final Color secondaryText =
            isDark ? Colors.grey.shade400 : onSurface.withOpacity(0.6);

        return GestureDetector(
          onTap: () => _toggleCheckin(index),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isToday ? primaryText : secondaryText,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: checked
                      ? Colors.green
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  border:
                      isToday ? Border.all(color: Colors.green, width: 2) : null,
                ),
                child: Icon(
                  checked ? Icons.check : Icons.circle_outlined,
                  size: checked ? 18 : 16,
                  color: checked ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTodayRing(double progress) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryText = isDark ? Colors.white : onSurface;
    final Color secondaryText =
        isDark ? Colors.grey.shade400 : onSurface.withOpacity(0.6);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 11,
            backgroundColor:
                isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            color: Colors.blue,
          ),
        ),
        Column(
          children: [
            Text(
              '$todaySteps',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            Text(
              'steps',
              style: TextStyle(color: secondaryText),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardioStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard('Steps', '$todaySteps'),
        _statCard('Distance', '${distanceKm.toStringAsFixed(2)} km'),
        _statCard('Calories', '${calories.toStringAsFixed(1)} kcal'),
      ],
    );
  }

  Widget _statCard(String label, String value) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color primaryText = isDark ? Colors.white : onSurface;
    final Color secondaryText =
        isDark ? Colors.grey.shade400 : onSurface.withOpacity(0.6);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: secondaryText,
          ),
        ),
      ],
    );
  }

 Widget _buildWeeklyStepsChart() {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  final Color bottomLabelColor =
      isDark ? Colors.grey.shade400 : onSurface.withOpacity(0.7);

  return SizedBox(
    height: 210,
    child: Stack(
      children: [

        // 👣 FOOTSTEP UX HINT (BACKGROUND)
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: isDark ? 0.05 : 0.07,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (_) => RotatedBox(
                    quarterTurns: 3, // 👈 upright
                    child: FaIcon(
                      FontAwesomeIcons.shoePrints,
                      size: 14,
                      color: isDark
                          ? const Color.fromARGB(255, 29, 27, 27)
                          : const Color.fromARGB(255, 7, 7, 7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // 📊 BAR CHART (FOREGROUND)
        BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final index = value.toInt();
                    if (index < 0 || index >= 7) {
                      return const SizedBox();
                    }
                    return Text(
                      _dayLabels[index],
                      style: TextStyle(
                        fontSize: 11,
                        color: bottomLabelColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(7, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: weeklySteps[i].toDouble(),
                    width: 14,
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    ),
  );
}
}


