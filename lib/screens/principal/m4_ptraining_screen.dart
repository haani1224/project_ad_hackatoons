import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/m4_training_service.dart';
import '../../services/m1_docstorage_service.dart';
import '../../widgets/loading_widget.dart';
import 'm4_ptraining2_screen.dart';
import '../../utils/theme_constants.dart';

class PrincipalTrainingScreen extends StatefulWidget {
  const PrincipalTrainingScreen({super.key});

  @override
  State<PrincipalTrainingScreen> createState() =>
      _PrincipalTrainingScreenState();
}

class _PrincipalTrainingScreenState extends State<PrincipalTrainingScreen>
    with SingleTickerProviderStateMixin {
  final _svc = TrainingService();
  final _docStorageSvc = StorageService();
  List<Map<String, dynamic>> _options = [];
  List<Map<String, dynamic>> _teacherProgress = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _svc.getTrainingOptionsWithApplicants(),
        _svc.getAllTeachersQuotaProgress(DateTime.now().year),
      ]);
      if (mounted) {
        setState(() {
          _options = results[0];
          _teacherProgress = results[1];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load records: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Training Management',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add training option',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTrainingOptionScreen(),
                ),
              );
              _load();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Training Courses'),
            Tab(text: 'Teacher Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCourseList(),
          _buildTeacherProgress(),
        ],
      ),
    );
  }

  Widget _buildCourseList() {
    if (_options.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No training options yet.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Training Option'),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTrainingOptionScreen(),
                  ),
                );
                _load();
              },
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final opt = _options[i];
          final count = opt['application_count'] as int? ?? 0;
          final pending = opt['pending_count'] as int? ?? 0;
          final date = DateTime.tryParse(opt['training_date'] as String? ?? '') ??
              DateTime.now();

          return Card(
            elevation: 3,
            shadowColor: navy.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              title: Text(opt['title'] as String? ?? 'Untitled',
                  style: const TextStyle( fontWeight: FontWeight.w800, color: navyDark,)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                      '${opt['category'] ?? "General"} · ${opt['mode'] ?? "Online"} · ${DateFormat('d MMM yyyy').format(date)}'),
                  Text('${opt['organizer'] ?? "N/A"} @ ${opt['venue'] ?? "N/A"}',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _countBadge('$count applied', Colors.blueGrey),
                      const SizedBox(width: 6),
                      if (pending > 0)
                        _countBadge('$pending pending', Colors.orange),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: navy,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TrainingApplicantsScreen(
                      option: opt,
                      applicants: List<Map<String, dynamic>>.from(
                        opt['applicants'] as List? ?? [],
                      ),
                    ),
                  ),
                );
                _load();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _countBadge(String label, Color color) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

  Widget _buildTeacherProgress() {
    final year = DateTime.now().year;

    if (_teacherProgress.isEmpty) {
      return const Center(child: Text('No teacher records found.'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Annual Training Progress ($year)',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Minimum required: 3 approved trainings per teacher',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 16),
          ..._teacherProgress.map((t) {
            final count = t['approved_count'] as int? ?? 0;
            final met = count >= 3;
            final progress = (count / 3).clamp(0.0, 1.0);

            return Card(
              elevation: 3,
              shadowColor: navy.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(t['full_name'] as String? ?? 'Unknown',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: met
                                ? Colors.green.withOpacity(0.12)
                                : Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: met
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.orange.withOpacity(0.5)),
                          ),
                          child: Text(
                            met ? 'Quota Met ✓' : '$count / 3',
                            style: TextStyle(
                                color: met ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        color: met ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$count approved training${count == 1 ? '' : 's'} this year',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class TrainingApplicantsScreen extends StatefulWidget {
  final Map<String, dynamic> option;
  final List<Map<String, dynamic>> applicants;

  const TrainingApplicantsScreen({
    super.key,
    required this.option,
    required this.applicants,
  });

  @override
  State<TrainingApplicantsScreen> createState() =>
      _TrainingApplicantsScreenState();
}

class _TrainingApplicantsScreenState extends State<TrainingApplicantsScreen> {
  final _svc = TrainingService();
  final _docStorageSvc = StorageService();
  late List<Map<String, dynamic>> _applicants;
  final Map<String, Future<String>> _downloadUrlCache = {};

  @override
  void initState() {
    super.initState();
    _applicants = List.from(widget.applicants);
    _precacheUrls();
  }

  void _precacheUrls() {
    for (var a in _applicants) {
      final photoUrls = List<String>.from(a['photo_urls'] ?? []);
      for (var path in photoUrls) {
        _downloadUrlCache.putIfAbsent(path, () => _docStorageSvc.getDownloadUrl(path));
      }
    }
  }

  Future<void> _updateStatus(String trainingId, String status) async {
    try {
      await _svc.updateTrainingStatus(trainingId, status);
      setState(() {
        final idx = _applicants.indexWhere((a) => a['id'] == trainingId);
        if (idx != -1) {
          _applicants[idx] = {..._applicants[idx], 'status': status};
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  void _showPhotoDialog(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
                child: Center(child: Image.network(url, fit: BoxFit.contain))),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'approved' => Colors.blue,
        'rejected' => Colors.red,
        'completed' => Colors.green,
        _ => Colors.orange,
      };

  IconData _statusIcon(String status) => switch (status) {
        'approved' => Icons.check_circle_outline,
        'rejected' => Icons.cancel,
        'completed' => Icons.verified,
        _ => Icons.pending_actions,
      };

  @override
  Widget build(BuildContext context) {
    final opt = widget.option;
    final date = DateTime.tryParse(opt['training_date'] as String? ?? '') ??
        DateTime.now();

    return Scaffold(
      appBar: AppBar(
          title: Text(opt['title'] as String? ?? 'Details',
              overflow: TextOverflow.ellipsis)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detail('Category', opt['category'] as String? ?? 'N/A'),
                _detail('Organizer', opt['organizer'] as String? ?? 'N/A'),
                _detail('Date', DateFormat('d MMM yyyy').format(date)),
                _detail('Duration', '${opt['duration_hours'] ?? 0} hours'),
                _detail('Mode', '${opt['mode'] ?? "Online"} @ ${opt['venue'] ?? "N/A"}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Applicants (${_applicants.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                _miniCount(
                    _applicants.where((a) => a['status'] == 'pending').length,
                    'pending',
                    Colors.orange),
                const SizedBox(width: 6),
                _miniCount(
                    _applicants.where((a) => a['status'] == 'approved').length,
                    'approved',
                    Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _applicants.isEmpty
                ? const Center(child: Text('No applications yet.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _applicants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final a = _applicants[i];
                      final status = a['status'] as String? ?? 'pending';
                      final tr = a['teacher_records'];
                      final name = tr is Map
                          ? tr['full_name'] as String? ?? 'Unknown'
                          : 'Unknown';
                      final reflection = a['reflection'] as String?;
                      final certUrl = a['certificate_url'] as String?;
                      final photoUrls = List<String>.from(a['photo_urls'] ?? []);

                      return Card(
                        elevation: 3,
                        shadowColor: navy.withOpacity(0.15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    child: Text(
                                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                  ),
                                  Icon(_statusIcon(status),
                                      color: _statusColor(status)),
                                  const SizedBox(width: 4),
                                  Text(status.toUpperCase(),
                                      style: TextStyle(
                                          color: _statusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                ],
                              ),
                              if (reflection != null && reflection.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                const Text('Reflection',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                const SizedBox(height: 4),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text('"$reflection"',
                                      style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13)),
                                ),
                              ],
                              if (certUrl != null && certUrl.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Text('Certificate',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () async {
                                    final url = await _docStorageSvc.getDownloadUrl(certUrl);
                                    await launchUrl(Uri.parse(url),
                                        mode: LaunchMode.inAppBrowserView);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red.shade200),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.picture_as_pdf,
                                            color: Colors.red, size: 18),
                                        SizedBox(width: 6),
                                        Text('View Certificate',
                                            style: TextStyle(color: Colors.red)),
                                        SizedBox(width: 6),
                                        Icon(Icons.open_in_new,
                                            color: Colors.red, size: 14),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              if (photoUrls.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Text('Training Photos',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                                const SizedBox(height: 6),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 6,
                                    mainAxisSpacing: 6,
                                    childAspectRatio: 1,
                                  ),
                                  itemCount: photoUrls.length,
                                  itemBuilder: (_, pi) {
                                    final path = photoUrls[pi];
                                    final futureUrl = _downloadUrlCache[path] ??
                                        _docStorageSvc.getDownloadUrl(path);

                                    return FutureBuilder<String>(
                                      future: futureUrl,
                                      builder: (context, snap) {
                                        if (!snap.hasData) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade200,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2)),
                                          );
                                        }
                                        return GestureDetector(
                                          onTap: () => _showPhotoDialog(snap.data!),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(snap.data!,
                                                fit: BoxFit.cover),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                              if (status == 'pending') ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateStatus(
                                            a['id'] as String, 'rejected'),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.red,
                                            side: const BorderSide(
                                                color: Colors.red)),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateStatus(
                                            a['id'] as String, 'approved'),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white),
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (status == 'approved') ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => _updateStatus(
                                      a['id'] as String, 'pending'),
                                  child: const Text('Reset to Pending',
                                      style: TextStyle(color: Colors.blueGrey)),
                                ),
                              ],
                              if (status == 'completed') ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.verified,
                                        color: Colors.green.shade600, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Report submitted and completed',
                                      style: TextStyle(
                                          color: Colors.green.shade600,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(
                width: 80,
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600))),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
          ],
        ),
      );

  Widget _miniCount(int count, String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$count $label',
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      );
}