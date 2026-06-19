import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/training_provider.dart';

class TrainingDevelopmentPage extends StatelessWidget {
  const TrainingDevelopmentPage({super.key});

  Widget buildKpiChecklist({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isAutoCalculated = false,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      value: value,
      onChanged: isAutoCalculated ? null : onChanged, 
      activeColor: Colors.blue,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training & Development'),
      ),
      body: Consumer<TrainingProvider>(
        builder: (context, provider, child) {
          if (!provider.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final kpi = provider.kpi;
          final history = provider.history;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER: Total Training Summary
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: provider.hasMetMinimum ? Colors.green.shade50 : Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: provider.hasMetMinimum ? Colors.green.shade200 : Colors.amber.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        provider.hasMetMinimum ? Icons.verified : Icons.info_outline,
                        color: provider.hasMetMinimum ? Colors.green : Colors.amber.shade700,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Training This Year: ${provider.totalTrainingThisYear}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: provider.hasMetMinimum ? Colors.green.shade800 : Colors.amber.shade900,
                              ),
                            ),
                            Text(
                              provider.hasMetMinimum 
                                  ? 'Minimum requirement met (3/year)' 
                                  : 'Has not met the minimum 3 trainings/year',
                              style: TextStyle(
                                fontSize: 13,
                                color: provider.hasMetMinimum ? Colors.green.shade700 : Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 2. KPI CHECKLIST SECTION
                const Text(
                  'KPI Checklist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        buildKpiChecklist(
                          title: 'Attend require training (minimum 3 per year)',
                          value: kpi.attendRequired,
                          onChanged: (val) => provider.toggleChecklist('attend', val ?? false),
                          isAutoCalculated: true, // Item ini auto-tick dari provider
                        ),
                        buildKpiChecklist(
                          title: 'Applies knowledge from training',
                          value: kpi.appliesKnowledge,
                          onChanged: (val) => provider.toggleChecklist('applies', val ?? false),
                        ),
                        buildKpiChecklist(
                          title: 'Shares learning with team',
                          value: kpi.sharesLearning,
                          onChanged: (val) => provider.toggleChecklist('shares', val ?? false),
                        ),
                        buildKpiChecklist(
                          title: 'Improves teaching skills',
                          value: kpi.improvesSkills,
                          onChanged: (val) => provider.toggleChecklist('improves', val ?? false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 3. TRAINING HISTORY SECTION
                const Text(
                  'Training History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                if (history.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No training records found.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true, 
                    physics: const NeverScrollableScrollPhysics(), 
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple.shade50,
                            child: const Icon(Icons.workspace_premium, color: Colors.purple, size: 24),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text('Date: ${item.date}'),
                              Text('Organizer: ${item.organizer}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}