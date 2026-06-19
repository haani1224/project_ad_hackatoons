import '../models/attendance.dart';

class AttendanceService {
  final List<Map<String, dynamic>> _mockDatabase = [
    {"id": "1", "date": "12", "day": "Fri", "arrived": "07:25", "left": "17:05", "isLate": false, "status": "Present"},
    {"id": "2", "date": "11", "day": "Thu", "arrived": "07:45", "left": "17:15", "isLate": true, "status": "Present"},
    {"id": "3", "date": "10", "day": "Wed", "arrived": "07:20", "left": "17:00", "isLate": false, "status": "Present"},
  ];

  Future<List<Attendance>> fetchAttendanceLogs(String teacherId, String monthYear) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockDatabase.map((json) => Attendance.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> submitClockIn(String time, String dateStr, String dayStr) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    bool lateCheck = false;
    if (hour > 7 || (hour == 7 && minute > 30)) {
      lateCheck = true;
    }

    final newRecord = {
      "id": DateTime.now().toString(),
      "date": dateStr,
      "day": dayStr,
      "arrived": time,
      "left": "--:--",
      "isLate": lateCheck,
      "status": "Present"
    };

    _mockDatabase.insert(0, newRecord); 
    return newRecord;
  }

  Future<void> submitClockOut(String time) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_mockDatabase.isNotEmpty) {
      _mockDatabase[0]['left'] = time; 
    }
  }
}