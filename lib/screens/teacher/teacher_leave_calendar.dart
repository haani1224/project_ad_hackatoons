import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveCalendarPage extends StatefulWidget {
  final int teacherId;

  const LeaveCalendarPage({
    super.key,
    required this.teacherId,
  });

  @override
  State<LeaveCalendarPage> createState() =>
      _LeaveCalendarPageState();
}

class _LeaveCalendarPageState
    extends State<LeaveCalendarPage> {
  final repo = LeaveRepository();

  Map<DateTime, List<String>> events = {};
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await repo.getTeacherLeaves(widget.teacherId);

    Map<DateTime, List<String>> temp = {};

    for (final l in data) {
      final start = DateTime.parse(l['start_date']);
      final end = DateTime.parse(l['end_date']);

      for (DateTime d = start;
          d.isBefore(end.add(const Duration(days: 1)));
          d = d.add(const Duration(days: 1))) {

        final day = DateTime(d.year, d.month, d.day);

        temp.putIfAbsent(day, () => []);
        temp[day]!.add(l['leave_types']?['name'] ?? '');
      }
    }

    setState(() {
      events = temp;
    });
  }

  List<String> getEvents(DateTime day) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leave Calendar"),
        backgroundColor: const Color(0xFF2E4365),
      ),

      body: TableCalendar(
        focusedDay: focusedDay,
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),

        eventLoader: getEvents,

        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),

        onDaySelected: (selectedDay, _) {
          final leaves = getEvents(selectedDay);

          showModalBottomSheet(
            context: context,
            builder: (_) => Container(
              padding: const EdgeInsets.all(16),
              height: 200,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    "${selectedDay.toLocal()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...leaves.map((e) => Text("• $e")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}