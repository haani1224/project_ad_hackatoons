import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<User?> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    return res.user;
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final data = await supabase
          .from('teachers')
          .select('role, status')
          .eq('user_id', userId)
          .single();

      return data['role'];
    } catch (e) {
      return null;
    }
  }

  Future<String?> getUserStatus(String userId) async {
    try {
      final data = await supabase
          .from('teachers')
          .select('status')
          .eq('user_id', userId)
          .single();

      return data['status'];
    } catch (e) {
      return null;
    }
  }
}