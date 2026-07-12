import 'package:supabase_flutter/supabase_flutter.dart';

class AppNotificationService {
  final _supabase = Supabase.instance.client;

  // ==========================================================
  // Generic notification methods
  // ==========================================================

  Future<void> createNotification({
    required String userId,
    required String message,
    required String type,
    String? referenceId,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'message': message,
      'type': type,
      'reference_id': referenceId,
    });
  }

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    final userId = _supabase.auth.currentUser!.id;

    final result = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    final userId = _supabase.auth.currentUser!.id;

    final result = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(result);
  }

  Future<void> markAsRead(String id) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', id);
  }

  Future<void> markAllAsRead() async {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<int> getUnreadCount() async {
    final userId = _supabase.auth.currentUser!.id;

    final result = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);

    return result.length;
  }

  // ==========================================================
  // Principal notifications
  // ==========================================================

  Future<void> notifyPrincipal({
    required String message,
    required String type,
    String? referenceId,
  }) async {
    final principal = await _supabase
        .from('users')
        .select('auth_user_id')
        .eq('role', 'principal')
        .single();

    await createNotification(
      userId: principal['auth_user_id'],
      message: message,
      type: type,
      referenceId: referenceId,
    );
  }

  Future<List<Map<String, dynamic>>> getUnreadPrincipalNotifications() async {
    final principal = await _supabase
        .from('users')
        .select('auth_user_id')
        .eq('role', 'principal')
        .single();

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', principal['auth_user_id'])
        .eq('is_read', false)
        .order('created_at', ascending:false);
    return List<Map<String,dynamic>>.from(data);
  }



  Future<List<Map<String,dynamic>>> getPrincipalNotifications() async {
    final principal = await _supabase
        .from('users')
        .select('auth_user_id')
        .eq('role','principal')
        .single();

    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', principal['auth_user_id'])
        .order('created_at', ascending:false);
    return List<Map<String,dynamic>>.from(data);
  }

  Future<bool> hasPendingDocumentNotification(String teacherId) async {
    final result = await _supabase
        .from('notifications')
        .select()
        .eq('reference_id', teacherId)
        .eq('type', 'document_submission')
        .eq('is_read', false)
        .maybeSingle();

    return result != null;
  }

  Future<void> notifyDocumentSubmission({
    required String teacherId,
    required String teacherName,
  }) async {

    final alreadyNotified =
        await hasPendingDocumentNotification(teacherId);

    if (alreadyNotified) {
      return;
    }

    await notifyPrincipal(
      message:
          "$teacherName has submitted documents for verification.",
      type: "document_submission",
      referenceId: teacherId,
    );
  }

  // ==========================================================
  // Teacher submits training application
  // ==========================================================

  Future<void> notifyTrainingApplication({
    required String teacherName,
    required String trainingTitle,
    required String trainingId,
  }) async {
    await notifyPrincipal(
      message:
          '$teacherName has applied for "$trainingTitle".',
      type: 'training_application',
      referenceId: trainingId,
    );
  }

  // ==========================================================
  // Principal approves / rejects application
  // ==========================================================

  Future<void> notifyTrainingStatusUpdated({
    required String teacherId,
    required String trainingTitle,
    required String status,
    String? rejectionReason,
  }) async {
    String message;

    if (status == 'approved') {
      message =
          'Your application for "$trainingTitle" has been approved.';
    } else if (status == 'rejected') {
      message =
          'Your application for "$trainingTitle" was rejected.'
          '${rejectionReason != null ? '\nReason: $rejectionReason' : ''}';
    } else if (status == 'pending') {
      message =
          'Your application for "$trainingTitle" has been reset to pending review.';
    } else if (status == 'completed') {
      message =
          'Your training "$trainingTitle" has been marked as completed.';
    } else {
      message =
          'Your training "$trainingTitle" status has been updated.';
    }

    await createNotification(
      userId: teacherId,
      message: message,
      type: 'training_status',
    );
  }

  // ==========================================================
  // Principal cancels training
  // ==========================================================

  Future<void> notifyTrainingCancelled({
    required String trainingOptionId,
    required String title,
  }) async {
    final teachers = await _supabase
        .from('trainings')
        .select('teacher_uuid')
        .eq('training_option_id', trainingOptionId);

    for (final teacher in teachers) {
      final teacherId = teacher['teacher_uuid'];

      if (teacherId != null) {
        await createNotification(
          userId: teacherId,
          message:
              'The training "$title" has been cancelled by the principal.',
          type: 'training_cancelled',
          referenceId: trainingOptionId,
        );
      }
    }
  }

  // ==========================================================
  // Teacher submits final report
  // ==========================================================

  Future<void> notifyTrainingCompleted({
    required String teacherName,
    required String trainingTitle,
    required String trainingId,
  }) async {
    await notifyPrincipal(
      message:
          '$teacherName has submitted the report for "$trainingTitle".',
      type: 'training_completed',
      referenceId: trainingId,
    );
  }
}