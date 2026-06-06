import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:car_damage_detection/loginscreen.dart';
import 'package:car_damage_detection/register_screen.dart';
import 'package:car_damage_detection/resetpassword_screen.dart';
import 'package:car_damage_detection/services/custom_observer_bloc.dart';
import 'package:car_damage_detection/splash_sceen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'Tabs/feature screen.dart';
import 'controller/ResetPassword_controller.dart';
import 'home_screen.dart';

void main() {
  Bloc.observer = CustomObserverBloc();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? startScreen;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();

    initApp();

    /// 🔥 listen for links while app is running
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (uri != null) {
        handleDeepLink(uri);
      }
    });
  }

  Future<void> initApp() async {
    /// 🔥 get link if app opened from it
    final uri = await _appLinks.getInitialLink();

    if (uri != null) {
      handleDeepLink(uri);
      return;
    }

    /// 🔥 normal flow (token)
    final prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString("token");

    if (savedToken != null) {
      startScreen = homescreen();
    } else {
      startScreen = loginscreen();
    }

    setState(() {});
  }

  void handleDeepLink(Uri uri) {
    final email = uri.queryParameters['email'];
    final token = uri.queryParameters['token'];

    if (email != null && token != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => ResetPasswordController(),
            child: ResetPasswordScreen(email: email, token: token),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (startScreen == null) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        splashScreen.RouteName: (context) => splashScreen(),
        loginscreen.RouteName: (context) => loginscreen(),
        register_screen.RouteName: (context) => register_screen(),
        homescreen.RouteName: (context) => homescreen(),
        FeaturesScreen.RouteName: (context) => FeaturesScreen(),
      },
      home: AnimatedSplashScreen(
        splash: splashScreen(),
        nextScreen: startScreen!,
        duration: 3000,
        splashIconSize: double.infinity,
      ),
    );
  }
}
