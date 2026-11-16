import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<JsonMap?> login(String username, String password) async {
    try {
      final res = await _api.post('/login', body: {'username': username, 'password': password}, withAuth: false);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as JsonMap;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);
        await prefs.setString('role', data['actor']);
        await prefs.setBool('is_profile_completed', data['is_profile_completed'] ?? false);
        return data;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendOtpEmail(String email) async {
    final res = await _api.post('/forgot-password/send-otp', body: {'email': email}, withAuth: false);
    return res.statusCode == 200;
  }

  Future<bool> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    final res = await _api.post('/forgot-password/reset', body: {
      'email': email,
      'otp': otp,
      'password': newPassword,
    }, withAuth: false);
    return res.statusCode == 200;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final res = await _api.post('/change-password', body: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    return res.statusCode == 200;
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}