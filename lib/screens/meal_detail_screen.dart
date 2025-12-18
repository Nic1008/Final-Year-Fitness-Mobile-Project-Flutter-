import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fitnessapp/models/meal.dart';

class MealDetailScreen extends StatelessWidget {
    final Meal meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: ListView(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.network(
              meal.imageUrl,
              width: double.infinity,
              height: 260,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 20),

          // NUTRITION ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nutritionBox("${meal.calories}", "Calories"),
                _nutritionBox("${meal.protein} g", "Protein"),
                _nutritionBox("${meal.fats} g", "Fats"),
                _nutritionBox(meal.prepTime, "Prep time"),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              meal.title,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              meal.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // OPTIONAL SECTION TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "How this helps your goals",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "This meal provides a good balance of proteins, fats and carbohydrates. "
              "It supports muscle recovery while keeping energy levels stable throughout the day.",
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),

      // BOTTOM BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                // TODO: Add to daily meal plan (Breakfast/Lunch/Dinner selection)
              },
              child: Text(
                "Add to Meal Plan",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _nutritionBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
