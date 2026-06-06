import 'dart:io';

class ApiConfig {

  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5161/api"; // emulator
    } else {
      return "http://192.168.100.6:5161/api"; // موبايل
    }
  }
}