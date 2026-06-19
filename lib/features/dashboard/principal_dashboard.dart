import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrincipalLeaveDashboard extends StatefulWidget {
  const PrincipalLeaveDashboard({super.key});

  @override
  State<PrincipalLeaveDashboard> createState() =>
      _PrincipalLeaveDashboardState();
}

class _PrincipalLeaveDashboardState extends State<PrincipalLeaveDashboard> {
  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    final res = await Supabase.instance.client
        .from('leaves')
        .select('''
          id,
          start_date,
          end_date,
          total_days,
          status,
          teachers(full_name),
          leave_types(name)
        ''')
        .order('created_at', ascending: false);

    setState(() {
      leaves = List<Map<String, dynamic>>.from(res);
      loading = false;
    });
  }

  Future updateStatus(String id, String status) async {
    await Supabase.instance.client
        .from('leaves')
        .update({'status': status})
        .eq('id', id);

    fetchLeaves();
  }

  List<Map<String, dynamic>> filter(String status) {
    return leaves.where((e) => e['status'] == status).toList();
  }

  Widget buildLeaveCard(Map<String, dynamic> leave) {
    final teacher = leave['teachers']?['full_name'] ?? "Unknown";
    final type = leave['leave_types']?['name'] ?? "Unknown";

    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(teacher),
        subtitle: Text(
          "$type\n${leave['start_date']} → ${leave['end_date']}\nDays: ${leave['total_days']}",
        ),
        isThreeLine: true,
        trailing: leave['status'] == 'pending'
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () =>
                        updateStatus(leave['id'], 'approved'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () =>
                        updateStatus(leave['id'], 'rejected'),
                  ),
                ],
              )
            : Text(
                leave['status'].toString().toUpperCase(),
                style: TextStyle(
                  color: leave['status'] == 'approved'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Leave Approval Dashboard"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Pending"),
              Tab(text: "Approved"),
              Tab(text: "Rejected"),
            ],
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  ListView(
                    children:
                        filter('pending').map(buildLeaveCard).toList(),
                  ),
                  ListView(
                    children:
                        filter('approved').map(buildLeaveCard).toList(),
                  ),
                  ListView(
                    children:
                        filter('rejected').map(buildLeaveCard).toList(),
                  ),
                ],
              ),
      ),
    );
  }
}