import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'report_screen.dart';

class ScanScreen extends StatefulWidget {
  final String carId;
  const ScanScreen({super.key, required this.carId});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isScanning = false;

  final String baseUrl = "http://10.0.2.2:5161/api/Analysis";


  Future<void> saveToHistory({
    required String analysisId,
    required String carId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList("history") ?? [];

    list.add(jsonEncode({
      "analysisId": analysisId,
      "carId": carId,
      "createdAt": DateTime.now().toIso8601String(),
    }));

    await prefs.setStringList("history", list);
  }
  // ── اختيار صورة ──────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // ── إرسال الصورة للـ AI ───────────────────────────────────────────────────
  Future<void> _startScan() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select an image first"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _isScanning = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? "";

      // Multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/analyze"),
      );

      request.headers['Authorization'] = "Bearer $token";
      request.fields['carId'] = widget.carId;
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final streamedResponse = await request.send();
      final response         = await http.Response.fromStream(streamedResponse);

      print("Analysis STATUS: ${response.statusCode}");
      print("Analysis BODY  : ${response.body}");

      if (response.statusCode == 200 && mounted) {
        // اجيب الـ analysisId من الرسبونس عشان أعرض التقرير
        // لو السيرفر بيرجع object فيه id استخدمه

        final data       = jsonDecode(response.body);
        final analysisId = data['id']?.toString() ?? data['analysisId']?.toString() ?? "";

        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => ReportScreen(analysisId: analysisId)));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("❌ Scan failed (${response.statusCode})"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Analysis ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("❌ Network error. Try again."),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Scan Car"),
        backgroundColor: const Color(0xFF3B6DE3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Info chip ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF3B6DE3), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Car saved ✅  ID: ${widget.carId}",
                      style: const TextStyle(color: Color(0xFF3B6DE3), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text("Car Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            // ── صورة أو Placeholder ──
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedImage != null
                        ? const Color(0xFF3B6DE3)
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text("Tap to add a photo",
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Camera / Gallery ──
            Row(
              children: [
                Expanded(child: _sourceBtn(Icons.camera_alt, "Camera",  ImageSource.camera)),
                const SizedBox(width: 12),
                Expanded(child: _sourceBtn(Icons.photo_library, "Gallery", ImageSource.gallery)),
              ],
            ),

            const SizedBox(height: 30),

            // ── Scan Button ──
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: _isScanning ? null : _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B6DE3),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isScanning
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                          SizedBox(width: 12),
                          Text("Analyzing...",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.document_scanner, color: Colors.white),
                          SizedBox(width: 10),
                          Text("Start AI Scan",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 5,
                decoration: BoxDecoration(color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xffE3F2FD),
                  child: Icon(Icons.camera_alt, color: Colors.blue)),
              title: const Text("Open Camera"),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
            ),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Color(0xffE8F5E9),
                  child: Icon(Icons.photo, color: Colors.green)),
              title: const Text("Choose from Gallery"),
              onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _sourceBtn(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () => _pickImage(source),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF3B6DE3), size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(
                color: Color(0xFF3B6DE3), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
