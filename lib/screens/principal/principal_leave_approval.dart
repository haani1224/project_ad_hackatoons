import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'principal_leave_calendar_heatmap.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PrincipalLeaveApproval extends StatefulWidget {
  const PrincipalLeaveApproval({super.key});

  @override
  State<PrincipalLeaveApproval> createState() =>
      _PrincipalLeaveApprovalState();
}

class _PrincipalLeaveApprovalState extends State<PrincipalLeaveApproval> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> leaves = [];
  bool loading = true;

  int tab = 0;
  String selectedStatus = "All";

  @override
  void initState() {
    super.initState();
    fetchLeaves();
  }

  Future fetchLeaves() async {
    setState(() {loading = true;});
    final data = await supabase.from('leave_requests').select('''
          *,
          leave_types(name),
          users!leave_requests_teacher_id_fkey(name)
        ''').order('submitted_date', ascending: false);
    for (final leave in data) {
      if (leave['status'] == "Pending") {
        final result = await validateLeaveRequest(leave);

        if (result['valid'] == false) {
          await supabase.from('leave_requests').update({
                'status': 'Rejected',
                'rejection_reason': result['reason'],
                'approved_date': DateTime.now().toIso8601String(),
              }).eq('id', leave['id']);
        }
      }
    }
    final updated = await supabase.from('leave_requests').select('''
          *,
          leave_types(name),
          users!leave_requests_teacher_id_fkey(name)
        ''').order('submitted_date', ascending: false);
    setState(() {
      leaves = List<Map<String, dynamic>>.from(updated);
      loading = false;
    });
  }

  int count(String status) =>
      leaves.where((e) => e['status'] == status).length;

  Future updateStatus(String id, String status) async {
    await supabase.from('leave_requests').update({
      'status': status,
      'approved_date': status == 'Approved' ? DateTime.now().toIso8601String() : null,
    }).eq('id', id);

    fetchLeaves();
  }

  Future revertToPending(String id) async {
    await supabase.from('leave_requests').update({
          'status': 'Pending',
          'approved_date': null,
          'rejection_reason': null,
        }).eq('id', id);
    fetchLeaves();
  }

  Future<int> getUsedLeaveDays(int teacherId, String leaveType) async {
    final data = await supabase.from('leave_requests').select('''total_days,leave_types(name)''')
    .eq('teacher_id', teacherId)
    .eq('status', 'Approved');
    int used = 0;
    for(var leave in data){
    if(leave['leave_types']['name']== leaveType){
        used += (leave['total_days'] ?? 0) as int;
      }
    }
    return used;
  }

  Future<Map<String, dynamic>> validateLeaveRequest(
    Map<String, dynamic> leave) async {

    final leaveType = leave['leave_types']['name'];
    final start = DateTime.parse(leave['start_date']);
    final end = DateTime.parse(leave['end_date']);
    final totalDays = end.difference(start).inDays + 1;
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

    final entitlement = entitlements[leaveType] ?? 0;
    final used = await getUsedLeaveDays(leave['teacher_id'], leaveType,);
    final remaining = entitlement - used;
    if(totalDays > remaining){
    return {
      "valid":false,
      "reason":
      "Insufficient $leaveType balance. "
      "Remaining balance: $remaining day(s)"
      };
    }
  return {"valid":true};
}

 Future previewAttachment(String path) async {

  try {

    final url = await supabase.storage
        .from('leave-documents')
        .createSignedUrl(
          path,
          300,
        );


    if(path.toLowerCase().endsWith(".pdf")) {


      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {

            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "PDF Attachment",
                ),
                backgroundColor: const Color(0xFF2E4365),
                foregroundColor: Colors.white,
              ),

              body: SfPdfViewer.network(
                url,
                onDocumentLoadFailed: (details) {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                      SnackBar(
                        content: Text(
                          details.description,
                        ),
                      ),
                    );

              },
              ),

            );

          },
        ),
      );


    } else {


      showDialog(
        context: context,
        builder: (_) {

          return Dialog(
            child: InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
              ),
            ),
          );

        },
      );


    }


  } catch(e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text(
              "Cannot open attachment: $e",
            ),
          ),
        );

  }

}

  Future showRejectDialog(Map<String, dynamic> leave) async {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.cancel_rounded,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text("Reject Leave"),
            ],
          ),
          content: TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Enter rejection reason...",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.block),
              label: const Text(
                "Reject",
              ),
              onPressed: () async {
                if(reasonController.text.trim().isEmpty){
                  ScaffoldMessenger.of(context)
                  .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please enter rejection reason",
                      ),
                    ),
                  );
                  return;
                }
                await supabase
                .from('leave_requests')
                .update({
                  'status': 'Rejected',
                  'rejection_reason':
                      reasonController.text.trim(),
                })
                .eq('id', leave['id']);
                Navigator.pop(context);
                fetchLeaves();
              },
            ),
          ],
        );
      },
    );
  }

  int calculateLeaveDays(String start, String end) {

    DateTime startDate = DateTime.parse(start);
    DateTime endDate = DateTime.parse(end);

    return endDate.difference(startDate).inDays + 1;
  }

  String formatDate(String date) {
    final parsed = DateTime.parse(date);

    return "${parsed.day.toString().padLeft(2, '0')}/"
        "${parsed.month.toString().padLeft(2, '0')}/"
        "${parsed.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      appBar: AppBar(
        title: const Text("Leave Management"),
        backgroundColor: const Color(0xFF2E4365),
        foregroundColor: Colors.white,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [

                // ================= TAB =================
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _tab("Overview", 0, Icons.dashboard),
                      _tab("Calendar", 1, Icons.calendar_month),
                      _tab("Insights", 2, Icons.insights),
                    ],
                  ),
                ),

                Expanded(child: _build()),
              ],
            ),
    );
  }

  Widget _build() {
    switch (tab) {

      // ================= OVERVIEW =================
      case 0:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            _header(),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedStatus = "Pending"),
                    child: _kpi("Pending", count("Pending"), Colors.orange),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedStatus = "Approved"),
                    child: _kpi("Approved", count("Approved"), Colors.green),
                  ),
                ),

                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedStatus = "Rejected"),
                    child: _kpi("Rejected", count("Rejected"), Colors.red),
                  ),
                ),
              ],
            ),
                
            const SizedBox(height: 20),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _statusChip("All"),
                      const SizedBox(width: 6),
                      _statusChip("Pending"),
                      const SizedBox(width: 6),
                      _statusChip("Approved"),
                      const SizedBox(width: 6),
                      _statusChip("Rejected"),
                    ],
                  ),
                ),

            const SizedBox(height: 20),

            Text(
              selectedStatus == "All"
                    ? "Leave History"
                    : "$selectedStatus Leave Requests",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...leaves.where((e) => selectedStatus == "All" ? true : e['status'] == selectedStatus).map((l) {
              return Card(
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    l['users']?['name'] ?? "Unknown Teacher",
                    style: const TextStyle(fontWeight: FontWeight.bold,),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l['leave_types']?['name'] ?? "",),
                      const SizedBox(height: 2),
                      Text(
                        "Applied: ${DateTime.parse(l['submitted_date']).day}/${DateTime.parse(l['submitted_date']).month}/${DateTime.parse(l['submitted_date']).year}",
                        style: const TextStyle(fontSize: 11.8),
                      ),
                      Text(
                        "Leave: ${formatDate(l['start_date'])} → ${formatDate(l['end_date'])}",
                        style: const TextStyle(fontSize: 11.8),
                      ),

                      const SizedBox(height: 4),

                    if (l['attachment_path'] != null)
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          previewAttachment(
                            l['attachment_path'],
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 4, bottom: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_file_rounded,
                                size: 14,
                                color: Colors.deepPurple,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Attachment",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${calculateLeaveDays(l['start_date'], l['end_date'])} day(s)",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),

                      if(l['status']=="Rejected" &&
                        l['rejection_reason'] != null)
                        
                        Text(
                          "Reason: ${l['rejection_reason']}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  
                  trailing: l['status'] == "Pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check_circle, color: Colors.green),
                            onPressed: () =>
                                updateStatus(l['id'], "Approved"),
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () =>
                                showRejectDialog(l),
                          ),
                        ],
                      )
                    : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: l['status'] == "Approved"
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: l['status'] == "Approved"
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                l['status'] == "Approved"
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                size: 18,
                                color: l['status'] == "Approved"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l['status'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: l['status'] == "Approved"
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Revert Button
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => revertToPending(l['id']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh_rounded,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Revert",
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
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
            }),
          ],
        );

      // ================= CALENDAR =================
      case 1:
        return LeaveCalendarHeatmap(
           leaves: leaves,
           onApprove: (id) async {await updateStatus(id, "Approved"); },
           onReject: (leave) async {await showRejectDialog(leave);},
        );

      // ================= INSIGHTS (WOW VERSION) =================
      case 2:
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [

            const Text(
              "Leave Insights Dashboard",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            _insightCard(
              "Total Requests",
              leaves.length,
              Icons.list_alt,
              Colors.blue,
            ),

            _insightCard(
              "Pending Workload",
              count("Pending"),
              Icons.hourglass_bottom,
              Colors.orange,
            ),

            _insightCard(
              "Approved Leaves",
              count("Approved"),
              Icons.verified,
              Colors.green,
            ),

            _insightCard(
              "Rejected Leaves",
              count("Rejected"),
              Icons.block,
              Colors.red,
            ),

            const SizedBox(height: 20),

            const Text(
              "Leave Distribution ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            _wowBar("Pending", count("Pending"), Colors.orange),
            _wowBar("Approved", count("Approved"), Colors.green),
            _wowBar("Rejected", count("Rejected"), Colors.red),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: count("Pending") > 10
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    count("Pending") > 10
                        ? Icons.warning
                        : Icons.check_circle,
                    color: count("Pending") > 10
                        ? Colors.red
                        : Colors.green,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      count("Pending") > 10
                          ? "⚠ High workload detected: consider fast approvals"
                          : "✅ Workload stable across staff",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
    return const SizedBox();
  }

  // ================= TAB =================
  Widget _tab(String label, int i, IconData icon) {
    final selected = tab == i;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tab = i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2E4365) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? Colors.white : Colors.grey),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E4365), Color(0xFF4C78A8)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings,
              color: Colors.white, size: 40),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Leave Management Control Center",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ================= KPI =================
  Widget _kpi(String label, int value, Color c) {
    return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                "$value",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: c),
              ),
              Text(label),
            ],
          ),
        ),
    );
  }

  Widget _statusChip(String status) {
    final selected = selectedStatus == status;
    // IconData icon;
    Color color;
    switch (status) {
      case "Pending":
        color = Colors.orange;
        break;
      case "Approved":
        color = Colors.green;
        break;
      case "Rejected":
        color = Colors.red;
        break;
      default:
        color = const Color(0xFF2E4365);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: ChoiceChip(
        label: Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : Colors.grey.shade700,
          ),
        ),
        selected: selected,
        checkmarkColor: Colors.white,
        onSelected: (_) {
          setState(() {
            selectedStatus = status;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: color,
        elevation: selected ? 4 : 1,
        shadowColor: color.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: selected
                ? color
                : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
  // ================= INSIGHT CARD =================
  Widget _insightCard(
      String title, int value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          "$value",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color),
        ),
      ),
    );
  }

  // ================= WOW BAR =================
  Widget _wowBar(String label, int value, Color color) {
    final width = (value * 18).clamp(10, 220).toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Text(
                "($value)",
                style: TextStyle(color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Stack(
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),

              Container(
                height: 16,
                width: width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withOpacity(0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}