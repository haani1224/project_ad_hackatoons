enum ProofMode {
  checklistImages,
  singleImage,
}

class DutyTask {
  final int id;
  final String dutyType;
  final String location;
  final int teacherId;
  final String teacherName;
  final String teacherEmail;
  final String day;
  final String time;
  final List<String> checklist;
  final ProofMode proofMode;

  String? singleProofImageUrl;
  final Map<int, String> checklistProofImages;

  DutyTask({
    required this.id,
    required this.dutyType,
    required this.location,
    required this.teacherId,
    required this.teacherName,
    required this.teacherEmail,
    required this.day,
    required this.time,
    required this.proofMode,
    this.checklist = const [],
    this.singleProofImageUrl = '',
    this.checklistProofImages = const {},
  });

  bool get isCompleted {
    if (proofMode == ProofMode.singleImage) {
      return singleProofImageUrl != null;
    }

    return checklistProofImages.length == checklist.length;
  }

  String get progressText {
    if (proofMode == ProofMode.singleImage) {
      return isCompleted ? "1 / 1 proof uploaded" : "0 / 1 proof uploaded";
    }

    return "${checklistProofImages.length} / ${checklist.length} proofs uploaded";
  }

  factory DutyTask.fromMap(Map<String, dynamic> map) {
    final teacher = map['users'] ?? {};
    final proofs = List<Map<String, dynamic>>.from(map['duty_proofs'] ?? []);

    String? singleProof;
    final Map<int, String> checklistProofs = {};

    for (final proof in proofs) {
      if (proof['checklist_index'] == null) {
        singleProof = proof['image_url'];
      } else {
        checklistProofs[proof['checklist_index']] = proof['image_url'];
      }
    }

    return DutyTask(
      id: map['id'],
      dutyType: map['duty_type'] ?? '',
      location: map['location'] ?? '',
      teacherId: map['teacher_id'],
      teacherName: teacher['name'] ?? '',
      teacherEmail: teacher['email'] ?? '',
      day: map['day'] ?? '',
      time: map['duty_time'] ?? '',
      proofMode: map['proof_mode'] == 'checklist'
          ? ProofMode.checklistImages
          : ProofMode.singleImage,
      checklist: List<String>.from(map['checklist'] ?? []),
      singleProofImageUrl: singleProof,
      checklistProofImages: checklistProofs,
    );
  }
}