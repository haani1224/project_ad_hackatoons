import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance.dart';

class AttendanceService with ChangeNotifier {
  final _supabase = Supabase.instance.client;
  List<AttendanceLog> _logs = []; 
  bool _isLoading = false;

  List<AttendanceLog> get logs => _logs;
  bool get isLoading => _isLoading;

  AttendanceService() {
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final data = await _supabase
          .from('attendance_logs')
          .select('*')
          .eq('teacher_uuid', user.id)
          .order('date', ascending: false);

      _logs = (data as List).map((json) => AttendanceLog.fromMap(json)).toList();
    } catch (e) {
      debugPrint("Error fetching: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAttendance(String status, String checkIn, String checkOut) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    //insert to Supabase
    await _supabase.from('attendance_logs').insert({
      'teacher_uuid': user.id,
      'date': DateTime.now().toIso8601String(),
      'status': status,
      'check_in_time': checkIn,
      'check_out_time': checkOut,
    });

    await _fetchAttendanceData(); // Refresh list setelah input
  }
}