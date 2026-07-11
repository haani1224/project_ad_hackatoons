import 'package:flutter/material.dart';

import 'principal_main_page.dart';
import '../../models/duty_task_model.dart';
import '../../services/duty_service.dart';
import '../../widgets/duty_card.dart';
import '../../utils/constants.dart';

class PrincipalDutyPage extends StatefulWidget {
  const PrincipalDutyPage({super.key});

  @override
  State<PrincipalDutyPage> createState() =>
      _PrincipalDutyPageState();
}

class _PrincipalDutyPageState extends State<PrincipalDutyPage> {
  final DutyService dutyService = DutyService();

  late Future<List<DutyTask>> futureDuties;
  bool isGenerating = false;

  @override
  void initState() {
    super.initState();
    loadDuties();
  }

  void loadDuties() {
    futureDuties = dutyService.getAllDuties();
  }

  Future<void> autoGenerate() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Generate New Roster?',
            style: AppTextStyles.sectionTitle,
          ),
          content: Text(
            'The current roster and existing duty proofs will be replaced.',
            style: AppTextStyles.body,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Generate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() => isGenerating = true);

      await dutyService.autoGenerateSchedule();

      setState(loadDuties);

      if (!mounted) return;

      _showMessage('Duty roster generated successfully');
    } catch (e) {
      if (!mounted) return;
      _showMessage(
        'Auto-generate failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => isGenerating = false);
      }
    }
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isError ? AppColors.danger : AppColors.primary,
        content: Text(
          message,
          style: AppTextStyles.body.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 78,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Duty Manager',
          style: AppTextStyles.pageTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Home',
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
          const SizedBox(width: 8),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textPrimary,
        elevation: 8,
        onPressed: isGenerating ? null : autoGenerate,
        icon: isGenerating
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textPrimary,
                ),
              )
            : const Icon(Icons.auto_awesome_rounded),
        label: Text(
          isGenerating ? 'Generating...' : 'Auto Generate',
          style: AppTextStyles.button,
        ),
      ),
      body: FutureBuilder<List<DutyTask>>(
        future: futureDuties,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: AppTextStyles.body,
              ),
            );
          }

          final duties = snapshot.data ?? [];
          final completed =
              duties.where((duty) => duty.isCompleted).length;
          final pending = duties.length - completed;
          final teacherIds =
              duties.map((duty) => duty.teacherId).toSet();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              setState(loadDuties);
              await futureDuties;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 110),
              children: [
                Text(
                  'Duty Overview',
                  style: AppTextStyles.heading,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        value: '${teacherIds.length}',
                        label: 'Teachers',
                        icon: Icons.people_alt_rounded,
                        color: AppColors.primary,
                        lightColor: const Color(0xFFE7ECF3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        value: '$completed',
                        label: 'Completed',
                        icon: Icons.check_circle_rounded,
                        color: AppColors.success,
                        lightColor: AppColors.successLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard(
                        value: '$pending',
                        label: 'Pending',
                        icon: Icons.pending_actions_rounded,
                        color: AppColors.warning,
                        lightColor: AppColors.warningLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      'Duty Roster',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const Spacer(),
                    Text(
                      '${duties.length} duties',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (duties.isEmpty)
                  _emptyRoster()
                else
                  ...duties.map(
                    (duty) => DutyCard(
                      duty: duty,
                      isAdminView: true,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color lightColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: lightColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTextStyles.heading.copyWith(
              color: color,
              fontSize: 20,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _emptyRoster() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: AppDecorations.card,
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            size: 58,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            'No roster generated',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 6),
          Text(
            'Tap Auto Generate to create duties for available teachers.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}