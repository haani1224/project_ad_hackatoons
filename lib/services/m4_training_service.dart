import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/m4_training_model.dart';

class TrainingService {
  final _client = Supabase.instance.client;

  // ─────────────────────────────────────────────
  // TEACHER (UUID ONLY)
  // ─────────────────────────────────────────────

  Future<String?> getTeacherIdFromAuth(String authUid) async {
    final res = await _client
        .from('teacher_records')
        .select('user_id')
        .eq('user_id', authUid)
        .maybeSingle();

    if (res == null) return null;
    return res['user_id'] as String;
  }

  // ─────────────────────────────────────────────
  // TRAINING OPTIONS
  // ─────────────────────────────────────────────

  Future<void> createTrainingOption(TrainingOption option) async {
    await _client.from('training_options').insert({
      ...option.toMap(),
      'created_by': _client.auth.currentUser!.id,
    });
  }

  Future<void> updateTrainingOption(TrainingOption option) async {
    await _client
        .from('training_options')
        .update(option.toMap())
        .eq('id', option.id!);
  }

  Future<void> cancelTrainingOption(String id) async {
    await _client
        .from('training_options')
        .update({'is_cancelled': true})
        .eq('id', id);
  }

  // ─────────────────────────────────────────────
  // AVAILABLE OPTIONS (FIXED UUID)
  // ─────────────────────────────────────────────

  Future<List<TrainingOption>> getAvailableTrainingOptions(String teacherUuid) async {
    final applied = await _client
        .from('trainings')
        .select('training_option_id')
        .eq('teacher_uuid', teacherUuid);    // ← was teacher_id

    final appliedIds = (applied as List)
        .map((e) => e['training_option_id'].toString())
        .toSet();

    final data = await _client
        .from('training_options')
        .select()
        .eq('is_cancelled', false)
        .order('training_date');

    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );
    return (data as List)
        .map((e) => TrainingOption.fromMap(e))
        .where((o) {
          final isNotApplied =
              !appliedIds.contains(o.id.toString());

          final trainingDay = DateTime(
            o.trainingDate.year,
            o.trainingDate.month,
            o.trainingDate.day,
          );

          final isUpcoming =
            trainingDay.isAfter(today);

          return isNotApplied && isUpcoming;
        })
        .toList();
  }

  Future<List<TrainingOption>> getAllTrainingOptions() async {
    final data = await _client
        .from('training_options')
        .select()
        .eq('is_cancelled', false)
        .order('training_date');

    return (data as List)
        .map((e) => TrainingOption.fromMap(e))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAllTeachersQuotaProgress(int year) async {
    try {
      final teachers = await _client
          .from('teacher_records')
          .select('user_id, full_name')
          .order('full_name');

      final approved = await _client
        .from('trainings')
        .select('teacher_uuid, training_option_id')   // ← was teacher_id
        .inFilter('status', ['approved', 'completed']);

      final optionDates = await _client
          .from('training_options')
          .select('id, training_date');

      final Map<String, String> dateMap = {
        for (final o in optionDates as List)
          o['id'].toString(): o['training_date'] as String? ?? ''
      };

      final Map<String, int> countMap = {};

      for (final row in approved as List) {
        final optId = row['training_option_id'].toString();
        final date = dateMap[optId] ?? '';

        final parsed = DateTime.tryParse(date);
        if (parsed == null || parsed.year != year) continue;

        final tid = row['teacher_uuid'].toString();
        countMap[tid] = (countMap[tid] ?? 0) + 1;
      }

      return (teachers as List).map((t) {
        final userId = t['user_id'].toString();

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

  // ─────────────────────────────────────────────
  // OPTIONS + APPLICANTS (UUID FIXED)
  // ─────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getTrainingOptionsWithApplicants() async {
    try {
      final options = await _client
          .from('training_options')
          .select()
          .order('training_date');

      final applications = await _client
        .from('trainings')
        .select('id, teacher_uuid, training_option_id, status, reflection, rejection_reason, certificate_url, photo_urls');

      final teachers = await _client
          .from('teacher_records')
          .select('user_id, full_name');

      final Map<String, String> nameMap = {
        for (final t in teachers as List)
          t['user_id'] as String: t['full_name'] as String? ?? 'Unknown'
      };

      final appsWithNames = (applications as List).map((app) {
        return {
          ...app as Map<String, dynamic>,
          'teacher_records': {
            'full_name': nameMap[app['teacher_uuid']] ?? 'Unknown'
          },
        };
      }).toList();

      final Map<String, List<Map<String, dynamic>>> grouped = {};

      for (final app in appsWithNames) {
        final optId = app['training_option_id'].toString();
        grouped.putIfAbsent(optId, () => []).add(app);
      }

      return (options as List).map((opt) {
        final apps = grouped[opt['id'].toString()] ?? [];

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

  // ─────────────────────────────────────────────
  // MY TRAININGS (FIXED FILTER)
  // ─────────────────────────────────────────────

  Future<List<TrainingRecord>> getMyTrainings(String teacherUuid) async {
    try {
      final data = await _client
          .from('trainings')
          .select('''
            id,
            teacher_id,
            teacher_uuid,
            training_option_id,
            status,
            reflection,
            rejection_reason,
            certificate_url,
            photo_urls,
            created_at,
            training_options (
              id,
              title,
              category,
              training_date,
              duration_hours,
              mode,
              venue,
              organizer,
              meeting_link
            )
          ''')
          .eq('teacher_uuid', teacherUuid)   // ← was teacher_id
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => TrainingRecord.fromMap(e as Map<String, dynamic>))
          .toList();
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

      return (data as List)
          .map((e) => TrainingRecord.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, s) {
      debugPrint('getAllTrainings error: $e\n$s');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // APPLY (UUID FIXED)
  // ─────────────────────────────────────────────

  Future<void> applyForTraining({
    required String teacherUuid,
    required String trainingOptionId,
  }) async {
    await _client.from('trainings').insert({
      'teacher_uuid': teacherUuid,           // ← was teacher_id
      'training_option_id': int.parse(trainingOptionId),
      'status': 'pending',
    });
  }

  // ─────────────────────────────────────────────
  // QUOTA (FIXED UUID)
  // ─────────────────────────────────────────────

  Future<int> getApprovedCountForYear(String teacherUuid, int year) async {
    final data = await _client
        .from('trainings')
        .select('teacher_uuid, training_option_id')
        .eq('teacher_uuid', teacherUuid)     // ← was teacher_id
        .inFilter('status', ['approved', 'completed']);

    final optionIds = (data as List)
        .map((e) => e['training_option_id'].toString())
        .toList();

    if (optionIds.isEmpty) return 0;

    final options = await _client
        .from('training_options')
        .select('id, training_date')
        .inFilter('id', optionIds);

    return (options as List)
        .where((o) => (o['training_date'] as String).startsWith('$year'))
        .length;
  }

  // ─────────────────────────────────────────────
  // STATUS + SUBMISSION
  // ─────────────────────────────────────────────

  Future<void> updateTrainingStatus(
    String id,
    String status, [
    String? rejectionReason,
  ]) async {
    await _client
        .from('trainings')
        .update({
          'status': status,
          'rejection_reason': status == 'rejected'
              ? rejectionReason
              : null,
        })
        .eq('id', id);
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