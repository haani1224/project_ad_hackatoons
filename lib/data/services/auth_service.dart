import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<User?> login(String email, String password) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

      final user = res.user;
      if (user == null) return null;

      final data = await supabase
          .from('teachers')
          .select('status')
          .eq('user_id', user.id)
          .maybeSingle();

      if (data == null || data['status'] != 'approved') {
        await supabase.auth.signOut();
        return null;
      }

      return user;
    }

  Future<String?> getUserRole(String userId) async {
    try {
      final data = await supabase
          .from('teachers')
          .select('role')
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