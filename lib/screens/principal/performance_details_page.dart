import 'package:flutter/material.dart';

class TeacherPerformanceDetailsPage extends StatelessWidget {
  final Map<String, dynamic> teacherData;

  const TeacherPerformanceDetailsPage({super.key, required this.teacherData});

  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    // 1. Ambil data utama
    final String name = teacherData['name'] ?? 'Unknown';
    final String role = teacherData['role'] ?? 'Staff';
    final double kpi = (teacherData['kpi'] ?? 0).toDouble();
    final bool isWarning = kpi < 60;

    // 2. Simulasi Data 6 Kategori (Nanti kalau DB udah siap, ganti kuncinya sesuai nama kolom di Supabase)
    // Logika dummy: Kalau KPI-nya hancur (<60), nilai sub-kategorinya kita bikin kecil juga biar logis pas ngetes UI.
    final double attPunctuality = (teacherData['attendance'] ?? (isWarning ? 55.0 : 85.0)).toDouble();
    final double classManagement = (teacherData['classroom'] ?? (isWarning ? 40.0 : 80.0)).toDouble();
    final double teachingPerf = (teacherData['teaching'] ?? (isWarning ? 50.0 : 88.0)).toDouble();
    final double studentDev = (teacherData['student_dev'] ?? (isWarning ? 60.0 : 75.0)).toDouble();
    final double documentation = (teacherData['documentation'] ?? (isWarning ? 45.0 : 90.0)).toDouble();
    final double communication = (teacherData['communication'] ?? (isWarning ? 65.0 : 82.0)).toDouble();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Teacher Details", style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PROFILE ---
            Container(
              width: double.infinity,
              color: navy,
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: gold,
                    child: Text(name[0], style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(role, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),

            // --- MAIN KPI CARD ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("OVERALL PERFORMANCE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: navy)),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Current KPI Score", style: TextStyle(fontSize: 15)),
                        Text("${kpi.toInt()}%", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: kpi / 100,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(isWarning ? Colors.red : Colors.green),
                      ),
                    ),

                    // WARNING SECTION & BUTTON (Hanya muncul kalau KPI < 60%)
                    if (isWarning) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50, 
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.red),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Critical: Performance is below the 60% threshold. Immediate action is required.", 
                                    style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w600)
                                  )
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.edit_document, size: 18),
                              label: const Text("Issue Warning Letter", style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                // TODO: Arahkan ke halaman form Warning Letter
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Navigating to Warning Letter draft...')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),

            // --- DETAILED METRICS CARD (6 Kategori) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DETAILED KPI METRICS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1, color: navy)),
                    const SizedBox(height: 24),
                    
                    _buildSubKpiRow("Attendance & Punctuality", attPunctuality),
                    _buildSubKpiRow("Classroom Management", classManagement),
                    _buildSubKpiRow("Teaching Performance", teachingPerf),
                    _buildSubKpiRow("Student Development", studentDev),
                    _buildSubKpiRow("Documentation & Records", documentation),
                    _buildSubKpiRow("Communication & Professionalism", communication, isLast: true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER BUAT 6 KATEGORI ---
  Widget _buildSubKpiRow(String title, double value, {bool isLast = false}) {
    // Nentuin warna bar per kategori (Merah kalau < 60, Emas kalau 60-79, Hijau kalau 80+)
    Color barColor;
    if (value < 60) {
      barColor = Colors.red;
    } else if (value >= 80) {
      barColor = Colors.green;
    } else {
      barColor = gold;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
              ),
              Text("${value.toInt()}%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: barColor)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}