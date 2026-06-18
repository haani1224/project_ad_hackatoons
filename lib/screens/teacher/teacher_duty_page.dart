import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'teacher_main_page.dart';
import '../../models/duty_task_model.dart';
import '../../models/teacher_model.dart';
import '../../services/duty_service.dart';
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

  @override
  void initState() {
    super.initState();
    loadDuties();
  }

  void loadDuties() {
    futureDuties = dutyService.getDutiesByTeacher(widget.teacher.id);
  }

  Future<void> pickSingleProof(DutyTask duty, ImageSource source) async {
    final image = await picker.pickImage(source: source);

    if (image != null) {
      await dutyService.uploadSingleProof(
        dutyTaskId: duty.id,
        image: image,
      );

      setState(() => loadDuties());
    }
  }

  Future<void> pickChecklistProof(
    DutyTask duty,
    int checklistIndex,
    ImageSource source,
  ) async {
    final image = await picker.pickImage(source: source);

    if (image != null) {
      await dutyService.uploadChecklistProof(
        dutyTaskId: duty.id,
        checklistIndex: checklistIndex,
        image: image,
      );

      setState(() => loadDuties());
    }
  }

  void showSingleUploadOptions(DutyTask duty) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _uploadOptions(
        onCamera: () => pickSingleProof(duty, ImageSource.camera),
        onGallery: () => pickSingleProof(duty, ImageSource.gallery),
      ),
    );
  }

  void showChecklistUploadOptions(DutyTask duty, int index) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _uploadOptions(
        onCamera: () => pickChecklistProof(duty, index, ImageSource.camera),
        onGallery: () => pickChecklistProof(duty, index, ImageSource.gallery),
      ),
    );
  }

  Widget _uploadOptions({
    required VoidCallback onCamera,
    required VoidCallback onGallery,
  }) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take Photo"),
            onTap: () {
              Navigator.pop(context);
              onCamera();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              onGallery();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("My Duties"),
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
                  builder: (_) => TeacherMainPage(
                    teacher: widget.teacher,
                  )
                ),
                (route) => false,
              );
            },
          ),
        ],
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
                  isAdminView: false,
                  onUploadSingleProof: () => showSingleUploadOptions(duty),
                  onDeleteSingleProof: () async {
                    await dutyService.deleteSingleProof(duty.id);
                    setState(() => loadDuties());
                  },
                  onUploadChecklistProof: (index) =>
                      showChecklistUploadOptions(duty, index),
                  onDeleteChecklistProof: (index) async {
                    await dutyService.deleteChecklistProof(
                      dutyTaskId: duty.id,
                      checklistIndex: index,
                    );
                    setState(() => loadDuties());
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}