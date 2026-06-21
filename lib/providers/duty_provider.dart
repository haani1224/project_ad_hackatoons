import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/duty_task_model.dart'; // Pastikan nama file model lu bener

class DutyProvider extends ChangeNotifier {
  String _selectedDay = 'Monday';
  final List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  String get selectedDay => _selectedDay;

  // Siapin mesin kamera buat upload bukti
  final ImagePicker _picker = ImagePicker();

  // --- DATA DUMMY TUGAS MENGGUNAKAN MODEL BARU ---
  final List<DutyTask> _allTasks = [
    // --- MONDAY ---
    DutyTask(
      id: 1,
      dutyType: 'Cleaning Duty',
      location: 'Classroom',
      teacherId: 1,
      teacherName: 'John Doe',
      teacherEmail: 'teacher@example.com',
      day: 'Monday',
      time: '13:00 PM - 14:30 PM',
      proofMode: ProofMode.checklistImages,
      checklist: [
        'Sweep the classroom floor',
        'Mop the classroom floor',
        'Wipe students’ table and chair',
        'Arrange table and chairs neatly',
        'Clean and wipe the whiteboard',
        'Organize teaching material and toys properly',
        'Arrange books and files properly',
        'Empty rubbish bins',
        'Wipe shelves, cabinets, windows, door',
        'Ensure classroom smells fresh and clean',
        'Switch off all electrical plugs, lights, air-conditioner',
      ],
      checklistProofImages: {},
    ),
    DutyTask(
      id: 2,
      dutyType: 'Morning Gate Duty',
      location: 'Main Gate',
      teacherId: 1,
      teacherName: 'John Doe',
      teacherEmail: 'teacher@example.com',
      day: 'Monday',
      time: '07:00 AM - 07:30 AM',
      proofMode: ProofMode.singleImage, // Tugas yang cuma butuh 1 foto
      singleProofImageUrl: '',
    ),

    // --- TUESDAY ---
    DutyTask(
      id: 3,
      dutyType: 'Cleaning Duty',
      location: 'Assembly Hall',
      teacherId: 1,
      teacherName: 'John Doe',
      teacherEmail: 'teacher@example.com',
      day: 'Tuesday',
      time: '13:00 PM - 14:30 PM',
      proofMode: ProofMode.checklistImages,
      checklist: [
        'Sweep the assembly hall floor',
        'Mop the assembly hall floor',
        'Arrange chair and table at teacher’s corner neatly',
        'Clean the tables at assembly hall',
        'Empty dustbins',
        'Arrange mic and audio equipment properly',
        'Clean and rearrange toys at Play Area',
        'Clean the trolleys at the assembly hall',
        'Switch off all lights and air conditioners',
      ],
      checklistProofImages: {},
    ),

    // --- WEDNESDAY ---
    DutyTask(
      id: 4,
      dutyType: 'Cleaning Duty',
      location: 'Dining Area',
      teacherId: 1,
      teacherName: 'John Doe',
      teacherEmail: 'teacher@example.com',
      day: 'Wednesday',
      time: '13:00 PM - 14:30 PM',
      proofMode: ProofMode.checklistImages,
      checklist: [
        'Sweep the dining area floor',
        'Mop the dining area floor',
        'Wipe and sanitize dining tables',
        'Arrange chairs neatly',
        'Empty the dirty dishes trolley',
        'Clean and empty main and students’ sinks',
        'Wipe student’s mirror',
        'Wash and dry the cleaning cloths',
        'Refill hand and dish soap',
        'Empty rubbish bin',
      ],
      checklistProofImages: {},
    ),

    // --- THURSDAY ---
    DutyTask(
      id: 5,
      dutyType: 'Cleaning Duty',
      location: 'Nap Room & Stairs',
      teacherId: 1,
      teacherName: 'John Doe',
      teacherEmail: 'teacher@example.com',
      day: 'Thursday',
      time: '13:00 PM - 14:30 PM',
      proofMode: ProofMode.checklistImages,
      checklist: [
        'Fold student’s blanket neatly',
        'Place the student’s blanket and pillow into their bags',
        'Store the mattresses neatly in the storeroom',
        'Sweep the stairs area',
        'Mop the stairs carefully',
        'Wipe stair handrails clean',
        'Arrange shoes neatly if any',
      ],
      checklistProofImages: {},
    ),

    // --- FRIDAY ---
    DutyTask(
      id: 6,
      dutyType: 'Cleaning Duty',
      location: 'Toilet',
      teacherId: 1,
      teacherName: 'John Doe',
      teacherEmail: 'teacher@example.com',
      day: 'Friday',
      time: '13:00 PM - 14:30 PM',
      proofMode: ProofMode.checklistImages,
      checklist: [
        'Flush all toilets properly',
        'Clean toilet bowls thoroughly',
        'Scrub and disinfect the toilet floor',
        'Refill hand soap',
        'Clean toilet doors',
        'Ensure buckets and cleaning tools are arrange neatly',
        'Arrange the slippers neatly',
        'Ensure there are no items left on the floor',
      ],
      checklistProofImages: {},
    ),
  ];

  // Data History (Kosongin dulu nggak apa-apa atau pakai ini buat dummy view)
  final List<Map<String, dynamic>> _historyLogs = [
    {'date': '19 June 2026', 'title': 'Toilet Duty', 'status': 'Completed'},
    {'date': '18 June 2026', 'title': 'Nap Room & Stairs Duty', 'status': 'Completed'},
    {'date': '17 June 2026', 'title': 'Dining Area Duty', 'status': 'Completed'},
  ];

  // --- GETTER ---
  List<DutyTask> get currentTasks => 
      _allTasks.where((task) => task.day == _selectedDay).toList();
      
  List<Map<String, dynamic>> get historyLogs => _historyLogs;

  // --- FUNGSI GANTI HARI ---
  void changeDay(String day) {
    _selectedDay = day;
    notifyListeners();
  }

  // --- FUNGSI UPLOAD FOTO CHECKLIST ---
  Future<void> uploadChecklistProof(DutyTask task, int checklistIndex) async {
    try {
      // Buka kamera HP (kasih quality 50 biar memori nggak cepet penuh)
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      
      // Kalau user batal jepret foto (klik tombol back)
      if (photo == null) return; 

      // TODO: Kodingan asli buat nyimpen ke Supabase Storage nanti ditaruh di sini
      // final bytes = await photo.readAsBytes();
      // await Supabase.instance.client.storage.from('duty_proofs').uploadBinary(photo.name, bytes);

      // Simulasi Lokal biar UI kecentang:
      task.checklistProofImages[checklistIndex] = photo.path; 
      notifyListeners();

    } catch (e) {
      print("Error buka kamera: $e");
    }
  }

  // --- FUNGSI UPLOAD FOTO SINGLE ---
  Future<void> uploadSingleProof(DutyTask task) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      
      if (photo == null) return;

      // Simulasi Lokal:
      task.singleProofImageUrl = photo.path; 
      notifyListeners();

    } catch (e) {
      print("Error buka kamera: $e");
    }
  }
}