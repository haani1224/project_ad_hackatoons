import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();
}

class _RegisterPageState
    extends State<RegisterPage> {

  final icController =
      TextEditingController();

  final nameController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  final authService = AuthService();

  bool loading = false;

  Future<void> register() async {

    if (passwordController.text !=
        confirmPasswordController.text) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Passwords do not match'),
        ),
      );

      return;
    }

    try {
      setState(() => loading = true);

      await authService.register(
        icNumber: icController.text.trim(),
        fullName: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Registration submitted. Awaiting approval.',
          ),
        ),
      );

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );

    } finally {

      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            TextField(
              controller: icController,
              decoration:
                  const InputDecoration(
                labelText: "IC Number",
              ),
            ),

            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(
                labelText: "Full Name",
              ),
            ),

            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(
                labelText: "Email",
              ),
            ),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText: "Password",
              ),
            ),

            TextField(
              controller:
                  confirmPasswordController,
              obscureText: true,
              decoration:
                  const InputDecoration(
                labelText:
                    "Confirm Password",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed:
                  loading ? null : register,
              child:
                  const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}