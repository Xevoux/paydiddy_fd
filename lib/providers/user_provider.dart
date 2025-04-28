import 'package:flutter/material.dart';
import 'package:paydiddy/models/user.dart';
import 'package:paydiddy/services/auth_service.dart';
import 'package:paydiddy/utils/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _token;
  String? _error;
  final AuthService _authService = AuthService();

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get error => _error;
  bool get isLoggedIn => _token != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;

  // Initialize from shared preferences
  Future<void> initUser() async {
    _setLoading(true);
    _clearError();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token != null) {
        // Get user profile from API if token exists
        await getUserProfile();
      }
    } catch (e) {
      _setError('Error initializing user: $e');
      _token = null;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  // Get user profile from API
  Future<void> getUserProfile() async {
    if (_token == null) return;

    _setLoading(true);
    _clearError();

    try {
      final data = await _authService.getUserProfile();
      _user = User.fromJson(data);
    } catch (e) {
      _setError('Error getting user profile: $e');
      // Token might be invalid, clear it
      _token = null;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } finally {
      _setLoading(false);
    }
  }

  // Login
  Future<User?> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);

      // Save token to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token']);
      await prefs.setString('role', response['role']);
      await prefs.setInt('user_id', response['user']['id']);

      _token = response['token'];
      _user = User.fromJson(response['user']);

      return _user;
    } catch (e) {
      _setError('Login error: $e');
      rethrow; // Rethrow to handle in UI
    } finally {
      _setLoading(false);
    }
  }

  // Register
  Future<void> register(String name, String email, String password, String phoneNumber) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.register(name, email, password, phoneNumber);
      // Note: We don't log in the user automatically after registration
    } catch (e) {
      _setError('Register error: $e');
      rethrow; // Rethrow to handle in UI
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      if (_token != null) {
        await _authService.logout();
      }

      // Clear stored data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _token = null;
      _user = null;
    } catch (e) {
      _setError('Logout error: $e');
      // Still clear local data even if API call fails
      _token = null;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<void> updateProfile({
    required String name,
    String? phoneNumber,
  }) async {
    if (_user == null) return;

    _setLoading(true);
    _clearError();

    try {
      final data = {
        'name': name,
      };

      if (phoneNumber != null) {
        data['phone_number'] = phoneNumber;
      }

      final response = await HttpHelper.put('user/profile', data);

      // Update local user object
      _user = User.fromJson(response['data']);

    } catch (e) {
      _setError('Update profile error: $e');
      rethrow; // Rethrow to handle in UI
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (_user == null) return;

    _setLoading(true);
    _clearError();

    try {
      await HttpHelper.put('user/password', {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      });

    } catch (e) {
      _setError('Change password error: $e');
      rethrow; // Rethrow to handle in UI
    } finally {
      _setLoading(false);
    }
  }

  // Update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _error = null;
    notifyListeners();
  }
}