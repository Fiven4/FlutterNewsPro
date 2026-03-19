import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'news_controller.dart';

class AuthController extends ChangeNotifier {
  UserModel? currentUser;
  bool isLoading = false;
  bool isInitialized = false;

  AuthController() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('current_user');
    if (userData != null) {
      currentUser = UserModel.fromJson(jsonDecode(userData));
      newsController.setUser(currentUser!.id);
    }
    isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentUser != null) {
      await prefs.setString('current_user', jsonEncode(currentUser!.toJson()));
    } else {
      await prefs.remove('current_user');
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (email.isNotEmpty && password.isNotEmpty) {
      currentUser = UserModel(id: email, name: email.split('@').first, email: email);
      await _saveUser();
      newsController.setUser(currentUser!.id);
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      currentUser = UserModel(id: email, name: name, email: email);
      await _saveUser();
      newsController.setUser(currentUser!.id);
      isLoading = false;
      notifyListeners();
      return true;
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  void updateProfile(String newName, String newBio) {
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(name: newName, bio: newBio);
      _saveUser();
      notifyListeners();
    }
  }

  void updateAvatar(String path) {
    if (currentUser != null) {
      currentUser = currentUser!.copyWith(avatarPath: path);
      _saveUser();
      notifyListeners();
    }
  }

  void logout() {
    currentUser = null;
    _saveUser();
    newsController.clearUser();
    notifyListeners();
  }
}

final authController = AuthController();