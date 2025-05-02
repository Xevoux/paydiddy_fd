import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpHelper {
  static final String baseUrl = dotenv.env['API_URL'] ?? 'http://192.168.0.106:8000/api';

  // Headers untuk request
  static Future<Map<String, String>> _getHeaders() async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();

      if (kDebugMode) {
        print('GET Request: $url');
        print('Headers: $headers');
      }

      final response = await http.get(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  static Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();

      if (kDebugMode) {
        print('POST Request: $url');
        print('Headers: $headers');
        print('Body: $data');
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, dynamic data) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();

      if (kDebugMode) {
        print('PUT Request: $url');
        print('Headers: $headers');
        print('Body: $data');
      }

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl/$endpoint');
      final headers = await _getHeaders();

      if (kDebugMode) {
        print('DELETE Request: $url');
        print('Headers: $headers');
      }

      final response = await http.delete(url, headers: headers);
      return _processResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Process response
  static dynamic _processResponse(http.Response response) {
    if (kDebugMode) {
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw _handleHttpError(response);
    }
  }

  // Handle HTTP errors
  static String _handleHttpError(http.Response response) {
    String errorMessage = 'Terjadi kesalahan pada server';

    try {
      Map<String, dynamic> responseBody = jsonDecode(response.body);

      if (responseBody.containsKey('message')) {
        errorMessage = responseBody['message'];
      } else if (responseBody.containsKey('error')) {
        errorMessage = responseBody['error'];
      } else if (responseBody.containsKey('errors')) {
        if (responseBody['errors'] is Map) {
          List<String> errorsList = [];
          (responseBody['errors'] as Map).forEach((key, value) {
            if (value is List) {
              errorsList.addAll(value.map((e) => e.toString()));
            } else {
              errorsList.add(value.toString());
            }
          });
          errorMessage = errorsList.join('\n');
        } else {
          errorMessage = responseBody['errors'].toString();
        }
      }
    } catch (e) {
      // If unable to parse response body, use status code
      errorMessage = 'Error ${response.statusCode}: ${response.reasonPhrase}';
    }

    return errorMessage;
  }

  // Handle general errors
  static String _handleError(dynamic error) {
    return error.toString();
  }
}