import 'package:flutter/material.dart';
import '../models/kpi_assessment.dart';

class PeerEvaluationProvider with ChangeNotifier {
  final List<String> _teacherList = [
    'Tc. Fetty', 'Tc. Siti', 'Tc. Fatin', 'Tc. Sufie', 
    'Tc. Zu', 'Tc. Mira', 'Tc. Nina', 'Tc. Akma'
  ];

  String? _selectedTeacher;
  CommunicationKpi _kpi = CommunicationKpi();

  List<String> get teacherList => _teacherList;
  String? get selectedTeacher => _selectedTeacher;
  CommunicationKpi get kpi => _kpi;

  // teacher dropdown
  void selectTeacher(String? teacherName) {
    _selectedTeacher = teacherName;
    _kpi = CommunicationKpi();
    notifyListeners();
  }

  // checklist
  void toggleChecklist(String category, bool value) {
    switch (category) {
      case 'polite':
        _kpi.speaksPolitely = value;
        break;
      case 'whatsapp':
        _kpi.respondsProfessionally = value;
        break;
      case 'teamwork':
        _kpi.worksWell = value;
        break;
      case 'feedback':
        _kpi.acceptsFeedback = value;
        break;
      case 'appearance':
        _kpi.professionalAppearance = value;
        break;
    }
    notifyListeners();
  }

  void submitEvaluation() {
    // Di sini lu bisa tambahin fungsi save ke database nantinya
    
    // Reset form setelah berhasil submit
    _selectedTeacher = null;
    _kpi = CommunicationKpi();
    notifyListeners();
  }
}