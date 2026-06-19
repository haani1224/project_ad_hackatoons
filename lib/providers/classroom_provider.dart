import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/classroom_kpi.dart';

class ClassroomProvider with ChangeNotifier {
  ClassroomKpi _kpi = ClassroomKpi();
  bool _isLoading = false;

  ClassroomKpi get kpi => _kpi;
  bool get isLoading => _isLoading;

  void toggleChecklist(String category, bool value) {
    switch (category) {
      case 'clean':
        _kpi.isClean = value;
        break;
      case 'managed':
        _kpi.studentsManaged = value;
        break;
      case 'corners':
        _kpi.cornersUpdated = value;
        break;
      case 'safety':
        _kpi.safetyRules = value;
        break;
      case 'lineup':
        _kpi.studentsLineUp = value;
        break;
    }
    notifyListeners();
  }

  Future<void> uploadProofPhoto(String category, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);

    if (image == null) return; 

    _isLoading = true;
    notifyListeners();

    try {
      final File file = File(image.path);
      final String fileExt = image.path.split('.').last;
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final String filePath = 'classroom/$fileName';

      await Supabase.instance.client.storage
          .from('kpi_proofs')
          .upload(filePath, file);

      final String publicUrl = Supabase.instance.client.storage
          .from('kpi_proofs')
          .getPublicUrl(filePath);

      if (category == 'clean') _kpi.cleanProofUrl = publicUrl;
      if (category == 'managed') _kpi.studentsManagedProofUrl = publicUrl;
      if (category == 'corners') _kpi.cornersProofUrl = publicUrl;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proof uploaded successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveClassroomKpi() async {
  }
}