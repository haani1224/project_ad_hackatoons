import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

class TeacherRecordService {
  final _client = Supabase.instance.client;

  Future<TeacherRecord?> getMyRecord(String userId) async {
    final data = await _client
        .from('teacher_records')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return data == null ? null : TeacherRecord.fromMap(data);
  }

  Future<List<TeacherRecord>> getAllRecords() async {
    final data = await _client
        .from('teacher_records')
        .select()
        .order('full_name');
    return (data as List).map((e) => TeacherRecord.fromMap(e)).toList();
  }

  Future<void> upsertTeacherRecord(TeacherRecord record) async {
    await _client
        .from('teacher_records')
        .upsert(record.toMap(), onConflict: 'ic_number');
  }
  
  Future<void> updateSingleDocStatus({
    required String icNumber,
    required String docType,
    required String? status,
    String? reason,
  }) async {
    final cleanIc = icNumber.trim();
    var response = await _client
        .from('teacher_records')
        .select('document_statuses, user_id')
        .eq('ic_number', cleanIc)
        .maybeSingle();

    if (response == null) {
      response = await _client
          .from('teacher_records')
          .select('document_statuses, user_id')
          .ilike('ic_number', '%$cleanIc%')
          .maybeSingle();
    }

    if (response == null) {
      throw Exception("No teacher record found in database matching IC: '$cleanIc'.");
    }

    final String targetUserId = response['user_id'];
    Map<String, dynamic> currentStatuses = Map<String, dynamic>.from(response['document_statuses'] ?? {});
    currentStatuses[docType] = {
      'status': status,
      'reason': reason,
    };

    final updateResponse = await _client
        .from('teacher_records')
        .update({'document_statuses': currentStatuses})
        .eq('user_id', targetUserId)
        .select();

    if (updateResponse.isEmpty) {
      throw Exception("Database update rejected! Check RLS policies.");
    }
  }

  Future<void> approveAllDocuments(String icNumber, List<String> docTypes) async {
    final cleanIc = icNumber.trim();
    final response = await _client
        .from('teacher_records')
        .select('user_id')
        .ilike('ic_number', '%$cleanIc%')
        .maybeSingle();

    if (response == null) {
      throw Exception("Approve All failed: Could not find teacher record matching IC '$cleanIc'.");
    }

    final String targetUserId = response['user_id'];
    Map<String, dynamic> approvedMap = {};
    for (var type in docTypes) {
      approvedMap[type] = {'status': 'approved', 'reason': null};
    }

    final updateResponse = await _client
        .from('teacher_records')
        .update({'document_statuses': approvedMap})
        .eq('user_id', targetUserId)
        .select();

    if (updateResponse.isEmpty) {
      throw Exception("Approve All rejected! Check RLS policies.");
    }
  }

  Future<void> updateTeacherDocumentPath({
    required String userId,
    required String docType,
    required String? filePath,
  }) async {
    String dbColumn;
    switch (docType) {
      case 'mykad': dbColumn = 'doc_mykad_url'; break;
      case 'passport': dbColumn = 'doc_passport_photo_url'; break;
      case 'resume': dbColumn = 'doc_resume_url'; break;
      case 'academic': dbColumn = 'doc_academic_cert_url'; break;
      case 'medical': dbColumn = 'doc_medical_report_url'; break;
      case 'bank': dbColumn = 'doc_bank_statement_url'; break;
      default: throw Exception('Invalid document type');
    }

    final record = await _client
        .from('teacher_records')
        .select('document_statuses')
        .eq('user_id', userId)
        .maybeSingle();

    Map<String, dynamic> currentStatuses = Map<String, dynamic>.from(record?['document_statuses'] ?? {});
    
    if (filePath == null || filePath.isEmpty) {
      currentStatuses.remove(docType);
      filePath = null;
    } else {
      currentStatuses[docType] = {
        'status': 'pending',
        'reason': null,
      };
    }

    await _client.from('teacher_records').update({
      dbColumn: filePath,
      'document_statuses': currentStatuses,
    }).eq('user_id', userId);
  }

  // ── Notifications ──
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final data = await _client
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<int> getUnreadCount(String userId) async {
    final data = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  Future<void> markAllNotificationsRead(String userId) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId);
  }
}