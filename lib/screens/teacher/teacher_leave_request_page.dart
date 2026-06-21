import 'package:flutter/material.dart';
import '../../data/repositories/leave_repository.dart';

class TeacherLeaveRequestPage extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveRequestPage({super.key, required this.teacherId});

  @override
  State<TeacherLeaveRequestPage> createState() =>
      _TeacherLeaveRequestPageState();
}

class _TeacherLeaveRequestPageState
    extends State<TeacherLeaveRequestPage> {
  final repo = LeaveRepository();

  List<Map<String, dynamic>> types = [];
  String? selectedType;

  DateTime? start;
  DateTime? end;

  final reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTypes();
  }

  Future<void> loadTypes() async {
    final data = await repo.getLeaveTypes();
    setState(() => types = data);
  }

  int get days {
    if (start == null || end == null) return 0;
    return end!.difference(start!).inDays + 1;
  }

  Future<void> submit() async {
  await repo.applyLeave({
    'teacher_id': widget.teacherId,
    'leave_type_id': selectedType,
    'start_date': start?.toIso8601String(),
    'end_date': end?.toIso8601String(),
    'total_days': days,
    'reason': reasonController.text,
    'status': 'Pending',
  });

  Navigator.pop(context, true);
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply Leave"),
        backgroundColor: const Color(0xFF2E4365),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField(
              items: types
                  .map((t) => DropdownMenuItem(
                        value: t['id'],
                        child: Text(t['name']),
                      ))
                  .toList(),
              onChanged: (v) => selectedType = v as String,
              decoration: const InputDecoration(labelText: "Leave Type"),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      start = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      setState(() {});
                    },
                    child: const Text("Start Date"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      end = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      setState(() {});
                    },
                    child: const Text("End Date"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text("Total Days: $days"),

            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: "Reason"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submit,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}