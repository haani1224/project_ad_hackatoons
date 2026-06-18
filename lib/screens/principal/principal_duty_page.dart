import 'package:flutter/material.dart';
import 'principal_main_page.dart';
import '../../models/duty_task_model.dart';
import '../../services/duty_service.dart';
import '../../widgets/duty_card.dart';
import '../../utils/constants.dart';


class PrincipalDutyPage extends StatefulWidget {
  const PrincipalDutyPage({super.key});

  @override
  State<PrincipalDutyPage> createState() => _PrincipalDutyPageState();
}

class _PrincipalDutyPageState extends State<PrincipalDutyPage> {
  final DutyService dutyService = DutyService();
  late Future<List<DutyTask>> futureDuties;

  @override
  void initState() {
    super.initState();
    loadDuties();
  }

  void loadDuties() {
    futureDuties = dutyService.getAllDuties();
  }

  Future<void> autoGenerate() async {
    try {
      await dutyService.autoGenerateSchedule();

      setState(() {
        loadDuties();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Duty roster generated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auto-generate failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Principal Duty Manager"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: "Home",
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrincipalMainPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.black,
        onPressed: autoGenerate,
        icon: const Icon(Icons.auto_fix_high),
        label: const Text("Auto Generate"),
      ),
      body: FutureBuilder<List<DutyTask>>(
        future: futureDuties,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final duties = snapshot.data ?? [];
          final completed = duties.where((d) => d.isCompleted).length;

          return ListView(
            padding: const EdgeInsets.all(14),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "$completed / ${duties.length} duties completed",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              ...duties.map(
                (duty) => DutyCard(
                  duty: duty,
                  isAdminView: true,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}