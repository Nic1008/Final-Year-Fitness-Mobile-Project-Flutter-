import 'package:fitnessapp/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme_manager.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? displayName;
  String? email;
  int? age;
  double? weight;
  double? height;
  String? gender;
  String? avatarUrl;
  double? targetWeight;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => loading = true);

    final prefs = await SharedPreferences.getInstance();
    email = prefs.getString("email");

    if (email == null) {
      setState(() => loading = false);
      return;
    }

    // 🔥 REMOVE legacy signup-name cache ONCE
    await prefs.remove("name_$email");

    final data = await ApiService.getProfile(email!);

    if (data != null) {
      displayName = data["display_name"] ?? data["name"];
      gender = data["gender"];
      age = data["age"];
      weight = data["weight"]?.toDouble();
      height = data["height"]?.toDouble();
      avatarUrl = data["avatar_url"];
      targetWeight = data["target_weight"]?.toDouble();

      if (displayName != null) {
        prefs.setString("display_name_$email", displayName!);
      }
      if (gender != null) prefs.setString("gender_$email", gender!);
      if (age != null) prefs.setInt("age_$email", age!);
      if (weight != null) prefs.setDouble("weight_$email", weight!);
      if (height != null) prefs.setDouble("height_$email", height!);
      if (targetWeight != null) {
        prefs.setDouble("target_weight_$email", targetWeight!);
      }
      if (avatarUrl != null) {
        prefs.setString("avatar_url_$email", avatarUrl!);
      }
    } else {
      // ---------- SAFE FALLBACK ----------
      displayName = prefs.getString("display_name_$email");
      gender = prefs.getString("gender_$email");
      age = prefs.getInt("age_$email");
      weight = prefs.getDouble("weight_$email");
      height = prefs.getDouble("height_$email");
      targetWeight = prefs.getDouble("target_weight_$email");
      avatarUrl = prefs.getString("avatar_url_$email");
    }

    setState(() => loading = false);
  }

  String genderSymbol() {
    if (gender == "Male") return "♂";
    if (gender == "Female") return "♀";
    return "⚧";
  }

  Future<void> _confirmDeleteAccount() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "This action is permanent. All your data will be deleted and cannot be recovered.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");

    if (email == null) return;

    final success = await ApiService.deleteAccount(email);

    if (!mounted) return;

    if (success) {
      await prefs.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete account")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeManager = Provider.of<ThemeManager>(context);
    final isDark = themeManager.isDarkMode;

    if (loading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Profile",
            onPressed: _loadProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // -------- Profile card --------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                      backgroundColor: theme.dividerColor.withOpacity(0.4),
                      child: avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 48,
                              color:
                                  theme.iconTheme.color?.withOpacity(0.5) ??
                                      Colors.grey,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    if (gender != null)
                      Text(
                        genderSymbol(),
                        style: TextStyle(
                          fontSize: 22,
                          color: gender == "Male"
                              ? Colors.blue
                              : gender == "Female"
                                  ? Colors.pink
                                  : Colors.purple,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      "Hi, ${displayName ?? 'User'} 👋",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (email != null)
                      Text(
                        email!,
                        style: theme.textTheme.bodySmall,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      "${age ?? '-'} years  •  ${weight?.toStringAsFixed(1) ?? '-'} kg  •  ${height?.toStringAsFixed(1) ?? '-'} cm",
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _sectionTitle(context, "Settings"),

              _menuTile(
                context,
                icon: Icons.brightness_6_rounded,
                text: "Dark Mode",
                trailing: Switch(
                  value: isDark,
                  onChanged: (value) => themeManager.toggleTheme(value),
                ),
                onTap: () {},
              ),

              _menuTile(
                context,
                icon: Icons.edit,
                text: "Edit Profile",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ).then((_) => _loadProfile());
                },
              ),

              _menuTile(
                context,
                icon: Icons.info_outline,
                text: "About This App",
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "Fitness App",
                    applicationVersion: "1.0.0",
                    children: const [
                      Text(
                        "This app helps users gain muscle, track progress, and stay consistent.",
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 10),

              _menuTile(
                context,
                icon: Icons.exit_to_app_rounded,
                text: "Logout",
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),

              const SizedBox(height: 10),

              _menuTile(
                context,
                icon: Icons.delete_forever,
                text: "Delete Account",
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: _confirmDeleteAccount,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          text,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String text,
    Color? iconColor,
    Color? textColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.iconTheme.color),
      title: Text(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: textColor ?? theme.textTheme.bodyMedium?.color,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

