import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import 'manage_user_page.dart';
import 'principal_duty_page.dart';
import 'principal_training_screen.dart';
import 'm1_precords_screen.dart';
import 'principal_dashboard.dart';
import 'principal_leave_approval.dart';
import '../../utils/theme_constants.dart';


class PrincipalMainPage extends StatelessWidget {
  const PrincipalMainPage({super.key});
  

  // Returns day & date in English
  String _getTodayDate() {
    final now = DateTime.now();
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${days[now.weekday % 7]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [

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
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      body: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(context)),

          // ── Section label ────────────────────────────────────
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(22, 8, 22, 4),
            sliver: SliverToBoxAdapter(
              child: Text(
                'MAIN MODULES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  color: Color(0xFF8FA3BF),
                ),
              ),
            ),
          ),

          // ── Module grid ──────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              delegate: SliverChildListDelegate([
                _ModuleCard(
                  title: 'Reporting',
                  subtitle: 'View teacher reports',
                  icon: Icons.insert_chart_rounded,
                  color: const Color(0xFF3B6CF8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PrincipalDashboard()),
                  ),
                ),
                const _ModuleCard(
                  title: 'Performance',
                  subtitle: 'Track achievements',
                  icon: Icons.bar_chart_rounded,
                  color: Color(0xFF22C55E),
                ),
                 _ModuleCard(
                  title: 'Leave',
                  subtitle: 'Manage leave requests',
                  icon: Icons.event_note_rounded,
                  color: Color(0xFFF97316),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrincipalLeaveApproval(),
                    ),
                  ),
                ),
                _ModuleCard(
                  title: 'Tasks',
                  subtitle: 'View task list',
                  icon: Icons.task_alt_rounded,
                  color: Color(0xFF8B5CF6),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrincipalDutyPage(),
                    ),
                  ),
                ),
                _ModuleCard(
                  title: "Teacher's Records",
                  subtitle: "Info & documents",
                  icon: Icons.folder_rounded,
                  color: Color(0xFF0EA5E9),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrincipalRecordsScreen(), 
                    ),
                  ),
                ),
                // _ModuleCard(
                //   title: 'Training',
                //   subtitle: 'Development programmes',
                //   icon: Icons.school_rounded,
                //   color:Color(0xFFEC4899),
                //   onTap: () => Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => const PrincipalTrainingScreen(), 
                //     ),
                //   ),
                // ),
                _ModuleCard(
                  title: 'Manage Users',
                  subtitle: 'View and manage teachers',
                  icon: Icons.people_alt_rounded,
                  color: Color(0xFFE59D2C),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ManageUserPage(),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Gradient header with logo + welcome card ──────────────
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                navyDark,
                Color(0xFF274060),
                navyLight,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 52),
              child: Column(
                children: [
                  // ── Top row: logo + name + notification ──
                  Row(
                    children: [
                      // School logo
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/LOGO TADIKA AQIL MIQAIL.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: gold.withOpacity(0.2),
                              child: const Icon(Icons.school, color: gold, size: 30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // School name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TADIKA',
                              style: TextStyle(
                                color: gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              'AQIL MIQAIL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Notification button
                      _HeaderButton(
                        icon: Icons.notifications_none_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _HeaderButton(
                        icon: Icons.menu_rounded,
                        onTap: () {
                          _showMenu(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Welcome card ──────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome back,',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Principal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Date chip
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: gold.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: gold.withOpacity(0.45),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      color: gold,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _getTodayDate(),
                                      style: const TextStyle(
                                        color: gold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          '👋',
                          style: TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Curved white scoop at bottom of header
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipPath(
            clipper: _ScoopClipper(),
            child: Container(height: 36, color: lightBg),
          ),
        ),
      ],
    );
  }
}

// ── Small icon button for header ────────────────────────────────
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(11),
        ),
        padding: const EdgeInsets.all(9),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── Upward scoop clipper ─────────────────────────────────────────
class _ScoopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(size.width / 2, 0, size.width, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> _) => false;
}

// ── Module card widget ───────────────────────────────────────────
class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative bubble (top-right)
              Positioned(
                top: -18,
                right: -18,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.07),
                  ),
                ),
              ),

              // Second smaller bubble
              Positioned(
                top: 24,
                right: 14,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.10),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon pill
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),

                    // Labels
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15.5,
                            color: navyDark,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8FA3BF),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom-left color accent bar
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}