import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PeerEvaluatePage extends StatefulWidget {
  const PeerEvaluatePage({super.key});

  @override
  State<PeerEvaluatePage> createState() => _PeerEvaluatePageState();
}

class _PeerEvaluatePageState extends State<PeerEvaluatePage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoadingTeachers = true;

  // Data guru dari Supabase
  List<Map<String, dynamic>> _teachers = [];
  String? _selectedTeacherId; // Kita simpan ID, bukan nama

  double _punctualityScore = 3.0;
  double _teachingScore = 3.0;
  double _teamworkScore = 3.0;

  final TextEditingController _feedbackCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    try {
      // Pastikan nama tabel di bawah sesuai dengan database Anda (misal: 'profiles')
      final data = await _supabase
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'teacher');
          
      setState(() {
        _teachers = List<Map<String, dynamic>>.from(data);
        _isLoadingTeachers = false;
      });
    } catch (e) {
      debugPrint("Error fetching teachers: $e");
      setState(() => _isLoadingTeachers = false);
    }
  }

  Future<void> _submitEvaluation() async {
    if (!_formKey.currentState!.validate() || _selectedTeacherId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih guru dan isi feedback!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Masukkan ke tabel 'evaluations'
      await _supabase.from('evaluations').insert({
        'evaluator_id': _supabase.auth.currentUser!.id,
        'target_teacher_id': _selectedTeacherId,
        'punctuality_score': _punctualityScore.toInt(),
        'teaching_score': _teachingScore.toInt(),
        'teamwork_score': _teamworkScore.toInt(),
        'feedback': _feedbackCtrl.text.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evaluasi berhasil dikirim!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F7),
      appBar: AppBar(
        title: const Text("Evaluate Teacher"),
        backgroundColor: const Color(0xFF1B2E4B),
      ),
      body: _isLoadingTeachers 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildSectionCard(
                    title: "SELECT STAFF",
                    child: DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      items: _teachers.map((t) => DropdownMenuItem <String>(
                        value: t['id'], 
                        child: Text(t['full_name'] ?? 'No Name')
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedTeacherId = val),
                      validator: (val) => val == null ? 'Pilih guru' : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: "METRICS",
                    child: Column(
                      children: [
                        _buildScoringSlider("Punctuality", _punctualityScore, (v) => setState(() => _punctualityScore = v)),
                        _buildScoringSlider("Teaching", _teachingScore, (v) => setState(() => _teachingScore = v)),
                        _buildScoringSlider("Teamwork", _teamworkScore, (v) => setState(() => _teamworkScore = v)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _feedbackCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: "Feedback..."),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitEvaluation,
                    child: _isSubmitting ? const CircularProgressIndicator() : const Text("Submit"),
                  )
                ],
              ),
            ),
          ),
    );
  }

  // Helper methods (biarkan sama seperti versi sebelumnya)
  Widget _buildSectionCard({required String title, required Widget child}) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title), const SizedBox(height: 10), child])
  );

  Widget _buildScoringSlider(String label, double val, Function(double) onChanged) => Column(
    children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(val.toInt().toString())]),
      Slider(value: val, min: 1, max: 5, divisions: 4, onChanged: onChanged),
    ]
  );
}