import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controller/ResetPassword_controller.dart';


class ResetPasswordScreen extends StatelessWidget {
  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ResetPasswordController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: controller.passwordController,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: controller.confirmPasswordController,
              decoration: const InputDecoration(
                labelText: "Confirm Password",
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final success = await controller.resetPassword(
                  email: email,
                  token: token,
                );

                if (success) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Reset"),
            )
          ],
        ),
      ),
    );
  }
}