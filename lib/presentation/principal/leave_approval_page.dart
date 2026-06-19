import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaveDashboardPage extends StatefulWidget {
  final String role;
  final String? userId;

  const LeaveDashboardPage({
    super.key,
    required this.role,
    this.userId,
  });

  @override
  State<LeaveDashboardPage> createState() => _LeaveDashboardPageState();
}

class _LeaveDashboardPageState extends State<LeaveDashboardPage>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    loadLeaves();
  }

  // ================= LOAD =================
  Future<void> loadLeaves() async {
    try {
      var baseQuery = supabase.from('leaves').select('''
        id,
        start_date,
        end_date,
        total_days,
        reason,
        status,
        teacher_id,
        teachers(full_name),
        leave_types(name)
      ''');

      final data;

      if (widget.role == "teacher") {
        data = await baseQuery
            .eq('teacher_id', widget.userId)
            .order('created_at', ascending: false);
      } else {
        data = await baseQuery
            .order('created_at', ascending: false);
      }
      
      setState(() {
        leaves = List<Map<String, dynamic>>.from(data);
        loading = false;
      });
    } catch (e) {
      debugPrint("LOAD ERROR: $e");
      setState(() => loading = false);
    }
  }

  // ================= APPROVE =================
  Future updateStatus(String id, String status) async {
    await supabase
        .from('leaves')
        .update({'status': status})
        .eq('id', id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Leave $status")),
    );

    loadLeaves();
  }

  // ================= FILTER =================
  List<Map<String, dynamic>> filterByStatus(String status) {
    return leaves.where((e) => e['status'] == status).toList();
  }

  // ================= CARD =================
  Widget buildCard(Map<String, dynamic> leave) {
    final teacherName =
        leave['teachers']?['full_name'] ?? "Unknown Teacher";

    final leaveType =
        leave['leave_types']?['name'] ?? "Unknown";

    final status = leave['status'];

    return Card(
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.role == "principal")
              Text(
                teacherName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

            Text("Leave Type: $leaveType"),

            Text(
              "${leave['start_date']} → ${leave['end_date']}",
            ),

            Text("Days: ${leave['total_days']}"),

            if (leave['reason'] != null)
              Text("Reason: ${leave['reason']}"),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: status == "approved"
                    ? Colors.green
                    : status == "rejected"
                        ? Colors.red
                        : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            // ONLY PRINCIPAL CAN APPROVE
            if (widget.role == "principal" && status == "pending")
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        updateStatus(leave['id'], "approved"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                    child: const Text("Approve"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () =>
                        updateStatus(leave['id'], "rejected"),
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
  }

  Widget buildList(String status) {
    final list = filterByStatus(status);

    if (list.isEmpty) {
      return const Center(child: Text("No data"));
    }

    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (_, i) => buildCard(list[i]),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Dashboard"),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: "Pending"),
            Tab(text: "Approved"),
            Tab(text: "Rejected"),
          ],
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: tabController,
              children: [
                buildList("pending"),
                buildList("approved"),
                buildList("rejected"),
              ],
            ),
    );
  }
}