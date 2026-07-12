class LeaveTypeModel {
  final String id;
  final String name;
  final int totalDays;

  LeaveTypeModel({
    required this.id,
    required this.name,
    required this.totalDays,
  });

  factory LeaveTypeModel.fromMap(Map<String, dynamic> map) {
    return LeaveTypeModel(
      id: map["id"],
      name: map["name"],
      totalDays: map["total_days"],
    );
  }
}