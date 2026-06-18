import 'package:flutter/material.dart';

class PrincipalDashboard extends StatelessWidget {
  const PrincipalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Principal Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Welcome Principal",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}