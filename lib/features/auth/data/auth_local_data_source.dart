import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:postsapp/features/auth/domain/user_model.dart';

class AuthLocalDataSource {
  static const _tokenKey = 'access_token';
  static const _userKey = 'cached_user';

  final FlutterSecureStorage storage;

  AuthLocalDataSource(this.storage);

  Future<void> saveToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _userKey);
  }

  Future<UserModel?> getUser() async {
    final raw = await storage.read(key: _userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  Future<void> saveUser(UserModel user) async {
    await storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }
}
