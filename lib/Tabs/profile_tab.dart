import 'package:car_damage_detection/loginscreen.dart';
import 'package:flutter/material.dart';
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
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(child: Text("❌ Failed to load user"));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔥 Header
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF3B6DE3),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [

                  /// Avatar
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Color(0xFF3B6DE3)),
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

            /// 🔥 Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [

                  _buildCard(
                    icon: Icons.person,
                    title: "Full Name",
                    value: user!['name'],
                  ),

                  const SizedBox(height: 15),

                  _buildCard(
                    icon: Icons.email,
                    title: "Email",
                    value: user!['email'],
                  ),

                  const SizedBox(height: 15),

                  _buildCard(
                    icon: Icons.verified,
                    title: "Status",
                    value: user!['status'] ?? "Active",
                  ),

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed:() {
                        Navigator.pushReplacementNamed(
                          context,
                          FeaturesScreen.RouteName,
                        );
                      },
                      label: const Text("about",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF3B6DE3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  /// 🔥 Logout
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout,color:Colors.red ,),
                      label: const Text("Logout",style: TextStyle(color: Colors.red),),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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