import 'package:flutter/material.dart';
import '../../data/repositories/teacher_repository.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final repo = TeacherRepository();

  int totalTeachers = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final data = await repo.getTeachers();

    setState(() {
      totalTeachers = data.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Card(
              child: ListTile(
                title: const Text("Total Teachers"),
                trailing: Text(
                  "$totalTeachers",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              color: Colors.amber.shade100,
              child: const ListTile(
                title: Text("System Status"),
                subtitle: Text("Phase 3 Active 🚀"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}