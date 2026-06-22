import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveCalendarHeatmap extends StatefulWidget {
  final List<Map<String, dynamic>> leaves;

  const LeaveCalendarHeatmap({
    super.key,
    required this.leaves,
  });

  @override
  State<LeaveCalendarHeatmap> createState() =>
      _LeaveCalendarHeatmapState();
}

class _LeaveCalendarHeatmapState
    extends State<LeaveCalendarHeatmap> {

  Map<DateTime, List<Map<String, dynamic>>> map = {};

  @override
  void initState() {
    super.initState();
    buildMap();
  }

  @override
  void didUpdateWidget(covariant LeaveCalendarHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    buildMap();
  }

  void buildMap() {
    Map<DateTime, List<Map<String, dynamic>>> temp = {};

    for (final l in widget.leaves) {
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

    setState(() => map = temp);
  }

  Color getColor(int count) {
    if (count >= 5) return Colors.red;
    if (count >= 3) return Colors.orange;
    if (count >= 1) return Colors.green;
    return Colors.grey.shade200;
  }

  String riskText(int count) {
    if (count >= 5) return "⚠ CRITICAL ($count teachers off)";
    if (count >= 3) return "⚠ Medium ($count teachers off)";
    if (count >= 1) return "Safe ($count off)";
    return "No leave";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ================= LEGEND =================
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
              _Legend(color: Colors.red, label: "Critical"),
              _Legend(color: Colors.orange, label: "Medium"),
              _Legend(color: Colors.green, label: "Safe"),
            ],
          ),
        ),

        Expanded(
          child: TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final key = DateTime(day.year, day.month, day.day);
                final list = map[key] ?? [];

                final count = list.length;

                return GestureDetector(
                  onTap: () => showDayDetail(context, day, list),
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: getColor(count),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "${day.day}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void showDayDetail(
    BuildContext context,
    DateTime day,
    List<Map<String, dynamic>> list,
  ) {
    final count = list.length;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "📅 ${day.day}/${day.month}/${day.year}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                riskText(count),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: count >= 5
                      ? Colors.red
                      : count >= 3
                          ? Colors.orange
                          : Colors.green,
                ),
              ),

              const SizedBox(height: 10),

              const Divider(),

              const Text(
                "Teachers on Leave:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (list.isEmpty)
                const Text("No leave on this day"),

              ...list.map((l) {
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Teacher ID: ${l['teacher_id']}"),
                  subtitle:
                      Text(l['leave_types']?['name'] ?? ""),
                  trailing: Text(l['status']),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}