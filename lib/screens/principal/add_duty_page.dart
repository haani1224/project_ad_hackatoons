import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/teacher_model.dart';
// Sesuaikan import model dan provider duty lu di bawah ini:
// import '../../models/duty_task_model.dart'; 
// import '../../providers/duty_provider.dart';

class AddDutyPage extends StatefulWidget {
  const AddDutyPage({super.key});

  @override
  State<AddDutyPage> createState() => _AddDutyPageState();
}

class _AddDutyPageState extends State<AddDutyPage> {
  // Palet Warna Premium
  static const Color navy = Color(0xFF1B2E4B);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  final _formKey = GlobalKey<FormState>();
  bool _isLoadingTeachers = true;
  bool _isSaving = false;

  List<TeacherModel> _teachers = [];
  
  // Variabel Penampung Input
  TeacherModel? _selectedTeacher;
  String _selectedDay = 'Monday';
  String _proofMode = 'Single Image'; // Default, sesuaikan dengan enum ProofMode lu
  
  final _dutyTypeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final List<String> _proofModes = ['Single Image', 'Checklist'];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  @override
  void dispose() {
    _dutyTypeCtrl.dispose();
    _locationCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  // Tarik data guru dari Supabase buat diisi ke Dropdown
  Future<void> _fetchTeachers() async {
    try {
      final response = await Supabase.instance.client
          .from('users') // Ganti dengan nama tabel lu kalau beda (misal: 'teacher_profiles')
          .select()
          .eq('role', 'teacher')
          .eq('status', 'active'); // Cuma nampilin guru yang aktif

      final List<TeacherModel> loaded = 
          (response as List).map((map) => TeacherModel.fromMap(map)).toList();

      if (mounted) {
        setState(() {
          _teachers = loaded;
          _isLoadingTeachers = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching teachers: $e');
      if (mounted) {
        setState(() => _isLoadingTeachers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load teachers: $e')),
        );
      }
    }
  }

  Future<void> _saveDuty() async {
    if (!_formKey.currentState!.validate() || _selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and select a teacher.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // TODO: Logika save data lu masukin sini.
      // Kalau lu pake Provider, panggil fungsi add-nya:
      // final provider = context.read<DutyProvider>();
      // provider.addTask(
      //   DutyTask(
      //     id: DateTime.now().millisecondsSinceEpoch.toString(), // Atau generate ID dari DB
      //     dutyType: _dutyTypeCtrl.text,
      //     teacherName: _selectedTeacher!.name,
      //     location: _locationCtrl.text,
      //     time: _timeCtrl.text,
      //     day: _selectedDay,
      //     proofMode: _proofMode == 'Checklist' ? ProofMode.checklistImages : ProofMode.singleImage,
      //     // ... dll sesuaikan dengan field model lu
      //   ),
      // );
      
      // Simulasi loading (Hapus ini kalau udah disambungin ke DB beneran)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Duty assigned successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Balik ke halaman sebelumnya
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save duty: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Assign New Duty", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoadingTeachers 
          ? const Center(child: CircularProgressIndicator(color: gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // CARD FORM INPUT
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("DUTY DETAILS"),
                          
                          _buildTextField(
                            label: "Duty Title / Type",
                            controller: _dutyTypeCtrl,
                            hint: "e.g. Morning Gate Duty, Playground",
                            icon: Icons.title_rounded,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildDropdownTeacher(),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: _buildDropdown(
                                  label: "Day",
                                  value: _selectedDay,
                                  items: _days,
                                  onChanged: (val) => setState(() => _selectedDay = val!),
                                  icon: Icons.calendar_today_rounded,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  label: "Time",
                                  controller: _timeCtrl,
                                  hint: "07:30 - 08:00",
                                  icon: Icons.schedule_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            label: "Location",
                            controller: _locationCtrl,
                            hint: "e.g. Main Gate, Hall",
                            icon: Icons.place_outlined,
                          ),
                          const SizedBox(height: 24),

                          _buildSectionTitle("VERIFICATION MODE"),
                          _buildDropdown(
                            label: "Required Proof",
                            value: _proofMode,
                            items: _proofModes,
                            onChanged: (val) => setState(() => _proofMode = val!),
                            icon: Icons.verified_user_outlined,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // TOMBOL SAVE
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: _isSaving ? null : _saveDuty,
                      child: _isSaving 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text("Assign Duty to Staff", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: navy)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownTeacher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Assign To", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: navy)),
        const SizedBox(height: 8),
        DropdownButtonFormField<TeacherModel>(
          value: _selectedTeacher,
          hint: Text("Select a teacher", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: _teachers.map((teacher) {
            return DropdownMenuItem<TeacherModel>(
              value: teacher,
              child: Text(teacher.name, style: const TextStyle(fontSize: 14, color: navy)),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedTeacher = val),
          validator: (val) => val == null ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: navy)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: bgColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14, color: navy)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}