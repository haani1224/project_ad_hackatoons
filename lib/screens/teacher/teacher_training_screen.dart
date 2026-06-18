import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/training_model.dart';
import '../../models/teacher_model.dart';
import '../../services/training_service.dart';
import '../../services/docstorage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';

// ── 1. Main list screen ───────────────────────────────────────────────────────

class TeacherTrainingScreen extends StatefulWidget {
  final int teacherId;

  const TeacherTrainingScreen({
    super.key,
    required this.teacherId,
  });

  @override
  State<TeacherTrainingScreen> createState() => _TeacherTrainingScreenState();
}

class _TeacherTrainingScreenState extends State<TeacherTrainingScreen> {
  final _svc = TrainingService();
  final _docStorageSvc = StorageService();
  List<TrainingRecord> _trainings = [];
  int _approvedCount = 0;
  bool _loading = true;

  String get _uid => Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
  try {
    print('Loading trainings...');

    final results = await Future.wait([
      _svc.getMyTrainings(_uid),
      _svc.getApprovedCountForYear(_uid, DateTime.now().year),
    ]);

    print('Trainings loaded');
    print('Count: ${results[0]}');
    print('Approved: ${results[1]}');

    if (mounted) {
      setState(() {
        _trainings = results[0] as List<TrainingRecord>;
        _approvedCount = results[1] as int;
        _loading = false;
      });
    }
  } catch (e, s) {
    print('TeacherTrainingScreen error: $e');
    print(s);

    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget());

    final bool meetsQuota = _approvedCount >= 3;

