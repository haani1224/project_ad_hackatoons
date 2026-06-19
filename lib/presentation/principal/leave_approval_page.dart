import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaveApprovalPage extends StatefulWidget {
  const LeaveApprovalPage({super.key});

  @override
  State<LeaveApprovalPage> createState() =>
      _LeaveApprovalPageState();
}

class _LeaveApprovalPageState extends State<LeaveApprovalPage> {
  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    final data = await Supabase.instance.client
        .from('leaves')
        .select('''
          id,
          start_date,
          end_date,
          total_days,
          reason,
          status,
          teachers(full_name),
          leave_types(name)
        ''')
        .order('created_at', ascending: false);

    setState(() {
      leaves = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future approve(String id) async {
    await Supabase.instance.client
        .from('leaves')
        .update({'status': 'approved'})
        .eq('id', id);

    loadLeaves();
  }

  Future reject(String id) async {
    await Supabase.instance.client
        .from('leaves')
        .update({'status': 'rejected'})
        .eq('id', id);

    loadLeaves();
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
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
      appBar: AppBar(
        title: const Text("Leave Approval"),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : leaves.isEmpty
              ? const Center(child: Text("No Leave Requests"))
              : ListView.builder(
                  itemCount: leaves.length,
                  itemBuilder: (context, index) {
                    final leave = leaves[index];

                    final teacherName =
                        leave['teachers']?['full_name'] ?? "Unknown";

                    final leaveType =
                        leave['leave_types']?['name'] ?? "Unknown";

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacherName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text("Leave Type: $leaveType"),

                            Text(
                              "${leave['start_date']} → ${leave['end_date']}",
                            ),

                            Text("Days: ${leave['total_days']}"),

                            if (leave['reason'] != null &&
                                leave['reason'].toString().isNotEmpty)
                              Text("Reason: ${leave['reason']}"),

                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor(leave['status']),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                leave['status'].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (leave['status'] == "pending")
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        approve(leave['id']),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green),
                                    child: const Text("Approve"),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () =>
                                        reject(leave['id']),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    child: const Text("Reject"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}