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
      Future<List<Map<String, dynamic>>> getAllLeaves() async {
        final res = await supabase
            .from('leaves')
            .select('''
              *,
              teachers(full_name),
              leave_types(name)
            ''')
            .order('created_at', ascending: false);

        return List<Map<String, dynamic>>.from(res);
      }

    Future<List<Map<String, dynamic>>> getLeavesForApproval() async {
    final res = await Supabase.instance.client
        .from('leaves')
        .select('''
          id,
          start_date,
          end_date,
          total_days,
          reason,
          status,
          teachers(full_name),
          leave_types(name)
        ''')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
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
