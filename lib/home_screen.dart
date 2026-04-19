import 'package:car_damage_detection/Tabs/History_tab.dart';
import 'package:car_damage_detection/Tabs/centers_tab.dart';
import 'package:car_damage_detection/Tabs/profile_tab.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Tabs/home_tap.dart';

class homescreen extends StatefulWidget {
  static const String RouteName = 'homescreen';

  const homescreen({super.key});

  @override
  State<homescreen> createState() => _homescreenState();
}

class _homescreenState extends State<homescreen> {
  int selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff0c77e1),
        elevation: 0,
        centerTitle: true,

        leading: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            Icons.car_crash_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),

        title: const Text(
          "Car Detect AI",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      /// 🔥 Body
      body: tabs[selectedIndex],

      /// 🔥 Floating Camera Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 90,
        width: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,

          /// 🔥 Glow خارجي
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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // 🔥 outline أبيض
            ),

            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    ),
                    builder: (_) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            const SizedBox(height: 20),

                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xffE3F2FD),
                                child: Icon(Icons.camera_alt, color: Colors.blue),
                              ),
                              title: const Text("Open Camera"),
                              onTap: () async {
                                Navigator.pop(context);
                                await _picker.pickImage(source: ImageSource.camera);
                              },
                            ),

                            ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xffE8F5E9),
                                child: Icon(Icons.photo, color: Colors.green),
                              ),
                              title: const Text("Choose from Gallery"),
                              onTap: () async {
                                Navigator.pop(context);
                                await _picker.pickImage(source: ImageSource.gallery);
                              },
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  );
                },

                /// 🔥 نخليها أصغر عشان تبان دائرية أكتر
                heroTag: "cameraBtn",
                backgroundColor: const Color(0xFF3B6DE3),
                elevation: 0,

                shape: const CircleBorder(),

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

      /// 🔥 Bottom Bar
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 10,
        color: Colors.white,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              /// LEFT
              _buildItem(Icons.home, "Home", 0),
              _buildItem(Icons.history, "History", 1),

              const SizedBox(width: 40), // space for FAB

              /// RIGHT
              _buildItem(Icons.map, "Centers", 2),
              _buildItem(Icons.person, "Profile", 3),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔥 Item Builder
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
            color: isSelected ? Color(0xFF3B6DE3) : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Color(0xFF3B6DE3) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> tabs = [
    HomeTab(),
    History_Tab(),
    centers_tab(),
    ProfileTab(),
  ];
}