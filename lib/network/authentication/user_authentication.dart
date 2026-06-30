import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ─────────────────────────────────────────────────────────────────//
// GLOBAL CONFIGURATION        ==================================
// ─────────────────────────────────────────────────────────────────//
class SecreteData {
  final String? apiToken;

  const SecreteData([this.apiToken]);

  static const String authUrl = 'https://merchantcore-api.onrender.com';
  static const String authLoginEndpoint = '/api/v1/auth/login';
  static const String authSignupEndpoint = '/api/v1/auth/register';
  static const String verifyEmailEndpoint = '/api/v1/auth/verify-email';
  static const String getUserInfoEndpoint = '/api/v1/users/me';

  Map<String, String> getHeaders() {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
    if (apiToken != null && apiToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiToken';
    }
    return headers;
  }
}

// ─────────────────────────────────────────────────────────────────
// FLUTTER ENCRYPTED SECURE STORAGE ENGINE
// ─────────────────────────────────────────────────────────────────
class TokenStorage {

  // Encapsulated secure hardware storage instance for iOS/Android
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'secure_access_token';

  /// Saves the token securely to the device hardware keychain system
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Reads the encrypted token value back out from hardware storage
  static Future<String?> loadToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Wipes out the current active session token storage data (Log out)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}

// ─────────────────────────────────────────────────────────────────
// FLUTTER MOBILE AUTHENTICATION ACTIONS
// ─────────────────────────────────────────────────────────────────
class UserService {
  final String _base = SecreteData.authUrl;

  /// Logs in a user, parses the access_token, and saves it securely to the device
  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$_base${SecreteData.authLoginEndpoint}');

    final response = await http.post(
      url,
      headers: const SecreteData().getHeaders(),
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final String token = body['access_token']?.toString() ?? '';

      if (token.isNotEmpty) {
        // Persist token safely inside the phone's encrypted environment
        await TokenStorage.saveToken(token);
      }
    }

    return response;
  }

  /// Registers a new user account on the backend server
  Future<http.Response> signUp(
    String email,
    String username,
    String password,
    String fullname,
  ) async {
    final url = Uri.parse('$_base${SecreteData.authSignupEndpoint}');

    final response = await http.post(
      url,
      headers: const SecreteData().getHeaders(),
      body: jsonEncode({
        "email": email,
        "username": username,
        "full_name": fullname,
        "password": password,
      }),
    );

    return response;
  }

  /// Verifies user email by passing the locally stored hardware token as a query parameter
  Future<http.Response?> verifyEmail() async {
    final token = await TokenStorage.loadToken();
    if (token == null || token.isEmpty) {
      debugPrint('Auth Error: No locally saved secure token found to verify.');
      return null;
    }

    final url = Uri.parse(
      '$_base${SecreteData.verifyEmailEndpoint}?token=$token',
    );
    return await http.get(url);
  }

  /// Reads the secure hardware token and requests profile details
  Future<http.Response?> getUserInfo() async {
    final token = await TokenStorage.loadToken();
    if (token == null || token.isEmpty) {
      debugPrint('Auth Error: No locally saved secure token found.');
      return null;
    }

    final url = Uri.parse('$_base${SecreteData.getUserInfoEndpoint}');

    return await http.get(url, headers: SecreteData(token).getHeaders());
  }
}
