import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/m4_training_service.dart';
import '../../services/m1_docstorage_service.dart';
import '../../models/m4_training_model.dart';
import '../../widgets/loading_widget.dart';
import 'm4_ptraining2_screen.dart';
import '../../utils/theme_constants.dart';
import '../../services/app_notification_service.dart';

class PrincipalTrainingScreen extends StatefulWidget {
  const PrincipalTrainingScreen({super.key});

  @override
  State<PrincipalTrainingScreen> createState() =>
      _PrincipalTrainingScreenState();
}

class _PrincipalTrainingScreenState extends State<PrincipalTrainingScreen>
    with SingleTickerProviderStateMixin {
  final _svc = TrainingService();
  final _notificationSvc = AppNotificationService();
  // final _docStorageSvc = StorageService();
  final _searchController = TextEditingController();

  String _search = '';
  String? _filterStatus;

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

  List<Map<String,dynamic>> get filteredOptions {
    return _options.where((o){
      final title = (o['title'] ?? '').toLowerCase();
      final matchesSearch =
          title.contains(_search.toLowerCase());
      final isCancelled = o['is_cancelled'] == true;
      final date = DateTime.tryParse(
            o['training_date'] as String? ?? '',
          ) ??
          DateTime.now();
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      final trainingDay = DateTime(
        date.year,
        date.month,
        date.day,
      );
      final isClosed = !isCancelled && !trainingDay.isAfter(today);

      bool matchesFilter = true;

      if (_filterStatus == "Upcoming") {
        matchesFilter = !isCancelled && !isClosed;
      }
      if (_filterStatus == "Closed") {
        matchesFilter = isClosed;
      }
      if (_filterStatus == "Cancelled") {
        matchesFilter = isCancelled;
      }
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        _svc.getTrainingOptionsWithApplicants(),
        _svc.getAllTeachersQuotaProgress(DateTime.now().year),
      ]);

      if (!mounted) return;

      setState(() {
        _options = results[0];
        _teacherProgress = results[1];
        _loading = false;
      });
    } catch (e, s) {
      debugPrint('LOAD ERROR: $e\n$s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load records: $e')),
        );
        setState(() => _loading = false);
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

  // ── Fix #6: confirmation dialog before cancelling a training option ──
  Future<bool> _confirmCancel(String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Training Option'),
        content: Text(
          'Are you sure you want to cancel "$title"? '
          'It will be hidden from teachers and no longer accept new applications. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );
    return confirm ?? false;
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
      child: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search training...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() => _search = value);
              },
            ),
          ),

          // Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _filterStatus,
              decoration: const InputDecoration(
                labelText: 'Filter',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                DropdownMenuItem(value: 'Closed', child: Text('Closed')),
                DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                setState(() => _filterStatus = value);
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOptions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final opt = filteredOptions[i];
              final count = opt['application_count'] as int? ?? 0;
              final pending = opt['pending_count'] as int? ?? 0;
              final date = DateTime.tryParse(opt['training_date'] as String? ?? '') ??
                  DateTime.now();
              final isCancelled = opt['is_cancelled'] == true;
              final today = DateTime.now();
              final trainingDay = DateTime(
                date.year,
                date.month,
                date.day,
              );
              final currentDay = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final isClosed = !isCancelled && !trainingDay.isAfter(currentDay);
              return Card(
                elevation: 3,
                shadowColor: navy.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt['title'] as String? ?? 'Untitled',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: (isCancelled || isClosed)
                                ? Colors.grey
                                : navyDark,

                            decoration: isCancelled
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),

                      if (isCancelled)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "CANCELLED",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "CLOSED",
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
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
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: navy),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTrainingOptionScreen(
                              option: TrainingOption.fromMap(Map<String, dynamic>.from(opt)),
                            ),
                          ),
                        );
                        _load();
                      }

                      if (value == 'cancel') {
                        final title = opt['title'] as String? ?? 'this training';
                        final confirmed = await _confirmCancel(title);
                        if (!confirmed) return;
                        await _notificationSvc.notifyTrainingCancelled(
                            trainingOptionId: opt['id'].toString(),
                            title: opt['title'],
                        );
                        await _svc.cancelTrainingOption(opt['id'].toString());
                        _load();
                      }
                    },
                    itemBuilder: (_) => [
                      if (!isCancelled && !isClosed)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),

                      if (!isCancelled && !isClosed)
                        const PopupMenuItem(
                          value: 'cancel',
                          child: Text('Cancel'),
                        ),
                    ],
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
          ),
        ],
      )
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
          const SizedBox(height: 4),
          Text('Tap a teacher to see their full training history.',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          ..._teacherProgress.map((t) {
            final count = t['approved_count'] as int? ?? 0;
            final met = count >= 3;
            final progress = (count / 3).clamp(0.0, 1.0);
            final userId = t['user_id'] as String? ?? '';
            final fullName = t['full_name'] as String? ?? 'Unknown';

            return Card(
              elevation: 3,
              shadowColor: navy.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                // ── Fix principal-side #1: drill into a teacher's full training list ──
                onTap: userId.isEmpty
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TeacherTrainingHistoryScreen(
                              teacherUuid: userId,
                              teacherName: fullName,
                            ),
                          ),
                        );
                      },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(fullName,
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
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
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
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// NEW: Full training history for a single teacher (principal view)
// ─────────────────────────────────────────────────────────────────
class TeacherTrainingHistoryScreen extends StatefulWidget {
  final String teacherUuid;
  final String teacherName;

  const TeacherTrainingHistoryScreen({
    super.key,
    required this.teacherUuid,
    required this.teacherName,
  });

  @override
  State<TeacherTrainingHistoryScreen> createState() =>
      _TeacherTrainingHistoryScreenState();
}

class _TeacherTrainingHistoryScreenState
    extends State<TeacherTrainingHistoryScreen> {
  final _svc = TrainingService();
  List<TrainingRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _svc.getMyTrainings(widget.teacherUuid);
      if (!mounted) return;
      setState(() {
        _records = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load training history: $e')),
      );
    }
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
    final approvedOrCompleted =
        _records.where((r) => r.isApproved || r.isCompleted).length;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text("${widget.teacherName}'s Trainings",
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: _loading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: _records.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('No training records found.')),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: navy.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: navy.withOpacity(0.15)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.school_rounded, color: navy),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$approvedOrCompleted approved/completed out of ${_records.length} total applications',
                                  style: const TextStyle(
                                      color: navyDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._records.map((r) => Card(
                              elevation: 3,
                              shadowColor: navy.withOpacity(0.15),
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                title: Text(r.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: navyDark)),
                                subtitle: Text(
                                  '${r.category} · ${DateFormat('d MMM yyyy').format(r.trainingDate)}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(_statusIcon(r.status),
                                        color: _statusColor(r.status),
                                        size: 18),
                                    const SizedBox(width: 4),
                                    Text(r.status.toUpperCase(),
                                        style: TextStyle(
                                            color: _statusColor(r.status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11)),
                                  ],
                                ),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PrincipalTrainingReportScreen(
                                        training: r,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )),
                      ],
                    ),
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
  final _notificationSvc = AppNotificationService();
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
      final photoUrls = (a['photo_urls'] as List? ?? []).cast<String>();
      for (var path in photoUrls) {
        _downloadUrlCache.putIfAbsent(path, () => _docStorageSvc.getDownloadUrl(path));
      }
    }
  }

  Future<void> _updateStatus(
    String trainingId,
    String status, [
    String? rejectionReason,
  ]) async {
    try {
      await _svc.updateTrainingStatus(
        trainingId,
        status,
        rejectionReason,
      );

      int idx = _applicants.indexWhere(
        (a) => a['id'].toString() == trainingId,
      );

      if (idx == -1) return;

      setState(() {
        _applicants[idx] = {
          ..._applicants[idx],
          'status': status,
          'rejection_reason':
              status == 'rejected' ? rejectionReason : null,
        };
      });

      await _notificationSvc.notifyTrainingStatusUpdated(
        teacherId: _applicants[idx]['teacher_uuid'],
        trainingTitle: widget.option['title'],
        status: status,
        rejectionReason: rejectionReason,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<bool?> _showApproveDialog() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Approve Application"),
        content: const Text(
          "Are you sure you want to approve this training application?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Approve"),
          ),
        ],
      ),
    );
  }

  Future<String?> _showRejectDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Application"),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: "Reason for rejection",
            hintText: "Enter rejection reason...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              Navigator.pop(context, controller.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
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
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(opt['title'] as String? ?? 'Details',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // ── Fix principal-side #2: explicit light background + explicit
          // text colors so this card is legible regardless of the app's
          // ambient/dark theme (previously relied on theme colorScheme,
          // which could render dark-on-dark). ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: navy.withOpacity(0.15)),
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
                        fontWeight: FontWeight.bold, fontSize: 16, color: navyDark)),
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
                      final name = (tr is Map && tr['full_name'] != null)
                        ? tr['full_name'].toString()
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
                                            fontSize: 15,
                                            color: navyDark)),
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
                                        fontSize: 13,
                                        color: navyDark)),
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
                                          fontSize: 13,
                                          color: Colors.black87)),
                                ),
                              ],
                              if (certUrl != null && certUrl.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                const Text('Certificate',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: navyDark)),
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
                                        fontSize: 13,
                                        color: navyDark)),
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
                                        onPressed: () async {
                                          final reason = await _showRejectDialog();

                                          if (reason != null) {
                                            await _updateStatus(
                                              (a['id'] ?? '').toString(),
                                              'rejected',
                                              reason,
                                            );
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                        ),
                                        child: const Text('Reject'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          final confirm = await _showApproveDialog();

                                          if (confirm == true) {
                                            await _updateStatus(
                                              (a['id'] ?? '').toString(),
                                              'approved',
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (status == 'approved' || status == 'rejected') ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () async {
                                    await _updateStatus(
                                      (a['id'] ?? '').toString(),
                                      'pending',
                                    );
                                  },
                                  child: Text(
                                    status == 'rejected'
                                        ? 'Revert Rejection'
                                        : 'Reset to Pending',
                                    style: const TextStyle(color: Colors.blueGrey),
                                  ),
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
            Expanded(
                child: Text(value,
                    style: const TextStyle(fontSize: 13, color: navyDark))),
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

class PrincipalTrainingReportScreen extends StatefulWidget {
  final TrainingRecord training;

  const PrincipalTrainingReportScreen({
    super.key,
    required this.training,
  });

  @override
  State<PrincipalTrainingReportScreen> createState() =>
      _PrincipalTrainingReportScreenState();
}

class _PrincipalTrainingReportScreenState
    extends State<PrincipalTrainingReportScreen> {

  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {

    final t = widget.training;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Training Report"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            _sectionCard(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  _info("Training", t.title),

                  _info("Status",
                      t.status.toUpperCase()),

                  _info("Category", t.category),

                  _info("Organizer",
                      t.organizer),

                  _info(
                    "Date",
                    DateFormat("d MMM yyyy")
                        .format(t.trainingDate),
                  ),

                  _info(
                    "Duration",
                    "${t.durationHours} hours",
                  ),

                  _info("Mode", t.mode),

                  _info("Venue", t.venue),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Reflection",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: navy.withOpacity(.05),
                borderRadius:
                    BorderRadius.circular(12),
              ),

              child: Text(
                t.reflection?.isNotEmpty == true
                    ? t.reflection!
                    : t.isRejected
                        ? "This training application was rejected by the principal. No training report was submitted."
                        : t.isPending
                            ? "This training has not been approved yet. A reflection can only be submitted after approval."
                            : "No reflection submitted.",
                style: TextStyle(
                  color: t.isRejected
                      ? Colors.red
                      : Colors.grey.shade700,
                  fontStyle: FontStyle.normal
                ),
              ),
            ),

                        if (t.certificateUrl != null) ...[

              const SizedBox(height: 24),

              const Text(
                "Certificate",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              ListTile(

                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                ),

                title:
                    const Text("View Certificate"),

                trailing:
                    const Icon(Icons.open_in_new),

                onTap: () async {

                  final url =
                      await _storage.getDownloadUrl(
                    t.certificateUrl!,
                  );

                  await launchUrl(
                    Uri.parse(url),
                    mode:
                        LaunchMode.inAppBrowserView,
                  );
                },
              ),
            ],

                        if (t.photoUrls.isNotEmpty) ...[

              const SizedBox(height: 24),

              const Text(
                "Training Photos",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),

              const SizedBox(height: 10),

              GridView.builder(

                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 3,

                  crossAxisSpacing: 8,

                  mainAxisSpacing: 8,
                ),

                itemCount: t.photoUrls.length,

                itemBuilder: (_, index) {

                  return FutureBuilder<String>(

                    future: _storage.getDownloadUrl(
                        t.photoUrls[index]),

                    builder: (_, snapshot) {

                      if (!snapshot.hasData) {

                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      return GestureDetector(

                        onTap: () {

                          showDialog(

                            context: context,

                            builder: (_) => Dialog(

                              child: Image.network(
                                  snapshot.data!),
                            ),
                          );
                        },

                        child: ClipRRect(

                          borderRadius:
                              BorderRadius.circular(10),

                          child: Image.network(

                            snapshot.data!,

                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
                      ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: navy.withOpacity(.05),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: navy.withOpacity(.15),
        ),
      ),
      child: child,
    );
  }

  Widget _info(
      String label,
      String value,
      ) {

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 3),

      child: Row(
        children: [

          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}