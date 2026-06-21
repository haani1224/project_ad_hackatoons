import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrincipalLeaveApproval extends StatefulWidget {
  const PrincipalLeaveApproval({super.key});

  @override
  State<PrincipalLeaveApproval> createState() =>
      _PrincipalLeaveApprovalState();
}

class _PrincipalLeaveApprovalState extends State<PrincipalLeaveApproval> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  String search = '';
  String statusFilter = 'All';

  final statuses = ['All', 'Pending', 'Approved', 'Rejected'];

  @override
  void initState() {
    super.initState();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    final data = await supabase.from('leave_requests').select('''
      *,
      leave_types(name)
    ''').order('submitted_date', ascending: false);

    setState(() {
      leaves = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await supabase.from('leave_requests').update({
      'status': status,
      'approved_date': status == 'Approved'
          ? DateTime.now().toIso8601String()
          : null,
    }).eq('id', id);

    fetchLeaves();
  }

  List<Map<String, dynamic>> get filtered {
    return leaves.where((l) {
      final matchStatus =
          statusFilter == 'All' || l['status'] == statusFilter;

      final matchSearch = (l['teacher_id'] ?? '')
          .toString()
          .toLowerCase()
          .contains(search.toLowerCase());

      return matchStatus && matchSearch;
    }).toList();
  }

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  Color color(String status) {
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
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Leave Approval"),
        backgroundColor: const Color(0xFF2E4365),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // KPI ROW
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      kpi("Total", leaves.length, Colors.blue),
                      kpi("Pending", count("Pending"), Colors.orange),
                      kpi("Approved", count("Approved"), Colors.green),
                      kpi("Rejected", count("Rejected"), Colors.red),
                    ],
                  ),
                ),

                // SEARCH
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    onChanged: (v) => setState(() => search = v),
                    decoration: const InputDecoration(
                      hintText: "Search teacher ID...",
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // FILTER CHIPS
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: statuses.length,
                    itemBuilder: (context, i) {
                      final s = statuses[i];
                      final selected = s == statusFilter;

                      return GestureDetector(
                        onTap: () => setState(() => statusFilter = s),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF2E4365)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              color:
                                  selected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: fetchLeaves,
                    child: ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final l = filtered[i];
                        final status = l['status'] ?? 'Pending';

                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Teacher ID: ${l['teacher_id']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),

                                Text(
                                  l['leave_types']?['name'] ??
                                      "No type",
                                ),

                                Text(
                                  "${l['start_date']} → ${l['end_date']}",
                                ),

                                Text("Days: ${l['total_days']}"),

                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: color(status),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                        color: Colors.white),
                                  ),
                                ),

                                if (status == 'Pending')
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => updateStatus(
                                            l['id'], 'Approved'),
                                        child: const Text("Approve"),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => updateStatus(
                                            l['id'], 'Rejected'),
                                        child: const Text("Reject"),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget kpi(String label, int value, Color c) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text("$value",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: c)),
            Text(label),
          ],
        ),
      ),
    );
  }
}