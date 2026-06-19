import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/attendance_provider.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Header 1
        title: const Text('Attendance Log'),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = provider.logs;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header 2: Total Late This Month
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded, color: Colors.redAccent),
                      const SizedBox(width: 12),
                      Text(
                        'Total late this month: ${provider.totalLateThisMonth}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // List Data Absensi
                Expanded(
                  child: logs.isEmpty
                      ? const Center(child: Text('No attendance records yet.'))
                      : ListView.builder(
                          itemCount: logs.length,
                          itemBuilder: (context, index) {
                            final log = logs[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14), // Identik sama style dosen
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue.shade50,
                                  child: const Icon(Icons.calendar_month, color: Colors.blue, size: 22),
                                ),
                                title: Text(
                                  log.date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text('Arrived: ${log.arrived}', style: const TextStyle(color: Colors.black87)),
                                    Text('Left: ${log.left}', style: const TextStyle(color: Colors.black87)),
                                  ],
                                ),
                                trailing: log.isLate
                                    ? const Tooltip(
                                        message: 'Late Arrival',
                                        child: Icon(Icons.error, color: Colors.red, size: 30), // Warning sign kalo telat
                                      )
                                    : const Icon(Icons.check_circle, color: Colors.green, size: 30),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}