import 'package:flutter/material.dart';
import '../models/m4_training_model.dart'; // Pastikan path ini bener ngarah ke model lu

// 🟢 Class KPI ditaruh di sini aja biar file model utama tetep bersih
class TrainingKpi {
  bool attendRequired;
  bool appliesKnowledge;
  bool sharesLearning;
  bool improvesSkills;

  TrainingKpi({
    this.attendRequired = false,
    this.appliesKnowledge = false,
    this.sharesLearning = false,
    this.improvesSkills = false,
  });
}

// 🟢 Pastikan nama class-nya TrainingService, biar klop sama UI lu
class TrainingService with ChangeNotifier {
  List<TrainingRecord> _history = [];
  TrainingKpi _kpi = TrainingKpi();
  bool _isLoaded = false;

  // --- GETTER (Ini yang dipanggil sama provider.history, provider.isLoaded, dll di UI) ---
  List<TrainingRecord> get history => _history;
  TrainingKpi get kpi => _kpi;
  bool get isLoaded => _isLoaded;

  int get totalTrainingThisYear => _history.length;
  bool get hasMetMinimum => totalTrainingThisYear >= 3;

  TrainingService() {
    _loadInitialData();
  }

  void _loadInitialData() {
    Future.delayed(const Duration(seconds: 1), () {
      // 🟢 Simulasi data dummy dibikin sesuai format baku di TrainingRecord
      _history = [
        TrainingRecord(
          id: '2702323276',
          teacherId: 1,
          trainingOptionId: 101,
          title: 'Effective Classroom Management',
          category: 'Classroom Management',
          organizer: 'KPM Johor',
          trainingDate: DateTime(2026, 5, 12),
          durationHours: 4.0,
          mode: 'Offline',
          venue: 'Dewan KPM',
          status: 'completed',
        ),
        TrainingRecord(
          id: '2703457336',
          teacherId: 1,
          trainingOptionId: 102,
          title: 'First Aid for Toddlers',
          category: 'Safety and First Aid',
          organizer: 'Red Crescent Society',
          trainingDate: DateTime(2026, 3, 3),
          durationHours: 6.0,
          mode: 'Offline',
          venue: 'School Hall',
          status: 'completed',
        ),
        TrainingRecord(
          id: '2704568447',
          teacherId: 1,
          trainingOptionId: 103,
          title: 'Creative Islamic Teaching',
          category: 'Islamic Education',
          organizer: 'Tadika Aqil Miqail',
          trainingDate: DateTime(2026, 1, 15),
          durationHours: 3.5,
          mode: 'Online',
          venue: 'Zoom',
          status: 'completed',
        ),
      ];
      
      if (hasMetMinimum) {
        _kpi.attendRequired = true;
      }
      
      _isLoaded = true;
      notifyListeners();
    });
  }

  // --- FUNGSI (Ini yang dipanggil pas checkbox di-klik) ---
  void toggleChecklist(String category, bool value) {
    switch (category) {
      case 'attend':
        _kpi.attendRequired = value;
        break;
      case 'applies':
        _kpi.appliesKnowledge = value;
        break;
      case 'shares':
        _kpi.sharesLearning = value;
        break;
      case 'improves':
        _kpi.improvesSkills = value;
        break;
    }
    notifyListeners();
  }
}