import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// ================== Center Model ==================
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
}

/// ================== Centers Data ==================
final List<CenterModel> centers = [
  CenterModel(
    name: 'Auto Fix Center',
    address: 'Nasr City, Cairo',
    lat: 30.0561,
    lng: 31.3301,
  ),
  CenterModel(
    name: 'Car Care Pro',
    address: 'Maadi, Cairo',
    lat: 29.9602,
    lng: 31.2569,
  ),
  CenterModel(
    name: 'Smart Repair Hub',
    address: '6th of October, Giza',
    lat: 29.9789,
    lng: 30.9446,
  ),
];

/// ================== Location ==================
Future<Position> _getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw 'Location services are disabled';
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw 'Location permission denied';
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw 'Location permissions are permanently denied';
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

/// ================== Nearest Center ==================
CenterModel _getNearestCenter({
  required double userLat,
  required double userLng,
  required List<CenterModel> centers,
}) {
  CenterModel nearest = centers.first;
  double shortestDistance = double.infinity;

  for (final center in centers) {
    final distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      center.lat,
      center.lng,
    );

    if (distance < shortestDistance) {
      shortestDistance = distance;
      nearest = center;
    }
  }

  return nearest;
}

/// ================== Open Directions ==================
Future<void> openDirectionsToNearestCenter(
    List<CenterModel> centers) async {
  final position = await _getCurrentLocation();

  final nearestCenter = _getNearestCenter(
    userLat: position.latitude,
    userLng: position.longitude,
    centers: centers,
  );

  final Uri directionsUrl = Uri.parse(
    'https://www.google.com/maps/dir/?api=1'
        '&origin=${position.latitude},${position.longitude}'
        '&destination=${nearestCenter.lat},${nearestCenter.lng}'
        '&travelmode=driving',
  );

  await launchUrl(
    directionsUrl,
    mode: LaunchMode.externalApplication,
  );
}

/// ================== Center Card ==================
class _CenterCard extends StatelessWidget {
  final CenterModel center;

  const _CenterCard({required this.center});

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
              const Icon(Icons.location_on, color: Colors.blue, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  center.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            center.address,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  openDirectionsToNearestCenter(centers),
              icon: const Icon(Icons.directions),
              label: const Text('Directions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================== Centers Tab ==================
class centers_tab extends StatelessWidget {
  const centers_tab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: centers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _CenterCard(center: centers[index]);
      },
    );
  }
}
