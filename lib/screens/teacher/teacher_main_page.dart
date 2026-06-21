import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import '../../models/teacher_model.dart';
import '../../models/m1_record_model.dart';
import '../../models/training_model.dart';
import 'teacher_duty_page.dart';
import 'm1_trecord_screen.dart';
import 'teacher_training_screen.dart';
import 'teacher_home.dart';

class TeacherMainPage extends StatelessWidget {
  final TeacherModel teacher;// 1. Add this variable
  final TeacherRecord? record;

  const TeacherMainPage({
    super.key,
    required this.teacher,
    this.record,
  });


  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  void _showMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.white,
            child: SizedBox(
              width: 260,
              height: double.infinity,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Menu",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(),

                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('My Profile'),
                      onTap: () {
                        Navigator.pop(context);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherProfileScreen(
                              userId: teacher.authId,
                            ),
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () async {
                        final nav = Navigator.of(context);

                        Navigator.pop(context);

                        await AuthService().logout();

                        nav.pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: offset,
          child: child,
        );
      },
    );
  }

  bool _hasMissingDocs(TeacherRecord? record) {
    if (record == null) return false;

    final hasMissingFiles =
        record.docMyKadUrl == null ||
        record.docMyKadUrl!.isEmpty ||
        record.docPassportPhotoUrl == null ||
        record.docPassportPhotoUrl!.isEmpty ||
        record.docResumeUrl == null ||
        record.docResumeUrl!.isEmpty ||
        record.docAcademicCertUrl == null ||
        record.docAcademicCertUrl!.isEmpty ||
        record.docBankStatementUrl == null ||
        record.docBankStatementUrl!.isEmpty;

    final isChangeRequested =
      (record.documentStatuses is Map) &&
      record.documentStatuses['status'] == "change_requested";

    return hasMissingFiles || isChangeRequested;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),
          
          if (_hasMissingDocs(record)) // or however you access record
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Some required documents are missing. Please upload them in My Profile.",
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherHome(userId: teacher.id),
                      ),
                    );
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherDutyPage(
                          teacher: teacher,
                        ),
                      ),
                    );
                  },
                ),

// record already go into menu tab

                _moduleCard(
                  context,
                  title: "Training",
                  subtitle: "Professional development",
                  icon: Icons.school_outlined,
                  gradient: const [Color(0xFF1565A8), Color(0xFF1E90FF)],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherTrainingScreen(
                          teacherId: teacher.id,
                        ),
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
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/LOGO TADIKA AQIL MIQAIL.jpg',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                  const SizedBox(width: 10),

                  // Menu (logout)
                  GestureDetector(
                    onTap: () => _showMenu(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Text(
                _getGreeting(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.65),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                teacher.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),

              const SizedBox(height: 16),

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

    if (hour < 12) {
      return "Good Morning,";
    } else if (hour < 17) {
      return "Good Afternoon,";
    } else {
      return "Good Evening,";
    }
  }

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