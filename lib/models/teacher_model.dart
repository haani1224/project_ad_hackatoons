class TeacherModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'],
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'teacher',
      status: map['status'] ?? 'active',
    );
  }
}

class TeacherRecord {
  final String icNumber;        // ← now the primary identifier
  final int userId;
  final String fullName;
  final String gender;
  final DateTime dateOfBirth;
  final String address;
  final String phoneNumber;
  final String email;
  final String maritalStatus;
  final String emergencyContactName;
  final String emergencyContactRelationship; // ← new
  final String emergencyContactPhone;
  final DateTime? createdAt;

  final String? docMyKadUrl;
  final String? docPassportPhotoUrl;
  final String? docResumeUrl;
  final String? docAcademicCertUrl;
  final String? docMedicalReportUrl;
  final String? docBankStatementUrl;
  final String docStatus;       // 'pending', 'approved', 'change_requested'
  final String? revisionReason;
  final Map<String, dynamic> documentStatuses;

  const TeacherRecord({
    required this.icNumber,
    required this.userId,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.maritalStatus,
    required this.emergencyContactName,
    required this.emergencyContactRelationship,
    required this.emergencyContactPhone,
    this.createdAt,
    this.docMyKadUrl,
    this.docPassportPhotoUrl,
    this.docResumeUrl,
    this.docAcademicCertUrl,
    this.docMedicalReportUrl,
    this.docBankStatementUrl,
    this.docStatus = 'pending',
    this.revisionReason,
    this.documentStatuses = const {},
  });

  factory TeacherRecord.fromMap(Map<String, dynamic> map) => TeacherRecord(
        icNumber: map['ic_number'] as String? ?? '',
        userId: map['user_id'] as int,
        fullName: map['full_name'] as String? ?? '',
        gender: map['gender'] as String? ?? 'Female',
        dateOfBirth: map['date_of_birth'] != null
            ? DateTime.tryParse(map['date_of_birth'] as String) ??
                DateTime(1990)
            : DateTime(1990),
        address: map['address'] as String? ?? '',
        phoneNumber: map['phone_number'] as String? ?? '',
        email: map['email'] as String? ?? '',
        maritalStatus: map['marital_status'] as String? ?? 'Single',
        emergencyContactName:
            map['emergency_contact_name'] as String? ?? '',
        emergencyContactRelationship:
            map['emergency_contact_relationship'] as String? ?? 'Mother',
        emergencyContactPhone:
            map['emergency_contact_phone'] as String? ?? '',
        docMyKadUrl: map['doc_mykad_url'] as String?,
        docPassportPhotoUrl: map['doc_passport_photo_url'] as String?,
        docResumeUrl: map['doc_resume_url'] as String?,
        docAcademicCertUrl: map['doc_academic_cert_url'] as String?,
        docMedicalReportUrl: map['doc_medical_report_url'] as String?,
        docBankStatementUrl: map['doc_bank_statement_url'] as String?,
        documentStatuses: Map<String, dynamic>.from(
            map['document_statuses'] as Map? ?? {}),
        createdAt: map['created_at'] != null
            ? DateTime.tryParse(map['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'ic_number': icNumber,
        'user_id': userId,
        'full_name': fullName,
        'gender': gender,
        'date_of_birth': dateOfBirth.toIso8601String(),
        'address': address,
        'phone_number': phoneNumber,
        'email': email,
        'marital_status': maritalStatus,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_relationship': emergencyContactRelationship,
        'emergency_contact_phone': emergencyContactPhone,
        'doc_mykad_url': docMyKadUrl,
        'doc_passport_photo_url': docPassportPhotoUrl,
        'doc_resume_url': docResumeUrl,
        'doc_academic_cert_url': docAcademicCertUrl,
        'doc_medical_report_url': docMedicalReportUrl,
        'doc_bank_statement_url': docBankStatementUrl,
        'doc_status': docStatus,
        'revision_reason': revisionReason,
        'document_statuses': documentStatuses,
      };
}