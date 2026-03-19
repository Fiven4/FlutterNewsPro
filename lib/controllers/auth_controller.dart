import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import 'news_controller.dart';

class AuthController extends ChangeNotifier {
  UserModel? currentUser;
  bool isLoading = false;
  bool isInitialized = false;
  String appDocPath = '';

  AuthController() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final dir = await getApplicationDocumentsDirectory();
    appDocPath = dir.path;

    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getString('current_user_id');

    if (currentId != null) {
      final userData = prefs.getString('user_$currentId');
      if (userData != null) {
        currentUser = UserModel.fromJson(jsonDecode(userData));
        newsController.setUser(currentUser!.id);
      }
    }
    isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentUser != null) {
      await prefs.setString('current_user_id', currentUser!.id);
      await prefs.setString('user_${currentUser!.id}', jsonEncode(currentUser!.toJson()));
    } else {
      await prefs.remove('current_user_id');
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('user_$email');

      if (savedUser != null) {
        currentUser = UserModel.fromJson(jsonDecode(savedUser));
      } else {
        currentUser = UserModel(id: email, name: email.split('@').first, email: email);
      }

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

    await Future.delayed(const Duration(milliseconds: 800));

    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final savedUser = prefs.getString('user_$email');

      if (savedUser != null) {
        currentUser = UserModel.fromJson(jsonDecode(savedUser));
      } else {
        currentUser = UserModel(id: email, name: name, email: email);
      }

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

  Future<void> updateAvatar(String path) async {
    if (currentUser != null) {
      try {
        final fileName = 'avatar_${currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedImage = await File(path).copy('$appDocPath/$fileName');

        currentUser = currentUser!.copyWith(avatarPath: fileName);
        await _saveUser();
        notifyListeners();
      } catch (e) {
        debugPrint(e.toString());
      }
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