import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../api config.dart';

class UserController {
  final String baseUrl = "${ApiConfig.baseUrl}/Authentication";

  Future<bool> uploadImage(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("http://10.0.2.2:5161/api/Authentication/UploadProfileImage"),
      );

      request.headers['Authorization'] = "Bearer $token";

      request.files.add(await http.MultipartFile.fromPath('image', path));

      var response = await request.send();

      print("STATUS: ${response.statusCode}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ ERROR: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      print("TOKEN: $token");

      if (token == null || token.isEmpty) {
        print("❌ No token found");
        return null;
      }

      final response = await http.get(
        Uri.parse("$baseUrl/GetCurrentUser"),
        headers: {"Authorization": "Bearer $token"},
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return null;
    } catch (e) {
      print("❌ ERROR: $e");
      return null;
    }
  }
}
