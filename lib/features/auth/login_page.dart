import 'package:flutter/material.dart';
import 'package:project_ad_hackatoons/features/teachers/teacher_list_page.dart';
import '../../data/services/auth_service.dart';
import '../../data/repositories/teacher_repository.dart';

import '../teachers/add_teacher_page.dart';
import '../dashboard/principal_dashboard.dart';
import '../dashboard/teacher_dashboard.dart';
import '../../presentation/principal/principal_approval_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State createState() => _LoginPageState();
}

class _LoginPageState extends State {
  final email = TextEditingController();
  final password = TextEditingController();

  final auth = AuthService();
  final repo = TeacherRepository();

  bool loading = false;

Future login() async {
  setState(() => loading = true);

  final user = await auth.login(
    email.text.trim(),
    password.text.trim(),
  );

  if (!mounted) return;

  if (user == null) {
    setState(() => loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login failed")),
    );
    return;
  }

  // 🔥 GET ROLE + STATUS
  final role = await auth.getUserRole(user.id);
  final status = await auth.getUserStatus(user.id);

  setState(() => loading = false);

  // ❗ BLOCK IF PENDING
  if (status == "pending") {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Account pending approval"),
      ),
    );
    return;
  }

  // 🔥 ROLE ROUTING
  if (role == "teacher") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherDashboard(),
      ),
    );
  } 
  else if (role == "principal") {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const TeacherListPage(),
      ),
    );
  } 
  else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid role")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Teacher Management Login",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: email,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("LOGIN"),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTeacherPage(),
                  ),
                );
              },
              child: const Text("New Teacher? Register here"),
            ),

          ],
        ),
      ),
    );
  }
}