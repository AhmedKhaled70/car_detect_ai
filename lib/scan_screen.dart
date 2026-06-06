import 'dart:io';

import 'package:car_damage_detection/api%20config.dart';
import 'package:car_damage_detection/cars_cubit/new_car_analyziz_cubit.dart';
import 'package:car_damage_detection/repos/app_repo.dart';
import 'package:car_damage_detection/services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'report_screen.dart';

class ScanScreen extends StatelessWidget {
  final String carBrand;
  final String carModel;
  final String carYear;
  final String carColor;
  final String carPlate;

  const ScanScreen({
    super.key,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.carColor,
    required this.carPlate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewCarAnalyzizCubit(
        appRepo: AppRepoImpl(
          apiService: ApiService(Dio(BaseOptions(baseUrl: ApiConfig.baseUrl))),
        ),
      ),
      child: _ScanScreenBody(
        carBrand: carBrand,
        carModel: carModel,
        carYear: carYear,
        carColor: carColor,
        carPlate: carPlate,
      ),
    );
  }
}

class _ScanScreenBody extends StatefulWidget {
  final String carBrand;
  final String carModel;
  final String carYear;
  final String carColor;
  final String carPlate;

  const _ScanScreenBody({
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.carColor,
    required this.carPlate,
  });

  @override
  State<_ScanScreenBody> createState() => _ScanScreenBodyState();
}

class _ScanScreenBodyState extends State<_ScanScreenBody> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _startScan() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image first"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<NewCarAnalyzizCubit>().analyzeNewCar(
          image: _selectedImage!,
          carPlate: widget.carPlate,
          carModel: widget.carModel,
          carYear: widget.carYear,
          carColor: widget.carColor,
          carBrand: widget.carBrand,
        );
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
      body: BlocListener<NewCarAnalyzizCubit, NewCarAnalyzizState>(
        listener: (context, state) {
          if (state is NewCarAnalyzizLoaded) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => ReportScreen(response: state.response),
              ),
            );
          } else if (state is NewCarAnalyzizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: Color(0xFF3B6DE3),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${widget.carBrand} ${widget.carModel} (${widget.carYear})",
                        style: const TextStyle(
                          color: Color(0xFF3B6DE3),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Car Photo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Tap to add a photo",
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _sourceBtn(
                      Icons.camera_alt,
                      "Camera",
                      ImageSource.camera,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _sourceBtn(
                      Icons.photo_library,
                      "Gallery",
                      ImageSource.gallery,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              BlocBuilder<NewCarAnalyzizCubit, NewCarAnalyzizState>(
                builder: (context, state) {
                  final isScanning = state is NewCarAnalyzizLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isScanning ? null : _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B6DE3),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: isScanning
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Analyzing...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.document_scanner,
                                    color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  "Start AI Scan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
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
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffE8F5E9),
                child: Icon(Icons.photo, color: Colors.green),
              ),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
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
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF3B6DE3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
