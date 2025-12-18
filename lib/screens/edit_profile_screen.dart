import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../models/meal_plan_manager.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();

  String? _gender;
  String? _avatarUrl;


  bool _saving = false;

  final List<String> avatars = const [
    "https://cdn-icons-png.flaticon.com/512/706/706830.png",
    "https://cdn-icons-png.flaticon.com/512/706/706837.png",
    "https://cdn-icons-png.flaticon.com/512/706/706826.png",
    "https://cdn-icons-png.flaticon.com/512/706/706813.png",
    "https://cdn-icons-png.flaticon.com/512/1998/1998671.png",
    "https://cdn-icons-png.flaticon.com/512/616/616521.png",
    "https://cdn-icons-png.flaticon.com/512/616/616555.png",
    "https://cdn-icons-png.flaticon.com/512/415/415733.png",
    "https://cdn-icons-png.flaticon.com/512/590/590685.png",
    "https://cdn-icons-png.flaticon.com/512/135/135620.png",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final email = prefs.getString("email");
    if (email == null) return;

    _nameCtrl.text = prefs.getString("display_name_$email") ?? "";
    _ageCtrl.text = prefs.getInt("age_$email")?.toString() ?? "";
    _weightCtrl.text = prefs.getDouble("weight_$email")?.toString() ?? "";
    _heightCtrl.text = prefs.getDouble("height_$email")?.toString() ?? "";
    _gender = prefs.getString("gender_$email");
    _avatarUrl = prefs.getString("avatar_url_$email");  

    setState(() {});
  }

  Future<void> _saveChanges() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _ageCtrl.text.trim().isEmpty ||
        _weightCtrl.text.trim().isEmpty ||
        _heightCtrl.text.trim().isEmpty ||
        _gender == null ||
        _avatarUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
final email = prefs.getString("email");

if (email == null) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("User not logged in")),
  );
  return;
}

// ✅ FIRST: parse form values
final name = _nameCtrl.text.trim();
final age = int.parse(_ageCtrl.text.trim());
final weight = double.parse(_weightCtrl.text.trim());
final height = double.parse(_heightCtrl.text.trim());

// ✅ THEN: use weight
final storedTargetWeight =
    prefs.getDouble("target_weight_$email") ?? weight;

    setState(() => _saving = true);


    // -------- SAVE BACKEND --------
    final success = await ApiService.updateProfile(
    email: email,
    displayName: name,
    age: age,
    weight: weight,
    height: height,
    gender: _gender,
    targetWeight: storedTargetWeight,
    avatarUrl: _avatarUrl,
  );

  if (!success) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Failed to update profile")),
  );
  return;
}

    await prefs.setString("display_name_$email", name);
    await prefs.remove("name_$email"); 
    await prefs.setInt("age_$email", age);
    await prefs.setDouble("weight_$email", weight);
    await prefs.setDouble("height_$email", height);
    await prefs.setString("gender_$email", _gender!);
    await prefs.setString("avatar_url_$email", _avatarUrl!);
    await prefs.setDouble("target_weight_$email", storedTargetWeight);


    // -------- UPDATE MEAL PLAN GOALS --------
    final mgr = MealPlanManager();
    await mgr.load();
    mgr.updateGoals(
      heightCm: height,
      weightKg: weight,
      age: age,
      gender: _gender!,
    );

    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 0.4,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------- AVATAR -----------------
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage:
                        _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    backgroundColor: Colors.grey.shade300,
                    child: _avatarUrl == null
                        ? const Icon(Icons.person, size: 40)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => _pickAvatar(),
                    child: const Text("Change Avatar"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ----------------- NAME -----------------
            _label("Name"),
            _inputField(_nameCtrl, "Your name"),

            const SizedBox(height: 18),

            // ----------------- GENDER -----------------
            _label("Gender"),
            Row(
              children: [
                _genderButton("Male", Icons.male, Colors.blue),
                const SizedBox(width: 10),
                _genderButton("Female", Icons.female, Colors.pink),
                const SizedBox(width: 10),
                _genderButton("Other", Icons.transgender, Colors.purple),
              ],
            ),

            const SizedBox(height: 18),

            // ----------------- AGE -----------------
            _label("Age"),
            _inputField(_ageCtrl, "21", number: true),

            const SizedBox(height: 18),

            // ----------------- WEIGHT -----------------
            _label("Weight (kg)"),
            _inputField(_weightCtrl, "60", number: true),

            const SizedBox(height: 18),

            // ----------------- HEIGHT -----------------
            _label("Height (cm)"),
            _inputField(_heightCtrl, "170", number: true),

            const SizedBox(height: 40),

            // ----------------- SAVE BUTTON -----------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // UI Helpers
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String hint,
      {bool number = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _genderButton(String label, IconData icon, Color color) {
    final selected = _gender == label;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: selected ? 2.5 : 1,
            ),
            color: selected ? color.withOpacity(0.15) : Colors.white,
          ),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  void _pickAvatar() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: avatars.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (_, i) {
              final url = avatars[i];
              final isSelected = url == _avatarUrl;

              return InkWell(
                onTap: () {
                  setState(() => _avatarUrl = url);
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 32,
                  backgroundColor:
                      isSelected ? Colors.black : Colors.grey.shade200,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(url),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
