import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterController extends ChangeNotifier {

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  bool isPasswordHidden = true;
  bool isLoading = false;

  String? nameError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;
  String? phoneError;

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  final String baseUrl = "10.0.2.2:5161"; // بدون http

  /// 🔥 اختيار صورة
  Future<void> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      selectedImage = File(picked.path);
      notifyListeners();
    }
  }

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

    if (nameController.text.isEmpty) nameError = "Required";
    if (emailController.text.isEmpty) emailError = "Required";
    if (phoneController.text.isEmpty) phoneError = "Required";
    if (passwordController.text.isEmpty) passwordError = "Required";
    if (confirmPasswordController.text.isEmpty) confirmPasswordError = "Required";

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

  /// 🔥 تسجيل المستخدم
  Future<bool> registerUser() async {
    if (!validate()) return false;

    try {
      isLoading = true;
      notifyListeners();

      final uri = Uri.http(
        baseUrl,
        "/api/Authentication/Register",
        {
          "Email": emailController.text.trim(),
          "Password": passwordController.text.trim(),
          "UserName": nameController.text.trim(),
          "Name": nameController.text.trim(),
          "PhoneNumber": phoneController.text.trim(),
        },
      );

      final request = http.MultipartRequest('POST', uri);

      /// 🔥 لو فيه صورة
      if (selectedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Image',
            selectedImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");

      if (response.statusCode != 200) {
        return false;
      }

      /// 🔥 خد الصورة من السيرفر
      final registerData = jsonDecode(response.body);
      String? profileImage = registerData["profileImage"];

      /// 🔥 Auto Login
      /// 🔥 Auto Login
      final loginResponse = await http.post(
        Uri.parse("http://$baseUrl/api/Authentication/Login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      print("LOGIN STATUS: ${loginResponse.statusCode}");
      print("LOGIN BODY: ${loginResponse.body}");

      final data = jsonDecode(loginResponse.body);

      /// 🔥 أهم check (مهم جدًا)
      if (data["StatusCode"] != null && data["StatusCode"] != 200) {
        print("❌ LOGIN ERROR: ${data["ErrorMessage"]}");
        return false;
      }

      /// 🔥 token
      final token = data['token'];

      if (token == null) {
        print("❌ No token");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();

      /// 🔥 حفظ التوكن
      await prefs.setString("token", token);

      /// 🔥 حفظ صورة المستخدم
      if (profileImage != null && profileImage.isNotEmpty) {
        await prefs.setString("profileImage", profileImage);
      }

      return true;

      return false;

    } catch (e) {
      print("❌ ERROR: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}