import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'evaluate_teachers_page.dart';
import 'performance_details_page.dart';

class TeacherPerformancePage extends StatefulWidget {
  const TeacherPerformancePage({super.key});

  @override
  State<TeacherPerformancePage> createState() => _TeacherPerformancePageState();
}

class _TeacherPerformancePageState extends State<TeacherPerformancePage> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _teachers = [];
  bool _isLoading = true;

  static const Color navy = Color(0xFF1B2E4B);
  static const Color gold = Color(0xFFE59D2C);
  static const Color lightGray = Color(0xFFF0F2F7);

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
  }

  Future<void> _fetchTeacherData() async {
    setState(() => _isLoading = true);
    try {
      final users = await _supabase.from('users').select('id, name, role').eq('role', 'teacher');
      final evaluations = await _supabase.from('evaluations').select('*');

      List<Map<String, dynamic>> processed = [];

      for (var u in users) {
        var tId = u['id'];
        var evals = evaluations.where((e) => e['target_teacher_id'] == tId).toList();
        
        // Logika KPI: Jika tidak ada evaluasi, beri nilai 80.0 sebagai placeholder
        double avgKpi = 80.0; 
        
        if (evals.isNotEmpty) {
          double sum = 0;
          for (var e in evals) {
            double totalScore = ((e['punctuality_score'] ?? 0) + (e['teaching_score'] ?? 0) + 
                                (e['material_score'] ?? 0) + (e['training_score'] ?? 0)).toDouble();
            sum += (totalScore / 20) * 100;
          }
          avgKpi = sum / evals.length;
        }

        // Menambahkan data metric dummy agar PerformanceDetailsPage tidak kosong
        processed.add({
          'id': tId.toString(),
          'name': u['name'] ?? 'No Name',
          'role': u['role'],
          'kpi': avgKpi,
          'attendance': avgKpi, // Placeholder sinkronisasi
          'classroom': avgKpi,
          'teaching': avgKpi,
          'student_dev': avgKpi,
          'documentation': avgKpi,
          'communication': avgKpi,
        });
      }

      setState(() {
        _teachers = processed;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        title: const Text("Staff Performance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: navy,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: navy))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: _teachers.length,
            itemBuilder: (context, index) => _buildTeacherListCard(_teachers[index]),
          ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: gold,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrincipalEvaluatePage())).then((_) => _fetchTeacherData()),
        label: const Text("EVALUATE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        icon: const Icon(Icons.assessment_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildTeacherListCard(Map<String, dynamic> teacher) {
    final double kpi = (teacher['kpi'] ?? 80.0).toDouble();
    final bool isWarning = kpi < 60;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: navy.withOpacity(0.1),
          child: Text(teacher['name'][0], style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
        ),
        title: Text(teacher['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: navy)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: kpi / 100,
              backgroundColor: Colors.grey.shade200,
              color: isWarning ? Colors.red : gold,
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
        trailing: Text("${kpi.toInt()}%", style: TextStyle(fontWeight: FontWeight.w900, color: isWarning ? Colors.red : navy, fontSize: 16)),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PerformanceDetailsPage(teacherData: teacher)));
        },
      ),
    );
  }
}