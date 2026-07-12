import 'package:flutter/material.dart';
import '../../data/repositories/leave_repository.dart';
import 'teacher_leave_type_history.dart';

class TeacherLeaveBalancePage extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveBalancePage({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherLeaveBalancePage> createState() =>
      _TeacherLeaveBalancePageState();
}

class _TeacherLeaveBalancePageState
    extends State<TeacherLeaveBalancePage> {
  final repo = LeaveRepository();

  bool loading = true;
  bool rulesExpanded = false;

  Map<String, int> usedDays = {};

  final Map<String, int> entitlements = {
    'Annual Leave': 8,
    'Medical Leave': 14,
    'Unpaid Leave': 8,
    'Maternity Leave': 98,
    'Marriage Leave': 5,
    'Compassionate Leave': 2,
    'Umrah Leave': 14,
    'Haji Leave': 40,
    'Birthday Leave': 1,
    'Half-Day Leave': 24,
  };

  @override
  void initState() {
    super.initState();
    loadBalance();
  }

  Future<void> loadBalance() async {
    final leaves =
        await repo.getApprovedLeaves(widget.teacherId);

    final Map<String, int> temp = {};

    for (final leave in leaves) {
      final type = leave['leave_types']?['name'] ?? '';
      final days = (leave['total_days'] as num?)?.toInt() ?? 0;

      temp[type] = (temp[type] ?? 0) + days;
    }

    setState(() {
      usedDays = temp;
      loading = false;
    });
  }

  static const Color navy = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bg = Color(0xFFF5F6F8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        title: const Text("Leave Balance"),
        backgroundColor: navy,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // ================= HEADER =================
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [navy, Color(0xFF3A5A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.wallet,
                          color: Colors.white, size: 40),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Your Leave Balance Overview",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ================= RULES (COLLAPSIBLE) =================
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.rule,
                            color: gold),
                        title: const Text(
                          "Leave Rules",
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            rulesExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                          ),
                          onPressed: () {
                            setState(() {
                              rulesExpanded = !rulesExpanded;
                            });
                          },
                        ),
                      ),

                      if (rulesExpanded)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text("🎂 Birthday: Only in birthday month"),
                              SizedBox(height: 6),
                              Text("🏥 Medical: MC required"),
                              SizedBox(height: 6),
                              Text("🕐 Half-Day: Max 2 per month"),
                              SizedBox(height: 6),
                              Text("👶 Maternity: 98 days fixed"),
                              SizedBox(height: 6),
                              Text("💍 Marriage: Max 5 days"),
                              SizedBox(height: 6),
                              Text("🖤 Compassionate: Max 2 days"),
                              SizedBox(height: 6),
                              Text("🕋 Umrah: Max 14 days"),
                              SizedBox(height: 6),
                              Text("🕌 Haji: Max 40 days"),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                // ================= BALANCE LIST =================
                ...entitlements.entries.map((entry) {
                  final type = entry.key;
                  final total = entry.value;
                  final used = usedDays[type] ?? 0;
                  final remaining =
                      (total - used).clamp(0, total);
                  final progress =
                      total == 0 ? 0.0 : remaining / total;

                  Color barColor;

                  if (remaining == 0) {
                    barColor = Colors.red;
                  } else if (remaining <= total * 0.3) {
                    barColor = Colors.orange;
                  } else {
                    barColor = Colors.green;
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.only(bottom: 12),

                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(16),

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                LeaveTypeHistoryPage(
                              teacherId: widget.teacherId,
                              leaveType: type,
                            ),
                          ),
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 8,
                            )
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            // TITLE
                            Row(
                              children: [
                                const Icon(
                                  Icons.event_available,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    type,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // PROGRESS BAR
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor:
                                    Colors.grey.shade200,
                                color: barColor,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // INFO ROW
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Text("Total: $total"),
                                Text(
                                  "Remaining: $remaining",
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: barColor,
                                  ),
                                ),
                                Text("Used: $used"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}