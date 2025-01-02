import 'package:http/http.dart' as http;
import 'package:project_android_final/config/config_url.dart';
import 'package:smart_auth/smart_auth.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
class AuthService {
  // đường dẫn tới API login
  String get apiUrl => "${Config_URL.baseUrl}Authenticate/login";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        //Lấy thông tin tên đăng nhập và password
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        bool status = data['status'];
        if (!status) {
          return {"success": false, "message": data['message']};
        }
        //lấy token trả về
        String token = data['token'];
        // Decode token để lấy các thông tin đăng nhập: tên đăng nhập, role...
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', token);  // Lưu token

        return {
          "success": true,
          "token": token,
          "decodedToken": decodedToken,
        };
      } else {
        // If status code is not 200, treat it as login failure
        return {"success": false, "message": "Failed to login: ${response.statusCode}"};
      }
    } catch (e) {
      // Handle network or parsing errors
      return {"success": false, "message": "Network error: $e"};
    }
  }
}

