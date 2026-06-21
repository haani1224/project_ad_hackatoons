import 'package:flutter/material.dart';
import 'performance_details_page.dart';
import 'principal_evaluate_teacher_page.dart'; // 🟢 Tambahin import ini buat navigasi FAB

class TeacherPerformancePage extends StatefulWidget {
  const TeacherPerformancePage({super.key});

  @override
  State<TeacherPerformancePage> createState() => _TeacherPerformancePageState();
}

class _TeacherPerformancePageState extends State<TeacherPerformancePage> {
  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  // DUMMY DATA GURU
  final List<Map<String, dynamic>> _teachers = [
    {'name': 'Tc. Fetty', 'role': 'Senior Teacher', 'kpi': 85},
    {'name': 'Tc. Sutie', 'role': 'Math Teacher', 'kpi': 55}, 
    {'name': 'Tc. Zu', 'role': 'Science Teacher', 'kpi': 92},
    {'name': 'Tc. Siti', 'role': 'English Teacher', 'kpi': 45}, 
    {'name': 'Tc. Mira', 'role': 'PE Teacher', 'kpi': 78},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Staff Performance", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: navy,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: const Text(
              "Select a teacher to view detailed metrics or evaluate staff.",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              "ALL TEACHERS (${_teachers.length})",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _teachers.length,
              itemBuilder: (context, index) {
                final teacher = _teachers[index];
                return _buildTeacherListCard(teacher);
              },
            ),
          ),
        ],
      ),
      
      // 🟢 TOMBOL EVALUATE PINDAH KESINI JADI FAB (Konsisten sama halaman Duty)
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        elevation: 4,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PeerEvaluatePage()));
        },
        icon: const Icon(Icons.rate_review_rounded, color: Colors.white),
        label: const Text(
          "Evaluate",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildTeacherListCard(Map<String, dynamic> teacher) {
    final double kpi = (teacher['kpi'] ?? 0).toDouble();
    final bool isWarning = kpi < 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // NAVIGASI KE DETAIL
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeacherPerformanceDetailsPage(teacherData: teacher),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: navyLight.withOpacity(0.1),
                child: Text(teacher['name'][0], style: const TextStyle(color: navy, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(teacher['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: navy)),
                    Text(teacher['role'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${kpi.toInt()}%", style: TextStyle(fontWeight: FontWeight.bold, color: isWarning ? Colors.red : gold)),
                  const Text("KPI", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}