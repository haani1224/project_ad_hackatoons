class LeaveRequestModel {
  final String? id;
  final int teacherId;
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final String? reason;
  final String? attachmentPath;
  final String status;

  LeaveRequestModel({
    this.id,
    required this.teacherId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    this.reason,
    this.attachmentPath,
    this.status = "Pending",
  });

  Map<String, dynamic> toMap() {
    return {
      "teacher_id": teacherId,
      "leave_type_id": leaveTypeId,
      "start_date": startDate.toIso8601String(),
      "end_date": endDate.toIso8601String(),
      "total_days": totalDays,
      "reason": reason,
      "attachment_path": attachmentPath,
      "status": status,
    };
  }
}