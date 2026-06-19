import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/leave_model.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveListPage extends StatefulWidget {
  const LeaveListPage({super.key});

  @override
  State createState() => _LeaveListPageState();
}

class _LeaveListPageState extends State {
  final repo = LeaveRepository();

  List<LeaveModel> leaves = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLeaves();
  }

  Future loadLeaves() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final data = await repo.getByTeacher(user.id);

    setState(() {
      leaves = data;
      loading = false;
    });
  }

  Color getColor(String status) {
    switch (status) {
      case "approved":
        return Colors.green;
      case "rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Leave Requests")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaves.length,
              itemBuilder: (context, index) {
                final leave = leaves[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("Leave Type: ${leave.leaveTypeId}"),
                    subtitle: Text(
                      "${leave.startDate.toString().split(' ')[0]} → "
                      "${leave.endDate.toString().split(' ')[0]}\n"
                      "Days: ${leave.totalDays}",
                    ),
                    trailing: Text(
                      leave.status,
                      style: TextStyle(
                        color: getColor(leave.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}