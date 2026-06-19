import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherLeaveDashboard extends StatefulWidget {
  const TeacherLeaveDashboard({super.key});

  @override
  State<TeacherLeaveDashboard> createState() =>
      _TeacherLeaveDashboardState();
}

class _TeacherLeaveDashboardState extends State<TeacherLeaveDashboard> {
  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  int totalApproved = 0;
  int totalPending = 0;

  @override
  void initState() {
    super.initState();
    fetchMyLeaves();
  }

  Future<void> fetchMyLeaves() async {
    final user = Supabase.instance.client.auth.currentUser;

    final teacherRes = await Supabase.instance.client
        .from('teachers')
        .select('id')
        .eq('user_id', user!.id)
        .single();

    final teacherId = teacherRes['id'];

    final res = await Supabase.instance.client
        .from('leaves')
        .select()
        .eq('teacher_id', teacherId);

    final data = List<Map<String, dynamic>>.from(res);

    totalApproved =
        data.where((e) => e['status'] == 'approved').length;

    totalPending =
        data.where((e) => e['status'] == 'pending').length;

    setState(() {
      leaves = data;
      loading = false;
    });
  }

  Widget buildCard(Map<String, dynamic> leave) {
    return Card(
      child: ListTile(
        title: Text(leave['status']),
        subtitle: Text(
          "${leave['start_date']} → ${leave['end_date']}\nDays: ${leave['total_days']}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Leave Dashboard")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // SUMMARY BOX
                Card(
                  margin: const EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text("$totalApproved",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text("Approved"),
                          ],
                        ),
                        Column(
                          children: [
                            Text("$totalPending",
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            const Text("Pending"),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: ListView(
                    children: leaves.map(buildCard).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}