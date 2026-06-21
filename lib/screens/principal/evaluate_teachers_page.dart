import 'package:flutter/material.dart';

class PeerEvaluatePage extends StatefulWidget {
  const PeerEvaluatePage({super.key});

  @override
  State<PeerEvaluatePage> createState() => _PeerEvaluatePageState();
}

class _PeerEvaluatePageState extends State<PeerEvaluatePage> {
  // --- PALET WARNA KONSISTEN ---
  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // DUMMY DATA GURU BUAT DROPDOWN (Bisa diganti pakai narik data 'users' dari Supabase)
  final List<String> _teachers = [
    'Sarah Jane',
    'Michael Wong',
    'Ahmad Rizal',
    'Jessica Lin',
    'David Lee'
  ];
  String? _selectedTeacher;

  // State buat nyimpen nilai slider (Range 1.0 - 5.0)
  double _punctualityScore = 3.0;
  double _teachingScore = 3.0;
  double _teamworkScore = 3.0;

  final TextEditingController _feedbackCtrl = TextEditingController();

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  // Logika saat tombol submit ditekan
  Future<void> _submitEvaluation() async {
    if (!_formKey.currentState!.validate() || _selectedTeacher == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a teacher and provide feedback."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Logika Insert ke tabel Supabase (misal: 'evaluations' atau 'kpi_records') masuk sini
      
      // Simulasi loading server (Hapus ini kalau udah pakai kode Supabase asli)
      await Future.delayed(const Duration(seconds: 1)); 

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evaluation submitted successfully!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Balik ke halaman Performance Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to submit: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Evaluate Teacher", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. CARD PILIH GURU
              _buildSectionCard(
                title: "SELECT STAFF",
                child: DropdownButtonFormField<String>(
                  value: _selectedTeacher,
                  hint: Text("Choose a teacher to evaluate", style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade400),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline, color: Colors.grey.shade400, size: 20),
                    filled: true,
                    fillColor: bgColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: _teachers.map((name) {
                    return DropdownMenuItem<String>(
                      value: name,
                      child: Text(name, style: const TextStyle(fontSize: 14, color: navy)),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedTeacher = val),
                  validator: (val) => val == null ? 'Required' : null,
                ),
              ),
              const SizedBox(height: 24),

              // 2. CARD SCORING METRICS
              _buildSectionCard(
                title: "PERFORMANCE METRICS (1-5)",
                child: Column(
                  children: [
                    _buildScoringSlider(
                      label: "Punctuality & Discipline",
                      value: _punctualityScore,
                      onChanged: (val) => setState(() => _punctualityScore = val),
                    ),
                    const Divider(height: 30),
                    _buildScoringSlider(
                      label: "Pedagogical / Teaching Skills",
                      value: _teachingScore,
                      onChanged: (val) => setState(() => _teachingScore = val),
                    ),
                    const Divider(height: 30),
                    _buildScoringSlider(
                      label: "Teamwork & Communication",
                      value: _teamworkScore,
                      onChanged: (val) => setState(() => _teamworkScore = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. CARD FEEDBACK
              _buildSectionCard(
                title: "CONSTRUCTIVE FEEDBACK",
                child: TextFormField(
                  controller: _feedbackCtrl,
                  maxLines: 4,
                  validator: (val) => val == null || val.isEmpty ? 'Feedback is required' : null,
                  decoration: InputDecoration(
                    hintText: "Provide detailed feedback on the teacher's performance...",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    filled: true,
                    fillColor: bgColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // TOMBOL SUBMIT EVALUATION
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isSubmitting ? null : _submitEvaluation,
                child: _isSubmitting 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Submit Evaluation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER UI ---

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildScoringSlider({required String label, required double value, required Function(double) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: navy)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: navyLight.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(
                value.toInt().toString(), // Nampilin skor bulet tanpa .0
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: navy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: gold,
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: navy,
            overlayColor: gold.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 1.0,
            max: 5.0,
            divisions: 4, // Bikin detakannya cuma di angka 1, 2, 3, 4, 5
            label: value.toInt().toString(),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Needs Work", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            Text("Excellent", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
          ],
        )
      ],
    );
  }
}