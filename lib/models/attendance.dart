class Attendance {
  final String id;
  final String date;
  final String day;
  final String arrived;
  final String left;
  final bool isLate;
  final String status;

  Attendance({
    required this.id,
    required this.date,
    required this.day,
    required this.arrived,
    required this.left,
    required this.isLate,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      date: json['date'] as String,
      day: json['day'] as String,
      arrived: json['arrived'] as String,
      left: json['left'] as String,
      isLate: json['isLate'] as bool,
      status: json['status'] as String,
    );
  }
}