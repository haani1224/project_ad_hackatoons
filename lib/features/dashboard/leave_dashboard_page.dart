import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LeaveDashboardPage extends StatefulWidget {
  final String role; // "teacher" or "principal"

  const LeaveDashboardPage({
    super.key,
    required this.role,
  });

  @override
  State<LeaveDashboardPage> createState() =>
      _LeaveDashboardPageState();
}

class _LeaveDashboardPageState extends State<LeaveDashboardPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  final searchController = TextEditingController();
  DateTime? filterDate;

  @override
  void initState() {
    super.initState();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    final user = Supabase.instance.client.auth.currentUser;

    late final res;

    if (widget.role == "teacher") {
      final teacher = await Supabase.instance.client
          .from('teachers')
          .select('id')
          .eq('user_id', user!.id)
          .single();

      res = await Supabase.instance.client
          .from('leaves')
          .select('''
            id,
            start_date,
            end_date,
            total_days,
            reason,
            status,
            leave_types(name)
          ''')
          .eq('teacher_id', teacher['id']);
    } else {
      // principal sees ALL
      res = await Supabase.instance.client
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
          ''');
    }

    setState(() {
      leaves = List<Map<String, dynamic>>.from(res);
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

  List<Map<String, dynamic>> get filteredLeaves {
    return leaves.where((leave) {
      final searchText = searchController.text.toLowerCase();

      final teacherName = (leave['teachers']?['full_name'] ?? "")
          .toString()
          .toLowerCase();

      final matchSearch = searchText.isEmpty ||
          (widget.role == "principal"
              ? teacherName.contains(searchText)
              : true);

      final matchDate = filterDate == null
          ? true
          : (leave['start_date'] != null &&
              DateTime.parse(leave['start_date'])
                  .isAtSameMomentAs(
                    DateTime(filterDate!.year, filterDate!.month, filterDate!.day),
                  ));

      return matchSearch && matchDate;
    }).toList();
  }

    List<Map<String, dynamic>> byStatus(String status) {
      return filteredLeaves
          .where((e) => e['status'] == status)
          .toList();
    }

    Widget buildCard(Map<String, dynamic> leave) {
      final teacherName = widget.role == "principal"
          ? (leave['teachers']?['full_name'] ?? "Unknown Teacher")
          : "My Leave";

      final type = leave['leave_types']?['name'] ?? "Unknown";

      final start = leave['start_date'] != null
          ? leave['start_date'].toString().split("T")[0]
          : "-";

      final end = leave['end_date'] != null
          ? leave['end_date'].toString().split("T")[0]
          : "-";

      return Card(
        margin: const EdgeInsets.all(10),
        child: ListTile(
          title: Text(teacherName),
          subtitle: Text(
            "$type\n$start → $end\nDays: ${leave['total_days'] ?? 0}",
          ),
          trailing: Text(
            leave['status'].toString().toUpperCase(),
            style: TextStyle(
              color: leave['status'] == 'approved'
                  ? Colors.green
                  : leave['status'] == 'rejected'
                      ? Colors.red
                      : Colors.orange,
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
          title: Text(
            widget.role == "principal"
                ? "Principal Dashboard"
                : "My Leave",
          ),
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
            : Column(
                children: [
                  if (widget.role == "principal")
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: "Search teacher...",
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),

                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                            children:
                                byStatus("pending").map(buildCard).toList()),
                        ListView(
                            children:
                                byStatus("approved").map(buildCard).toList()),
                        ListView(
                            children:
                                byStatus("rejected").map(buildCard).toList()),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}