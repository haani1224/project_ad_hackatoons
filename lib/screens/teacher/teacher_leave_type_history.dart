import 'package:flutter/material.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveTypeHistoryPage extends StatefulWidget {
  final int teacherId;
  final String leaveType;

  const LeaveTypeHistoryPage({
    super.key,
    required this.teacherId,
    required this.leaveType,
  });

  @override
  State<LeaveTypeHistoryPage> createState() =>
      _LeaveTypeHistoryPageState();
}

class _LeaveTypeHistoryPageState
    extends State<LeaveTypeHistoryPage> {
  final repo = LeaveRepository();

  bool loading = true;
  List<Map<String, dynamic>> data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final all = await repo.getTeacherLeaves(widget.teacherId);

    final filtered = all.where((e) =>
        e['leave_types']?['name'] ==
        widget.leaveType).toList();

    setState(() {
      data = filtered;
      loading = false;
    });
  }

  Color getColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.leaveType),
        backgroundColor: const Color(0xFF2E4365),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final l = data[i];

                final status = l['status'];

                return Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.event_note,
                      color: getColor(status),
                    ),
                    title: Text(
                      "${l['start_date']} → ${l['end_date']}",
                    ),
                    subtitle: Text(
                      l['reason'] ?? 'No reason',
                    ),
                    trailing: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(status),
                        Text("${l['total_days']} days"),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}