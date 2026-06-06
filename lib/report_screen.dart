import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  final String analysisId;
  const ReportScreen({super.key, required this.analysisId});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  Map<String, dynamic>? _report;
  bool _isLoading = true;
  String? _error;

  final String analysisUrl = "http://10.0.2.2:5161/api/Analysis";
  final String centersUrl  = "http://10.0.2.2:5161/api/RepairCenters";

  @override
  void initState() {
    super.initState();
    _fetchReport();
  }

  Future<void> _fetchReport() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _report = {
        "damageType": "Front Bumper Damage",
        "severity": "Moderate",
        "estimatedCost": "2500 EGP",
        "imageUrl": "https://images.unsplash.com/photo-1503376780353-7e6692767b70"
      };

      _isLoading = false;
    });
  }
  String getDamageExplanation(String damageType, String severity) {

    if (severity.toLowerCase() == "low") {
      return "The damage appears to be minor. It may include small scratches or dents that do not affect the car's performance. The vehicle is safe to drive, but repair is recommended for aesthetic purposes.";
    }

    if (severity.toLowerCase() == "moderate") {
      return "The car has moderate damage. This may affect some external parts such as the bumper or door. Driving is possible but not recommended for long periods without repair.";
    }

    if (severity.toLowerCase() == "severe") {
      return "Severe damage detected. The structure of the car may be affected, which can impact safety. It is strongly advised not to drive the vehicle and seek repair immediately.";
    }

    return "Damage details are not available.";
  }

  /// 🔥 مراكز الصيانة + GPS
  Future<void> _showCenters() async {
    try {

      /// 🔥 تحقق من الـ GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw "Location service disabled";
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw "Location permission permanently denied";
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse(centersUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);

        /// 🔥 حساب المسافة
        for (var center in data) {
          double lat = (center['latitude'] ?? center['lat'] ?? 0).toDouble();
          double lng = (center['longitude'] ?? center['lng'] ?? 0).toDouble();

          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            lat,
            lng,
          );

          center['distance'] = distance;
        }

        /// 🔥 ترتيب
        data.sort((a, b) => a['distance'].compareTo(b['distance']));

        /// 🔥 عرض Bottom Sheet
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (_, i) {
                final center = data[i];

                double distanceKm = (center['distance'] / 1000);

                return ListTile(
                  leading: const Icon(Icons.build, color: Colors.blue),

                  title: Text(center['name'] ?? 'Center'),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(center['address'] ?? ''),
                      Text("📍 ${distanceKm.toStringAsFixed(2)} km"),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.directions, color: Colors.green),
                    onPressed: () async {

                      double lat = (center['latitude'] ?? center['lat'] ?? 0).toDouble();
                      double lng = (center['longitude'] ?? center['lng'] ?? 0).toDouble();

                      final uri = Uri.parse(
                        "https://www.google.com/maps/dir/?api=1"
                            "&destination=$lat,$lng"
                            "&travelmode=driving",
                      );

                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                );
              },
            );
          },
        );

      } else {
        throw "Failed to load centers";
      }

    } catch (e) {
      print("CENTERS ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Scan Report"),
        backgroundColor: const Color(0xFF3B6DE3),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : _buildReport(),
    );
  }

  Widget _buildReport() {
    final car = _report?['car'] ?? {};
    final damageType = _report?['damageType'] ?? 'Unknown';
    final severity   = _report?['severity'] ?? 'Unknown';
    final cost       = _report?['estimatedCost'] ?? 'N/A';
    final imageUrl   = _report?['imageUrl'] ?? '';

    /// 🔥 نسبة damage (لو مش موجودة نخليها fake)
    double damagePercent =
    (_report?['damagePercentage'] ?? 0.65).toDouble();

    Color severityColor = Colors.green;

    if (severity.toLowerCase().contains("moderate")) {
      severityColor = Colors.orange;
    } else if (severity.toLowerCase().contains("severe")) {
      severityColor = Colors.red;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔥 صورة العربية
          if (imageUrl.toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          const SizedBox(height: 20),

          /// 🚗 بيانات العربية
          _sectionTitle("Car Details"),

          _cardRow("Brand", car['brand'] ?? 'Unknown'),
          _cardRow("Model", car['model'] ?? 'Unknown'),
          _cardRow("Year", car['year']?.toString() ?? 'N/A'),
          _cardRow("Color", car['color'] ?? 'N/A'),

          const SizedBox(height: 20),

          /// 📊 نسبة الضرر
          _sectionTitle("Damage Analysis"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Damage Percentage",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: damagePercent,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(10),
                  color: severityColor,
                  backgroundColor: Colors.grey.shade300,
                ),

                const SizedBox(height: 8),

                Text("${(damagePercent * 100).toStringAsFixed(0)}%"),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// ⚠️ Severity
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: severityColor),
                const SizedBox(width: 10),
                Text(
                  "Severity: $severity",
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          /// 🧠 نوع الضرر
          _cardRow("Damage Type", damageType),
          _sectionTitle("Damage Explanation"),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              getDamageExplanation(damageType, severity),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          /// 💰 التكلفة
          _cardRow("Estimated Cost", cost),

          const SizedBox(height: 25),

          /// 🔥 زرار المراكز
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _showCenters,
              icon: const Icon(Icons.location_on),
              label: const Text("Nearby Repair Centers"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("Back to Home"),
            ),
          ),
        ],
      ),
    );
  }
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _cardRow(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
  Widget _card(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text("$title: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}