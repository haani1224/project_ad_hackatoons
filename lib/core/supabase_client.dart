import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseClientManager {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://ihfkdslnfkdtrajfkmgj.supabase.co',
      publishableKey: 'sb_publishable_6iT4xy4yxdKV1HZoWik_Cg_QOiwt5TD',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}