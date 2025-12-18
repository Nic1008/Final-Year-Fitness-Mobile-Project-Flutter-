import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../models/meal_plan_manager.dart';

class UpdateWeightScreen extends StatefulWidget {
  const UpdateWeightScreen({super.key});

  @override
  State<UpdateWeightScreen> createState() => _UpdateWeightScreenState();
}

class _UpdateWeightScreenState extends State<UpdateWeightScreen> {
  final TextEditingController _weightCtrl = TextEditingController();
  bool _loading = false;

  double? storedHeight;
  int? storedAge;
  String? storedGender;
  double? storedWeight;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    storedHeight = prefs.getDouble("height");
    storedAge = prefs.getInt("age");
    storedGender = prefs.getString("gender");
    storedWeight = prefs.getDouble("weight");

    // Pre-fill current weight
    if (storedWeight != null) {
      _weightCtrl.text = storedWeight!.toStringAsFixed(1);
    }

    setState(() {});
  }

  Future<void> _save() async {
  if (_weightCtrl.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter your new weight")),
    );
    return;
  }

  final newWeight = double.tryParse(_weightCtrl.text.trim());
  if (newWeight == null || newWeight < 30 || newWeight > 300) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter a valid weight")),
    );
    return;
  }

  setState(() => _loading = true);

  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString("email");

  if (email == null) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("User not logged in")),
    );
    return;
  }

  // 🔑 REQUIRED values for backend
  final storedAge = prefs.getInt("age_$email");
  final storedHeight = prefs.getDouble("height_$email");
  final storedGender = prefs.getString("gender_$email");
  final storedTargetWeight =
      prefs.getDouble("target_weight_$email") ?? newWeight;

  if (storedAge == null || storedHeight == null) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile incomplete. Please edit profile first.")),
    );
    return;
  }

  // -------- UPDATE BACKEND (SOURCE OF TRUTH) --------
  final success = await ApiService.updateProfile(
    email: email,
    age: storedAge,
    weight: newWeight,
    height: storedHeight,
    gender: storedGender,
    targetWeight: storedTargetWeight,
  );

  if (!success) {
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to update weight")),
    );
    return;
  }

  // -------- UPDATE LOCAL CACHE (MIRROR BACKEND) --------
  await prefs.setDouble("weight_$email", newWeight);
  await prefs.setDouble("target_weight_$email", storedTargetWeight);

  // -------- UPDATE MEAL PLAN MANAGER --------
  if (storedGender != null) {
    final mgr = MealPlanManager();
    await mgr.load();
    mgr.updateGoals(
      heightCm: storedHeight,
      weightKg: newWeight,
      age: storedAge,
      gender: storedGender,
    );
  }

  setState(() => _loading = false);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Weight updated successfully")),
  );

  Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Weight"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.4,
      ),
      backgroundColor: const Color(0xFFF8F8F8),
      body: storedWeight == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enter your new weight",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We’ll recalculate your daily calories and macros based on this.",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Weight Input
                  TextField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Weight (kg)",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
