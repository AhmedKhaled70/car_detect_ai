import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../report_screen.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late Future<List<Map<String, dynamic>>> _future;

  final String baseUrl = "http://10.0.2.2:5161/api";

  @override
  void initState() {
    super.initState();
    _future = _loadHistoryWithDetails();
  }

  /// 🔥 اقرأ الـ IDs من SharedPreferences
  Future<List<Map<String, dynamic>>> _getSavedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("history") ?? [];

    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  /// 🔥 جيب تفاصيل كل Analysis
  Future<Map<String, dynamic>?> _fetchAnalysis(String id, String token) async {
    try {
      final res = await http.get(
        Uri.parse("$baseUrl/Analysis/$id"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (_) {}

    return null;
  }

  /// 🔥 دمج الـ IDs مع البيانات من السيرفر
  Future<List<Map<String, dynamic>>> _loadHistoryWithDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final saved = await _getSavedHistory();

    // اعمل requests مع بعض (سريع)
    final futures = saved.map((item) {
      return _fetchAnalysis(item['analysisId'], token).then((data) {
        if (data != null) {
          data['analysisId'] = item['analysisId'];
          data['createdAt'] = item['createdAt'];
        }
        return data;
      });
    }).toList();

    final results = await Future.wait(futures);

    // شيل null
    final list = results.whereType<Map<String, dynamic>>().toList();

    // رتب بالأحدث
    list.sort((a, b) =>
        (b['createdAt'] ?? "").compareTo(a['createdAt'] ?? ""));

    return list;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadHistoryWithDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(child: Text("Error loading history"));
          }

          final data = snap.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No scans yet"));
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final item = data[i];

                final car = item['car'] ?? {};
                final damage = item['damageType'] ?? "Unknown";
                final severity = item['severity'] ?? "Unknown";
                final image = item['imageUrl'] ?? "";

                Color color = Colors.green;
                if (severity.toString().toLowerCase().contains("moderate")) {
                  color = Colors.orange;
                } else if (severity.toString().toLowerCase().contains("severe")) {
                  color = Colors.red;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: image.toString().isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Icon(Icons.directions_car),

                    title: Text(
                      "${car['brand'] ?? ''} ${car['model'] ?? ''}".trim(),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(damage),
                        const SizedBox(height: 4),
                        Text(
                          severity,
                          style: TextStyle(color: color),
                        ),
                      ],
                    ),

                    trailing: const Icon(Icons.arrow_forward_ios),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportScreen(
                            analysisId: item['analysisId'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}