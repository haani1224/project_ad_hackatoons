import 'package:flutter/material.dart';
// import 'principal_dashboard.dart';

const Color _navy = Color(0xFF2E4365);
const Color _gold = Color(0xFFE59D2C);

class PrincipalMainPage extends StatelessWidget {
  const PrincipalMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text("Principal Dashboard"),
        backgroundColor: _navy,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            // _moduleCard(
            //   context,
            //   title: "Reporting",
            //   icon: Icons.report,
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => const PrincipalDashboard(),
            //       ),
            //     );
            //   },
            // ),

            _moduleCard(
              context,
              title: "Performance",
              icon: Icons.bar_chart,
              onTap: () {},
            ),

            _moduleCard(
              context,
              title: "Leave",
              icon: Icons.event_note,
              onTap: () {},
            ),

            _moduleCard(
              context,
              title: "Task",
              icon: Icons.task_alt,
              onTap: () {},
            ),

            _moduleCard(
              context,
              title: "Records",
              icon: Icons.folder,
              onTap: () {},
            ),

            _moduleCard(
              context,
              title: "Training",
              icon: Icons.school,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

Widget _moduleCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 55,
            color: _gold,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

