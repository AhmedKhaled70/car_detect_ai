import 'package:car_damage_detection/models/new_car_analyziz_response/new_car_analyziz_response.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatelessWidget {
  final NewCarAnalyzizResponse response;

  const ReportScreen({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final finding = response.finding;
    final severity = finding?.severity ?? 'Unknown';
    final severityColor = _getSeverityColor(severity);
    final confidence = finding?.confidence ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Scan Report"),
        backgroundColor: const Color(0xFF3B6DE3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (finding?.imagePath != null && finding!.imagePath!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  finding.imagePath!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined, size: 48),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Severity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: severityColor),
                  const SizedBox(width: 10),
                  Text(
                    "Severity: $severity",
                    style: TextStyle(
                      color: severityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Damage analysis section
            _sectionTitle("Damage Analysis"),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.location_on_outlined,
                    "Location",
                    finding?.locationLabel ?? 'Unknown',
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.speed,
                    "Confidence",
                    "${(confidence * 100).toInt()}%",
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.attach_money,
                    "Estimated Cost",
                    "\$${finding?.estimatedCost ?? 0}",
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.monetization_on_outlined,
                    "Total Cost",
                    "\$${response.totalEstimatedCost ?? 0}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Confidence bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "AI Confidence",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: confidence,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                    color: severityColor,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text("${(confidence * 100).toInt()}%"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Explanation
            _sectionTitle("Damage Explanation"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _getDamageExplanation(severity),
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),

            const SizedBox(height: 20),

            // Recommended repair centers
            if (response.recommendations != null &&
                response.recommendations!.isNotEmpty) ...[
              _sectionTitle("Recommended Repair Centers"),
              ...response.recommendations!.map(
                (rec) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.build_circle_outlined,
                            color: Colors.orange.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.name ?? 'Unknown Center',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            if (rec.address != null && rec.address!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  rec.address!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (rec.phone != null && rec.phone!.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () async {
                            final uri = Uri.parse("tel:${rec.phone}");
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Back to home button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B6DE3),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF3B6DE3)),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'very low':
      case 'low':
        return Colors.green;
      case 'moderate':
      case 'medium':
        return Colors.orange;
      case 'high':
      case 'severe':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDamageExplanation(String severity) {
    switch (severity.toLowerCase()) {
      case 'very low':
      case 'low':
        return "The damage appears to be minor. It may include small scratches or dents that do not affect the car's performance. The vehicle is safe to drive, but repair is recommended for aesthetic purposes.";
      case 'moderate':
      case 'medium':
        return "The car has moderate damage. This may affect some external parts such as the bumper or door. Driving is possible but not recommended for long periods without repair.";
      case 'high':
      case 'severe':
        return "Severe damage detected. The structure of the car may be affected, which can impact safety. It is strongly advised not to drive the vehicle and seek repair immediately.";
      default:
        return "Damage details are not available.";
    }
  }
}
