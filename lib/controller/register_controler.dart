import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterController extends ChangeNotifier {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController(); // 🔥 جديد

  bool isPasswordHidden = true;
  bool isLoading = false;

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? phoneError;

  final String baseUrl = "http://10.0.2.2:5161/api/Authentication";

  void togglePassword() {
    isPasswordHidden = !isPasswordHidden;
    notifyListeners();
  }

  void clearErrors() {
    nameError = null;
    emailError = null;
    passwordError = null;
    confirmPasswordError = null;
    phoneError = null;
  }

  bool validate() {
    clearErrors();

    if (nameController.text.isEmpty) {
      nameError = "Required";
    }

    if (emailController.text.isEmpty) {
      emailError = "Required";
    }

    if (phoneController.text.isEmpty) {
      phoneError = "Required";
    }

    if (passwordController.text.isEmpty) {
      passwordError = "Required";
    }

    if (confirmPasswordController.text.isEmpty) {
      confirmPasswordError = "Required";
    }

    if (passwordController.text != confirmPasswordController.text) {
      confirmPasswordError = "Passwords don't match";
    }

    notifyListeners();

    return nameError == null &&
        emailError == null &&
        passwordError == null &&
        confirmPasswordError == null &&
        phoneError == null;
  }

  Future<bool> registerUser() async {
    if (!validate()) return false;

    try {
      isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse("$baseUrl/Register"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameController.text.trim(),
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
          "phoneNumber": phoneController.text.trim(), // 🔥 مهم
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      return response.statusCode == 200;

    } catch (e) {
      print("❌ ERROR: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}