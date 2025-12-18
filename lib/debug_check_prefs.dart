import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebugCheckPrefs extends StatefulWidget {
  const DebugCheckPrefs({super.key});

  @override
  State<DebugCheckPrefs> createState() => _DebugCheckPrefsState();
}

class _DebugCheckPrefsState extends State<DebugCheckPrefs> {
  Map<String, dynamic> prefsData = {};

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefsData = {
        "name": prefs.getString('name'),
        "gender": prefs.getString('gender'),
        "age": prefs.getInt('age'),
        "onboarded": prefs.getBool('onboarded'),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SharedPreferences Debug")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          prefsData.entries.map((e) => "${e.key}: ${e.value}").join("\n"),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
