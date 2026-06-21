import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/classroom_service.dart';

class ClassroomManagementPage extends StatelessWidget {
  const ClassroomManagementPage({super.key});

  // Palet warna senada dengan aplikasi
  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  @override
  Widget build(BuildContext context) {
    // Pakai context.watch biar kodingan lebih clean dari Consumer
    final provider = context.watch<ClassroomProvider>();
    final kpi = provider.kpi;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Header Premium
              _buildAppBar(context),

              // 2. Konten Checklist
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'KPI Checklist',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: navy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please check the items below and upload photo proofs where required.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List Cards
                      _buildKpiCard(
                        title: 'Classroom is clean and organised',
                        value: kpi.isClean,
                        onChanged: (val) => provider.toggleChecklist('clean', val ?? false),
                        requiresProof: true,
                        proofUrl: kpi.cleanProofUrl,
                        onUploadTap: () => provider.uploadProofPhoto('clean', context),
                      ),
                      _buildKpiCard(
                        title: 'Students are well managed',
                        value: kpi.studentsManaged,
                        onChanged: (val) => provider.toggleChecklist('managed', val ?? false),
                        requiresProof: true,
                        proofUrl: kpi.studentsManagedProofUrl,
                        onUploadTap: () => provider.uploadProofPhoto('managed', context),
                      ),
                      _buildKpiCard(
                        title: 'Learning corners are updated',
                        value: kpi.cornersUpdated,
                        onChanged: (val) => provider.toggleChecklist('corners', val ?? false),
                        requiresProof: true,
                        proofUrl: kpi.cornersProofUrl,
                        onUploadTap: () => provider.uploadProofPhoto('corners', context),
                      ),
                      _buildKpiCard(
                        title: 'Safety rules are followed',
                        value: kpi.safetyRules,
                        onChanged: (val) => provider.toggleChecklist('safety', val ?? false),
                      ),
                      _buildKpiCard(
                        title: 'Students line up properly',
                        value: kpi.studentsLineUp,
                        onChanged: (val) => provider.toggleChecklist('lineup', val ?? false),
                      ),

                      const SizedBox(height: 24),
                      
                      // Tombol Save
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.saveClassroomKpi();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Classroom KPI Saved Successfully!'),
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
                          icon: const Icon(Icons.save_rounded, size: 22),
                          label: const Text(
                            'Save Assessment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. Loading Overlay transparan kalau lagi nge-save
          if (provider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: gold),
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
                    child: const Icon(Icons.meeting_room_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Classroom KPI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage and verify classroom standards',
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

  Widget _buildKpiCard({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool requiresProof = false,
    String? proofUrl,
    VoidCallback? onUploadTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: value ? navy : Colors.black87,
              ),
            ),
            value: value,
            onChanged: onChanged,
            activeColor: gold,
            checkColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            controlAffinity: ListTileControlAffinity.leading,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          
          // Kolom Upload Bukti Foto (Cuma muncul kalau dicentang & butuh bukti)
          if (value && requiresProof)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onUploadTap,
                      icon: Icon(
                        proofUrl == null ? Icons.camera_alt_rounded : Icons.cameraswitch_rounded,
                        size: 18,
                        color: proofUrl == null ? navyLight : Colors.grey.shade600,
                      ),
                      label: Text(
                        proofUrl == null ? 'Take Photo Proof' : 'Retake Photo',
                        style: TextStyle(
                          color: proofUrl == null ? navyLight : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(
                          color: proofUrl == null ? navyLight.withOpacity(0.5) : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (proofUrl != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Uploaded',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
        ],
      ),
    );
  }
}