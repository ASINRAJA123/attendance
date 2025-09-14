// providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  final ApiService _apiService = ApiService();

  User? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  String? get userRole => _user?.role;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }

    final extractedUserData = jsonDecode(prefs.getString('userData')!) as Map<String, dynamic>;
    _token = extractedUserData['token'];
    _user = User(
      id: extractedUserData['id'],
      name: extractedUserData['name'],
      rollNumber: extractedUserData['rollNumber'], // Load rollNumber
      email: extractedUserData['email'],
      role: extractedUserData['role'],
    );
    notifyListeners();
    return true;
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.login(email, password);
    _token = response['token'];
    _user = User.fromJson(response);

    final prefs = await SharedPreferences.getInstance();
    final userData = jsonEncode({
      'token': _token,
      'id': _user!.id,
      'name': _user!.name,
      'rollNumber': _user!.rollNumber, // Save rollNumber
      'email': _user!.email,
      'role': _user!.role,
    });
    await prefs.setString('userData', userData);

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}