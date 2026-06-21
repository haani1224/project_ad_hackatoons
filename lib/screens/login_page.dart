import 'package:flutter/material.dart';
import 'principal/principal_main_page.dart';
import 'teacher/teacher_main_page.dart';
import '../services/auth_service.dart';
import '../screens/register_page.dart';
import '../services/m1_record_service.dart';
import '../utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService =
    AuthService();

  bool isLoading = false;
  bool hidePassword = true;

  Future<void> login() async {
    setState(() => isLoading = true);

    try {
      final teacher = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      if (teacher == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
        return;
      }

      if (teacher.role == 'principal') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PrincipalMainPage()),
        );
      } else {
        final record = await TeacherRecordService().getMyRecord(teacher.authId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TeacherMainPage(
              teacher: teacher,
              record: record, // <- you must pass this
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Preschool Duty Login",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [

                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 14),

                      TextField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: login,
                        child: const Text("Login"),
                      ),
                      // Registeration link
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const RegisterPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create Account',
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}