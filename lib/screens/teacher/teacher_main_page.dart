import 'package:flutter/material.dart';
// import 'teacher_home.dart';

class TeacherMainPage extends StatelessWidget {
  final int userId;
  final String teacherName; // Pass the name from your DB/session

  const TeacherMainPage({
    super.key,
    required this.userId,
    this.teacherName = "Teacher", // fallback default
  });

  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color goldLight = Color(0xFFFFF0CC);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Curved Header ──
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // ── Section Label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text(
                "MAIN MODULES",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.8,
                  color: navyLight.withOpacity(0.5),
                ),
              ),
            ),
          ),

          // ── Module Grid ──
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
                _moduleCard(
                  context,
                  title: "Reporting",
                  subtitle: "Raise issues & submit reports",
                  icon: Icons.insert_chart_outlined_rounded,
                  gradient: const [Color(0xFF2E4365), Color(0xFF3A6186)],
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (_) => TeacherHome(userId: userId),
                    //   ),
                    // );
                  },
                ),
                _moduleCard(
                  context,
                  title: "Performance",
                  subtitle: "Track student progress",
                  icon: Icons.emoji_events_outlined,
                  gradient: const [Color(0xFFB07D1A), Color(0xFFE59D2C)],
                  onTap: () {},
                ),
                _moduleCard(
                  context,
                  title: "Leave",
                  subtitle: "Applications & approvals",
                  icon: Icons.event_available_outlined,
                  gradient: const [Color(0xFF1A7A5E), Color(0xFF2EAF88)],
                  onTap: () {},
                ),
                _moduleCard(
                  context,
                  title: "Tasks",
                  subtitle: "Daily task checklist",
                  icon: Icons.task_alt_rounded,
                  gradient: const [Color(0xFF6B3FA0), Color(0xFF9B6BD1)],
                  onTap: () {},
                ),
                _moduleCard(
                  context,
                  title: "Records",
                  subtitle: "Files & important docs",
                  icon: Icons.folder_open_rounded,
                  gradient: const [Color(0xFFC0392B), Color(0xFFE74C3C)],
                  onTap: () {},
                ),
                _moduleCard(
                  context,
                  title: "Training",
                  subtitle: "Professional development",
                  icon: Icons.school_outlined,
                  gradient: const [Color(0xFF1565A8), Color(0xFF1E90FF)],
                  onTap: () {},
                ),
              ]),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Header Widget ──
  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [navy, navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: logo + school name + notification
              Row(
                children: [
                  // ── School Logo ──
                  // Replace AssetImage path with your actual logo asset:
                  // assets/images/LOGO TADIKA AQIL MIQAIL.jpg
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      image: const DecorationImage(
                        // ↓ Change this path to match your pubspec.yaml asset declaration
                        image: AssetImage(
                            'assets/images/LOGO TADIKA AQIL MIQAIL.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Tadika Aqil Miqail",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Teacher Portal",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Welcome text
              Text(
                _getGreeting(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                teacherName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 16),

              // Gold accent divider + tagline
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Have a wonderful day! 🌟",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Quick stats bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem("Students", "28"),
                    _divider(),
                    _statItem("Present Today", "25"),
                    _divider(),
                    _statItem("New Tasks", "3"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: gold,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.65),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withOpacity(0.2),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,";
    if (hour < 17) return "Good Afternoon,";
    return "Good Evening,";
  }

  // ── Module Card ──
  Widget _moduleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon container with gradient
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),

                // Title + subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1B2E4B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}