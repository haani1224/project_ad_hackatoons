import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/teacher_model.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> register({
    required String icNumber,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final authResult =
        await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (authResult.user == null) {
      throw Exception('Failed to create account');
    }

    final userData = await supabase
        .from('users')
        .insert({
          'auth_user_id': authResult.user!.id,
          'name': fullName,
          'email': email,
          'role': 'teacher',
          'status': 'pending',
        })
        .select()
        .single();

    await supabase
        .from('teacher_records')
        .insert({
          'ic_number': icNumber,
          'user_id': userData['id'],
          'full_name': fullName,
          'email': email,
        });
  }

  Future<TeacherModel?> login(
    String email,
    String password,
  ) async {
    final authResult =
        await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResult.user == null) {
      return null;
    }

    final userData = await supabase
        .from('users')
        .select()
        .eq('auth_user_id', authResult.user!.id)
        .single();

    if (userData['status'] != 'active') {
      await supabase.auth.signOut();

      throw Exception(
        'Your account is awaiting approval.',
      );
    }

    return TeacherModel.fromMap(userData);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}

// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../models/teacher_model.dart';

// class AuthService {
//   final SupabaseClient supabase = Supabase.instance.client;

//   Future<TeacherModel?> login(
//     String email,
//     String password,
//   ) async {

//     final authResult =
//         await supabase.auth.signInWithPassword(
//       email: email,
//       password: password,
//     );

//     final authUser = authResult.user;

//     if (authUser == null) {
//       return null;
//     }

//     print("========== LOGIN DEBUG ==========");
//     print("Auth User ID: ${authUser.id}");
//     print("Email: ${authUser.email}");

//     final rows = await supabase
//         .from('users')
//         .select()
//         .eq('auth_user_id', authUser.id);

//     print("Rows found:");
//     print(rows);

//     if (rows.isEmpty) {
//       throw Exception(
//         'No user record found for this auth account.'
//       );
//     }

//     if (rows.length > 1) {
//       throw Exception(
//         'Multiple users found with same auth_user_id.'
//       );
//     }

//     final userData = rows.first;

//     if (userData['status'] != 'active') {

//       await supabase.auth.signOut();

//       throw Exception(
//         'Account awaiting approval.'
//       );
//     }

//     return TeacherModel.fromMap(userData);
//   }

//   Future<void> logout() async {
//     await supabase.auth.signOut();
//   }
// }