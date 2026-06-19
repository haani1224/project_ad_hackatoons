import 'package:flutter/material.dart';
import '../models/attendance.dart';

class AttendanceProvider with ChangeNotifier {
  List<Attendance> _logs = [];
  bool _isLoaded = false;

  List<Attendance> get logs => _logs;
  bool get isLoaded => _isLoaded;
  bool get hasClockedInToday {
    if (_logs.isEmpty) return false;
    final today = DateTime.now();
    final lastLogDate = DateTime.parse(_logs.first.date);
    return lastLogDate.year == today.year &&
        lastLogDate.month == today.month &&
        lastLogDate.day == today.day;
  }
  int get totalLateThisMonth {
    return _logs.where((log) => log.isLate).length;
  }

  AttendanceProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    Future.delayed(const Duration(seconds: 1), () {
      _logs = [
        Attendance(id: '1', date: '18 June 2026', day: 'Monday', arrived: '07:20', left: '17:00', isLate: false, status: 'Present'),
        Attendance(id: '2', date: '17 June 2026', day: 'Sunday', arrived: '07:45', left: '17:15', isLate: true, status: 'Late'),
        Attendance(id: '3', date: '16 June 2026', day: 'Saturday', arrived: '07:15', left: '17:00', isLate: false, status: 'Present'),
        Attendance(id: '4', date: '15 June 2026', day: 'Friday', arrived: '08:00', left: '17:30', isLate: true, status: 'Late'),
      ];
      _isLoaded = true;
      notifyListeners();
    });
  }
}