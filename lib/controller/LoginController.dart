import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api config.dart';

class LoginController extends ChangeNotifier {

  /// 🔹 Controllers
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  /// 🔹 States
  bool isLoading = false;
  bool isPasswordHidden = true;

  String? emailError;
  String? passwordError;

  final String baseUrl = "${ApiConfig.baseUrl}/Authentication";

  /// 🔹 Toggle Password
  void togglePassword() {
    isPasswordHidden = !isPasswordHidden;
    notifyListeners();
  }

  /// 🔹 Validation
  bool validate() {
    emailError = null;
    passwordError = null;

    if (emailController.text.isEmpty) {
      emailError = "Email is required";
    }

    if (passwordController.text.isEmpty) {
      passwordError = "Password is required";
    }

    notifyListeners();

    return emailError == null && passwordError == null;
  }

  /// 🔐 Login
  Future<bool> loginUser() async {
    if (!validate()) return false;

    try {
      isLoading = true;
      notifyListeners();

      print("🚀 START LOGIN");

      final response = await http.post(
        Uri.parse("$baseUrl/Login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      /// 🔥 Handle API error (حتى لو status 200)
      if (data["StatusCode"] != null && data["StatusCode"] != 200) {
        print("❌ LOGIN ERROR: ${data["ErrorMessage"]}");
        return false;
      }

      /// 🔥 Token
      final token = data['token'];

      if (token == null || token.toString().isEmpty) {
        print("❌ No token received");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      /// 🔥 Save token
      await prefs.setString("token", token);

      /// 🔥 Save profile image (من غير ما تمسح القديمة)
      if (data["profileImage"] != null &&
          data["profileImage"].toString().isNotEmpty) {

        await prefs.setString("profileImage", data["profileImage"]);
        print("🖼 SAVED IMAGE: ${data["profileImage"]}");
      } else {
        print("⚠️ No image returned from login, keeping old one");
      }

      print("🔥 TOKEN SAVED");

      return true;

    } catch (e) {
      print("❌ EXCEPTION: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🔐 Forgot Password
  Future<String?> resetPassword() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ForgotPassword"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      return data['message'];
    } catch (e) {
      return "Something went wrong";
    }
  }

  /// 🔓 Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");

    /// ❗ مهم: امسح الصورة كمان لو عايز reset كامل
    await prefs.remove("profileImage");
  }
}