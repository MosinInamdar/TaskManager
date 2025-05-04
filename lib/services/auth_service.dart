import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  final List<User> _users = [];
  User? _currentUser;

  AuthService() {
    loadData();
  }

  User? get currentUser => _currentUser;

  bool isLoggedIn() {
    return _currentUser != null;
  }

  Future<void> signUp(String email, String password) async {
    try {
      // Check if user already exists
      final existingUser = _users.any((user) => user.email == email);
      if (existingUser) {
        throw Exception('User with this email already exists');
      }
      
      final newUser = User(id: const Uuid().v4(), email: email, password: password);
      _users.add(newUser);
      _currentUser = newUser;
      await saveData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error signing up: $e');
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      // Using firstWhere with orElse to handle when no user is found
      final user = _users.firstWhere(
        (user) => user.email == email && user.password == password,
        orElse: () => throw Exception('Invalid email or password'),
      );
      
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error during login: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadData() async {
    try {
      final file = await _getLocalFile();
      if (await file.exists()) {
        final jsonString = await file.readAsString();
        if (jsonString.isNotEmpty) {
          final List<dynamic> jsonList = json.decode(jsonString);
          _users.clear();
          _users.addAll(jsonList.map((json) => User.fromJson(json)));
          debugPrint('Loaded ${_users.length} users');
        }
      }
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  Future<void> saveData() async {
    try {
      final file = await _getLocalFile();
      final jsonString = json.encode(_users.map((user) => user.toJson()).toList());
      await file.writeAsString(jsonString);
      debugPrint('Saved ${_users.length} users');
    } catch (e) {
      debugPrint('Error saving users: $e');
    }
  }

  Future<File> _getLocalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/users.txt');
  }
}