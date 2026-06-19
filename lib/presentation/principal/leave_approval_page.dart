import 'package:flutter/material.dart';

import '../../data/models/leave_model.dart';
import '../../data/repositories/leave_repository.dart';

class LeaveApprovalPage extends StatefulWidget {
  const LeaveApprovalPage({super.key});

  @override
  State<LeaveApprovalPage> createState() =>
      _LeaveApprovalPageState();
}

class _LeaveApprovalPageState
    extends State<LeaveApprovalPage> {

  final repo = LeaveRepository();

  List<LeaveModel> leaves = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadLeaves();
  }

  Future<void> loadLeaves() async {
    final data = await repo.getAllLeaves();

    setState(() {
      leaves = data;
      loading = false;
    });
  }

  Future<void> approve(String id) async {
    await repo.approveLeave(id);
    loadLeaves();
  }

  Future<void> reject(String id) async {
    await repo.rejectLeave(id);
    loadLeaves();
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Leave Approval Dashboard",
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : leaves.isEmpty
              ? const Center(
                  child: Text(
                    "No Leave Requests",
                  ),
                )
              : ListView.builder(
                  itemCount: leaves.length,

                  itemBuilder: (context, index) {

                    final leave = leaves[index];

                    return Card(
                      margin: const EdgeInsets.all(10),

                      child: Padding(
                        padding: const EdgeInsets.all(12),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              "Teacher ID: ${leave.teacherId}",
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Leave Type ID: ${leave.leaveTypeId}",
                            ),

                            Text(
                              "${leave.startDate.toString().split(' ')[0]}"
                              " → "
                              "${leave.endDate.toString().split(' ')[0]}",
                            ),

                            Text(
                              "Days: ${leave.totalDays}",
                            ),

                            if (leave.reason != null &&
                                leave.reason!.isNotEmpty)
                              Text(
                                "Reason: ${leave.reason}",
                              ),

                            const SizedBox(height: 10),

                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),

                              decoration: BoxDecoration(
                                color: statusColor(
                                  leave.status,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                  20,
                                ),
                              ),

                              child: Text(
                                leave.status
                                    .toUpperCase(),
                                style:
                                    const TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            if (leave.status ==
                                "pending")
                              Row(
                                children: [

                                  ElevatedButton(
                                    onPressed: () =>
                                        approve(
                                      leave.id!,
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          Colors.green,
                                    ),
                                    child: const Text(
                                      "Approve",
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 10,
                                  ),

                                  ElevatedButton(
                                    onPressed: () =>
                                        reject(
                                      leave.id!,
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      backgroundColor:
                                          Colors.red,
                                    ),
                                    child: const Text(
                                      "Reject",
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}