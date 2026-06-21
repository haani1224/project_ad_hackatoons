import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/leave_model.dart';
// import '../models/teacher_model.dart';

class LeaveRepository {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    final data =
        await supabase.from('leave_types').select();

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> applyLeave(
      Map<String, dynamic> leaveData) async {
    await supabase
        .from('leave_requests')
        .insert(leaveData);
  }

 Future<List<Map<String, dynamic>>> getTeacherLeaves(
    int teacherId,
  ) async {
    final data = await supabase
        .from('leave_requests')
        .select('''
          *,
          leave_types(name,total_days)
        ''')
        .eq('teacher_id', teacherId)
        .order(
          'submitted_date',
          ascending: false,
        );

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>>
      getAllLeaveRequests() async {
    final data = await supabase
        .from('leave_requests')
        .select('''
          *,
          leave_types(name,total_days)
        ''')
        .order('submitted_date',
            ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> approveLeave(
      String leaveId,
      String principalName) async {
    await supabase
        .from('leave_requests')
        .update({
      "status": "Approved",
      "approver_name": principalName,
      "approved_date":
          DateTime.now().toIso8601String(),
    }).eq("id", leaveId);
  }

  Future<void> rejectLeave(
      String leaveId,
      String reason,
      String principalName) async {
    await supabase
        .from('leave_requests')
        .update({
      "status": "Rejected",
      "approver_name": principalName,
      "rejection_reason": reason,
    }).eq("id", leaveId);
  }

  Future<Map<String, int>> getLeaveBalance(int teacherId) async {
  final data = await supabase
      .from('leave_requests')
      .select('''
        total_days,
        status,
        leave_types(name)
      ''')
      .eq('teacher_id', teacherId)
      .eq('status', 'Approved');

  int annual = 0;
  int medical = 0;
  int emergency = 0;

  for (final d in data) {
    final type = d['leave_types']?['name'];
    final days = (d['total_days'] ?? 0) as int;

    if (type == 'Annual Leave') {
      annual += days;
    } else if (type == 'Medical Leave') {
      medical += days;
    } else if (type == 'Emergency Leave') {
      emergency += days;
    }
  }

  return {
    'annual_used': annual,
    'medical_used': medical,
    'emergency_used': emergency,
  };
}

  // //  CREATE LEAVE
  // Future<String?> applyLeave(LeaveModel leave) async {
  //   try {
  //     await supabase.from('leave_requests').insert(leave.toMap());
  //     return null;
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

  // //  GET ALL LEAVES
  //     Future<List<Map<String, dynamic>>> getAllLeaves() async {
  //       final res = await supabase
  //           .from('leaves')
  //           .select('''
  //             *,
  //             teachers(full_name),
  //             leave_types(name)
  //           ''')
  //           .order('created_at', ascending: false);

  //       return List<Map<String, dynamic>>.from(res);
  //     }

  //   Future<List<Map<String, dynamic>>> getLeavesForApproval() async {
  //   final res = await Supabase.instance.client
  //       .from('leaves')
  //       .select('''
  //         id,
  //         start_date,
  //         end_date,
  //         total_days,
  //         reason,
  //         status,
  //         teachers(full_name),
  //         leave_types(name)
  //       ''')
  //       .order('created_at', ascending: false);

  //   return List<Map<String, dynamic>>.from(res);
  // }

  // // GET BY TEACHER
  // Future<List<LeaveModel>> getByTeacher(String teacherId) async {
  //   final res = await supabase
  //       .from('leave_requests')
  //       .select()
  //       .eq('teacher_id', teacherId);

  //   return (res as List)
  //       .map((e) => LeaveModel.fromMap(e))
  //       .toList();
  // }

  //  // APPROVE LEAVE
  // Future<String?> approveLeave(String id) async {
  //   try {
  //     await supabase
  //         .from('leave_requests')
  //         .update({
  //           'status': 'approved',
  //           'approved_date': DateTime.now().toIso8601String(),
  //         })
  //         .eq('id', id);

  //     return null;
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

  // // REJECT LEAVE
  // Future<String?> rejectLeave(String id) async {
  //   try {
  //     await supabase
  //         .from('leave_requests')
  //         .update({
  //           'status': 'rejected',
  //           'approved_date': DateTime.now().toIso8601String(),
  //         })
  //         .eq('id', id);

  //     return null;
  //   } catch (e) {
  //     return e.toString();
  //   }
  // }

}
