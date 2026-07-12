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
      print("CLICKED");
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;

      // FIX #1: Guard against null bytes before force-unwrapping
      if (file.bytes == null) {
        debugPrint("Upload failed: file bytes are null for '${file.name}'");
        return null;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExt = file.extension;
      final filePath = '$userId/${docType}_$timestamp.$fileExt';

      // FIX #2: Delete old file from storage before uploading the new one
      if (oldPath != null && oldPath.isNotEmpty) {
        try {
          await _storage.from('teacher_documents').remove([oldPath]);
          debugPrint("Old file deleted: $oldPath");
        } catch (e) {
          debugPrint("Warning: could not delete old file '$oldPath': $e");
          // Non-fatal — continue with upload even if old file deletion fails
        }
      }

      final response = await _storage
          .from('teacher_documents')
          .uploadBinary(filePath, file.bytes!);

      print("UPLOAD SUCCESS: $response");

      return filePath;
    } catch (e, st) {
      debugPrint("========== UPLOAD FAILED ==========");
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }

  Future<List<String>> getSignedUrls(List<String> paths) async {
    final urls = <String>[];
    for (final p in paths) {
      try {
        final url = await _storage.from('teacher_documents').createSignedUrl(p, 60 * 15);
        urls.add(url);
      } catch (e) {
        // FIX #5: Log which path failed instead of silently swallowing
        debugPrint("getSignedUrls: failed to sign URL for path '$p': $e");
      }
    }
    return urls;
  }

  // FIX #4: Add error handling so caller gets a proper exception instead of a raw crash
  Future<String> getDownloadUrl(String path) async {
    try {
      return await _storage.from('teacher_documents').createSignedUrl(path, 60 * 15);
    } catch (e) {
      debugPrint("getDownloadUrl failed for path '$path': $e");
      rethrow;
    }
  }

  // FIX #3: Throw on delete failure so callers know it didn't succeed
  Future<void> deleteTeacherDocument({required String path}) async {
    try {
      await _storage.from('teacher_documents').remove([path]);
    } catch (e) {
      debugPrint('Delete error: $e');
      rethrow; // Let the caller decide how to handle this
    }
  }
}