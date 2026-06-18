import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/training_model.dart';

class TrainingService {
  final _client = Supabase.instance.client;

  Future<void> createTrainingOption(TrainingOption option) async {
    await _client.from('training_options').insert({
      ...option.toMap(),
      'created_by': _client.auth.currentUser!.id,
    });
  }

  Future<void> deleteTrainingOption(String id) async {
    await _client.from('training_options').delete().eq('id', id);
  }

  Future<List<TrainingOption>> getAvailableTrainingOptions(String teacherId) async {
    final applied = await _client
        .from('trainings')
        .select('training_option_id')
        .eq('teacher_id', teacherId);
    final appliedIds = (applied as List).map((e) => e['training_option_id'] as String).toSet();

    final data = await _client
        .from('training_options')
        .select()
        .order('training_date');

    return (data as List)
        .map((e) => TrainingOption.fromMap(e))
        .where((o) => !appliedIds.contains(o.id))
        .toList();
  }

  Future<List<TrainingOption>> getAllTrainingOptions() async {
    final data = await _client
        .from('training_options')
        .select()
        .order('training_date');
    return (data as List).map((e) => TrainingOption.fromMap(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getTrainingOptionsWithApplicants() async {
    try {
      final options = await _client.from('training_options').select().order('training_date');
      final applications = await _client.from('trainings').select('id, teacher_id, training_option_id, status, reflection, certificate_url, photo_urls');
      final teacherRecords = await _client.from('teacher_records').select('user_id, full_name');

      final Map<String, String> nameMap = {
        for (final t in teacherRecords as List)
          t['user_id'] as String: t['full_name'] as String? ?? 'Unknown'
      };

      final appsWithNames = (applications as List).map((app) {
        return {
          ...app as Map<String, dynamic>,
          'teacher_records': {'full_name': nameMap[app['teacher_id']] ?? 'Unknown'},
        };
      }).toList();

      final Map<String, List<Map<String, dynamic>>> grouped = {};
      for (final app in appsWithNames) {
        final optId = app['training_option_id'] as String;
        grouped.putIfAbsent(optId, () => []).add(app);
      }

      return (options as List).map((opt) {
        final apps = grouped[opt['id'] as String] ?? [];
        return {
          ...opt as Map<String, dynamic>,
          'applicants': apps,
          'application_count': apps.length,
          'pending_count': apps.where((a) => a['status'] == 'pending').length,
        };
      }).toList();
    } catch (e, s) {
      debugPrint('getTrainingOptionsWithApplicants error: $e\n$s');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getAllTeachersQuotaProgress(int year) async {
    try {
      final teachers = await _client.from('teacher_records').select('user_id, full_name').order('full_name');
      final approved = await _client.from('trainings').select('teacher_id, training_option_id').inFilter('status', ['approved', 'completed']);
      final optionDates = await _client.from('training_options').select('id, training_date');

      final Map<String, String> dateMap = {
        for (final o in optionDates as List) o['id'] as String: o['training_date'] as String? ?? ''
      };

      final Map<String, int> countMap = {};
      for (final row in approved as List) {
        final optId = row['training_option_id'] as String;
        final date = dateMap[optId] ?? '';
        if (!date.startsWith('$year')) continue;
        final tid = row['teacher_id'] as String;
        countMap[tid] = (countMap[tid] ?? 0) + 1;
      }

      return (teachers as List).map((t) {
        final userId = t['user_id'] as String;
        return {
          'user_id': userId,
          'full_name': t['full_name'] as String? ?? 'Unknown',
          'approved_count': countMap[userId] ?? 0,
        };
      }).toList();
    } catch (e, s) {
      debugPrint('getAllTeachersQuotaProgress error: $e\n$s');
      return [];
    }
  }

  Future<void> applyForTraining({required String teacherId, required String trainingOptionId}) async {
    await _client.from('trainings').insert({
      'teacher_id': teacherId,
      'training_option_id': trainingOptionId,
      'status': 'pending',
    });
  }

  Future<List<TrainingRecord>> getMyTrainings(String teacherId) async {
    try {
      final data = await _client
          .from('trainings')
          .select('*, training_options(*)')
          .eq('teacher_id', teacherId)
          .order('created_at', ascending: false);
      return (data as List).map((e) => TrainingRecord.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e, s) {
      debugPrint('getMyTrainings error: $e\n$s');
      return [];
    }
  }

  Future<List<TrainingRecord>> getAllTrainings() async {
    try {
      final data = await _client
          .from('trainings')
          .select('*, training_options(*), teacher_records(full_name)')
          .order('created_at', ascending: false);
      return (data as List).map((e) => TrainingRecord.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e, s) {
      debugPrint('getAllTrainings error: $e\n$s');
      return [];
    }
  }

  Future<int> getApprovedCountForYear(String teacherId, int year) async {
    final data = await _client
        .from('trainings')
        .select('teacher_id, training_option_id')
        .eq('teacher_id', teacherId)
        .inFilter('status', ['approved', 'completed']);
        
    final optionIds = (data as List).map((e) => e['training_option_id'] as String).toList();
    if (optionIds.isEmpty) return 0;

    final options = await _client.from('training_options').select('id, training_date').inFilter('id', optionIds);
    return (options as List).where((o) => (o['training_date'] as String).startsWith('$year')).length;
  }

  Future<void> updateTrainingStatus(String id, String status) async {
    await _client.from('trainings').update({'status': status}).eq('id', id);
  }

  Future<void> saveTrainingSubmission({
    required String trainingId,
    required String reflection,
    required String? certificateUrl,
    required List<String> photoUrls,
  }) async {
    await _client.from('trainings').update({
      'reflection': reflection,
      'certificate_url': certificateUrl,
      'photo_urls': photoUrls,
      'status': 'completed',
    }).eq('id', trainingId);
  }
}