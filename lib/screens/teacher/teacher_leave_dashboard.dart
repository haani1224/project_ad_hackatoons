import 'package:flutter/material.dart';
import '../../data/repositories/leave_repository.dart';

class TeacherLeaveDashboard extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveDashboard({super.key, required this.teacherId});

  @override
  State<TeacherLeaveDashboard> createState() => _TeacherLeaveDashboardState();
}

class _TeacherLeaveDashboardState extends State<TeacherLeaveDashboard>
    with SingleTickerProviderStateMixin {
  final repo = LeaveRepository();

  List<Map<String, dynamic>> leaves = [];
  Map<String, int> balance = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final l = await repo.getTeacherLeaves(widget.teacherId);
    final b = await repo.getLeaveBalance(widget.teacherId);

    setState(() {
      leaves = l;
      balance = b;
      loading = false;
    });
  }

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        title: const Text("Leave Dashboard"),
        backgroundColor: const Color(0xFF2E4365),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [

                  // ================= BALANCE =================
                  const Text(
                    "Leave Balance",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _card("Annual", 14 - (balance['annual_used'] ?? 0)),
                      _card("Medical", 18 - (balance['medical_used'] ?? 0)),
                      _card("Emergency", 7 - (balance['emergency_used'] ?? 0)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ================= STATUS =================
                  Row(
                    children: [
                      _stat("Pending", count("Pending"), Colors.orange),
                      _stat("Approved", count("Approved"), Colors.green),
                      _stat("Rejected", count("Rejected"), Colors.red),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Recent Requests",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  ...leaves.take(5).map((l) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        child: ListTile(
                          leading: const Icon(Icons.event_note),
                          title: Text(l['leave_types']?['name'] ?? ''),
                          subtitle: Text(
                            "${l['start_date']} → ${l['end_date']}",
                          ),
                          trailing: Text(l['status']),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _card(String title, int value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text("$value",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text("$value",
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            Text(title),
          ],
        ),
      ),
    );
  }
}// import 'package:flutter/material.dart';
// import '../../data/repositories/leave_repository.dart';

// class TeacherLeaveDashboard extends StatefulWidget {
//   final String teacherId;

//   const TeacherLeaveDashboard({super.key, required this.teacherId});

//   @override
//   State<TeacherLeaveDashboard> createState() =>
//       _TeacherLeaveDashboardState();
// }

// class _TeacherLeaveDashboardState extends State<TeacherLeaveDashboard> {
//   final repo = LeaveRepository();

//   List<Map<String, dynamic>> leaves = [];
//   Map<String, int> balance = {};
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   Future<void> loadData() async {
//     final l = await repo.getTeacherLeaves(widget.teacherId);
//     final b = await repo.getLeaveBalance(widget.teacherId);

//     setState(() {
//       leaves = l;
//       balance = b;
//       loading = false;
//     });
//   }

//   int count(String status) =>
//       leaves.where((e) => e['status'] == status).length;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F6F8),
//       appBar: AppBar(
//         title: const Text("My Leave Dashboard"),
//         backgroundColor: const Color(0xFF2E4365),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : RefreshIndicator(
//               onRefresh: loadData,
//               child: ListView(
//                 padding: const EdgeInsets.all(12),
//                 children: [
//                   // ================= BALANCE =================
//                   const Text(
//                     "Leave Balance",
//                     style:
//                         TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 10),

//                   Row(
//                     children: [
//                       balanceCard(
//                         "Annual",
//                         14 - (balance['annual_used'] ?? 0),
//                       ),
//                       balanceCard(
//                         "Medical",
//                         18 - (balance['medical_used'] ?? 0),
//                       ),
//                       balanceCard(
//                         "Emergency",
//                         7 - (balance['emergency_used'] ?? 0),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   // ================= STATUS =================
//                   Row(
//                     children: [
//                       statCard("Pending", count("Pending"), Colors.orange),
//                       statCard("Approved", count("Approved"), Colors.green),
//                       statCard("Rejected", count("Rejected"), Colors.red),
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   const Text(
//                     "Recent Requests",
//                     style:
//                         TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),

//                   const SizedBox(height: 10),

//                   ...leaves.take(5).map((l) {
//                     return Card(
//                       child: ListTile(
//                         title: Text(l['leave_types']?['name'] ?? ''),
//                         subtitle: Text(
//                           "${l['start_date']} → ${l['end_date']}",
//                         ),
//                         trailing: Text(l['status']),
//                       ),
//                     );
//                   }),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget balanceCard(String label, int value) {
//     return Expanded(
//       child: Card(
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Column(
//             children: [
//               Text("$value",
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//               Text(label),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget statCard(String label, int value, Color color) {
//     return Expanded(
//       child: Container(
//         margin: const EdgeInsets.all(4),
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           children: [
//             Text("$value",
//                 style: TextStyle(
//                     color: color,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold)),
//             Text(label),
//           ],
//         ),
//       ),
//     );
//   }
// }