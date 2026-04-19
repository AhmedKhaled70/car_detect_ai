import 'package:flutter/material.dart';

class FeaturesScreen extends StatelessWidget {
  static const String RouteName = 'FeaturesScreen';
  const FeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("About App"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          _FeatureCard(
            icon: Icons.psychology,
            title: "AI Damage Detection",
            description:
            "The system uses artificial intelligence to detect car damage from uploaded images and classify severity into Minor, Moderate, or Severe.",
          ),

          _FeatureCard(
            icon: Icons.camera_alt,
            title: "Real-Time Scanning",
            description:
            "Users can scan vehicles in real-time using the camera for instant AI-powered damage analysis.",
          ),

          _FeatureCard(
            icon: Icons.photo_library,
            title: "Upload From Gallery",
            description:
            "Upload car images directly from your phone gallery for damage detection.",
          ),

          _FeatureCard(
            icon: Icons.attach_money,
            title: "Cost Estimation",
            description:
            "Based on the detected damage, the system provides an estimated repair cost.",
          ),

          _FeatureCard(
            icon: Icons.history,
            title: "Scan History",
            description:
            "View and manage previous scan results with detailed reports and analysis.",
          ),

          _FeatureCard(
            icon: Icons.security,
            title: "Secure Authentication",
            description:
            "Login and register securely using Firebase Authentication for user data protection.",
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// Icon Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.blue),
          ),

          const SizedBox(width: 15),

          /// Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}