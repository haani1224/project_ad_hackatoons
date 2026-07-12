import 'package:supabase_flutter/supabase_flutter.dart';

class LeaveRepository {
  final supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> streamTeacherLeaves(int teacherId) {
    return supabase
        .from('leave_requests')
        .stream(primaryKey: ['id'])
        .eq('teacher_id', teacherId)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<List<Map<String, dynamic>>> getLeaveTypes() async {
    final data =
        await supabase.from('leave_types').select();

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> getTeacherProfile(int teacherId) async {
    final data = await supabase
        .from('teacher_records')
        .select('ic_number')
        .eq('system_user_id', teacherId)
        .maybeSingle();

    return data;
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

    Future<List<Map<String, dynamic>>> getApprovedLeaves(
      int teacherId,
    ) async {
      final data = await supabase
          .from('leave_requests')
          .select('''
            total_days,
            leave_types(name,total_days)
          ''')
          .eq('teacher_id', teacherId)
          .eq('status', 'Approved');

      return List<Map<String, dynamic>>.from(data);
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
}