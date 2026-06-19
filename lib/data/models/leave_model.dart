class LeaveModel {
  final String? id;
  final String teacherId;
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String? reason;
  final String status;

  LeaveModel({
    this.id,
    required this.teacherId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    this.status = "pending",
  });

  factory LeaveModel.fromMap(Map<String, dynamic> json) {
    return LeaveModel(
      id: json['id'],
      teacherId: json['teacher_id'],
      leaveTypeId: json['leave_type_id'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      totalDays: json['total_days'] ?? 0,
      reason: json['reason'],
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teacher_id': teacherId,
      'leave_type_id': leaveTypeId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_days': totalDays,
      'reason': reason,
      'status': status,
    };
  }
}