    return Scaffold(
      appBar: AppBar(title: const Text('My Training')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Apply for Training'),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => SelectTrainingScreen(teacherId: _uid)));
          _load();
        },
      ),
      body: Column(
        children: [
          // Quota progress card
          Card(
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Annual Training Quota',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Chip(
                        label: Text(
                          meetsQuota ? 'QUOTA MET ✓' : 'IN PROGRESS',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11),
                        ),
                        backgroundColor:
                            meetsQuota ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_approvedCount / 3).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.grey.shade200,
                      color: meetsQuota ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_approvedCount / 3 approved trainings this year'
                    '${meetsQuota ? ' — keep going, more are welcome!' : ''}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('My Applications',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: _trainings.isEmpty
                ? const Center(
                    child: Text('No applications yet.\nTap + to apply.',
                        textAlign: TextAlign.center))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: _trainings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final t = _trainings[i];
                      return Card(
                        child: ListTile(
                          title: Text(t.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${t.category} · ${DateFormat('d MMM yyyy').format(t.trainingDate)}'),
                          trailing: Icon(
                            t.isApproved
                                ? Icons.check_circle
                                : t.isRejected
                                    ? Icons.cancel
                                    : t.isCompleted
                                        ? Icons.verified
                                        : Icons.pending_actions,
                            color: t.isApproved
                                ? Colors.blue
                                : t.isRejected
                                    ? Colors.red
                                    : t.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                          ),
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        TrainingDetailScreen(training: t)));
                            _load();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Select from principal's list ──────────────────────────────────────────

class SelectTrainingScreen extends StatefulWidget {
  final String teacherId;
  const SelectTrainingScreen({super.key, required this.teacherId});

  @override
  State<SelectTrainingScreen> createState() => _SelectTrainingScreenState();
}

class _SelectTrainingScreenState extends State<SelectTrainingScreen> {
  final _svc = TrainingService();
  final _docStorageSvc = StorageService();
  List<TrainingOption> _options = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data =
        await _svc.getAvailableTrainingOptions(widget.teacherId);
    setState(() {
      _options = data;
      _loading = false;
    });
  }

  Future<void> _apply(TrainingOption option) async {
    try {
      await _svc.applyForTraining(
        teacherId: widget.teacherId.toString(),
        trainingOptionId: option.id.toString(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Application submitted! Awaiting principal approval.')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().contains('unique')
              ? 'You already applied for this training.'
              : 'Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Trainings')),
      body: _loading
          ? const LoadingWidget()
          : _options.isEmpty
              ? const Center(
                  child: Text(
                      'No training courses available yet.\n'
                      'The principal has not published any options.',
                      textAlign: TextAlign.center))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final o = _options[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${o.category} · ${o.mode}',
                                style:
                                    const TextStyle(color: Colors.grey)),
                            Text(
                                '${DateFormat('d MMM yyyy').format(o.trainingDate)} · ${o.durationHours}h'),
                            Text('${o.organizer} @ ${o.venue}'),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _apply(o),
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                child: const Text('Apply'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ── 3. Training detail + reflection + uploads ─────────────────────────────────

class TrainingDetailScreen extends StatefulWidget {
  final TrainingRecord training;
  const TrainingDetailScreen({super.key, required this.training});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  final _svc = TrainingService();
  final _docStorageSvc = StorageService();
  final _reflCtrl = TextEditingController();
  String? _certPath;
  List<String> _photoPaths = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _reflCtrl.text = widget.training.reflection ?? '';
    _certPath = widget.training.certificateUrl;
    _photoPaths = List<String>.from(widget.training.photoUrls);
  }

  Future<void> _saveChanges() async {
    if (_reflCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write your reflection.')));
      return;
    }
    if (_photoPaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one training photo.')));
      return;
    }
    setState(() => _saving = true);
    await _svc.saveTrainingSubmission(
      trainingId: widget.training.id,
      reflection: _reflCtrl.text.trim(),
      certificateUrl: _certPath, // null is fine
      photoUrls: _photoPaths,
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Training report saved!')));
      Navigator.pop(context);
    }
  }

  Widget _completedView(TrainingRecord t) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusBanner(
          'Training Completed ✓',
          'Your report has been submitted successfully.',
          Colors.green,
          Icons.verified,
        ),
        const SizedBox(height: 24),
        Text('Your Reflection',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(t.reflection ?? '',
              style: const TextStyle(fontSize: 14, height: 1.5)),
        ),
        if (t.certificateUrl != null) ...[
          const SizedBox(height: 20),
          Text('Certificate',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: const Text('View Certificate'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () async {
              final url =
                  await _docStorageSvc.getDownloadUrl(t.certificateUrl!);
              await launchUrl(Uri.parse(url),
                  mode: LaunchMode.inAppBrowserView);
            },
          ),
        ],
        if (t.photoUrls.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Training Photos',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: t.photoUrls.length,
            itemBuilder: (context, i) => FutureBuilder<String>(
              future: _docStorageSvc.getDownloadUrl(t.photoUrls[i]),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(snap.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity),
                );
              },
            ),
          ),
        ],
      ],
    );

  @override
  Widget build(BuildContext context) {
    final t = widget.training;
    return Scaffold(
      appBar: AppBar(title: Text(t.title, overflow: TextOverflow.ellipsis)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Training info
            _infoRow('Status', t.status.toUpperCase()),
            _infoRow('Category', t.category),
            _infoRow('Organizer', t.organizer),
            _infoRow('Date', DateFormat('d MMM yyyy').format(t.trainingDate)),
            _infoRow('Duration', '${t.durationHours} hours'),
            _infoRow('Mode', t.mode),
            _infoRow('Venue', t.venue),
            const Divider(height: 32),

            // State-based content
            if (t.isRejected)
              _statusBanner(
                'Application Not Approved',
                'Please contact the principal for more information.',
                Colors.red,
                Icons.cancel_outlined,
              )
            else if (t.isPending)
              _statusBanner(
                'Awaiting Principal Approval',
                'Once approved, you can submit your reflection, certificate, and photos here.',
                Colors.orange,
                Icons.pending_actions,
              )
            else if (t.isCompleted)   // ← must be before isApproved
              _completedView(t)
            else if (t.isApproved) ...[
              // Approved — unlock submission
              Text('1. Reflection',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('What did you learn from this training?',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Write your reflection here...',
                controller: _reflCtrl,
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              Text('2. Certificate (Optional)',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Upload your completion certificate if available.',
                  style: TextStyle(color: Colors.grey.shade600)),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Completion Certificate'),
                subtitle: Text(
                  _certPath == null ? 'Not uploaded (optional)' : 'Uploaded ✓',
                  style: TextStyle(
                      color: _certPath == null ? Colors.grey : Colors.green), // grey not red
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_certPath != null)
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: 'View',
                        onPressed: () async {
                          final url = await _docStorageSvc.getDownloadUrl(_certPath!);
                          await launchUrl(Uri.parse(url),
                              mode: LaunchMode.inAppBrowserView);
                        },
                      ),
                    IconButton(
                      icon: Icon(_certPath == null
                          ? Icons.upload_file
                          : Icons.refresh),
                      tooltip: _certPath == null ? 'Upload' : 'Replace',
                      onPressed: () async {
                        final path = await _docStorageSvc.uploadTeacherDocument(
                            userId: t.teacherId.toString(),
                            docType: 'cert_${t.id}',
                            oldPath: _certPath);
                        if (path != null) setState(() => _certPath = path);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),

              Text('3. Training Photos *',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('At least one photo required as proof of attendance.',
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _photoPaths.length + 1,
                itemBuilder: (context, index) {
                  // Add button
                  if (index == _photoPaths.length) {
                    return InkWell(
                      onTap: () async {
                        final path = await _docStorageSvc.uploadTeacherDocument(
                            userId: t.teacherId.toString(),
                            docType: 'img_${t.id}_$index');
                        if (path != null) {
                          setState(() => _photoPaths.add(path));
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Icon(Icons.add_a_photo,
                            color: Colors.blueGrey),
                      ),
                    );
                  }
                  // Photo tile with delete
                  final photoPath = _photoPaths[index];
                  return Stack(
                    children: [
                      FutureBuilder<String>(
                        future: _docStorageSvc.getDownloadUrl(photoPath),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(snap.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity),
                          );
                        },
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () async {
                            await _docStorageSvc.deleteTeacherDocument(
                                path: photoPath);
                            setState(
                                () => _photoPaths.removeAt(index));
                          },
                          child: CircleAvatar(
                            radius: 13,
                            backgroundColor:
                                Colors.red.withOpacity(0.9),
                            child: const Icon(Icons.close,
                                size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                  label: 'Save Training Report',
                  onPressed: _saveChanges,
                  isLoading: _saving),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
                width: 90,
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                        fontSize: 13))),
            Expanded(child: Text(value)),
          ],
        ),
      );

  Widget _statusBanner(
          String title, String body, Color color, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: TextStyle(
                          color: color.withOpacity(0.8), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
}