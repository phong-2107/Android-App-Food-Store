import 'dart:convert';
import 'package:project_android_final/services/api_client.dart';
import 'package:project_android_final/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth {
  static final AuthService _authService = AuthService();
  static final ApiClient _apiClient = ApiClient();

  static Future<Map<String, dynamic>> login(String username, String password) async {
    var result = await _authService.login(username, password);
    print("Kết quả trả về từ API: $result");

    if (result.containsKey('decodedToken')) {
      // Lấy giá trị role từ decodedToken
      var decodedToken = result['decodedToken'];
      if (decodedToken != null && decodedToken.containsKey('role')) {
        result['role'] = decodedToken['role'];

        // Lưu role vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', decodedToken['role']);
      }
    }

    print("Role sau khi xử lý: ${result['role']}");
    return result; // returns a map with {success: bool, token: string?, role: string?, message: string?}
  }

  // Đăng ký tài khoản mới
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String role,
    required String phone,
  }) async {
    // Tạo body để gửi lên API
    Map<String, dynamic> body = {
      "username": username,
      "email": email,
      "password": password,
      "role": role,
      "phone": phone,
    };

    // Gọi API đăng ký thông qua ApiClient
    try {
      var response = await _apiClient.post('Authenticate/register', body: body);
      print('Response body: ${response.body}');
      // Xử lý kết quả từ API
      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);
        print("Kết quả đăng ký account: $result");

        // Kiểm tra giá trị `status` trong kết quả API
        if (result['status'] == true || result['status'] == "1") {
          return {
            'success': true,
            'token': result['token'] ?? '', // Xử lý nếu `token` không tồn tại
            'role': result['role'] ?? 'User', // Xử lý nếu `role` không tồn tại
            'message': result['message'] ?? 'Registration successful',
          };
        } else {
          return {
            'success': false,

            'message': result['message'] ?? 'Registration failed',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Đăng ký thất bại, vui lòng thử lại.'
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}'
      };
    }
  }
  static Future<String> verifyToken(String token) async {
    try {
      var response = await _apiClient.post(
        'Authenticate/verifyToken',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Kiểm tra trạng thái phản hồi từ API
      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);

        if (result['success'] == true) {
          // Lưu role vào SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userRole', result['role'] ?? 'User');

          // Trả về vai trò nếu token hợp lệ
          return result['role'] ?? 'User';
        } else {
          // Trả về lỗi nếu token không hợp lệ
          throw Exception(result['message'] ?? 'Token không hợp lệ');
        }
      } else {
        throw Exception('Lỗi từ máy chủ: ${response.statusCode}');
      }
    } catch (e) {
      // Xử lý lỗi kết nối hoặc lỗi khác
      throw Exception('Lỗi kết nối: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> logout(String token) async {
    try {
      // Gọi API logout thông qua ApiClient
      var response = await _apiClient.post(
        'Authenticate/logout',
        headers: {
          'Authorization': 'Bearer $token', // Đính kèm token trong header
          'Content-Type': 'application/json',
        },
      );

      // Kiểm tra trạng thái phản hồi từ API
      if (response.statusCode == 200) {
        // Chuyển đổi body JSON từ API thành Map
        var result = jsonDecode(response.body);

        // Xóa role khỏi SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('userRole');

        return {
          'success': result['Status'] ?? true,
          'message': result['Message'] ?? 'Đăng xuất thành công',
        };
      } else {
        return {
          'success': false,
          'message': 'Đăng xuất thất bại, vui lòng thử lại.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: ${e.toString()}',
      };
    }
  }
}
