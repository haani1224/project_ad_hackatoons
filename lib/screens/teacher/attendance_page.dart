import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/attendance_service.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  static const Color navy = Color(0xFF1B2E4B);
  static const Color gold = Color(0xFFE59D2C);

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Log", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: navy,
      ),
      body: attendanceProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: navy))
          : Column(
              children: [
                _buildAttendanceHeader(context),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: attendanceProvider.logs.length,
                    itemBuilder: (context, index) {
                      final log = attendanceProvider.logs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text("${log.date.day}/${log.date.month}/${log.date.year}"),
                          subtitle: Text("Check-in: ${log.checkIn} | Check-out: ${log.checkOut}"),
                          trailing: Chip(
                            label: Text(log.status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            backgroundColor: log.status == 'on-time' ? Colors.green.shade100 : Colors.red.shade100,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        onPressed: () => _handleCheckIn(context),
        label: const Text("CHECK-IN NOW", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.fingerprint, color: Colors.white),
      ),
    );
  }

  Widget _buildAttendanceHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: navy.withOpacity(0.05),
      child: const Column(
        children: [
          Text("Reminder", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("Don't forget to clock in before 07:30 AM to stay on-time!", 
               textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _handleCheckIn(BuildContext context) async {
    final provider = Provider.of<AttendanceService>(context, listen: false);
    final now = TimeOfDay.now();
    
    // Logika 07:30
    bool isLate = now.hour > 7 || (now.hour == 7 && now.minute > 30);
    String status = isLate ? 'late' : 'on-time';
    String timeNow = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    await provider.submitAttendance(status, timeNow, "17:00");
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Absen berhasil: $status pada jam $timeNow")),
      );
    }
  }
}