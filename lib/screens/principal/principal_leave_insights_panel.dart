import 'package:flutter/material.dart';

class LeaveInsightsPanel extends StatelessWidget {
  final List<Map<String, dynamic>> leaves;

  const LeaveInsightsPanel({super.key, required this.leaves});

  @override
  Widget build(BuildContext context) {
    int pending = leaves.where((e) => e['status'] == "Pending").length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "🧠 HR Insights",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              pending > 5
                  ? "⚠️ High pending workload. Approvals needed urgently."
                  : "✔ System is under control.",
            ),

            const SizedBox(height: 8),

            Text(
              "💡 Suggestion: Avoid approving too many leaves in same week if staffing is low.",
            ),
          ],
        ),
      ),
    );
  }
}