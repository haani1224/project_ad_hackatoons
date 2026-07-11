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
  bool showBirthdayReminder = false;

  @override
  void initState() {
    super.initState();
    load();
  }

Future<void> load() async {
  try {
    setState(() => loading = true);

    print("Teacher ID = ${widget.teacherId}");

    final data = await repo.getTeacherLeaves(widget.teacherId);

    final Map<DateTime, List<Map<String, dynamic>>> temp = {};

    for (final l in data) {
      final start = DateTime.parse(l['start_date']);
      final end = DateTime.parse(l['end_date']);

      for (
        DateTime d = start;
        !d.isAfter(end);
        d = d.add(const Duration(days: 1))
      ) {
        final key = DateTime(d.year, d.month, d.day);
        temp.putIfAbsent(key, () => []);
        temp[key]!.add(l);
      }
    }

    leaves = data;
    calendar = temp;

    await checkBirthdayReminder();
  } catch (e, stackTrace) {
    debugPrint("LOAD ERROR:");
    debugPrint(e.toString());
    debugPrint(stackTrace.toString());
  } finally {
    if (mounted) {
      setState(() => loading = false);
    }
  }
}

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  Color statusColor(String status) {
    if (status == "Approved") return Colors.green;
    if (status == "Pending") return Colors.orange;
    if (status == "Rejected") return Colors.red;
    return Colors.grey;
  }

  Future<void> checkBirthdayReminder() async {
  print("Checking birthday reminder...");

  final teacher = await repo.getTeacherProfile(widget.teacherId);


  if (teacher == null) {
    showBirthdayReminder = false;
    return;
  }

  final ic = teacher['ic_number'] ?? '';

  if (ic.length < 4) {
    showBirthdayReminder = false;
    return;
  }

  final birthMonth = int.tryParse(ic.substring(2, 4));
  if (birthMonth == null || birthMonth != DateTime.now().month) {
    showBirthdayReminder = false;
    return;
  }

  final alreadyApproved = leaves.any((leave) {
    if (leave['leave_types']?['name'] != 'Birthday Leave') return false;
    if (leave['status'] != 'Approved') return false;

    return DateTime.parse(leave['start_date']).year == DateTime.now().year;
  });
  showBirthdayReminder = !alreadyApproved;
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
                        "${l['start_date']} → ${l['end_date']}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 80, 80, 80),
                        ),
                    ),    
                        
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

backgroundColor: const Color(0xFFF4F6FB),

appBar: AppBar(

backgroundColor: const Color(0xFF2E4365),

elevation: 0,

title: const Text(
  "Leave Management",
  style: TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
),

iconTheme: const IconThemeData(
  color: Colors.white,
),

),


    body: Container(
      color: const Color(0xFFF4F6FB),
      child: loading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : ListView(

        padding: const EdgeInsets.only(
          top: 20,
          left:16,
          right:16,
          bottom:20,
        ),
        children:[
                  // ================= HEADER =================
                  Container(
padding: const EdgeInsets.all(20),

decoration: BoxDecoration(

gradient: const LinearGradient(

colors:[
Color(0xFF2E4365),
Color(0xFF5478B5),
],

begin: Alignment.topLeft,
end: Alignment.bottomRight,

),


borderRadius: BorderRadius.circular(22),


boxShadow:[
BoxShadow(
color: Colors.black.withOpacity(.15),
blurRadius:15,
offset: const Offset(0,8),
)
]

),


child: const Row(

children:[

Icon(
Icons.calendar_month_rounded,
color: Colors.white,
size:40,
),


SizedBox(width:15),


Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children:[

Text(
"Leave Dashboard",
style:TextStyle(
color:Colors.white,
fontSize:22,
fontWeight:FontWeight.bold,
),
),


SizedBox(height:5),


Text(
"Track your leave applications",
style:TextStyle(
color:Colors.white70,
fontSize:13,
),
)

],

)

],

),

),

if (showBirthdayReminder) ...[
  const SizedBox(height: 15),

  Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: Colors.amber.shade400,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const Icon(
          Icons.cake_rounded,
          color: Colors.orange,
          size: 34,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "🎉 It is your Birthday Month!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Celebrate your special month! 🎂\n\n"
                "Don't forget to claim your Birthday Leave before the month ends.",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),

            ],
          ),
        ),
      ],
    ),
  ),
],
                  const SizedBox(height: 15),
                  // ================= STATUS =================
                  Row(
children: [

_stat(
 "Pending",
 count("Pending"),
 Colors.orange,
 Icons.hourglass_top_rounded,
),


_stat(
 "Approved",
 count("Approved"),
 Colors.green,
 Icons.check_circle_rounded,
),


_stat(
 "Rejected",
 count("Rejected"),
 Colors.red,
 Icons.cancel_rounded,
),

],
),

                  const SizedBox(height: 15),

                  // ================= CALENDAR =================
               Card(

elevation:0,

color:Colors.transparent,


child:Container(

padding:const EdgeInsets.all(18),


decoration:BoxDecoration(

color:Colors.white,

borderRadius:
BorderRadius.circular(22),


boxShadow:[

BoxShadow(

color:Colors.black.withOpacity(.08),

blurRadius:18,

offset:
const Offset(0,8),

)

],

),


child:Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


Row(

children:[


Container(

padding:
const EdgeInsets.all(8),


decoration:BoxDecoration(

color:
Color(0xFF2E4365).withOpacity(.12),

shape:
BoxShape.circle,

),


child:const Icon(

Icons.calendar_month_rounded,

color:
Color(0xFF2E4365),

),

),


const SizedBox(width:10),


const Text(

"Leave Calendar",

style:TextStyle(

fontSize:16,

fontWeight:
FontWeight.bold,

),

),


],

),


const SizedBox(height:15),


Row(

children:[

Icon(Icons.circle,
size:10,
color:Colors.green),

SizedBox(width:5),

Text("Approved"),


SizedBox(width:15),


Icon(Icons.circle,
size:10,
color:Colors.orange),

SizedBox(width:5),

Text("Pending"),


SizedBox(width:15),


Icon(Icons.circle,
size:10,
color:Colors.red),

SizedBox(width:5),

Text("Rejected"),

],

),


const SizedBox(height:10),


TableCalendar(

focusedDay:DateTime.now(),
firstDay:DateTime(2020),
lastDay:DateTime(2040),

onDaySelected:(selectedDay,_){showDayDetails(selectedDay);},

availableCalendarFormats: const {
  CalendarFormat.month: 'Month',
},

headerStyle: const HeaderStyle(
  titleCentered: true,
  formatButtonVisible: false,
),

calendarBuilders:
CalendarBuilders(

markerBuilder:
(context,day,events){


final key =
DateTime(
day.year,
day.month,
day.day
);


final items =
calendar[key];


if(items==null)
return null;



return Align(

alignment:
Alignment.bottomCenter,


child:Container(

width:7,

height:7,


decoration:
BoxDecoration(

color:
statusColor(
items.first['status']
),

shape:
BoxShape.circle,

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
  elevation: 0,
  color: Colors.transparent,
  child: Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.08),
          blurRadius: 18,
          offset: const Offset(0,8),
        )
      ],
    ),

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

  Widget _stat(String title, int value, Color color, IconData icon) {
  return Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],

        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),

      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),


          const SizedBox(height: 8),


          Text(
            "$value",

            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),


          Text(
            title,

            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
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

          width: 26,

          borderRadius: BorderRadius.circular(10),

          gradient: LinearGradient(

            colors:[

            color.withOpacity(.5),
            color,

            ],

            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,

            ),
        ),
      ],
    );
  }
}