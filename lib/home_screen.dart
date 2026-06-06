import 'package:car_damage_detection/Tabs/profile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'History_tab.dart';
import 'Tabs/home_tap.dart';
import 'car_details.dart';
import 'controller/user_controler.dart';

class homescreen extends StatefulWidget {
  static const String RouteName = 'homescreen';

  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  int selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();

  List<Widget> tabs = [
    const HomeTab(),
    const HistoryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      /// 🔥 AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xff0c77e1),
        elevation: 0,
        title: const Text(
          "Car Detect AI",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        /// 🔥 Profile Image
        actions: [
          FutureBuilder(
            future: UserController().getCurrentUser(),
            builder: (context, snapshot) {

              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: CircleAvatar(child: Icon(Icons.person)),
                );
              }

              final user = snapshot.data!;
              final imageUrl = user["profileImage"];

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileTab(),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl == null || imageUrl.isEmpty)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      /// 🔥 Animation Switch
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.2, 0),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: tabs[selectedIndex],
      ),

      /// 🔥 Floating Button في النص
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFAB(),

      /// 🔥 Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 20,
        elevation: 10,
        color: Colors.white,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// 🔥 الشمال
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: _buildItem(Icons.home, "Home", 0),
              ),

              /// 🔥 مساحة للـ FAB
              const SizedBox(width: 80),

              /// 🔥 اليمين
              Padding(
                padding: const EdgeInsets.only(right: 25),
                child: _buildItem(Icons.history, "History", 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 FAB احترافي
  Widget _buildFAB() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1, end: 1.08),
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B6DE3).withOpacity(0.4),
                  blurRadius: 25,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Container(
                height: 75,
                width: 75,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: FloatingActionButton(
                    heroTag: "cameraBtn",
                    backgroundColor: const Color(0xFF3B6DE3),
                    elevation: 0,
                    shape: const CircleBorder(),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CarDetailsScreen(),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.camera_alt,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  /// 🔥 Bottom Item
  Widget _buildItem(IconData icon, String label, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF3B6DE3) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? const Color(0xFF3B6DE3) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}