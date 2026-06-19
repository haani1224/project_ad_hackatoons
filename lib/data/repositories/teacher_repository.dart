import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

class TeacherRepository {
  final supabase = Supabase.instance.client;

  // GET ALL
  Future<List<Map<String, dynamic>>> getAllLeaves() async {
    final res = await supabase
        .from('leave_requests')
        .select('''
          id,
          start_date,
          end_date,
          total_days,
          status,
          reason,
          teachers(full_name),
          leave_types(name)
        ''')
        .order('start_date', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<TeacherModel>> getTeachers() async {
    final res = await supabase.from('teachers').select();

    return (res as List)
        .map((e) => TeacherModel.fromMap(e))
        .toList();
  }

  // ADD TEACHER (AUTH + PROFILE)
  Future<String?> registerTeacher({
    required String email,
    required String password,
    required TeacherModel teacher,
  }) async {
    try {
     
      final authRes = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      // print("STEP 2");

      await supabase.from('teachers').insert({
        ...teacher.toMap(),
        'user_id': authRes.user!.id,
        'role': 'teacher',
        'status': 'pending',
      });
      // print("STEP 3");

            return null;
          } catch (e) {
            return e.toString();
          }
        }

  // UPDATE STATUS (APPROVE/REJECT)
  Future updateTeacherStatus(String id, String status) async {
    await supabase
        .from('teachers')
        .update({'status': status})
        .eq('id', id);
  }

  // UPDATE
  Future updateTeacher(String id, TeacherModel teacher) async {
    await supabase
        .from('teachers')
        .update(teacher.toMap())
        .eq('id', id);
  }

  // DELETE
  Future deleteTeacher(String id) async {
    await supabase.from('teachers').delete().eq('id', id);
  }
}