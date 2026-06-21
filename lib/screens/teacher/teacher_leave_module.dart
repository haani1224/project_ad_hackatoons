import 'package:flutter/material.dart';

import 'teacher_leave_dashboard.dart';
import 'teacher_leave_history_page.dart';
import 'teacher_leave_request_page.dart';

class TeacherLeaveModule extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveModule({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherLeaveModule> createState() =>
      _TeacherLeaveModuleState();
}

class _TeacherLeaveModuleState extends State<TeacherLeaveModule> {
  int index = 0;

  late List<Widget> pages;

  static const Color gold = Color(0xFFE59D2C);
  static const Color lightGold = Color(0xFFF3D58D);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [lightGold, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();

    pages = [
      TeacherLeaveDashboard(
        teacherId: widget.teacherId,
      ),
      TeacherLeaveHistoryPage(
        teacherId: widget.teacherId,
      ),
    ];
  }

  Future<void> _openApplyLeave() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherLeaveRequestPage(
          teacherId: widget.teacherId,
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() {
        index = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      // ================= FLOATING BUTTON (GRADIENT) =================
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: goldGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Apply Leave",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: _openApplyLeave,
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        selectedItemColor: const Color(0xFF2E4365),
        unselectedItemColor: Colors.grey,
        onTap: (value) {
          setState(() {
            index = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: "History",
          ),
        ],
      ),
    );
  }
}