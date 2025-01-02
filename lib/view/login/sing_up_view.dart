import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project_android_final/common/color_extension.dart';
import 'package:project_android_final/common_widget/round_button.dart';
import 'package:project_android_final/common_widget/round_textfield.dart';
import 'package:project_android_final/common/extension.dart';
import 'package:project_android_final/common/globs.dart';
import 'package:project_android_final/view/login/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_android_final/view/main_tabview/main_tabview.dart';
import '../../utils/auth.dart';
import '../on_boarding/on_boarding_view.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController txtName = TextEditingController();
  final TextEditingController txtMobile = TextEditingController();
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();

  bool _isLoading = false;

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
                "Sign Up",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                "Add your details to sign up",
                style: TextStyle(
                  color: TColor.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Name",
                controller: txtName,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Email",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Mobile No",
                controller: txtMobile,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundTextfield(
                hintText: "Confirm Password",
                controller: txtConfirmPassword,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              RoundButton(
                title: _isLoading ? "Loading..." : "Sign Up",
                onPressed: (){_isLoading ? null : btnSignUp();}
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Already have an Account? ",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Login",
                      style: TextStyle(
                        color: TColor.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Xử lý đăng ký khi nhấn nút Sign Up
  Future<void> btnSignUp() async {
    if (txtName.text.isEmpty) {
      showAlert("Error", "Please enter your name");
      return;
    }

    if (txtEmail.text.isEmpty || !RegExp(r'\S+@\S+\.\S+').hasMatch(txtEmail.text)) {
      showAlert("Error", "Please enter a valid email");
      return;
    }

    if (txtMobile.text.isEmpty) {
      showAlert("Error", "Please enter your mobile number");
      return;
    }

    if (txtPassword.text.isEmpty || txtPassword.text.length < 3) {
      showAlert("Error", "Password must be at least 6 characters");
      return;
    }

    if (txtPassword.text != txtConfirmPassword.text) {
      showAlert("Error", "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await Auth.register(
        username: txtName.text,
        email: txtEmail.text,
        password: txtPassword.text,
        role: "User",
        phone: txtMobile.text,
      );

      if (result['success'] == true) {
        // Lưu JWT token vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', result['token']);
        String role = result['role'] ?? "User";

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
        showAlert("Error", result['message'] ?? "Registration failed");
      }
    } catch (e) {
      showAlert("Error", "An error occurred: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }


  void showAlert(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onOk != null) onOk();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
