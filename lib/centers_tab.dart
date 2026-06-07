import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Model ─────────────────────────────────────────────────────────────────────
class CenterModel {
  final String name;
  final String address;
  final double lat;
  final double lng;

  CenterModel({
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory CenterModel.fromJson(Map<String, dynamic> json) {
    return CenterModel(
      name: json['name'] ?? json['centerName'] ?? 'Unknown',
      address: json['address'] ?? json['location'] ?? '',
      lat: (json['latitude'] ?? json['lat'] ?? 0).toDouble(),
      lng: (json['longitude'] ?? json['lng'] ?? 0).toDouble(),
    );
  }
}

// ── Tab ───────────────────────────────────────────────────────────────────────
class centers_tab extends StatefulWidget {
  const centers_tab({super.key});

  @override
  State<centers_tab> createState() => _centers_tabState();
}

class _centers_tabState extends State<centers_tab> {
  List<CenterModel> _centers = [];
  bool _isLoading = true;
  String? _error;

  final String baseUrl = "http://10.0.2.2:5161/api/RepairCenters";

  @override
  void initState() {
    super.initState();
    _fetchCenters();
  }

  Future<void> _fetchCenters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("Centers STATUS: ${response.statusCode}");
      print("Centers BODY  : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _centers = data.map((e) => CenterModel.fromJson(e)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load centers";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Centers ERROR: $e");
      setState(() {
        _error = "Network error";
        _isLoading = false;
      });
    }
  }

  // ── فتح Google Maps للمركز الأقرب ─────────────────────────────────────────
  Future<void> _openDirections(CenterModel center) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw 'Location services disabled';

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) throw 'Permission denied';
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${pos.latitude},${pos.longitude}'
        '&destination=${center.lat},${center.lng}'
        '&travelmode=driving',
      );

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3B6DE3)),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 60, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchCenters();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B6DE3),
              ),
            ),
          ],
        ),
      );
    }

    if (_centers.isEmpty) {
      return const Center(
        child: Text(
          "No repair centers found",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCenters,
      color: const Color(0xFF3B6DE3),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _centers.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _CenterCard(
            center: _centers[index],
            onDirections: () => _openDirections(_centers[index]),
          );
        },
      ),
    );
  }
}

// ── Card ──────────────────────────────────────────────────────────────────────
class _CenterCard extends StatelessWidget {
  final CenterModel center;
  final VoidCallback onDirections;

  const _CenterCard({required this.center, required this.onDirections});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.build,
                  color: Color(0xFF3B6DE3),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (center.address.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        center.address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDirections,
              icon: const Icon(Icons.directions, size: 18),
              label: const Text("Get Directions"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B6DE3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
