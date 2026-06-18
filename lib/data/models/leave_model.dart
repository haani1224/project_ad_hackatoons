class LeaveModel {
  final String? id;
  final String teacherId;
  final String leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String? reason;
  final String status;

  LeaveModel({
    this.id,
    required this.teacherId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    this.status = "pending",
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      teacherId: json['teacher_id'],
      leaveType: json['leave_type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalDays: json['total_days'],
      reason: json['reason'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher_id': teacherId,
      'leave_type': leaveType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'reason': reason,
      'status': status,
    };
  }
}