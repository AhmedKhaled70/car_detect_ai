import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api config.dart';

class ForgotPasswordController extends ChangeNotifier {

  final emailController = TextEditingController();

  bool isLoading = false;
  String? emailError;

  final String baseUrl = "${ApiConfig.baseUrl}/Authentication";

  bool validate() {
    emailError = null;

    if (emailController.text.isEmpty) {
      emailError = "Email is required";
      notifyListeners();
      return false;
    }

    return true;
  }

  Future<String?> sendReset() async {
    if (!validate()) return null;

    try {
      isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse("$baseUrl/ForgotPassword"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": emailController.text.trim(),
        }),
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      final data = jsonDecode(response.body);

      return data['message'] ?? "Check your email";

    } catch (e) {
      return "Something went wrong";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}