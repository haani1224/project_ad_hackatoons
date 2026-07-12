// lib/models/attendance.dart
class AttendanceLog {
  final DateTime date;
  final String status;
  final String checkIn;
  final String checkOut;

  AttendanceLog({required this.date, required this.status, required this.checkIn, required this.checkOut});

  factory AttendanceLog.fromMap(Map<String, dynamic> map) {
    return AttendanceLog(
      date: DateTime.parse(map['date']),
      status: map['status'],
      checkIn: map['check_in_time'] ?? '-',
      checkOut: map['check_out_time'] ?? '-',
    );
  }
}