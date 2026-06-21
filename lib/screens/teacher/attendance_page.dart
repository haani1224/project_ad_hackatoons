import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/attendance_service.dart';
import '../../models/attendance.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    final AttendanceService provider = context.watch<AttendanceService>();

    if (!provider.isLoaded) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: navy)),
      );
    }

    final logs = provider.logs;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: _buildSummaryCard(provider.totalLateThisMonth),
            ),
          ),
          if (logs.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: Text('No attendance records yet.', style: TextStyle(color: Colors.grey, fontSize: 16))),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = logs[index];
                    return _buildLogCard(log);
                  },
                  childCount: logs.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(right: -40, top: -30, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: navyLight.withOpacity(0.5)))),
            Positioned(right: 60, bottom: -50, child: Container(width: 130, height: 130, decoration: BoxDecoration(shape: BoxShape.circle, color: gold.withOpacity(0.12)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(color: gold, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text('Attendance Log', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('Track your daily punctuality', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int totalLate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.red.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.warning_rounded, color: Colors.redAccent, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total late this month', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('$totalLate Days', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(AttendanceLog log) {
    final bool isLate = log.status.toLowerCase() == 'late';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: navyLight.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.calendar_today_rounded, color: navyLight, size: 22),
        ),
        title: Text(log.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: navy)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              _timeBadge(Icons.login_rounded, log.checkInTime, isLate ? Colors.redAccent : Colors.green),
              const SizedBox(width: 12),
              _timeBadge(Icons.logout_rounded, log.checkOutTime, Colors.grey.shade700),
            ],
          ),
        ),
        trailing: isLate
            ? const Tooltip(message: 'Late Arrival', child: Icon(Icons.error_rounded, color: Colors.redAccent, size: 28))
            : const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
      ),
    );
  }

  Widget _timeBadge(IconData icon, String time, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(time, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}