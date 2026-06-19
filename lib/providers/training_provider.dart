import 'package:flutter/material.dart';
import '../models/training.dart';

class TrainingProvider with ChangeNotifier {
  List<TrainingHistory> _history = [];
  TrainingKpi _kpi = TrainingKpi();
  bool _isLoaded = false;

  List<TrainingHistory> get history => _history;
  TrainingKpi get kpi => _kpi;
  bool get isLoaded => _isLoaded;

  int get totalTrainingThisYear => _history.length;
  bool get hasMetMinimum => totalTrainingThisYear >= 3;

  TrainingProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    Future.delayed(const Duration(seconds: 1), () {
      _history = [
        TrainingHistory(
          id: '1',
          title: 'Effective Classroom Management',
          date: '12 May 2026',
          organizer: 'KPM Johor',
          category: 'Classroom Management',
        ),
        TrainingHistory(
          id: '2',
          title: 'First Aid for Toddlers',
          date: '03 March 2026',
          organizer: 'Red Crescent Society',
          category: 'Safety and First Aid',
        ),
        TrainingHistory(
          id: '3',
          title: 'Creative Islamic Teaching',
          date: '15 January 2026',
          organizer: 'Tadika Aqil Miqail',
          category: 'Islamic Education',
        ),
      ];
      
      if (hasMetMinimum) {
        _kpi.attendRequired = true;
      }
      
      _isLoaded = true;
      notifyListeners();
    });
  }

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