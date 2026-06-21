import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/peer_eval_service.dart';

class PeerEvaluationPage extends StatelessWidget {
  const PeerEvaluationPage({super.key});

  // Palet warna konsisten dengan modul lainnya
  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    // Menggunakan context.watch agar lebih reaktif dan bersih
    final provider = context.watch<PeerEvaluationProvider>();
    final kpi = provider.kpi;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        slivers: [
          // 1. Header Premium (Senada dengan Homepage)
          _buildAppBar(context),

          // 2. Konten Utama
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Communication & Professionalism',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Assess your colleague\'s communication skills and professionalism.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BAGIAN PILIH GURU ---
                  _buildSectionTitle('Target Evaluation'),
                  const SizedBox(height: 10),
                  _buildDropdownCard(provider),

                  const SizedBox(height: 24),

                  // --- BAGIAN CHECKLIST (Hanya muncul jika guru dipilih) ---
                  if (provider.selectedTeacher != null) ...[
                    _buildSectionTitle('Assessment Checklist'),
                    const SizedBox(height: 10),
                    _buildChecklistCard(provider, kpi),
                    
                    const SizedBox(height: 32),

                    // Tombol Submit Premium
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          provider.submitEvaluation();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Evaluation Submitted Successfully!'),
                              backgroundColor: Colors.green.shade600,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: gold.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: const Text(
                          'Submit Assessment',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: navy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Ornamen Lingkaran
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: navyLight.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: gold.withOpacity(0.12),
                ),
              ),
            ),
            // Konten Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.people_alt_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Peer Evaluation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feedback for colleagues & peers',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: navyLight,
      ),
    );
  }

  Widget _buildDropdownCard(PeerEvaluationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: provider.selectedTeacher,
        isExpanded: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.person_search_rounded, color: navyLight),
          hintText: 'Select Teacher to Evaluate',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        items: provider.teacherList.map((String teacher) {
          return DropdownMenuItem<String>(
            value: teacher,
            child: Text(teacher, style: const TextStyle(fontSize: 15, color: navy)),
          );
        }).toList(),
        onChanged: (value) => provider.selectTeacher(value),
      ),
    );
  }

  Widget _buildChecklistCard(PeerEvaluationProvider provider, dynamic kpi) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildSurveyCheckbox(
              title: 'Speaks politely to everyone',
              value: kpi.speaksPolitely,
              onChanged: (val) => provider.toggleChecklist('polite', val ?? false),
            ),
            const Divider(height: 1),
            _buildSurveyCheckbox(
              title: 'Professional in WhatsApp groups',
              value: kpi.respondsProfessionally,
              onChanged: (val) => provider.toggleChecklist('whatsapp', val ?? false),
            ),
            const Divider(height: 1),
            _buildSurveyCheckbox(
              title: 'Works well with team members',
              value: kpi.worksWell,
              onChanged: (val) => provider.toggleChecklist('teamwork', val ?? false),
            ),
            const Divider(height: 1),
            _buildSurveyCheckbox(
              title: 'Accepts feedback positively',
              value: kpi.acceptsFeedback,
              onChanged: (val) => provider.toggleChecklist('feedback', val ?? false),
            ),
            const Divider(height: 1),
            _buildSurveyCheckbox(
              title: 'Maintains professional appearance',
              value: kpi.professionalAppearance,
              onChanged: (val) => provider.toggleChecklist('appearance', val ?? false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: value ? navy : Colors.black87,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: gold,
      checkColor: Colors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}