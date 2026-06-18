class ReportModel {
  final String id;
  final String referenceNo;
  final String reportType;
  final String description;
  final String status;
  final bool isAnonymous;
  final String reporterId;
  final String? principalRemark;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.referenceNo,
    required this.reportType,
    required this.description,
    required this.status,
    required this.isAnonymous,
    required this.reporterId,
    this.principalRemark,
    required this.createdAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      referenceNo: json['reference_no'],
      reportType: json['report_type'],
      description: json['description'],
      status: json['status'],
      isAnonymous: json['is_anonymous'],
      reporterId: json['reporter_id'],
      principalRemark: json['principal_remark'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference_no': referenceNo,
      'report_type': reportType,
      'description': description,
      'status': status,
      'is_anonymous': isAnonymous,
      'reporter_id': reporterId,
      'principal_remark': principalRemark,
    };
  }
}