import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  final supabase = Supabase.instance.client;

  Future<String> createReport({
    required String reportType,
    required String description,
    required bool isAnonymous,
    required String reporterId,
  }) async {
    try {
      final referenceNo =
          "RPT-${DateTime.now().millisecondsSinceEpoch}";

      final response = await supabase
          .from('reports')
          .insert({
            'reference_no': referenceNo,
            'report_type': reportType,
            'description': description,
            'status': 'Pending',
            'is_anonymous': isAnonymous,
            'reporter_id': reporterId,
          })
          .select()
          .single();

      final reportId = response['id'];

      print("REPORT ID = $reportId");

      await supabase
      .from('report_timeline')
      .insert({
        'report_id': reportId,
        'action': 'Submitted',
        'remarks': 'Report submitted by teacher',
      });

      print("TIMELINE CREATED");

      return reportId;
    } catch (e) {
      print("ERROR = $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getReportsByUser(
    String userId,
  ) async {
    final response = await supabase
        .from('reports')
        .select()
        .eq('reporter_id', userId)
        .order(
          'created_at',
          ascending: false,
        );

    return response;
  }

  Future<List<dynamic>> getTimeline(
    String reportId,
  ) async {
    final response = await supabase
        .from('report_timeline')
        .select()
        .eq('report_id', reportId)
        .order(
          'created_at',
          ascending: true,
        );

    return response;
  }

  Future<List<dynamic>> getAllReports() async {
      final response = await supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      return response;
    }
    Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String comment,
  }) async {
    await supabase.from('reports').update({
      'status': status,
      'principal_remark': comment,
    }).eq('id', reportId);

    await supabase.from('report_timeline').insert({
      'report_id': reportId,
      'action': status,
      'remarks': comment,
    });
  }
}
