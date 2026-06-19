import 'package:flutter/material.dart';

class TeacherPerformanceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> teacherData;

  const TeacherPerformanceDetailsPage({Key? key, required this.teacherData}) : super(key: key);

  Widget buildProgressRow(String title, double value) {
    int percent = (value * 100).round();
    Color progressColor = value <= 0.60 ? Colors.redAccent : Colors.blueAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
              Text(
                '$percent%',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: progressColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = teacherData['name'];
    final double overallKpi = teacherData['kpi'];
    final int overallPercent = (overallKpi * 100).round();
    final bool needsWarning = overallKpi <= 0.60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // HEADER OVERALL KPI
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              color: needsWarning ? Colors.red.shade50 : Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: needsWarning ? Colors.red.shade200 : Colors.blue.shade200,
                      child: Icon(Icons.person, size: 40, color: needsWarning ? Colors.red.shade700 : Colors.blue.shade700),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Overall KPI: $overallPercent%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: needsWarning ? Colors.red : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BREAKDOWN PROGRESS (Dikasih pengaman ?? overallKpi biar gak error pas data aslinya kosong)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KPI Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 24),
                    buildProgressRow('Attendance Progress', teacherData['attendance'] ?? overallKpi),
                    buildProgressRow('Classroom Management', teacherData['classroom'] ?? overallKpi),
                    buildProgressRow('Teaching Performance', teacherData['teaching'] ?? overallKpi),
                    buildProgressRow('Student Development', teacherData['student'] ?? overallKpi),
                    buildProgressRow('Training & Self Development', teacherData['training'] ?? overallKpi),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (needsWarning)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Warning letter drafted for $name')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.warning_amber_rounded),
                  label: const Text(
                    'Issue Warning Letter',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}