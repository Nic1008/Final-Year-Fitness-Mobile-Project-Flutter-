import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int selectedTab = 0; // 0 = Food, 1 = Workout

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
        title: Text(
          "MY FAVORITES",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          Row(
            children: [
              _tabItem("Food", 0),
              _tabItem("Workout", 1),
            ],
          ),

          const SizedBox(height: 40),

          Icon(
            Icons.restaurant_menu,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            "Favorite meals will appear here\nwhen you start saving them.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              height: 1.4,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final selected = index == selectedTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.grey.shade200,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
