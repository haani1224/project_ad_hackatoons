import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'teacher_main_page.dart';
import '../../models/duty_task_model.dart';
import '../../models/teacher_model.dart';
import '../../services/duty_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/duty_card.dart';
import '../../utils/constants.dart';

class TeacherDutyPage extends StatefulWidget {
  final TeacherModel teacher;

  const TeacherDutyPage({
    super.key,
    required this.teacher,
  });

  @override
  State<TeacherDutyPage> createState() => _TeacherDutyPageState();
}

class _TeacherDutyPageState extends State<TeacherDutyPage> {
  final DutyService dutyService = DutyService();
  final ImagePicker picker = ImagePicker();

  late Future<List<DutyTask>> futureDuties;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    futureDuties = _fetchDuties();
  }

  Future<List<DutyTask>> _fetchDuties() async {
    final duties = await dutyService.getDutiesByTeacher(
      widget.teacher.id,
    );

    try {
      await NotificationService.instance.scheduleDutyReminders(
        duties,
      );
    } catch (e, stackTrace) {
      debugPrint('DUTY NOTIFICATION ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
    }

    return duties;
  }

  void loadDuties() {
    setState(() {
      futureDuties = _fetchDuties();
    });
  }

  Future<void> pickSingleProof(
    DutyTask duty,
    ImageSource source,
  ) async {
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        isUploading = true;
      });

      await dutyService.uploadSingleProof(
        dutyTaskId: duty.id,
        image: image,
      );

      loadDuties();

      if (!mounted) return;

      _showMessage('Proof uploaded successfully');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Upload failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  Future<void> pickChecklistProof(
    DutyTask duty,
    int checklistIndex,
    ImageSource source,
  ) async {
    try {
      final image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        isUploading = true;
      });

      await dutyService.uploadChecklistProof(
        dutyTaskId: duty.id,
        checklistIndex: checklistIndex,
        image: image,
      );

      loadDuties();

      if (!mounted) return;

      _showMessage('Checklist proof uploaded successfully');
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Upload failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void showSingleUploadOptions(DutyTask duty) {
    _showUploadOptions(
      onCamera: () => pickSingleProof(
        duty,
        ImageSource.camera,
      ),
      onGallery: () => pickSingleProof(
        duty,
        ImageSource.gallery,
      ),
    );
  }

  void showChecklistUploadOptions(
    DutyTask duty,
    int checklistIndex,
  ) {
    _showUploadOptions(
      onCamera: () => pickChecklistProof(
        duty,
        checklistIndex,
        ImageSource.camera,
      ),
      onGallery: () => pickChecklistProof(
        duty,
        checklistIndex,
        ImageSource.gallery,
      ),
    );
  }

  void _showUploadOptions({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                Text(
                  'Upload Duty Proof',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 14),
                _uploadOptionTile(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take Photo',
                  subtitle: 'Use your phone camera',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onCamera();
                  },
                ),
                const SizedBox(height: 10),
                _uploadOptionTile(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from Gallery',
                  subtitle: 'Select an existing image',
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    onGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _uploadOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyles.cardTitle,
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.caption,
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textSecondary,
        ),
        onTap: onTap,
      ),
    );
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
          style: AppTextStyles.body.copyWith(
            color: Colors.white,
          ),
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
          'My Duties',
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
                  builder: (_) => TeacherMainPage(
                    teacher: widget.teacher,
                  ),
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
      body: Stack(
        children: [
          FutureBuilder<List<DutyTask>>(
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
                return _errorState(
                  snapshot.error.toString(),
                );
              }

              final duties = snapshot.data ?? [];

              if (duties.isEmpty) {
                return _noDutiesState();
              }

              final completed = duties
                  .where((duty) => duty.isCompleted)
                  .length;

              final progress = duties.isEmpty
                  ? 0.0
                  : completed / duties.length;

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  final refreshed = _fetchDuties();

                  setState(() {
                    futureDuties = refreshed;
                  });

                  await refreshed;
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    32,
                  ),
                  children: [
                    _welcomeCard(
                      completed: completed,
                      total: duties.length,
                      progress: progress,
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'Assigned Duties',
                      style: AppTextStyles.sectionTitle,
                    ),
                    const SizedBox(height: 12),
                    ...duties.map(
                      (duty) => DutyCard(
                        duty: duty,
                        isAdminView: false,
                        onUploadSingleProof: () {
                          showSingleUploadOptions(duty);
                        },
                        onDeleteSingleProof: () async {
                          await dutyService
                              .deleteSingleProof(duty.id);

                          loadDuties();
                        },
                        onUploadChecklistProof: (index) {
                          showChecklistUploadOptions(
                            duty,
                            index,
                          );
                        },
                        onDeleteChecklistProof:
                            (index) async {
                          await dutyService
                              .deleteChecklistProof(
                            dutyTaskId: duty.id,
                            checklistIndex: index,
                          );

                          loadDuties();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (isUploading)
            Container(
              color: Colors.black.withOpacity(0.22),
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _welcomeCard({
    required int completed,
    required int total,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${widget.teacher.name}',
            style: AppTextStyles.heading.copyWith(
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Complete your assigned duties and upload the required proof.',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '$completed / $total completed',
                style: AppTextStyles.cardTitle.copyWith(
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor:
                  Colors.white.withOpacity(0.16),
              valueColor: const AlwaysStoppedAnimation(
                AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noDutiesState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final refreshed = _fetchDuties();

        setState(() {
          futureDuties = refreshed;
        });

        await refreshed;
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 110),
          Container(
            padding: const EdgeInsets.all(28),
            decoration: AppDecorations.card,
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: const BoxDecoration(
                    color: AppColors.successLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_available_rounded,
                    color: AppColors.success,
                    size: 42,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No duties assigned',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You currently have no duties assigned. '
                  'This may be because you are on approved leave '
                  'or no roster has been generated for today.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AppColors.danger,
            ),
            const SizedBox(height: 14),
            Text(
              'Unable to load duties',
              style: AppTextStyles.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: loadDuties,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}