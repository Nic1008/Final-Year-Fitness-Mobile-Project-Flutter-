import 'package:fitnessapp/models/meal_plan_manager.dart';
import 'package:fitnessapp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreetingOnboardingScreen extends StatefulWidget {
  const GreetingOnboardingScreen({super.key});

  @override
  State<GreetingOnboardingScreen> createState() =>
      _GreetingOnboardingScreenState();
}

class _GreetingOnboardingScreenState extends State<GreetingOnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _targetWeightCtrl = TextEditingController();

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

  bool _validateStep(int step) {
    switch (step) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty;
      case 1:
        return _gender != null;
      case 2:
        return _ageCtrl.text.trim().isNotEmpty &&
            _weightCtrl.text.trim().isNotEmpty &&
            _heightCtrl.text.trim().isNotEmpty;
      case 3:
         return _targetWeightCtrl.text.trim().isNotEmpty;
      case 4:
         return _avatarUrl != null;
      case 5:
         return true;
    }
    return false;
  }

  Future<void> _finish() async {
  if (!_validateStep(4)) return;

  setState(() => _saving = true);

  final prefs = await SharedPreferences.getInstance();
  final email = prefs.getString("email");

  if (email == null || email.isEmpty) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No logged-in user found")),
    );
    return;
  }

  // ✅ Parse ONCE, treat as NON-NULL
  final name = _nameCtrl.text.trim();
  final age = int.parse(_ageCtrl.text.trim());
  final weight = double.parse(_weightCtrl.text.trim());
  final height = double.parse(_heightCtrl.text.trim());
  final targetWeight = double.parse(_targetWeightCtrl.text.trim());
  final gender = _gender!;

  // ---------------- SAVE PROFILE TO BACKEND ----------------
  final success = await ApiService.updateProfile(
    email: email,
    displayName: name,
    age: age,
    weight: weight,
    height: height,
    gender: gender,
    targetWeight: targetWeight,
    avatarUrl: _avatarUrl,
  );

  if (!success) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to save profile. Please try again.")),
    );
    return;
  }

  // ------------------ NUTRITION CALCULATION ------------------
  double bmr;

  if (gender == "Male") {
    bmr = 10 * weight + 6.25 * height - 5 * age + 5;
  } else if (gender == "Female") {
    bmr = 10 * weight + 6.25 * height - 5 * age - 161;
  } else {
    bmr = 10 * weight + 6.25 * height - 5 * age - 80;
  }

  final tdee = bmr * 1.55;
  final dailyCalorieGoal = tdee + 300;
  final dailyProteinGoal = weight * 1.8;
  final dailyFatGoal = (dailyCalorieGoal * 0.25) / 9;
  final remainingCalories =
      dailyCalorieGoal - (dailyProteinGoal * 4) - (dailyFatGoal * 9);
  final double dailyCarbGoal =
      remainingCalories > 0 ? remainingCalories / 4 : 0;

  await prefs.setDouble("daily_calorie_goal", dailyCalorieGoal);
  await prefs.setDouble("daily_protein_goal", dailyProteinGoal);
  await prefs.setDouble("daily_fat_goal", dailyFatGoal);
  await prefs.setDouble("daily_carb_goal", dailyCarbGoal);

  final mgr = MealPlanManager();
  await mgr.load();
  mgr.dailyCalorieGoal = dailyCalorieGoal;
  mgr.proteinGoal = dailyProteinGoal;
  mgr.fatGoal = dailyFatGoal;

  prefs.setBool("onboarded", true);

  setState(() => _saving = false);
  Navigator.pushReplacementNamed(context, "/home");
}


  void _next() {
    if (!_validateStep(_step)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please complete this step')));
      return;
    }

    if (_step < 4) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _targetWeightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // prevent overflow when keyboard opens
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: "Let’s personalize your journey",
              step: _step + 1,
              total: 6,
            ),

            const SizedBox(height: 12),

            // MAIN CONTENT PANEL
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _stepPage(_NameStep(controller: _nameCtrl)),
                    _stepPage(_GenderStep(
                      gender: _gender,
                      onSelect: (g) => setState(() => _gender = g),
                    )),
                    _stepPage(_BodyStep(
                      ageCtrl: _ageCtrl,
                      weightCtrl: _weightCtrl,
                      heightCtrl: _heightCtrl,
                    )),
                    _stepPage(_TargetWeightStep(
                        controller: _targetWeightCtrl)),
                    _stepPage(_AvatarStep(
                      avatars: avatars,
                      selected: _avatarUrl,
                      onPick: (url) => setState(() => _avatarUrl = url),
                    )),
                    _stepPage(_SummaryStep(
                      name: _nameCtrl.text.trim().isEmpty
                          ? "Athlete"
                          : _nameCtrl.text.trim(),
                      gender: _gender ?? "—",
                      age: _ageCtrl.text.trim(),
                      weight: _weightCtrl.text.trim(),
                      height: _heightCtrl.text.trim(),
                      avatar: _avatarUrl,
                    )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // NAV BUTTONS
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _step == 0 ? null : _back,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Back", style: TextStyle(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _step == 4 ? (_saving ? null : _finish) : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _step == 4
                        ? (_saving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Let’s start"))
                        : const Text("Next"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Wrap each step in scroll view
  Widget _stepPage(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/* ================= HEADER ================= */

class _Header extends StatelessWidget {
  final String title;
  final int step;
  final int total;

  const _Header({
    required this.title,
    required this.step,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (step / total);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              Text("Step $step of $total",
                  style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.grey.shade200,
              color: Colors.black,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= STEPS UI ================= */

class _NameStep extends StatelessWidget {
  final TextEditingController controller;

  const _NameStep({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("How may we address you?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Tell us your preferred name.",
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 22),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: "Name",
            hintText: "e.g., Nicholas",
            filled: true,
            fillColor: Colors.white,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _GenderStep extends StatelessWidget {
  final String? gender;
  final ValueChanged<String> onSelect;

  const _GenderStep({required this.gender, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = [
      ("Male", Icons.male, Colors.blue),
      ("Female", Icons.female, Colors.pink),
      ("Other", Icons.transgender, Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("What’s your gender?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Pick the option you're most comfortable with.",
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 18),
        Row(
          children: items.map((tuple) {
            final selected = gender == tuple.$1;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelect(tuple.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? tuple.$3 : Colors.grey.shade300,
                        width: selected ? 2.5 : 1,
                      ),
                      color: selected
                          ? tuple.$3.withOpacity(0.15)
                          : Colors.white,
                    ),
                    child: Column(
                      children: [
                        Icon(tuple.$2, color: tuple.$3, size: 36),
                        const SizedBox(height: 6),
                        Text(tuple.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BodyStep extends StatelessWidget {
  final TextEditingController ageCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController heightCtrl;

  const _BodyStep({
    required this.ageCtrl,
    required this.weightCtrl,
    required this.heightCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Your basic stats",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("These will help personalize your program.",
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _numField(
                  label: "Age",
                  hint: "21",
                  controller: ageCtrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                  label: "Weight (kg)",
                  hint: "60",
                  controller: weightCtrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _numField(
                  label: "Height (cm)",
                  hint: "170",
                  controller: heightCtrl),
            ),
          ],
        ),
      ],
    );
  }

  Widget _numField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _AvatarStep extends StatelessWidget {
  final List<String> avatars;
  final String? selected;
  final ValueChanged<String> onPick;

  const _AvatarStep({
    required this.avatars,
    required this.selected,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Choose your avatar",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Characters, animals, or fruits — pick your vibe.",
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 16),

        // Preview
        Row(
          children: [
            const Text("Preview:", style: TextStyle(fontSize: 16)),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: NetworkImage(selected ?? avatars.first),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Avatar Grid (scrollable)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: avatars.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemBuilder: (_, i) {
            final url = avatars[i];
            final active = url == selected;
            return InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onPick(url),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(url),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TargetWeightStep extends StatelessWidget {
  final TextEditingController controller;

  const _TargetWeightStep({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "What’s your target weight?",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "This helps us track your muscle gain goal.",
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "Target Weight (kg)",
            hintText: "e.g., 58",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}


class _SummaryStep extends StatelessWidget {
  final String name;
  final String gender;
  final String age;
  final String weight;
  final String height;
  final String? avatar;

  const _SummaryStep({
    required this.name,
    required this.gender,
    required this.age,
    required this.weight,
    required this.height,
    required this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("All set, $name!",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Here’s your profile preview.",
            style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  avatar != null ? NetworkImage(avatar!) : null,
              backgroundColor: Colors.grey.shade100,
              child: avatar == null
                  ? const Icon(Icons.person, size: 28, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                Text("$gender • ${age.isEmpty ? '—' : '$age y'}",
                    style: TextStyle(color: Colors.grey.shade600)),
                Text(
                    "${weight.isEmpty ? '—' : '$weight kg'} • ${height.isEmpty ? '—' : '$height cm'}",
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            )
          ],
        ),
      ],
    );
  }
}


