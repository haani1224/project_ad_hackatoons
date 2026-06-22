import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'principal_leave_calendar_heatmap.dart';

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

  int tab = 0;

  @override
  void initState() {
    super.initState();
    fetchLeaves();
  }

  Future fetchLeaves() async {
    setState(() => loading = true);

    final data = await supabase.from('leave_requests').select('''
      *,
      leave_types(name)
    ''').order('submitted_date', ascending: false);

    setState(() {
      leaves = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  Future updateStatus(String id, String status) async {
    await supabase.from('leave_requests').update({
      'status': status,
      'approved_date':
          status == 'Approved' ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);

    fetchLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        title: const Text("Principal HR Dashboard"),
        backgroundColor: const Color(0xFF2E4365),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ================= TAB =================
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _tab("Overview", 0, Icons.dashboard),
                      _tab("Calendar", 1, Icons.calendar_month),
                      _tab("Insights", 2, Icons.insights),
                    ],
                  ),
                ),

                Expanded(child: _build()),
              ],
            ),
    );
  }

  Widget _build() {
    switch (tab) {

      // ================= OVERVIEW =================
      case 0:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            _header(),

            const SizedBox(height: 16),

            Row(
              children: [
                _kpi("Pending", count("Pending"), Colors.orange),
                _kpi("Approved", count("Approved"), Colors.green),
                _kpi("Rejected", count("Rejected"), Colors.red),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Pending Approvals",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...leaves.where((e) => e['status'] == "Pending").take(5).map((l) {
              return Card(
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Teacher ${l['teacher_id']}"),
                  subtitle: Text(l['leave_types']?['name'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () =>
                            updateStatus(l['id'], "Approved"),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () =>
                            updateStatus(l['id'], "Rejected"),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );

      // ================= CALENDAR =================
      case 1:
        return LeaveCalendarHeatmap(leaves: leaves);

      // ================= INSIGHTS (WOW VERSION) =================
      case 2:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            const Text(
              "HR Insights Dashboard",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _insightCard(
              "Total Requests",
              leaves.length,
              Icons.list_alt,
              Colors.blue,
            ),

            _insightCard(
              "Pending Workload",
              count("Pending"),
              Icons.hourglass_bottom,
              Colors.orange,
            ),

            _insightCard(
              "Approved Leaves",
              count("Approved"),
              Icons.verified,
              Colors.green,
            ),

            _insightCard(
              "Rejected Cases",
              count("Rejected"),
              Icons.block,
              Colors.red,
            ),

            const SizedBox(height: 20),

            const Text(
              "Leave Distribution (Clean Bar View)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _wowBar("Pending", count("Pending"), Colors.orange),
            _wowBar("Approved", count("Approved"), Colors.green),
            _wowBar("Rejected", count("Rejected"), Colors.red),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: count("Pending") > 10
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    count("Pending") > 10
                        ? Icons.warning
                        : Icons.check_circle,
                    color: count("Pending") > 10
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      count("Pending") > 10
                          ? "⚠ High workload detected: consider fast approvals"
                          : "✅ Workload stable across staff",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
    return const SizedBox();
  }

  // ================= TAB =================
  Widget _tab(String label, int i, IconData icon) {
    final selected = tab == i;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2E4365) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : Colors.grey),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E4365), Color(0xFF4C78A8)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings,
              color: Colors.white, size: 40),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Leave Management Control Center",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ================= KPI =================
  Widget _kpi(String label, int value, Color c) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                "$value",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: c),
              ),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  // ================= INSIGHT CARD =================
  Widget _insightCard(
      String title, int value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          "$value",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color),
        ),
      ),
    );
  }

  // ================= WOW BAR =================
  Widget _wowBar(String label, int value, Color color) {
    final width = (value * 18).clamp(10, 220).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Text(
                "($value)",
                style: TextStyle(color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Stack(
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              Container(
                height: 16,
                width: width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}