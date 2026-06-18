import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class EvidenceService {
  final String cloudName = "dmgd6lcxd";
  final String uploadPreset = "flutter_upload";

  Future<String?> uploadFile(File file, String type) async {
    try {
      // FIX: normalize Cloudinary resource type
      String resourceType;

      if (type == "image") {
        resourceType = "image";
      } else if (type == "video") {
        resourceType = "video";
      } else {
        resourceType = "raw"; // PDF, docs, etc
      }

      final url = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload",
      );

      final request = http.MultipartRequest("POST", url);

      request.fields['upload_preset'] = uploadPreset;

      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          file.path,
          filename: basename(file.path),
        ),
      );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        print("❌ CLOUDINARY UPLOAD FAILED: $resBody");
        return null;
      }

      final urlResult = RegExp(r'"secure_url":"(.*?)"')
          .firstMatch(resBody)
          ?.group(1);

      print("✅ UPLOAD SUCCESS: $urlResult");

      return urlResult;
    } catch (e) {
      print("❌ UPLOAD ERROR: $e");
      return null;
    }
  }
}