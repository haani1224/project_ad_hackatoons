import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/classroom_provider.dart';

class ClassroomManagementPage extends StatelessWidget {
  const ClassroomManagementPage({super.key});

  Widget buildKpiCard({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool requiresProof = false,
    String? proofUrl,
    VoidCallback? onUploadTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            
            if (value && requiresProof)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onUploadTap,
                        icon: const Icon(Icons.camera_alt),
                        label: Text(proofUrl == null ? 'Take Photo Proof' : 'Retake Photo'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    if (proofUrl != null) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 4),
                      const Text('Uploaded', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Classroom Management'),
      ),
      body: Consumer<ClassroomProvider>(
        builder: (context, provider, child) {
          final kpi = provider.kpi;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'KPI Checklist',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Please check the items below and upload photo proofs where required.',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 18),

                    buildKpiCard(
                      context: context,
                      title: 'Classroom is clean and organised',
                      value: kpi.isClean,
                      onChanged: (val) => provider.toggleChecklist('clean', val ?? false),
                      requiresProof: true,
                      proofUrl: kpi.cleanProofUrl,
                      onUploadTap: () => provider.uploadProofPhoto('clean', context),
                    ),

                    buildKpiCard(
                      context: context,
                      title: 'Students are well managed',
                      value: kpi.studentsManaged,
                      onChanged: (val) => provider.toggleChecklist('managed', val ?? false),
                      requiresProof: true,
                      proofUrl: kpi.studentsManagedProofUrl,
                      onUploadTap: () => provider.uploadProofPhoto('managed', context),
                    ),

                    buildKpiCard(
                      context: context,
                      title: 'Learning corners are updated',
                      value: kpi.cornersUpdated,
                      onChanged: (val) => provider.toggleChecklist('corners', val ?? false),
                      requiresProof: true,
                      proofUrl: kpi.cornersProofUrl,
                      onUploadTap: () => provider.uploadProofPhoto('corners', context),
                    ),

                    buildKpiCard(
                      context: context,
                      title: 'Safety rules are followed',
                      value: kpi.safetyRules,
                      onChanged: (val) => provider.toggleChecklist('safety', val ?? false),
                    ),

                    buildKpiCard(
                      context: context,
                      title: 'Students line up properly',
                      value: kpi.studentsLineUp,
                      onChanged: (val) => provider.toggleChecklist('lineup', val ?? false),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          provider.saveClassroomKpi();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Classroom KPI Saved!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Save Assessment', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              
              if (provider.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}