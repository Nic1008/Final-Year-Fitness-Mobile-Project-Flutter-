import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import '../services/progress_service.dart';

class CardioProgressScreen extends StatefulWidget {
  const CardioProgressScreen({super.key});

  @override
  State<CardioProgressScreen> createState() => _CardioProgressScreenState();
}

class _CardioProgressScreenState extends State<CardioProgressScreen> {
  Stream<StepCount>? _stepCountStream;

  int todaySteps = 0;
  double distanceKm = 0.0;
  double calories = 0.0;

  final int dailyGoal = 6000;
  double userWeight = 70.0;

  List<int> weeklySteps = List.filled(7, 0);
  final List<String> days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFromBackend();
    _initPedometer();
  }

  Future<void> _loadFromBackend() async {
    try {
      final data = await ProgressService.getProgress();

      setState(() {
        weeklySteps =
            List<int>.from(data["weekly_steps"] ?? List.filled(7, 0));
        todaySteps = data["daily_steps"] ?? 0;
        distanceKm = todaySteps * 0.0008;
        calories = todaySteps * 0.04 * (userWeight / 70.0);
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading cardio progress: $e");
      setState(() => loading = false);
    }
  }

  void _initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(_onStepCount).onError((error) {
      debugPrint('Pedometer error: $error');
    });
  }

  void _onStepCount(StepCount event) {
    setState(() {
      todaySteps = event.steps;
      distanceKm = todaySteps * 0.0008;
      calories = todaySteps * 0.04 * (userWeight / 70.0);

      int index = DateTime.now().weekday - 1; // 0-based index
      if (index >= 0 && index < 7) {
        weeklySteps[index] = todaySteps;
      }
    });

    _syncToBackend();
  }

  Future<void> _syncToBackend() async {
    int runs = 0;
    double maxDist = 0.0;

    for (final s in weeklySteps) {
      if (s > 2000) {
        runs++;
        double d = s * 0.0008;
        if (d > maxDist) maxDist = d;
      }
    }

    try {
      await ProgressService.updateCardio(
        dailySteps: todaySteps,
        weeklySteps: weeklySteps,
        totalRuns: runs,
        bestRunKm: maxDist,
      );
    } catch (e) {
      debugPrint("Error updating cardio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = min(todaySteps / dailyGoal, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cardio Progress",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFromBackend,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _todayProgress(progress),
                    const SizedBox(height: 25),
                    _statsRow(),
                    const SizedBox(height: 30),
                    _weeklyChart(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _todayProgress(double progress) {
    return Column(
      children: [
        const Text("Today's Steps",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 14),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
              ),
            ),
            Column(
              children: [
                Text(
                  "$todaySteps",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Text("steps",
                    style: TextStyle(color: Colors.black54)),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _statsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statsCard("Distance", "${distanceKm.toStringAsFixed(2)} km",
            Icons.map_rounded),
        _statsCard("Calories", "${calories.toStringAsFixed(1)} kcal",
            Icons.local_fire_department_rounded),
      ],
    );
  }

  Widget _statsCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _weeklyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Weekly Steps",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          SizedBox(
            height: 210,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        int index = value.toInt();
                        if (index < 0 || index > 6) {
                          return const SizedBox();
                        }
                        return Text(days[index],
                            style: const TextStyle(fontSize: 12));
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
                        color: Colors.blue,
                        width: 14,
                        borderRadius: BorderRadius.circular(8),
                      )
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




