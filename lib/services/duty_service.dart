import 'dart:io';
import 'dart:math';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/duty_task_model.dart';
import '../models/teacher_model.dart';

class DutyService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<TeacherModel?> loginTeacher(String email, String password) async {
    final data = await supabase
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .eq('status', 'active')
        .maybeSingle();

    if (data == null) return null;

    return TeacherModel.fromMap(data);
  }

  Future<List<TeacherModel>> getAvailableTeachersForDate(DateTime date) async {
    final dateText = date.toIso8601String().split('T').first;

    final teacherData = await supabase
        .from('users')
        .select()
        .eq('role', 'teacher')
        .eq('status', 'active');

    final teachers = List<Map<String, dynamic>>.from(teacherData)
        .map((e) => TeacherModel.fromMap(e))
        .toList();

    final leaveData = await supabase
        .from('leave_requests')
        .select('teacher_id')
        .eq('status', 'Approved')
        .lte('start_date', dateText)
        .gte('end_date', dateText);

    final leaveTeacherIds =
        List<Map<String, dynamic>>.from(leaveData)
            .map((e) => e['teacher_id'])
            .toSet();

    return teachers
        .where((teacher) => !leaveTeacherIds.contains(teacher.id))
        .toList();
  }

  Future<List<DutyTask>> getAllDuties() async {
    final data = await supabase
        .from('duty_tasks')
        .select('*, users(*), duty_proofs(*)')
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data)
        .map((e) => DutyTask.fromMap(e))
        .toList();
  }

  Future<List<DutyTask>> getDutiesByTeacher(int teacherId) async {
    final data = await supabase
        .from('duty_tasks')
        .select('*, users(*), duty_proofs(*)')
        .eq('teacher_id', teacherId)
        .order('id', ascending: true);

    return List<Map<String, dynamic>>.from(data)
        .map((e) => DutyTask.fromMap(e))
        .toList();
  }

  final List<Map<String, dynamic>> dutyTemplates = [
    {
      "duty_type": "Cleaning Duty",
      "location": "Classroom",
      "time": "4:30 PM - 5:00 PM",
      "proof_mode": "checklist",
      "checklist": [
        "Sweep the classroom floor",
        "Mop the classroom floor",
        "Wipe students' table and chair",
        "Arrange table and chairs neatly",
        "Clean and wipe the whiteboard",
        "Organize teaching material and toys properly",
        "Arrange books and files properly",
        "Empty rubbish bins",
        "Wipe shelves, cabinets, windows, door",
        "Ensure classroom smells fresh and clean",
        "Switch off electrical plugs, lights and air-conditioner",
      ],
    },
    {
      "duty_type": "Cleaning Duty",
      "location": "Assembly Hall",
      "time": "4:30 PM - 5:00 PM",
      "proof_mode": "checklist",
      "checklist": [
        "Sweep assembly hall floor",
        "Mop assembly hall floor",
        "Arrange chairs and tables neatly",
        "Clean assembly hall tables",
        "Empty dustbins",
        "Arrange microphone and audio equipment",
        "Clean and rearrange toys at play area",
        "Clean trolleys at assembly hall",
        "Switch off lights and air-conditioners",
      ],
    },
    {
      "duty_type": "Cleaning Duty",
      "location": "Dining Area",
      "time": "4:30 PM - 5:00 PM",
      "proof_mode": "checklist",
      "checklist": [
        "Sweep dining area floor",
        "Mop dining area floor",
        "Wipe and sanitize dining tables",
        "Arrange chairs neatly",
        "Empty dirty dishes trolley",
        "Clean main and students' sinks",
        "Wipe students' mirror",
        "Wash and dry cleaning cloths",
        "Refill hand soap and dish soap",
        "Empty rubbish bin",
      ],
    },
    {
      "duty_type": "Cleaning Duty",
      "location": "Nap Room & Stairs",
      "time": "4:30 PM - 5:00 PM",
      "proof_mode": "checklist",
      "checklist": [
        "Fold students' blankets neatly",
        "Place blankets and pillows into bags",
        "Store mattresses properly",
        "Sweep stairs area",
        "Mop stairs carefully",
        "Wipe stair handrails",
        "Arrange shoes neatly if any",
      ],
    },
    {
      "duty_type": "Cleaning Duty",
      "location": "Toilet",
      "time": "4:30 PM - 5:00 PM",
      "proof_mode": "checklist",
      "checklist": [
        "Flush all toilets properly",
        "Clean toilet bowls thoroughly",
        "Scrub and disinfect toilet floor",
        "Refill hand soap",
        "Clean toilet doors",
        "Arrange cleaning tools neatly",
        "Arrange slippers neatly",
        "Ensure no items are left on the floor",
      ],
    },
    {
      "duty_type": "Arrival Duty",
      "location": "Main Door",
      "time": "7:30 AM - 8:00 AM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Arrival Duty",
      "location": "Stairs",
      "time": "7:30 AM - 8:00 AM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Arrival Duty",
      "location": "Hall 1st Floor",
      "time": "7:30 AM - 8:00 AM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Arrival Duty",
      "location": "Hall 2nd Floor",
      "time": "7:30 AM - 8:00 AM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Dismissal Duty",
      "location": "Main Door",
      "time": "12:00 PM - 12:30 PM / 5:00 PM - 5:15 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Dismissal Duty",
      "location": "Stairs",
      "time": "12:00 PM - 12:30 PM / 5:00 PM - 5:15 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Dismissal Duty",
      "location": "Shoes Rack",
      "time": "12:00 PM - 12:30 PM / 5:00 PM - 5:15 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Half-Full Day Transition Duty",
      "location": "Full Day Boy",
      "time": "12:00 PM - 2:30 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Half-Full Day Transition Duty",
      "location": "Full Day Girl",
      "time": "12:00 PM - 2:30 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Half-Full Day Transition Duty",
      "location": "Full Day 6 Years Old",
      "time": "12:00 PM - 2:30 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Half-Full Day Transition Duty",
      "location": "Hall and Cooking Rice",
      "time": "12:00 PM - 2:30 PM",
      "proof_mode": "single",
    },
    {
      "duty_type": "Assembly Duty",
      "location": "Introduction",
      "time": "",
      "proof_mode": "single",
    },
    {
      "duty_type": "Assembly Duty",
      "location": "Song",
      "time": "",
      "proof_mode": "single",
    },
    {
      "duty_type": "Assembly Duty",
      "location": "Islamic Content",
      "time": "",
      "proof_mode": "single",
    },
    {
      "duty_type": "Assembly Duty",
      "location": "Words of the Week",
      "time": "",
      "proof_mode": "single",
    },
  ];

  Future<void> autoGenerateSchedule({DateTime? date}) async {
    final selectedDate = date ?? DateTime.now();

    final teachers = await getAvailableTeachersForDate(selectedDate);

    if (teachers.isEmpty) {
      throw Exception("No available teachers. All teachers are on leave.");
    }

    final shuffledTeachers = [...teachers];
    shuffledTeachers.shuffle(Random());

    await supabase.from('duty_proofs').delete().neq('id', 0);
    await supabase.from('duty_tasks').delete().neq('id', 0);

    for (int i = 0; i < dutyTemplates.length; i++) {
      final teacher = shuffledTeachers[i % shuffledTeachers.length];
      final template = dutyTemplates[i];

      await supabase.from('duty_tasks').insert({
        'duty_type': template['duty_type'],
        'location': template['location'],
        'teacher_id': teacher.id,
        'day': _getDayName(selectedDate),
        'duty_time': template['time'],
        'proof_mode': template['proof_mode'],
        'checklist': template['checklist'] ?? [],
        'status': 'pending',
      });
    }
  }

  Future<void> uploadSingleProof({
    required int dutyTaskId,
    required XFile image,
  }) async {
    await supabase
        .from('duty_proofs')
        .delete()
        .eq('duty_task_id', dutyTaskId)
        .filter('checklist_index', 'is', null);

    final imageUrl = await _uploadImageToStorage(image);

    await supabase.from('duty_proofs').insert({
      'duty_task_id': dutyTaskId,
      'checklist_index': null,
      'image_url': imageUrl,
    });
  }

  Future<void> uploadChecklistProof({
    required int dutyTaskId,
    required int checklistIndex,
    required XFile image,
  }) async {
    await supabase
        .from('duty_proofs')
        .delete()
        .eq('duty_task_id', dutyTaskId)
        .eq('checklist_index', checklistIndex);

    final imageUrl = await _uploadImageToStorage(image);

    await supabase.from('duty_proofs').insert({
      'duty_task_id': dutyTaskId,
      'checklist_index': checklistIndex,
      'image_url': imageUrl,
    });
  }

  Future<void> deleteSingleProof(int dutyTaskId) async {
    await supabase
        .from('duty_proofs')
        .delete()
        .eq('duty_task_id', dutyTaskId)
        .filter('checklist_index', 'is', null);
  }

  Future<void> deleteChecklistProof({
    required int dutyTaskId,
    required int checklistIndex,
  }) async {
    await supabase
        .from('duty_proofs')
        .delete()
        .eq('duty_task_id', dutyTaskId)
        .eq('checklist_index', checklistIndex);
  }

  Future<String> _uploadImageToStorage(XFile image) async {
    final fileExt = image.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    final filePath = 'proofs/$fileName';

    await supabase.storage.from('duty-proofs').upload(
          filePath,
          File(image.path),
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('duty-proofs').getPublicUrl(filePath);
  }

  String _getDayName(DateTime date) {
    const days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return days[date.weekday - 1];
  }
}