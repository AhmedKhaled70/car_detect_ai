import 'package:car_damage_detection/home_screen.dart';
import 'package:car_damage_detection/register_screen.dart';
import 'package:car_damage_detection/controller/forgetscreen_controller.dart';
import 'package:car_damage_detection/forget_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller/LoginController.dart';

class loginscreen extends StatelessWidget {
  static const String RouteName = 'loginscreen';

  const loginscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoginController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Container(
                  height: 180,
                  width: 180,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/car_icon1.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Car Detect AI',
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),

                const Text(
                  'Login to your account',
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 40),

                _buildTextField(
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  controller: controller.emailController,
                  errorText: controller.emailError,
                ),

                const SizedBox(height: 16),

                _buildTextField(
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  controller: controller.passwordController,
                  isPassword: true,
                  errorText: controller.passwordError,
                  isHidden: controller.isPasswordHidden,
                  onToggle: controller.togglePassword,
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangeNotifierProvider(
                            create: (_) => ForgotPasswordController(),
                            child: const ForgotPasswordScreen(),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Forget Password?',
                      style: TextStyle(
                        color: Color(0xFF5B6CFF),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            bool success = await controller.loginUser();

                            if (success) {
                              Navigator.pushReplacementNamed(
                                context,
                                homescreen.RouteName,
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B6CFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: controller.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Login',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don’t Have Account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          register_screen.RouteName,
                        );
                      },
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Color(0xFF5B6CFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required String hint,
  required IconData icon,
  required TextEditingController controller,
  bool isPassword = false,
  String? errorText,
  bool isHidden = true,
  VoidCallback? onToggle,
}) {
  return TextFormField(
    controller: controller,
    obscureText: isPassword ? isHidden : false,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      errorText: errorText,
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
              onPressed: onToggle,
            )
          : null,
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
