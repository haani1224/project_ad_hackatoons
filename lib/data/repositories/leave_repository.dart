import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/leave_model.dart';
import '../models/teacher_model.dart';

class LeaveRepository {
  final supabase = Supabase.instance.client;

  // 🟢 CREATE LEAVE
  Future<String?> applyLeave(LeaveModel leave) async {
    try {
      await supabase.from('leave_requests').insert(leave.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 🟢 GET ALL LEAVES
  Future<List<LeaveModel>> getAllLeaves() async {
    final res = await supabase
        .from('leave_requests')
        .select()
        .order('submitted_date', ascending: false);

    return (res as List)
        .map((e) => LeaveModel.fromMap(e))
        .toList();
  }

  // 🟢 GET BY TEACHER
  Future<List<LeaveModel>> getByTeacher(String teacherId) async {
    final res = await supabase
        .from('leave_requests')
        .select()
        .eq('teacher_id', teacherId);

    return (res as List)
        .map((e) => LeaveModel.fromMap(e))
        .toList();
  }

   // APPROVE LEAVE
  Future<String?> approveLeave(String id) async {
    try {
      await supabase
          .from('leave_requests')
          .update({
            'status': 'approved',
            'approved_date': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // REJECT LEAVE
  Future<String?> rejectLeave(String id) async {
    try {
      await supabase
          .from('leave_requests')
          .update({
            'status': 'rejected',
            'approved_date': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      return null;
    } catch (e) {
      return e.toString();
    }
  }


}
