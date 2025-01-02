import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Để lưu token
import 'package:project_android_final/common/color_extension.dart';
import 'package:project_android_final/common/extension.dart';
import 'package:project_android_final/common/globs.dart';
import 'package:project_android_final/common_widget/round_button.dart';
import 'package:project_android_final/view/login/rest_password_view.dart';
import 'package:project_android_final/view/login/sing_up_view.dart';
import 'package:project_android_final/view/main_tabview/main_tabview.dart';
import '../../common_widget/round_textfield.dart';
import '../../utils/auth.dart'; // Thêm Auth vào import

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController txtUsername = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),
              Text(
                "Login",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
              Text(
                "Add your details to login",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Your Username",
                controller: txtUsername,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundButton(
                title: isLoading ? "Loading..." : "Login",
                onPressed: (){ isLoading ? null : btnLogin();},
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResetPasswordView(),
                    ),
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "or Login With",
                style: TextStyle(
                    color: TColor.secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 30),
              // Add other login options here
            ],
          ),
        ),
      ),
    );
  }

  Future<void> btnLogin() async {
    if (txtUsername.text.isEmpty) {
      mdShowAlert(Globs.appName, "Please enter your username", () {});
      return;
    }

    if (txtPassword.text.isEmpty) {
      mdShowAlert(Globs.appName, "Please enter your password", () {});
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await Auth.login(
        txtUsername.text.trim(),
        txtPassword.text.trim(),
      );

      setState(() => isLoading = false);

      if (result['success'] == true) {
        // Lưu token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', result['token']);

        // Điều hướng dựa trên vai trò
        final role = result['role'] ?? "User";

        if (role == 'Admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainTabView()), // Thay đổi nếu cần
          );
        } else if (role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainTabView()), // Thay đổi nếu cần
          );
        } else {
          mdShowAlert(
            Globs.appName,
            "Invalid role: $role",
                () {},
          );
        }
      } else {
        mdShowAlert(
          Globs.appName,
          result['message'] ?? "Login failed",
              () {},
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      mdShowAlert(Globs.appName, "An error occurred: ${e.toString()}", () {});
    }
  }
}
