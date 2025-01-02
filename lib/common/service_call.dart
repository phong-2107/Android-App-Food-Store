import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:project_android_final/common/globs.dart';
import 'package:project_android_final/common/locator.dart';

typedef ResSuccess = Future<void> Function(Map<String, dynamic>);
typedef ResFailure = Future<void> Function(dynamic);

class ServiceCall {
  static final NavigationService navigationService = locator<NavigationService>();
  static Map userPayload = {};


  static void post(Map<String, dynamic> parameter, String path,
      {bool isToken = false, ResSuccess? withSuccess, ResFailure? failure}) {
    Future(() {
      try {
        // Kiểm tra thông tin đăng nhập demo
        if (path == SVKey.svLogin ||
            parameter['email'] == '1@gmail.com' &&
            parameter['password'] == '1') {
          // Trả về phản hồi giả lập khi thông tin đúng
          var fakeResponse = {
            "status": "1",
            "message": "Login successful",
            "payload": {
              "user_id": "123",
              "email": "demo@gmail.com",
              "name": "Demo User",
            }
          };

          if (withSuccess != null) {
            withSuccess(fakeResponse);
          }
          return;
        }

        // Xử lý trường hợp thông tin không hợp lệ
        if (path == SVKey.svLogin) {
          var fakeErrorResponse = {
            "status": "0",
            "message": "Invalid email or password",
          };

          if (withSuccess != null) {
            withSuccess(fakeErrorResponse);
          }
          return;
        }

        // Thực hiện yêu cầu HTTP nếu không phải kiểm tra demo
        var headers = {'Content-Type': 'application/x-www-form-urlencoded'};
        http
            .post(Uri.parse(path), body: parameter, headers: headers)
            .then((value) {
          if (kDebugMode) {
            print(value.body);
          }
          try {
            var jsonObj =
                json.decode(value.body) as Map<String, dynamic>? ?? {};

            if (withSuccess != null) withSuccess(jsonObj);
          } catch (err) {
            if (failure != null) failure(err.toString());
          }
        }).catchError((e) {
          if (failure != null) failure(e.toString());
        });
      } catch (err) {
        if (failure != null) failure(err.toString());
      }
    });
  }


  static logout(){
    Globs.udBoolSet(false, Globs.userLogin);
    userPayload = {};
    navigationService.navigateTo("welcome");
  }


}
