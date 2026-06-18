import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PrincipalApprovalPage extends StatefulWidget {
  const PrincipalApprovalPage({super.key});

  @override
  State<PrincipalApprovalPage> createState() => _PrincipalApprovalPageState();
}

class _PrincipalApprovalPageState extends State<PrincipalApprovalPage> {
  final supabase = Supabase.instance.client;

  List teachers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadPendingTeachers();
  }

  Future loadPendingTeachers() async {
    setState(() => loading = true);

    final data = await supabase
        .from('teachers')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    setState(() {
      teachers = data;
      loading = false;
    });
  }

  Future approveTeacher(String id) async {
    await supabase
        .from('teachers')
        .update({'status': 'approved'})
        .eq('id', id);

    loadPendingTeachers();
  }

  Future rejectTeacher(String id) async {
    await supabase
        .from('teachers')
        .update({'status': 'rejected'})
        .eq('id', id);

    loadPendingTeachers();
  }

  String getInitial(String name) {
    if (name.isEmpty) return "?";
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Principal Approval Panel"),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            onPressed: loadPendingTeachers,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
              ? const Center(
                  child: Text(
                    "No pending teacher registrations",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final t = teachers[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.indigo,
                                  child: Text(
                                    getInitial(t['full_name'] ?? ''),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t['full_name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(t['email'] ?? ''),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            Text("IC: ${t['ic_number'] ?? '-'}"),
                            Text("Phone: ${t['phone'] ?? '-'}"),
                            Text("State: ${t['state'] ?? '-'}"),

                            const SizedBox(height: 12),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [

                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () => approveTeacher(t['id']),
                                  icon: const Icon(Icons.check),
                                  label: const Text("Approve"),
                                ),

                                const SizedBox(width: 10),

                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => rejectTeacher(t['id']),
                                  icon: const Icon(Icons.close),
                                  label: const Text("Reject"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}