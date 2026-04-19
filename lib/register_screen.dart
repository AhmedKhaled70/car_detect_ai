import 'package:car_damage_detection/home_screen.dart';
import 'package:car_damage_detection/loginscreen.dart';
import 'package:car_damage_detection/controller/register_controler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class register_screen extends StatelessWidget {
  static const String RouteName = 'register_screen';

  const register_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterController(),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatelessWidget {
  const _RegisterView({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = context.watch<RegisterController>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const SizedBox(height: 50),

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
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'Create New Account',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 40),

              _buildTextField(
                hint: 'Name',
                icon: Icons.person,
                controller: controller.nameController,
                errorText: controller.nameError,
              ),

              const SizedBox(height: 16),

              _buildTextField(
                hint: 'Email',
                icon: Icons.email_outlined,
                controller: controller.emailController,
                errorText: controller.emailError,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                hint: 'Phone Number',
                icon: Icons.phone,
                controller: controller.phoneController,
                errorText: controller.phoneError,
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

              const SizedBox(height: 16),

              _buildTextField(
                hint: 'Confirm Password',
                icon: Icons.lock_outline,
                controller: controller.confirmPasswordController,
                isPassword: true,
                errorText: controller.confirmPasswordError,
                isHidden: controller.isPasswordHidden,
                onToggle: controller.togglePassword,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                    bool success =
                    await controller.registerUser();

                    if (success) {
                      Navigator.pushReplacementNamed(
                          context, homescreen.RouteName);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B6CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading
                      ? const CircularProgressIndicator(
                      color: Colors.white)
                      : const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(
                        context,
                        loginscreen.RouteName,
                      );
                    },
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF5B6CFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
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
        icon: Icon(
          isHidden
              ? Icons.visibility_off
              : Icons.visibility,
        ),
        onPressed: onToggle,
      )
          : null,
      filled: true,
      fillColor: Colors.grey.shade50,
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