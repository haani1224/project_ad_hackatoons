import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class LeaveCalendarHeatmap extends StatefulWidget {
  final List<Map<String, dynamic>> leaves;
  final Future<void> Function(String id)? onApprove;
  final Future<void> Function(Map<String, dynamic>)? onReject;  

  const LeaveCalendarHeatmap({
    super.key,
    required this.leaves,
    this.onApprove,
    this.onReject,
  });

  @override
  State<LeaveCalendarHeatmap> createState() =>
      _LeaveCalendarHeatmapState();
}

class _LeaveCalendarHeatmapState
    extends State<LeaveCalendarHeatmap> {

  Map<DateTime, List<Map<String, dynamic>>> map = {};
  Map<DateTime, List<Map<String, dynamic>>> pendingMap = {};

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

  List<Map<String, dynamic>> leavesForDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return map[key] ?? [];
  }

  Map<DateTime, List<Map<String, dynamic>>> leavesThisWeek() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 6));
    final result = <DateTime, List<Map<String, dynamic>>>{};

    for (final entry in map.entries) {
      if (!entry.key.isBefore(start) &&
          !entry.key.isAfter(end)) {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  void buildMap() {
      final approved = <DateTime, List<Map<String, dynamic>>>{};
      final pending = <DateTime, List<Map<String, dynamic>>>{};

      for (final l in widget.leaves) {

        final start = DateTime.parse(l['start_date']);
        final end = DateTime.parse(l['end_date']);

        for (
          DateTime d = start;
          !d.isAfter(end);
          d = d.add(const Duration(days: 1))
        ) {

          final key = DateTime(d.year, d.month, d.day);

          if (l['status'] == "Approved") {
            approved.putIfAbsent(key, () => []);
            approved[key]!.add(l);
          }

          if (l['status'] == "Pending") {
            pending.putIfAbsent(key, () => []);
            pending[key]!.add(l);
          }
        }
      }

      setState(() {
        map = approved;
        pendingMap = pending;
      });
  }

  Color getColor(int count) {
    if (count >= 5) return const Color(0xFFF8BBD0);
    if (count >= 3) return const Color(0xFFD1C4E9);
    if (count >= 1) return const Color(0xFFBBDEFB);
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
    return SingleChildScrollView(
      child: Column(
        children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const _Legend(color:  Color(0xFFF8BBD0), label: "Critical"),
              const _Legend(color:  Color(0xFFD1C4E9), label: "Medium"),
              const _Legend(color:  Color(0xFFBBDEFB), label: "Safe"),
              const _Legend(color:  Colors.orangeAccent, label: "Pending"),
              
            ],
          ),
        ),

        TableCalendar(
            focusedDay: DateTime.now(),
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            headerStyle: const HeaderStyle(formatButtonVisible: false,titleCentered: true,),

            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) {
                final key = DateTime(day.year, day.month, day.day);
                final approvedList = map[key] ?? [];

                final count = approvedList.length;

                return GestureDetector(
                  onTap: () => showDayDetail(context,day,),
                  child: Stack(
                  children: [

                    Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: getColor(count),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          "${day.day}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    if ((pendingMap[key] ?? []).isNotEmpty)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.orangeAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                );
              },
            ),
          ),
        const SizedBox(height: 16),
        _buildSchedulePanel(),
        const SizedBox(height: 20),
      ],
     ),
    );
  }

  Widget _buildSchedulePanel() {
    final today = DateTime.now();
    final tomorrow =today.add(const Duration(days: 1));
    final week = leavesThisWeek();
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),

      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const Text(
            "Leave Schedule",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _daySection(
            "Today",
            today,
            leavesForDay(today),
          ),
          const SizedBox(height: 18),
          _daySection(
            "Tomorrow",
            tomorrow,
            leavesForDay(tomorrow),
          ),
          const SizedBox(height: 18),
          const Text(
            "Upcoming Leaves",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          ...(() {
              final sortedWeek = week.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));

              return sortedWeek.map((entry) {

                if (entry.key.day == today.day) {
                  return const SizedBox();
                }

                if (entry.key.day == tomorrow.day) {
                  return const SizedBox();
                }

                return _weekTile(
                  entry.key,
                  entry.value,
                );

              }).toList();
            })(),
        ],
      ),
    );
  }

  Widget _daySection(
    String title,
    DateTime day,
    List<Map<String, dynamic>> list,
  ) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title • ${day.day}/${day.month}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Text(
                "No teachers on leave",
              ),
            ),

          ...list.map((leave) {
            return Card(
              elevation: 0,
              color: Colors.grey.shade100,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text(
                  leave['users']?['name'] ??
                      "Unknown Teacher",
                ),
                subtitle: Text(
                  leave['leave_types']?['name'] ?? "",
                ),
              ),
            );
          }),
        ],
      );
    }

  Widget _weekTile(
    DateTime day,
    List<Map<String, dynamic>> list,
  ) {
      return ExpansionTile(
        title: Text(
          "${day.day}/${day.month}",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text("${list.length} teacher(s) on leave",),
        children: list.map((leave) {
          return ListTile(
            dense: true,
            leading: const Icon(Icons.person),
            title: Text(leave['users']?['name'] ?? "Unknown Teacher",),
            subtitle: Text(leave['leave_types']?['name'] ?? "",),
          );
        }).toList(),
      );
    }

    Widget _sectionTitle(
        String title,
        IconData icon,
        Color color,
        ){

        return Row(
        children:[
        Icon(icon,color:color),
        const SizedBox(width:8),

        Text(
        title,
        style:const TextStyle(
        fontSize:17,
        fontWeight:FontWeight.bold,
        ),
        ),

        ],
        );

        }



        Widget _emptyCard(String text){

        return Container(
        margin:const EdgeInsets.only(top:10),
        padding:const EdgeInsets.all(16),

        decoration:BoxDecoration(
        color:Colors.white,
        borderRadius:BorderRadius.circular(16),
        ),

        child:Text(
        text,
        style:TextStyle(
        color:Colors.grey.shade600,
        ),
        ),

        );

        }



        Widget _modernTeacherCard(
        Map<String,dynamic> leave,
        Color color,
        IconData icon,
        String status,
        Widget? action,
        ){

        return Container(
        margin:const EdgeInsets.only(top:10),

        padding:const EdgeInsets.all(14),

        decoration:BoxDecoration(
        color:Colors.white,
        borderRadius:BorderRadius.circular(18),

        boxShadow:[
        BoxShadow(
        color:Colors.black.withOpacity(.05),
        blurRadius:10,
        )
        ],

        ),

        child:Row(
        children:[
          CircleAvatar(
            backgroundColor:
            color.withOpacity(.15),
            child:Icon(
              icon,
              color:color,
            ),
          ),
          const SizedBox(width:12),
          Expanded(
          child:Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

        children:[
            Text(
              leave['users']?['name']??"Unknown Teacher",
              style:const TextStyle(
                fontWeight:FontWeight.bold,
              ),
            ),

            const SizedBox(height:4),

            Text(
              leave['leave_types']?['name']??"",
              style:TextStyle(
                color:Colors.grey.shade600,
              ),
            ),
            ],
            ),
            ),

            if(action!=null)
            action
            else

            Container(
            padding:
            const EdgeInsets.symmetric(
            horizontal:10,
            vertical:5,
            ),

            decoration:BoxDecoration(
            color:color.withOpacity(.12),
            borderRadius:
            BorderRadius.circular(20),
            ),

            child:Text(
              status,
              style:TextStyle(
                color:color,
                fontWeight:FontWeight.bold,
                fontSize:12,
              ),
            ),

         )
        ],
     ),
   );
  }


  void showDayDetail(
    BuildContext context,
    DateTime day,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {

        DateTime selectedDay = day;

        return StatefulBuilder(
          builder: (context, setModalState) {

            final key = DateTime(
              selectedDay.year,
              selectedDay.month,
              selectedDay.day,
            );

            final approved = map[key] ?? [];
            final pending = pendingMap[key] ?? [];

            final count = approved.length;

            return Container(
              height: MediaQuery.of(context).size.height * .78,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FC),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              child: Column(
                children: [

                  // Drag handle
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),


                  // ================= HEADER =================
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF2E4365),
                          Color(0xFF4C78A8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Row(
                      children: [

                        IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                          ),

                          onPressed: () {
                            setModalState(() {
                              selectedDay =
                                  selectedDay.subtract(
                                    const Duration(days:1),
                                  );
                            });
                          },
                        ),

                        Expanded(
                          child: Column(
                            children: [

                              Text(
                                "${selectedDay.day}/${selectedDay.month}/${selectedDay.year}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height:6),

                              Text(
                                count == 0
                                ? "No approved leave"
                                : "$count teacher(s) on leave",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(.8),
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),

                          onPressed: () {
                            setModalState(() {
                              selectedDay =
                                  selectedDay.add(
                                    const Duration(days:1),
                                  );
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal:16,
                      ),

                      children: [

                        // ================= RISK CARD =================

                        Container(
                          padding: const EdgeInsets.all(16),

                          decoration: BoxDecoration(
                            color:
                            count >=5 ? Color(0xFFF8BBD0)
                            : count >=3 ? Color(0xFFD1C4E9)
                            : Color(0xFFBBDEFB),

                            borderRadius:
                            BorderRadius.circular(18),
                          ),


                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  riskText(count),

                                  style: const TextStyle(
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize:15,
                                  ),
                                ),
                              )

                            ],
                          ),
                        ),


                        const SizedBox(height:20),

                        _sectionTitle(
                            "Teacher On Leave",
                            Icons.person_off_rounded,
                            Colors.blue,
                          ),

                        if(approved.isEmpty)
                          _emptyCard(
                            "No approved leave",
                          ),


                        ...approved.map(
                          (l)=>_modernTeacherCard(
                            l,
                            Colors.green,
                            Icons.check_circle,
                            "Approved",
                            null,
                          ),
                        ),



                        const SizedBox(height:20),



                        _sectionTitle(
                          "Pending Applications",
                          Icons.pending_actions,
                          Colors.orange,
                        ),



                        if(pending.isEmpty)
                          _emptyCard(
                            "No pending applications",
                          ),



                        ...pending.map(
                          (l)=>_modernTeacherCard(
                            l,
                            Colors.orange,
                            Icons.pending,
                            "Pending",
                            Row(
                              children: [

                                IconButton(
                                  icon: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),

                                  onPressed:() async {

                                    await widget.onApprove
                                        ?.call(l['id']);

                                    buildMap();

                                    setModalState((){});
                                  },
                                ),


                                IconButton(
                                  icon: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),

                                  onPressed:() async {

                                    await widget.onReject
                                        ?.call(l);

                                    buildMap();

                                    setModalState((){});
                                  },
                                ),

                              ],
                            ),
                          ),
                        ),


                      ],
                    ),
                  ),

                ],
              ),
            );
          },
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