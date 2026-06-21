import 'package:flutter/material.dart';
import '../../models/teacher_model.dart';
import 'attendance_page.dart';
import 'classroom_management_page.dart';
import 'peer_eval_page.dart' show PeerEvaluationPage;
import 'training_development_page.dart';

class PerformanceTrackerDashboard extends StatelessWidget {
  final TeacherModel teacher;

  const PerformanceTrackerDashboard({
    super.key,
    required this.teacher,
  });

  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text(
                "PERFORMANCE MODULES",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: navyLight.withOpacity(0.5),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildListDelegate([
                // _moduleCard(
                //   context,
                //   title: "Attendance",
                //   subtitle: "Track attendance records",
                //   icon: Icons.check_circle_outline_rounded,
                //   gradient: const [Color(0xFF1565A8), Color(0xFF1E90FF)],
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (_) => const AttendancePage(),
                //       ),
                //     );
                //   },
                // ),
                _moduleCard(
                  context,
                  title: "Classroom",
                  subtitle: "Manage classroom performance",
                  icon: Icons.class_rounded,
                  gradient: const [Color(0xFF2E7D32), Color(0xFF43A047)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ClassroomManagementPage(),
                      ),
                    );
                  },
                ),
                _moduleCard(
                  context,
                  title: "Peer Evaluation",
                  subtitle: "Peer feedback & assessment",
                  icon: Icons.people_alt_rounded,
                  gradient: const [Color(0xFFC0392B), Color(0xFFE74C3C)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PeerEvaluationPage(),
                      ),
                    );
                  },
                ),
                _moduleCard(
                  context,
                  title: "Training",
                  subtitle: "Professional development",
                  icon: Icons.school_rounded,
                  gradient: const [Color(0xFF6B3FA0), Color(0xFF9B6BD1)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TrainingDevelopmentPage(),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: navyLight.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withOpacity(0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.trending_up_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Performance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tracker Dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moduleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                icon,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon,
                        color: Colors.white, size: 24),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
