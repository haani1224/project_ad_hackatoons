import 'package:flutter/material.dart';
import 'peer_eval_page.dart';
import 'teacher_performance_details_page.dart'; 

class PrincipalView extends StatelessWidget {
  const PrincipalView({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _teachers = const [
    {
      'name': 'Alice Johnson',
      'kpi': 0.86,
      'attendance': 0.82,
      'classroom': 0.88,
      'teaching': 0.91,
      'student': 0.79,
      'training': 0.84,
    },
    {
      'name': 'Bob Smith',
      'kpi': 0.72,
      'attendance': 0.68,
      'classroom': 0.75,
      'teaching': 0.70,
      'student': 0.76,
      'training': 0.72,
    },
    {
      'name': 'Carla Gomez',
      'kpi': 0.94,
      'attendance': 0.92,
      'classroom': 0.95,
      'teaching': 0.96,
      'student': 0.91,
      'training': 0.94,
    },
    {
      'name': 'David Lee',
      'kpi': 0.63,
      'attendance': 0.60,
      'classroom': 0.65,
      'teaching': 0.62,
      'student': 0.61,
      'training': 0.64,
    },
    {
      'name': 'Eve Martinez',
      'kpi': 0.79,
      'attendance': 0.80,
      'classroom': 0.78,
      'teaching': 0.81,
      'student': 0.75,
      'training': 0.81,
    },
    {
      'name': 'Bad Teacher',
      'kpi': 0.55,
      'attendance': 0.50,
      'classroom': 0.58,
      'teaching': 0.52,
      'student': 0.49,
      'training': 0.61,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Principal Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.orange.shade100,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PeerEvaluationPage()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_rounded, size: 46, color: Colors.orange.shade700),
                        const SizedBox(height: 12),
                        const Text(
                          'Teacher Evaluation',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemCount: _teachers.length,
                itemBuilder: (context, index) {
                  final teacher = _teachers[index];
                  final double kpi = teacher['kpi'] as double;
                  final int percent = (kpi * 100).round();

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeacherPerformanceDetailsPage(teacherData: teacher),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.blue.shade200,
                                    child: const Icon(Icons.person, color: Colors.blue, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      teacher['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}