import 'package:paydiddy/utils/http_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Register
  Future<Map<String, dynamic>> register(
      String name,
      String email,
      String password,
      String phoneNumber,
      ) async {
    final response = await HttpHelper.post('register', {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'phone_number': phoneNumber,
    });

    return response;
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await HttpHelper.post('login', {
      'email': email,
      'password': password,
    });

    return response;
  }

  // Logout
  Future<void> logout() async {
    await HttpHelper.post('logout', {});

    // Clear stored token and user data
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await HttpHelper.get('user');
    return response;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null;
  }

  // Get user role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }
}