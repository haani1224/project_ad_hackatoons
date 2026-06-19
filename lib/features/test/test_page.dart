import 'package:flutter/material.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../features/teachers/add_teacher_page.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final repo = TeacherRepository();
  List<TeacherModel> teachers = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await repo.getTeachers();
    setState(() => teachers = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Teachers")),
      body: teachers.isEmpty
          ? const Center(child: Text("No teachers yet"))
          : ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final t = teachers[index];

                return Card(
                  child: ListTile(
                    title: Text(t.fullName),
                    subtitle: Text(t.icNumber),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await repo.deleteTeacher(t.id!);
                        loadData();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTeacherPage(),
            ),
          );

          if (result == true) {
            loadData(); // refresh list
          }
        },
          child: const Icon(Icons.add),
      ),
    );
  }
}