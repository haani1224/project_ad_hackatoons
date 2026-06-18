import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final _storage = Supabase.instance.client.storage;

  Future<String?> uploadTeacherDocument({
    required String userId,
    required String docType,
    String? oldPath,
  }) async {
    try {
      await FilePicker.platform.clearTemporaryFiles();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      );
      if (result == null || result.files.isEmpty) return null;

      final file = File(result.files.first.path!);
      
      if (oldPath != null) {
        try {
          await _storage.from('teacher_documents').remove([oldPath]);
        } catch (_) {}
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = result.files.first.extension;
      final filePath = '$userId/${docType}_$timestamp.$fileExt';

      await _storage.from('teacher_documents').upload(filePath, file);
      return filePath;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  Future<List<String>> getSignedUrls(List<String> paths) async {
    final urls = <String>[];
    for (final p in paths) {
      try {
        final url = await _storage.from('teacher_documents').createSignedUrl(p, 60 * 15);
        urls.add(url);
      } catch (_) {}
    }
    return urls;
  }
  
  Future<String> getDownloadUrl(String path) async {
    return _storage.from('teacher_documents').createSignedUrl(path, 60 * 15);
  }

  Future<void> deleteTeacherDocument({required String path}) async {
    try {
      await _storage.from('teacher_documents').remove([path]);
    } catch (e) {
      debugPrint('Delete error: $e');
    }
  }
}