import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ======================================================
  // SIGNUP
  // ======================================================
  static Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(res);
    } catch (e) {
      return {'status': 500, 'data': {'message': 'Network error'}};
    }
  }

  // ======================================================
  // LOGIN
  // ======================================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final response = _handleResponse(res);

      if (response['status'] == 200) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('email', email);

        final profile = response['data']['profile'];
        if (profile != null) {

          // ✅ CORRECT KEY
          if (profile['display_name'] != null) {
            await prefs.setString(
              'display_name_$email',
              profile['display_name'],
            );
          }

          if (profile['gender'] != null) {
            await prefs.setString('gender_$email', profile['gender']);
          }

          if (profile['age'] != null) {
            await prefs.setInt('age_$email', profile['age']);
          }

          if (profile['weight'] != null) {
            await prefs.setDouble(
              'weight_$email',
              profile['weight'].toDouble(),
            );
          }

          if (profile['height'] != null) {
            await prefs.setDouble(
              'height_$email',
              profile['height'].toDouble(),
            );
          }

          if (profile['target_weight'] != null) {
            await prefs.setDouble(
              'target_weight_$email',
              profile['target_weight'].toDouble(),
            );
          }

          if (profile['avatar_url'] != null) {
            await prefs.setString(
              'avatar_url_$email',
              profile['avatar_url'],
            );
          }
        }
      }

      return response;
    } catch (e) {
      return {'status': 500, 'data': {'message': 'Network error'}};
    }
  }

  // ======================================================
  // GET PROFILE
  // ======================================================
  static Future<Map<String, dynamic>?> getProfile(String email) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/profile?email=$email'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ======================================================
  // UPDATE PROFILE
  // ======================================================
  static Future<bool> updateProfile({
    required String email,
    String? displayName,
    int? age,
    double? weight,
    double? height,
    String? gender,
    double? targetWeight,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'email': email,
      };

      if (displayName != null) body['display_name'] = displayName;
      if (age != null) body['age'] = age;
      if (weight != null) body['weight'] = weight;
      if (height != null) body['height'] = height;
      if (gender != null) body['gender'] = gender;
      if (targetWeight != null) body['target_weight'] = targetWeight;
      if (avatarUrl != null) body['avatar_url'] = avatarUrl;

      final res = await http.put(
        Uri.parse('$baseUrl/profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ======================================================
  // DELETE ACCOUNT
  // ======================================================
  static Future<bool> deleteAccount(String email) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/auth/delete-account'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ======================================================
  // RESPONSE HANDLER
  // ======================================================
  static Map<String, dynamic> _handleResponse(http.Response res) {
    try {
      return {
        'status': res.statusCode,
        'data': jsonDecode(res.body),
      };
    } catch (_) {
      return {
        'status': res.statusCode,
        'data': {'message': res.body},
      };
    }
  }
}




