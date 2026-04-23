import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'scan_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({super.key});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController  = TextEditingController();
  final colorController = TextEditingController();
  final plateController = TextEditingController();
  final _formKey        = GlobalKey<FormState>();
  bool _isLoading       = false;

  final String baseUrl = "http://10.0.2.2:5161/api/Cars";

  Future<String?> _saveCar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      final response = await http.post(
        Uri.parse("$baseUrl/Add"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "carId"      : "00000000-0000-0000-0000-000000000000",
          "plateNumber": plateController.text.trim(),
          "brand"      : brandController.text.trim(),
          "model"      : modelController.text.trim(),
          "year"       : int.tryParse(yearController.text.trim()) ?? 0,
          "color"      : colorController.text.trim(),
        }),
      );

      print("Cars/Add STATUS: ${response.statusCode}");
      print("Cars/Add BODY  : ${response.body}");

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.isNotEmpty) {
          try {
            final data = jsonDecode(body);
            return data['carId']?.toString() ?? data['id']?.toString();
          } catch (_) {
            return body;
          }
        }
      }
      return null;
    } catch (e) {
      print("Cars/Add ERROR: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Car Details"),
        backgroundColor: const Color(0xFF3B6DE3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your car info",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                "This data will be saved and attached to your scan report",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              _buildField("Car Brand (e.g. Toyota, BMW)", brandController, Icons.directions_car),
              _buildField("Model (e.g. Camry, X5)",       modelController,  Icons.model_training),
              _buildField("Year (e.g. 2022)",             yearController,   Icons.calendar_today,
                  inputType: TextInputType.number),
              _buildField("Color",                        colorController,  Icons.color_lens),
              _buildField("Plate Number",                 plateController,  Icons.pin),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    setState(() => _isLoading = true);

                    final carId = await _saveCar();
                    setState(() => _isLoading = false);

                    if (carId != null && mounted) {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ScanScreen(carId: carId)));
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("❌ Failed to save car. Try again."),
                        backgroundColor: Colors.red,
                      ));
                    }
                  },
                  icon: _isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text(_isLoading ? "Saving..." : "Continue to Scan",
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B6DE3),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController ctrl, IconData icon,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        keyboardType: inputType,
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF3B6DE3)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          border:            OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder:     OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder:     OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF3B6DE3), width: 1.5)),
          errorBorder:       OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1)),
          focusedErrorBorder:OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        ),
      ),
    );
  }
}
