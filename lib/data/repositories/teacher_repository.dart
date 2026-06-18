import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

class TeacherRepository {
  final supabase = Supabase.instance.client;

  // GET ALL
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
      // // 1. Create Auth User
      // final authRes = await supabase.auth.signUp(
      //   email: email,
      //   password: password,
      // );

      // final userId = authRes.user?.id;

      // if (userId == null) {
      //   return "Auth registration failed";
      // }

      // // 2. Insert into teachers table
      // await supabase.from('teachers').insert({
      //   ...teacher.toMap(),
      //   'user_id': userId,
      //   'role': 'teacher',
      //   'status': 'pending', // 🔥 IMPORTANT for approval system
      // });
      // print("STEP 1");
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