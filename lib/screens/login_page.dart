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
    resizeToAvoidBottomInset: true,
    body: SafeArea(
  child: SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      24,
      40,
      24,
      MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Column(
      children: [

        // Logo
Hero(
  tag: "logo",
  child: Container(
    width: 150,
    height: 150,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.10),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: ClipOval(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Image.asset(
          'assets/LOGO TADIKA AQIL MIQAIL.jpg',
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    ),
  ),
),


        const SizedBox(height: 24),

        const Text(
          "Genius Aqil OS",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          "Teacher Management System",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 35),

        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                decoration: InputDecoration(
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2E4365),
                        Color(0xFF4C78A8),
                      ],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  "Create Account",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),
  );
}
}