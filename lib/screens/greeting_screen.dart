import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GreetingScreen extends StatefulWidget {
  const GreetingScreen({super.key});

  @override
  State<GreetingScreen> createState() => _GreetingScreenState();
}

class _GreetingScreenState extends State<GreetingScreen> {
  bool _animate = false;

@override
void initState() {
  super.initState();
  _checkFirstTime();

  Future.delayed(const Duration(milliseconds: 300), () {
    if (mounted) {
      setState(() => _animate = true);
    }
  });
}

Future<void> _checkFirstTime() async {
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool("onboarded") ?? false;

  if (onboarded) {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }
}

 void _continue() {
  Navigator.pushReplacementNamed(context, "/login");
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        // 🔹 Background gym image
        Image.network(
          'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80',
          fit: BoxFit.cover,
        ),

        // 🔹 Dark overlay
        Container(color: Colors.black.withOpacity(0.6)),

        // 🔹 Foreground content
        SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale: _animate ? 1 : 0.85,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    child: const Icon(
                      Icons.fitness_center,
                      size: 90,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 30),

                  AnimatedOpacity(
                    opacity: _animate ? 1 : 0,
                    duration: const Duration(milliseconds: 700),
                    child: AnimatedSlide(
                      offset: _animate ? Offset.zero : const Offset(0, 0.2),
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOut,
                      child: const Text(
                        "Welcome to ChampsFit",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  AnimatedOpacity(
                    opacity: _animate ? 1 : 0,
                    duration: const Duration(milliseconds: 900),
                    child: AnimatedSlide(
                      offset: _animate ? Offset.zero : const Offset(0, 0.3),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOut,
                      child: const Text(
                        "Your reliable mass gainer application",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  AnimatedOpacity(
                    opacity: _animate ? 1 : 0,
                    duration: const Duration(milliseconds: 1100),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _continue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
