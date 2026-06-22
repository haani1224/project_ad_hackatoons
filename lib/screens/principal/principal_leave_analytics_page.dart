import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LeaveAnalyticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> leaves;

  const LeaveAnalyticsPage({super.key, required this.leaves});

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Analytics"),
        backgroundColor: const Color(0xFF2E4365),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            const Text(
              "📊 Monthly Leave Overview",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    _bar(0, count("Pending").toDouble(), Colors.orange),
                    _bar(1, count("Approved").toDouble(), Colors.green),
                    _bar(2, count("Rejected").toDouble(), Colors.red),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          switch (v.toInt()) {
                            case 0:
                              return const Text("Pending");
                            case 1:
                              return const Text("Approved");
                            case 2:
                              return const Text("Rejected");
                          }
                          return const Text("");
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "🧠 Insight: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            Text(
              count("Pending") > 5
                  ? "High workload ⚠️ Too many pending approvals"
                  : "Workload is stable 👍",
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color c) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: c,
          width: 25,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}