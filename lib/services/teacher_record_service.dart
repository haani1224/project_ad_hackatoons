// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/teacher_model.dart';

// class TeacherRecordService {
//   final _client = Supabase.instance.client;

//   Future<TeacherRecord?> getMyRecord(int userId) async {
//     final allRecords = await _client
//         .from('teacher_records')
//         .select();

//     print("ALL RECORDS:");
//     print(allRecords);

//     final data = await _client
//         .from('teacher_records')
//         .select()
//         .eq('user_id', userId)
//         .maybeSingle();

//     print("FILTERED RESULT:");
//     print(data);

//     return data == null ? null : TeacherRecord.fromMap(data);
//   }

//   Future<List<TeacherRecord>> getAllRecords() async {
//     final data = await _client
//         .from('teacher_records')
//         .select()
//         .order('full_name');
//     return (data as List).map((e) => TeacherRecord.fromMap(e)).toList();
//   }

//   Future<void> upsertTeacherRecord(TeacherRecord record) async {
//     await _client
//         .from('teacher_records')
//         .upsert(record.toMap(), onConflict: 'ic_number');
//   }
  
//   Future<void> updateSingleDocStatus({
//     required String icNumber,
//     required String docType,
//     required String? status,
//     String? reason,
//   }) async {
//     final cleanIc = icNumber.trim();
//     var response = await _client
//         .from('teacher_records')
//         .select('document_statuses, user_id')
//         .eq('ic_number', cleanIc)
//         .maybeSingle();

//     if (response == null) {
//       response = await _client
//           .from('teacher_records')
//           .select('document_statuses, user_id')
//           .ilike('ic_number', '%$cleanIc%')
//           .maybeSingle();
//     }

//     if (response == null) {
//       throw Exception("No teacher record found in database matching IC: '$cleanIc'.");
//     }

//     final String targetUserId = response['user_id'];
//     Map<String, dynamic> currentStatuses = Map<String, dynamic>.from(response['document_statuses'] ?? {});
//     currentStatuses[docType] = {
//       'status': status,
//       'reason': reason,
//     };

//     final updateResponse = await _client
//         .from('teacher_records')
//         .update({'document_statuses': currentStatuses})
//         .eq('user_id', targetUserId)
//         .select();

//     if (updateResponse.isEmpty) {
//       throw Exception("Database update rejected! Check RLS policies.");
//     }
//   }

//   Future<void> approveAllDocuments(String icNumber, List<String> docTypes) async {
//     final cleanIc = icNumber.trim();
//     final response = await _client
//         .from('teacher_records')
//         .select('user_id')
//         .ilike('ic_number', '%$cleanIc%')
//         .maybeSingle();

//     if (response == null) {
//       throw Exception("Approve All failed: Could not find teacher record matching IC '$cleanIc'.");
//     }

//     final String targetUserId = response['user_id'];
//     Map<String, dynamic> approvedMap = {};
//     for (var type in docTypes) {
//       approvedMap[type] = {'status': 'approved', 'reason': null};
//     }

//     final updateResponse = await _client
//         .from('teacher_records')
//         .update({'document_statuses': approvedMap})
//         .eq('user_id', targetUserId)
//         .select();

//     if (updateResponse.isEmpty) {
//       throw Exception("Approve All rejected! Check RLS policies.");
//     }
//   }

//   Future<void> updateTeacherDocumentPath({
//     required String userId,
//     required String docType,
//     required String? filePath,
//   }) async {
//     String dbColumn;
//     switch (docType) {
//       case 'mykad': dbColumn = 'doc_mykad_url'; break;
//       case 'passport': dbColumn = 'doc_passport_photo_url'; break;
//       case 'resume': dbColumn = 'doc_resume_url'; break;
//       case 'academic': dbColumn = 'doc_academic_cert_url'; break;
//       case 'medical': dbColumn = 'doc_medical_report_url'; break;
//       case 'bank': dbColumn = 'doc_bank_statement_url'; break;
//       default: throw Exception('Invalid document type');
//     }

