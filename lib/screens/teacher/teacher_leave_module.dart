import 'package:flutter/material.dart';

import 'teacher_leave_dashboard.dart';
import 'teacher_leave_history_page.dart';
import 'teacher_leave_request_page.dart';
import 'teacher_leave_balance_page.dart';

class TeacherLeaveModule extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveModule({super.key, required this.teacherId});

  @override
  State<TeacherLeaveModule> createState() =>
      _TeacherLeaveModuleState();
}

class _TeacherLeaveModuleState
    extends State<TeacherLeaveModule> {
  int index = 0;

  final GlobalKey dashboardKey = GlobalKey();

  void goApply() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherLeaveRequestPage(
          teacherId: widget.teacherId,
        ),
      ),
    );

    if (result == true) {
      final state = dashboardKey.currentState;

      if (state != null) {
        (state as dynamic).load();
      }

      setState(() => index = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TeacherLeaveDashboard(
        key: dashboardKey,
        teacherId: widget.teacherId,
      ),

      TeacherLeaveBalancePage(
        teacherId: widget.teacherId,
      ),

      TeacherLeaveHistoryPage(
        teacherId: widget.teacherId,
      ),
    ];

    return Scaffold(
      body: pages[index],

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE59D2C),
        icon: const Icon(Icons.add),
        label: const Text("Apply Leave"),
        onPressed: goApply,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: "Balance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}