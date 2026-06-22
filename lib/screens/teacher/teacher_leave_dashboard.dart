import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/repositories/leave_repository.dart';

class TeacherLeaveDashboard extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveDashboard({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherLeaveDashboard> createState() =>
      _TeacherLeaveDashboardState();
}

class _TeacherLeaveDashboardState
    extends State<TeacherLeaveDashboard> {
  final repo = LeaveRepository();

  bool loading = true;

  List<Map<String, dynamic>> leaves = [];

  // date -> list of status
  Map<DateTime, List<Map<String, dynamic>>> calendar = {};

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    final data =
        await repo.getTeacherLeaves(widget.teacherId);

    Map<DateTime, List<Map<String, dynamic>>> temp = {};

    for (final l in data) {
      final start = DateTime.parse(l['start_date']);
      final end = DateTime.parse(l['end_date']);

      for (DateTime d = start;
          d.isBefore(end.add(const Duration(days: 1)));
          d = d.add(const Duration(days: 1))) {
        final key = DateTime(d.year, d.month, d.day);

        temp.putIfAbsent(key, () => []);
        temp[key]!.add(l);
      }
    }

    setState(() {
      leaves = data;
      calendar = temp;
      loading = false;
    });
  }

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  Color statusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Pending") return Colors.orange;
    if (status == "Rejected") return Colors.red;
    return Colors.grey;
  }

  void showDayDetails(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final items = calendar[key] ?? [];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("📅 ${day.day}/${day.month}/${day.year}"),
        content: items.isEmpty
            ? const Text("No leave on this day")
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: items.map((l) {
                  return ListTile(
                    title: Text(l['leave_types']?['name'] ?? ''),
                    subtitle: Text(
                        "${l['start_date']} → ${l['end_date']}"),
                    trailing: Text(
                      l['status'],
                      style: TextStyle(
                        color: statusColor(l['status']),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5F6F8),
              Color(0xFFE3EDF7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ================= HEADER =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2E4365),
                          Color(0xFF3C5A8A)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "📊 Leave Dashboard",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================= STATUS =================
                  Row(
                    children: [
                      _stat("Pending",
                          count("Pending"),
                          Colors.orange),
                      _stat("Approved",
                          count("Approved"),
                          Colors.green),
                      _stat("Rejected",
                          count("Rejected"),
                          Colors.red),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // ================= CALENDAR =================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📅 Leave Calendar",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: const [
                              Icon(Icons.circle,
                                  size: 10,
                                  color: Colors.green),
                              SizedBox(width: 5),
                              Text("Approved"),
                              SizedBox(width: 10),
                              Icon(Icons.circle,
                                  size: 10,
                                  color: Colors.orange),
                              SizedBox(width: 5),
                              Text("Pending"),
                              SizedBox(width: 10),
                              Icon(Icons.circle,
                                  size: 10,
                                  color: Colors.red),
                              SizedBox(width: 5),
                              Text("Rejected"),
                            ],
                          ),

                          const SizedBox(height: 10),

                          TableCalendar(
                            focusedDay: DateTime.now(),
                            firstDay: DateTime(2020),
                            lastDay: DateTime(2030),

                            onDaySelected: (selectedDay, _) {
                              showDayDetails(selectedDay);
                            },

                            calendarBuilders:
                                CalendarBuilders(
                              markerBuilder: (context, day, events) {
                                final key = DateTime(
                                    day.year, day.month, day.day);

                                final items = calendar[key];

                                if (items == null) return null;

                                // show FIRST status color
                                final color = statusColor(
                                    items.first['status']);

                                return Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ================= CHART =================
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "📊 Leave Status Overview",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Breakdown of your leave request statuses",
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey),
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            height: 240,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,

                                // 🔥 GRID CLEAN LOOK
                                gridData: FlGridData(show: false),

                                // 🔥 REMOVE BORDER
                                borderData: FlBorderData(show: false),

                                // ================= AXIS LABELS =================
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),

                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),

                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),

                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final style = const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        );

                                        switch (value.toInt()) {
                                          case 0:
                                            return  Text("Pending", style: style);
                                          case 1:
                                            return  Text("Approved", style: style);
                                          case 2:
                                            return  Text("Rejected", style: style);
                                        }

                                        return const Text("");
                                      },
                                    ),
                                  ),
                                ),

                                // ================= BARS =================
                                barGroups: [
                                  _bar(0, count("Pending").toDouble(), Colors.orange),
                                  _bar(1, count("Approved").toDouble(), Colors.green),
                                  _bar(2, count("Rejected").toDouble(), Colors.red),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _stat(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,

          // 🔥 thicker = nicer
          width: 26,

          // 🔥 rounded top bars (modern look)
          borderRadius: BorderRadius.circular(10),

          // 🔥 gradient-like effect
          color: color.withOpacity(0.9),
        ),
      ],
    );
  }
}