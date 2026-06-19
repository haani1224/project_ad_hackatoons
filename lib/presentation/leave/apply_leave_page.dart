import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/leave_model.dart';
import '../../data/repositories/leave_repository.dart';
import '../../data/models/teacher_model.dart';
import '../../data/services/leave_validation_services.dart';
import '../widgets/app_drawer.dart';

class ApplyLeavePage extends StatefulWidget {
  const ApplyLeavePage({super.key});

  @override
  State<ApplyLeavePage> createState() => _ApplyLeavePageState();
}

class _ApplyLeavePageState extends State<ApplyLeavePage> {
  final repo = LeaveRepository();

  String? selectedLeaveTypeId;
  List<Map<String, dynamic>> leaveTypes = [];

  DateTime? startDate;
  DateTime? endDate;

  final reasonController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchLeaveTypes();
  }

  Future<void> fetchLeaveTypes() async {
    try {
      final res = await Supabase.instance.client
          .from('leave_types')
          .select();

      if (!mounted) return;

      setState(() {
        leaveTypes = List<Map<String, dynamic>>.from(res);
      });
    } catch (e) {
      debugPrint("Error fetching leave types: $e");
    }
  }

  int calculateDays() {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }

  Future pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() => startDate = date);
    }
  }

  Future pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() => endDate = date);
    }
  }

  Future<void> submit() async {
    if (selectedLeaveTypeId == null ||
        startDate == null ||
        endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;

      if (user == null) {
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not logged in")),
        );
        return;
      }

      // ✅ STEP 1: Get FULL teacher record (IMPORTANT FIX)
      final teacherRes = await Supabase.instance.client
          .from('teachers')
          .select()
          .eq('user_id', user.id)
          .single();

      final teacher = TeacherModel.fromMap(teacherRes);
      final teacherId = teacherRes['id'];

      final leave = LeaveModel(
        teacherId: teacherId,
        leaveTypeId: selectedLeaveTypeId!,
        startDate: startDate!,
        endDate: endDate!,
        totalDays: calculateDays(),
        reason: reasonController.text,
      );

      final selectedLeave = leaveTypes.firstWhere(
        (e) => e['id'].toString() == selectedLeaveTypeId,
      );

      final leaveTypeName = selectedLeave['name'];

      // validation
      final validationError =
          LeaveValidationService.validateLeave(
        teacher,
        leave,
        leaveTypeName,
      );

      if (validationError != null) {
        setState(() => loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // submit
      final error = await repo.applyLeave(leave);

      if (!mounted) return;

      setState(() => loading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Leave submitted successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Apply Leave")),

      drawer: const AppDrawer(role: "teacher"),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedLeaveTypeId,
              hint: const Text("Select Leave Type"),
              items: leaveTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['id'].toString(),
                  child: Text(type['name'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLeaveTypeId = value;
                });
              },
            ),

            const SizedBox(height: 12),

            ListTile(
              title: Text(startDate == null
                  ? "Select Start Date"
                  : startDate!.toString().split(" ")[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickStartDate,
            ),

            ListTile(
              title: Text(endDate == null
                  ? "Select End Date"
                  : endDate!.toString().split(" ")[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: pickEndDate,
            ),

            const SizedBox(height: 10),

            Text("Total Days: ${calculateDays()}"),

            const SizedBox(height: 10),

            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: "Reason (optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("SUBMIT LEAVE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}