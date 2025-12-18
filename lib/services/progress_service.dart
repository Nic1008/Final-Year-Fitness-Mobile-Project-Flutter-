import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String baseUrl = "http://10.0.2.2:8000";

  // -------------------------
  // Get logged-in user email
  // -------------------------
  static Future<String> _email() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    if (email == null) {
      throw Exception("User not logged in");
    }
    return email;
  }

  // -------------------------
  // GET cardio progress (legacy)
  // -------------------------
  static Future<Map<String, dynamic>> getProgress() async {
    final email = await _email();

    final res = await http.get(
      Uri.parse("$baseUrl/progress?email=$email"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load progress");
    }
  }

  // -------------------------
  // UPDATE cardio
  // -------------------------
  static Future<void> updateCardio({
    required int dailySteps,
    required List<int> weeklySteps,
    required int totalRuns,
    required double bestRunKm,
  }) async {
    final email = await _email();

    final res = await http.put(
      Uri.parse("$baseUrl/progress/cardio"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "daily_steps": dailySteps,
        "weekly_steps": weeklySteps,
        "total_runs": totalRuns,
        "best_run_km": bestRunKm,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to update cardio progress");
    }
  }

  // ======================================================
  // LOG WORKOUT (DB SOURCE OF TRUTH)
  // ======================================================
  static Future<void> logWorkout() async {
    final email = await _email();

    final res = await http.post(
      Uri.parse("$baseUrl/progress/workout/checkin?email=$email"),
    );

    if (res.statusCode != 200) {
      throw Exception("Workout already logged or server error");
    }
  }

  // ======================================================
  // GET DAILY CHECKINS (CURRENT WEEK)
  // ======================================================
  static Future<Map<String, bool>> getDailyCheckins() async {
    final email = await _email();

    final res = await http.get(
      Uri.parse("$baseUrl/progress/daily-checkins?email=$email"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load daily check-ins");
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data.map((k, v) => MapEntry(k, v as bool));
  }

  // ======================================================
  // GET WEEKLY SUMMARY (HERO CARD)
  // ======================================================
  static Future<Map<String, dynamic>> getWeeklySummary() async {
    final email = await _email();

    final res = await http.get(
      Uri.parse("$baseUrl/progress/weekly-summary?email=$email"),
    );

    if (res.statusCode != 200) {
      throw Exception("Failed to load weekly summary");
    }

    return jsonDecode(res.body);
  }
}




