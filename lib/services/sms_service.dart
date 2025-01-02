import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:smart_auth/smart_auth.dart';

class SmsService {
  final SmartAuth smartAuth = SmartAuth.instance;

  /// Lấy mã OTP qua SMS User Consent API
  Future<String?> getOtpWithUserConsent() async {
    final res = await smartAuth.getSmsWithUserConsentApi();
    if (res.hasData) {
      return res.requireData.code;
    } else if (res.isCanceled) {
      print('Người dùng đã hủy dialog.');
      return null;
    } else {
      print('Lỗi khi lấy mã OTP: ${res.error}');
      return null;
    }
  }

  /// Lấy mã OTP qua SMS Retriever API
  Future<String?> getOtpWithRetriever() async {
    final res = await smartAuth.getSmsWithRetrieverApi();
    if (res.hasData) {
      return res.requireData.code;
    } else {
      print('Lỗi khi lấy mã OTP: ${res.error}');
      return null;
    }
  }

  /// Tạo mã OTP ngẫu nhiên
  String generateOtp({int length = 6}) {
    final random = Random();
    String otp = '';
    for (int i = 0; i < length; i++) {
      otp += random.nextInt(10).toString(); // Tạo số từ 0 đến 9
    }
    print('Mã OTP được tạo: $otp');
    return otp;
  }

  /// Gửi mã OTP qua SMS
  Future<void> sendOtp(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-backend-api/send-otp'),
        body: {
          'phone': phoneNumber,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        print('Mã OTP đã được gửi đến $phoneNumber.');
      } else {
        print('Lỗi khi gửi OTP: ${response.body}');
      }
    } catch (e) {
      print('Lỗi khi gửi OTP: $e');
    }
  }

  /// Xóa listener khi không cần
  void removeSmsListeners() {
    smartAuth.removeUserConsentApiListener();
    smartAuth.removeSmsRetrieverApiListener();
  }
}
