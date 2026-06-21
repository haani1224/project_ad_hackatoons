class TrainingOption {
  final int? id;
  final String title;
  final String category;
  final String organizer;
  final DateTime trainingDate;
  final double durationHours;
  final String mode;
  final String venue;
  final DateTime? createdAt;

  const TrainingOption({
    this.id,
    required this.title,
    required this.category,
    required this.organizer,
    required this.trainingDate,
    required this.durationHours,
    required this.mode,
    required this.venue,
    this.createdAt,
  });

  factory TrainingOption.fromMap(Map<String, dynamic> map) => TrainingOption(
        id: map['id'] as int?,
        title: map['title'] as String,
        category: map['category'] as String,
        organizer: map['organizer'] as String,
        trainingDate: DateTime.parse(map['training_date'] as String),
        durationHours: (map['duration_hours'] as num).toDouble(),
        mode: map['mode'] as String,
        venue: map['venue'] as String,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'organizer': organizer,
        'training_date': trainingDate.toIso8601String().substring(0, 10),
        'duration_hours': durationHours,
        'mode': mode,
        'venue': venue,
      };
}

class TrainingRecord {
  final String id;
  final int teacherId;
  final int trainingOptionId;
  // Flattened from training_options join — read only, never sent to DB
  final String title;
  final String category;
  final String organizer;
  final DateTime trainingDate;
  final double durationHours;
  final String mode;
  final String venue;
  // Teacher's own submission fields
  final String? reflection;
  final String status;
  final String? certificateUrl;
  final List<String> photoUrls;
  // Joined from teacher_records — read only
  final String? teacherName;
  final DateTime? createdAt;

  const TrainingRecord({
    required this.id,
    required this.teacherId,
    required this.trainingOptionId,
    required this.title,
    required this.category,
    required this.organizer,
    required this.trainingDate,
    required this.durationHours,
    required this.mode,
    required this.venue,
    this.reflection,
    required this.status,
    this.certificateUrl,
    this.photoUrls = const [],
    this.teacherName,
    this.createdAt,
  });

  factory TrainingRecord.fromMap(Map<String, dynamic> map) {
    // training details come from the joined training_options object
    final opt = map['training_options'] as Map<String, dynamic>?;

    // teacher name comes from joined teacher_records object
    final tr = map['teacher_records'];
    String? teacherName;
    if (tr is Map) {
      teacherName = tr['full_name'] as String?;
    } else if (tr is List && tr.isNotEmpty) {
      teacherName = tr[0]['full_name'] as String?;
    }

    return TrainingRecord(
      id: map['id'] as String,
      teacherId: map['teacher_id'] as int,
      trainingOptionId: map['training_option_id'] as int,
      // Pull details from joined option; fall back to flat columns for safety
      title: opt?['title'] as String? ?? map['title'] as String? ?? '',
      category: opt?['category'] as String? ?? map['category'] as String? ?? '',
      organizer: opt?['organizer'] as String? ?? map['organizer'] as String? ?? '',
      trainingDate: DateTime.tryParse(
              opt?['training_date'] as String? ??
              map['training_date'] as String? ?? '') ??
          DateTime.now(),
      durationHours:
          ((opt?['duration_hours'] ?? map['duration_hours']) as num?)
                  ?.toDouble() ??
              0,
      mode: opt?['mode'] as String? ?? map['mode'] as String? ?? '',
      venue: opt?['venue'] as String? ?? map['venue'] as String? ?? '',
      reflection: map['reflection'] as String?,
      status: map['status'] as String? ?? 'pending',
      certificateUrl: map['certificate_url'] as String?,
      photoUrls: List<String>.from(map['photo_urls'] ?? []),
      teacherName: teacherName,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
    );
  }

  // Only columns that belong in the trainings table — no denormalized data
  Map<String, dynamic> toMap() => {
        if (id.isNotEmpty) 'id': id,
        'teacher_id': teacherId,
        'training_option_id': trainingOptionId,
        'reflection': reflection,
        'status': status,
        'certificate_url': certificateUrl,
        'photo_urls': photoUrls,
      };

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCompleted => status == 'completed';
}