import 'package:flutter/material.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveTestPage extends StatefulWidget {
  const LeaveTestPage({super.key});

  @override
  State<LeaveTestPage> createState() => _LeaveTestPageState();
}

class _LeaveTestPageState extends State<LeaveTestPage> {
  final repo = LeaveRepository();

  List leaves = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future load() async {
    final data = await repo.getAllLeaves();

    setState(() {
      leaves = data;
      loading = false;
    });

    print("TOTAL LEAVES: ${data.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave Test")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: leaves.length,
              itemBuilder: (context, i) {
                final l = leaves[i];

                return ListTile(
                  title: Text(l.leaveType),
                  subtitle: Text(l.status),
                );
              },
            ),
    );
  }
}