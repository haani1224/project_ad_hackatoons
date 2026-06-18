import 'package:flutter/material.dart';

import '../../data/models/teacher_model.dart';

class TeacherDetailPage extends StatelessWidget {
  final TeacherModel teacher;

  const TeacherDetailPage({
    super.key,
    required this.teacher,
  });

    double calculateCompletion() {
    int completed = 0;

    final fields = [
      teacher.fullName,
      teacher.icNumber,
      teacher.gender,
      teacher.dob,
      teacher.phone,
      teacher.email,
      teacher.address,
      teacher.state,
      teacher.postcode,
      teacher.maritalStatus,
      teacher.emergencyName,
      teacher.emergencyPhone,
    ];

    for (var field in fields) {
      if (field != null &&
          field.toString().trim().isNotEmpty) {
        completed++;
      }
    }

    return completed / fields.length;
  }

  Widget buildInfo(String label, String? value) {
    return Card(
      child: ListTile(
        title: Text(label),
        subtitle: Text(
          value == null || value.isEmpty
              ? "-"
              : value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final percent = (calculateCompletion() * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Center(
              child:CircleAvatar(
                radius: 50,
                backgroundImage: teacher.avatarUrl != null
                    ? NetworkImage(teacher.avatarUrl!)
                    : null,
                child: teacher.avatarUrl == null
                    ? Text(teacher.fullName[0])
                    : null,
              ),
            ),

            Card(
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "$percent% Complete",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: percent / 100),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            buildInfo(
              "Full Name",
              teacher.fullName,
            ),

            buildInfo(
              "IC Number",
              teacher.icNumber,
            ),

            buildInfo(
              "Gender",
              teacher.gender,
            ),

            buildInfo(
              "Date Of Birth",
              teacher.dob,
            ),

            buildInfo(
              "Phone",
              teacher.phone,
            ),

            buildInfo(
              "Email",
              teacher.email,
            ),

            buildInfo(
              "Address",
              teacher.address,
            ),

            buildInfo(
              "State",
              teacher.state,
            ),

            buildInfo(
              "Postcode",
              teacher.postcode,
            ),

            buildInfo(
              "Marital Status",
              teacher.maritalStatus,
            ),

            buildInfo(
              "Emergency Contact",
              teacher.emergencyName,
            ),

            buildInfo(
              "Emergency Phone",
              teacher.emergencyPhone,
            ),
          ],
        ),
      ),
    );
  }


}