//     final record = await _client
//         .from('teacher_records')
//         .select('document_statuses')
//         .eq('user_id', userId)
//         .maybeSingle();

//     Map<String, dynamic> currentStatuses = Map<String, dynamic>.from(record?['document_statuses'] ?? {});
    
//     if (filePath == null || filePath.isEmpty) {
//       currentStatuses.remove(docType);
//       filePath = null;
//     } else {
//       currentStatuses[docType] = {
//         'status': 'pending',
//         'reason': null,
//       };
//     }

//     await _client.from('teacher_records').update({
//       dbColumn: filePath,
//       'document_statuses': currentStatuses,
//     }).eq('user_id', userId);
//   }

//   // ── Notifications ──
//   Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
//     final data = await _client
//         .from('notifications')
//         .select()
//         .eq('user_id', userId)
//         .order('created_at', ascending: false);
//     return List<Map<String, dynamic>>.from(data);
//   }

//   Future<int> getUnreadCount(String userId) async {
//     final data = await _client
//         .from('notifications')
//         .select('id')
//         .eq('user_id', userId)
//         .eq('is_read', false);
//     return (data as List).length;
//   }

//   Future<void> markAllNotificationsRead(String userId) async {
//     await _client
//         .from('notifications')
//         .update({'is_read': true})
//         .eq('user_id', userId);
//   }
// }

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

class TeacherRecordService {
  final _client = Supabase.instance.client;

  Future<TeacherRecord?> getMyRecord(int userId) async {
    // FIX #10: Removed print(allRecords) that leaked all teachers' personal data

    final data = await _client
        .from('teacher_records')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    print("FILTERED RESULT:");
    print(data);

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
      // FIX #7: Use exact match in fallback instead of broad ilike to avoid multi-row ambiguity
      final fallbackResults = await _client
          .from('teacher_records')
          .select('document_statuses, user_id')
          .ilike('ic_number', cleanIc)
          .limit(2);

      if (fallbackResults.isEmpty) {
        throw Exception("No teacher record found in database matching IC: '$cleanIc'.");
      }
      if (fallbackResults.length > 1) {
        throw Exception("Ambiguous IC match: multiple records found for '$cleanIc'. Cannot update safely.");
      }
      response = fallbackResults.first;
    }

    // FIX #6: Safely handle user_id regardless of whether it comes back as int or String
    final targetUserId = response['user_id'].toString();

    Map<String, dynamic> currentStatuses = Map<String, dynamic>.from(response['document_statuses'] ?? {});

    if (status == null) {
      // FIX: If status is null (e.g. after delete), remove the doc entry entirely
      currentStatuses.remove(docType);
    } else {
      currentStatuses[docType] = {
        'status': status,
        'reason': reason,
      };
    }

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
        .select('user_id, document_statuses') // FIX #9: also fetch existing statuses
        .ilike('ic_number', '%$cleanIc%')
        .maybeSingle();

    if (response == null) {
      throw Exception("Approve All failed: Could not find teacher record matching IC '$cleanIc'.");
    }

    // FIX #6: Safely coerce user_id to String
    final targetUserId = response['user_id'].toString();

    // FIX #9: Merge approvals into existing statuses instead of overwriting everything
    Map<String, dynamic> mergedStatuses = Map<String, dynamic>.from(response['document_statuses'] ?? {});
    for (var type in docTypes) {
      mergedStatuses[type] = {'status': 'approved', 'reason': null};
    }

    final updateResponse = await _client
        .from('teacher_records')
        .update({'document_statuses': mergedStatuses})
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

    // FIX #8: Use a local variable instead of reassigning the parameter
    final String? resolvedPath;

    if (filePath == null || filePath.isEmpty) {
      currentStatuses.remove(docType);
      resolvedPath = null;
    } else {
      currentStatuses[docType] = {
        'status': 'pending',
        'reason': null,
      };
      resolvedPath = filePath;
    }

    await _client.from('teacher_records').update({
      dbColumn: resolvedPath,
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