import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await supabase
        .from('users')
        .select()
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> approveUser(int id) async {
    await supabase
        .from('users')
        .update({'status': 'active'})
        .eq('id', id)
        .select();
  }

  Future<void> rejectUser(int id) async {
    await supabase
        .from('users')
        .update({'status': 'rejected'})
        .eq('id', id)
        .select();
  }

  Future<void> deactivateUser(int id) async {
    await supabase
        .from('users')
        .update({'status': 'inactive'})
        .eq('id', id)
        .select();
  }

  Future<void> deleteUser(int id) async {
    await supabase
        .from('users')
        .delete()
        .eq('id', id);
  }
}