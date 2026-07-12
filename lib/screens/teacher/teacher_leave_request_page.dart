import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class TeacherLeaveRequestPage extends StatefulWidget {
  final int teacherId;

  const TeacherLeaveRequestPage({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherLeaveRequestPage> createState() =>
      _TeacherLeaveRequestPageState();
}

class _TeacherLeaveRequestPageState
    extends State<TeacherLeaveRequestPage> {
  final supabase = Supabase.instance.client;

  DateTime? startDate;
  DateTime? endDate;

  final reasonController = TextEditingController();

  List<Map<String, dynamic>> leaveTypes = [];
  String? selectedLeaveType;

  File? attachmentFile;
  String? attachmentName;

  bool loading = false;

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  int get totalDays {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  @override
  void initState() {
    super.initState();
    fetchLeaveTypes();
  }

  Future<void> fetchLeaveTypes() async {
    final data = await supabase.from('leave_types').select();

    setState(() {
      leaveTypes = List<Map<String, dynamic>>.from(data);
    });
  }

  Future<void> pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        startDate = date;
        if (endDate != null && endDate!.isBefore(date)) {
          endDate = null;
        }
      });
    }
  }

  Future<void> pickEndDate() async {
    if (startDate == null) return;

    final date = await showDatePicker(
      context: context,
      initialDate: startDate!,
      firstDate: startDate!,
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() => endDate = date);
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        attachmentFile = File(result.files.single.path!);
        attachmentName = result.files.single.name;
      });
    }
  }

  Future<void> submitLeave() async {
    if (selectedLeaveType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select leave type")),
      );
      return;
    }

    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select dates")),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("End date cannot be before start date"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      String? filePath;
      if (attachmentFile != null) {
        final fileName =
            "${widget.teacherId}_${DateTime.now().millisecondsSinceEpoch}_$attachmentName";
        await supabase.storage
            .from('leave-documents')
            .upload(
              fileName,
              attachmentFile!,
            );
        filePath = fileName;
      }

      await supabase.from('leave_requests').insert({
        'teacher_id': widget.teacherId,
        'leave_type_id': selectedLeaveType,
        'start_date': startDate!.toIso8601String(),
        'end_date': endDate!.toIso8601String(),
        'total_days': totalDays,
        'reason': reasonController.text,
        'attachment_path': filePath,
        'status': 'Pending',
        'submitted_date': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Leave submitted successfully")),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ================= UI COLORS =================
  static const Color bg = Color(0xFFF6F7FB);
  static const Color navy = Color(0xFF2E4365);

  static const Color gold = Color(0xFFE59D2C);
  static const Color lightGold = Color(0xFFF3D58D);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [lightGold, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        title: const Text("Apply Leave"),
        backgroundColor: navy,
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= LEAVE TYPE =================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Leave Type",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: selectedLeaveType,
                    items: leaveTypes.map((type) {
                      return DropdownMenuItem(
                        value: type['id'].toString(),
                        child: Text(type['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedLeaveType = value);
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================= DATE =================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Dates",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  _dateTile("Start Date", startDate, pickStartDate),
                  const SizedBox(height: 10),
                  _dateTile("End Date", endDate, pickEndDate),

                  const SizedBox(height: 12),

                  if (startDate != null && endDate != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "Selected: ${formatDate(startDate!)} → ${formatDate(endDate!)} ($totalDays days)",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: navy,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================= ATTACHMENT =================
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Attachment (MC / Letter / Proof)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton.icon(
                    onPressed: pickFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload File"),
                  ),

                  if (attachmentName != null)
                    Text(
                      "Selected: $attachmentName",
                      style: const TextStyle(color: Colors.green),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ================= REASON =================
            _card(
              child: TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Reason",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= SUBMIT =================
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: goldGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading ? null : submitLeave,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Leave",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CARD WIDGET =================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }

  // ================= DATE TILE =================
  Widget _dateTile(String title, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(
              date == null ? "Select" : formatDate(date),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}