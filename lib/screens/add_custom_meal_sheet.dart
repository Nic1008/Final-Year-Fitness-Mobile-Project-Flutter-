// lib/screens/add_custom_meal_sheet.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/meal.dart';
import '../models/meal_plan_manager.dart';

class AddCustomMealSheet extends StatefulWidget {
  const AddCustomMealSheet({super.key});

  @override
  State<AddCustomMealSheet> createState() => _AddCustomMealSheetState();
}

class _AddCustomMealSheetState extends State<AddCustomMealSheet> {
  final _titleCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _timeCtrl = TextEditingController(text: "10 min prep");

  XFile? _pickedFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _pickedFile = picked);
    }
  }

  Future<void> _save() async {
    if (_titleCtrl.text.isEmpty ||
        _calCtrl.text.isEmpty ||
        _proteinCtrl.text.isEmpty ||
        _fatCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final meal = Meal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      calories: int.tryParse(_calCtrl.text.trim()) ?? 0,
      protein: int.tryParse(_proteinCtrl.text.trim()) ?? 0,
      fats: int.tryParse(_fatCtrl.text.trim()) ?? 0,
      prepTime: _timeCtrl.text.trim(),
      description: "Custom meal created by you",
      imageUrl: _pickedFile?.path ?? "",
      isCustom: true,
    );

    MealPlanManager().addCustomMeal(meal);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Add Custom Meal",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: "Meal name"),
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _calCtrl,
                    decoration: const InputDecoration(labelText: "Calories"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _proteinCtrl,
                    decoration:
                        const InputDecoration(labelText: "Protein (g)"),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fatCtrl,
                    decoration: const InputDecoration(labelText: "Fats (g)"),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _timeCtrl,
                    decoration: const InputDecoration(labelText: "Prep time"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _pickedFile == null
                    ? const Center(child: Text("Tap to upload image"))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pickedFile!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text("Save Meal"),
            ),
          ],
        ),
      ),
    );
  }
}

