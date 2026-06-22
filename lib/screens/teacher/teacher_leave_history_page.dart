import 'package:flutter/material.dart';
import '../../data/repositories/leave_repository.dart';

class TeacherLeaveHistoryPage extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveHistoryPage({super.key, required this.teacherId});

  @override
  State<TeacherLeaveHistoryPage> createState() =>
      _TeacherLeaveHistoryPageState();
}

class _TeacherLeaveHistoryPageState
    extends State<TeacherLeaveHistoryPage> {
  final repo = LeaveRepository();

  List<Map<String, dynamic>> leaves = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await repo.getTeacherLeaves(widget.teacherId);
    setState(() => leaves = data);
  }

  Color color(String status) {
    switch (status) {
      case "Approved":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave History"),
        backgroundColor: const Color(0xFF2E4365),
      ),
      body: ListView.builder(
        itemCount: leaves.length,
        itemBuilder: (context, i) {
          final l = leaves[i];

          return Card(
            child: ListTile(
              title: Text(l['leave_types']?['name'] ?? ''),
              subtitle: Text(
                  "${l['start_date']} → ${l['end_date']}"),
              trailing: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color(l['status']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l['status'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

