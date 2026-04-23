import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../api config.dart';

class ResetPasswordController extends ChangeNotifier {

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? passwordError;
  String? confirmError;
  bool isLoading = false;

  final String baseUrl = "${ApiConfig.baseUrl}/Authentication";
  Future<bool> resetPassword({
    required String email,
    required String token,
  }) async {

    if (passwordController.text.isEmpty) {
      passwordError = "Required";
      notifyListeners();
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      confirmError = "Passwords don't match";
      notifyListeners();
      return false;
    }

    try {
      isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse("$baseUrl/ResetPassword"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "token": token,
          "newPassword": passwordController.text.trim(),
        }),
      );

      print(response.body);

      return response.statusCode == 200;

    } catch (e) {
      print(e);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}