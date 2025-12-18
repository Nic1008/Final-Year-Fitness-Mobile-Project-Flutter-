// ignore: unused_import
import 'package:fitnessapp/models/meal_plan_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true;
  String? error;

  Future<void> _login() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      setState(() {
        error = "Please enter both email and password";
      });
      return;
    }

    setState(() => loading = true);

    try {
      final res = await ApiService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() => loading = false);

      // inside _login()

if (res['status'] == 200) {
  final prefs = await SharedPreferences.getInstance();
  final email = emailController.text.trim();

  await prefs.setString("email", email);

  final profile = await ApiService.getProfile(email);

  if (profile != null) {
    if (profile['display_name'] != null) { 
      await prefs.setString(
        "display_name_$email",
        profile['display_name'],
      );
    }

    if (profile['avatar_url'] != null) {
      await prefs.setString(
        "avatar_url_$email",
        profile['avatar_url'],
      );
    }

    if (profile['gender'] != null) {
      await prefs.setString("gender_$email", profile['gender']);
    }

    if (profile['age'] != null) {
      await prefs.setInt("age_$email", profile['age']);
    }

    if (profile['weight'] != null) {
      await prefs.setDouble(
        "weight_$email",
        profile['weight'].toDouble(),
      );
    }

    if (profile['target_weight'] != null) {
      await prefs.setDouble(
        "target_weight_$email",
        profile['target_weight'].toDouble(),
      );
    }
  }

  if (!mounted) return;
  Navigator.pushReplacementNamed(context, '/home');
}
else {
        setState(() => error = res['data']['message'] ?? 'Login failed');
      }
    } catch (_) {
      setState(() {
        loading = false;
        error = "Network or server error";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        brightness: Brightness.light,
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black54),
        ),
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?auto=format&fit=crop&w=800&q=80',
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withOpacity(0.55)),

            // LOGIN CARD
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Welcome to ChampsFit",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Your fitness journey starts here 💪",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // EMAIL
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email_outlined, color: Colors.black),
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.black87),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PASSWORD
                      TextField(
                        controller: passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black87),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.black87,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(error!, style: const TextStyle(color: Colors.red)),
                        ),

                      GestureDetector(
                        onTap: loading ? null : _login,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.teal.shade400,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Log in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Forgot password?",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No account? ",
                              style: TextStyle(color: Colors.black87)),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/signup'),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

