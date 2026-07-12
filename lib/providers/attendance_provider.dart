// import 'package:flutter/material.dart';
// import '../models/attendance.dart'; // Pastikan path ke model AttendanceLog sudah benar

// class AttendanceService with ChangeNotifier {
//   List<AttendanceLog> _logs = [];
//   bool _isLoaded = false;

//   List<AttendanceLog> get logs => _logs;
//   bool get isLoaded => _isLoaded;

//   // 🟢 Otomatis menghitung total log yang statusnya 'Late'
//   int get totalLateThisMonth {
//     return _logs.where((log) => log.status.toLowerCase() == 'late').length;
//   }

//   AttendanceService() {
//     _loadInitialData();
//   }

//   void _loadInitialData() {
//     Future.delayed(const Duration(seconds: 1), () {
//       _logs = [
//         AttendanceLog(
//           id: '101',
//           date: '21 June 2026',
//           status: 'Present',
//           checkInTime: '07:15',
//           checkOutTime: '16:00',
//         ),
//         AttendanceLog(
//           id: '102',
//           date: '20 June 2026',
//           status: 'Late',
//           checkInTime: '08:05',
//           checkOutTime: '16:00',
//         ),
//         AttendanceLog(
//           id: '103',
//           date: '19 June 2026',
//           status: 'Present',
//           checkInTime: '07:22',
//           checkOutTime: '16:15',
//         ),
//         AttendanceLog(
//           id: '104',
//           date: '18 June 2026',
//           status: 'Late',
//           checkInTime: '07:45',
//           checkOutTime: '16:00',
//         ),
//         AttendanceLog(
//           id: '105',
//           date: '17 June 2026',
//           status: 'Present',
//           checkInTime: '07:10',
//           checkOutTime: '16:00',
//         ),
//       ];
//       _isLoaded = true;
      
//       notifyListeners(); 
//     });
//   }

  
// }