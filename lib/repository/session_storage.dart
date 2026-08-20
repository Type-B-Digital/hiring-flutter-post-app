import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:post_app/models/auth_user.dart';

class SessionStorage {
  static const _key = 'session_user';

  Future<void> saveSession(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
  }

  Future<AuthUser?> readSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    return AuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
