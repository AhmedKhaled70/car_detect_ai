import 'dart:io';
import 'package:car_damage_detection/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/user_controler.dart';
import 'feature screen.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {

  final UserController _controller = UserController();

  Map<String, dynamic>? user;
  bool isLoading = true;

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final data = await _controller.getCurrentUser();

      setState(() {
        user = data;
        isLoading = false;
      });

    } catch (e) {
      print("ERROR: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushNamedAndRemoveUntil(
      context,
      loginscreen.RouteName,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("❌ Failed to load user")),
      );
    }
    final imageUrl = user!['profileImage'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      /// 🔥 AppBar بسهم رجوع
      appBar: AppBar(
        backgroundColor: const Color(0xFF3B6DE3),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // 🔥 رجوع للهوم
          },
        ),
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white,fontSize:30),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔥 Header
            Container(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B6DE3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  /// 🔥 Avatar (Editable)
                  GestureDetector(

                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: selectedImage != null
                          ? FileImage(selectedImage!) as ImageProvider
                          : (imageUrl != null && imageUrl.toString().isNotEmpty
                          ? NetworkImage(imageUrl)
                          : null),
                      child: (selectedImage == null &&
                          (imageUrl == null || imageUrl.toString().isEmpty))
                          ? const Icon(Icons.person,
                          size: 50, color: Color(0xFF3B6DE3))
                          : null,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// Name
                  Text(
                    user!['name'] ?? "No Name",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  /// Email
                  Text(
                    user!['email'] ?? "",
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  _buildCard(
                    icon: Icons.person,
                    title: "Full Name",
                    value: user!['name'] ?? "",
                  ),

                  const SizedBox(height: 20),

                  _buildCard(
                    icon: Icons.email,
                    title: "Email",
                    value: user!['email'] ?? "",
                  ),

                  const SizedBox(height: 200),

                  /// About
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          FeaturesScreen.RouteName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B6DE3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "About",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Logout
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B6DE3)),
          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }
}