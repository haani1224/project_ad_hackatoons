import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/peer_eval_provider.dart';

class PeerEvaluationPage extends StatelessWidget {
  const PeerEvaluationPage({super.key});

  InputDecoration buildDropdownDecoration() {
    return InputDecoration(
      labelText: 'Select Teacher to Evaluate',
      prefixIcon: const Icon(Icons.person_search),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget buildSurveyCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Evaluation'),
      ),
      body: Consumer<PeerEvaluationProvider>(
        builder: (context, provider, child) {
          final kpi = provider.kpi;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Communication & Professionalism',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Assess your colleague\'s communication skills and professionalism.',
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 18),

                //dropdwn
                DropdownButtonFormField<String>(
                  value: provider.selectedTeacher,
                  decoration: buildDropdownDecoration(),
                  items: provider.teacherList.map((String teacher) {
                    return DropdownMenuItem<String>(
                      value: teacher,
                      child: Text(teacher),
                    );
                  }).toList(),
                  onChanged: (value) => provider.selectTeacher(value),
                ),
                const SizedBox(height: 20),

                // survey checklist
                if (provider.selectedTeacher != null) ...[
                  const Text(
                    'Assessment Checklist',
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
                          buildSurveyCheckbox(
                            title: 'Speaks politely to students, parents and colleagues',
                            value: kpi.speaksPolitely,
                            onChanged: (val) => provider.toggleChecklist('polite', val ?? false),
                          ),
                          buildSurveyCheckbox(
                            title: 'Responds professionally in WhatsApp groups',
                            value: kpi.respondsProfessionally,
                            onChanged: (val) => provider.toggleChecklist('whatsapp', val ?? false),
                          ),
                          buildSurveyCheckbox(
                            title: 'Works well with team members',
                            value: kpi.worksWell,
                            onChanged: (val) => provider.toggleChecklist('teamwork', val ?? false),
                          ),
                          buildSurveyCheckbox(
                            title: 'Accept feedback positively',
                            value: kpi.acceptsFeedback,
                            onChanged: (val) => provider.toggleChecklist('feedback', val ?? false),
                          ),
                          buildSurveyCheckbox(
                            title: 'Maintains professional appearance',
                            value: kpi.professionalAppearance,
                            onChanged: (val) => provider.toggleChecklist('appearance', val ?? false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        provider.submitEvaluation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Survey submitted successfully!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Assessment', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}