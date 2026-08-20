import 'package:flutter/foundation.dart';
import 'package:post_app/models/auth_user.dart';
import 'package:post_app/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider(this._repository, {this.user});

  AuthUser? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => user != null;

  Future<void> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      user = await _repository.login(username: username, password: password);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    user = null;
    notifyListeners();
  }
}
