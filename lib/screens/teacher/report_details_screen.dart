import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'upload_evidence.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> report;

  const ReportDetailsScreen({
    super.key,
    required this.report,
  });

  // Brand colors
  static const Color navy = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgGrey = Color(0xFFF5F6F8);

  String formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('dd/MM/yyyy hh:mm a').format(dt);
    } catch (e) {
      return "No date";
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Resolved':
        return const Color(0xFF2E7D32);
      case 'In Progress':
        return gold;
      case 'Under Review':
        return navy;
      case 'Rejected':
        return const Color(0xFFC62828);
      default:
        return navy.withOpacity(0.6);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle_rounded;
      case 'In Progress':
        return Icons.autorenew_rounded;
      case 'Under Review':
        return Icons.visibility_rounded;
      case 'Rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  // index of the current step in the timeline, -1 for rejected (special case)
  int currentStepIndex(String status) {
    switch (status) {
      case 'Under Review':
        return 1;
      case 'In Progress':
        return 2;
      case 'Resolved':
        return 3;
      case 'Rejected':
        return -1;
      default:
        return 0; // Pending / just submitted
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = report['status'] ?? 'Pending';

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Report Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(status),
            const SizedBox(height: 18),
            _buildInfoCard(),
            const SizedBox(height: 18),
            _buildEvidenceCard(context),
            const SizedBox(height: 18),
            _buildTimelineCard(status),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeaderCard(String status) {
    final statusColor = getStatusColor(status);

    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report['reference_no'] ?? 'No Reference',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report['id'] != null ? "ID: ${report['id']}" : '',
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(getStatusIcon(status), size: 13, color: statusColor),
                const SizedBox(width: 5),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= REPORT INFO =================
  Widget _buildInfoCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            icon: Icons.category_outlined,
            label: "Report Type",
            value: report['report_type'] ?? 'No report type provided',
          ),
          const SizedBox(height: 16),
          _infoRow(
            icon: Icons.notes_rounded,
            label: "Description",
            value: report['description'] ?? 'No description provided',
          ),
          const SizedBox(height: 16),
          _infoRow(
            icon: Icons.access_time_rounded,
            label: "Created At",
            value: formatDateTime(report['created_at'] ?? ''),
          ),
          const SizedBox(height: 16),
          _infoRow(
            icon: Icons.comment_outlined,
            label: "Principal Comment",
            value: report['principal_remark'] ?? 'No comment yet',
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: navy.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17, color: navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ================= EVIDENCE =================
  Widget _buildEvidenceCard(BuildContext context) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Evidence",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UploadEvidenceScreen(
                        reportId: report['id'].toString(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text("Add"),
                style: TextButton.styleFrom(foregroundColor: navy),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder(
            future: Supabase.instance.client
                .from('report_evidence')
                .select()
                .eq('report_id', report['id']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _evidencePlaceholder(
                  icon: Icons.hourglass_top_rounded,
                  text: "Loading evidence...",
                );
              }

              final data = snapshot.data as List;

              if (data.isEmpty) {
                return _evidencePlaceholder(
                  icon: Icons.folder_off_outlined,
                  text: "No evidence was provided",
                );
              }

              return Column(
                children: data.map((e) => _evidenceTile(e)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _evidencePlaceholder({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.black26),
            const SizedBox(height: 8),
            Text(text, style: const TextStyle(color: Colors.black45, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _evidenceTile(Map e) {
    final String type = e['file_type'] ?? 'file';
    final String url = e['file_url'] ?? '';
    final String fileName = url.isNotEmpty ? url.split('/').last : 'Unknown file';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: navy.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: type == 'image' && url.isNotEmpty
                ? Image.network(
                    url,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _evidenceIconBox(type),
                  )
                : _evidenceIconBox(type),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type[0].toUpperCase() + type.substring(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenceIconBox(String type) {
    final IconData icon = type == 'video'
        ? Icons.videocam_rounded
        : type == 'image'
            ? Icons.image_rounded
            : Icons.insert_drive_file_rounded;

    return Container(
      width: 44,
      height: 44,
      color: gold.withOpacity(0.15),
      child: Icon(icon, size: 20, color: navy),
    );
  }

  // ================= TIMELINE =================
  Widget _buildTimelineCard(String status) {
    final int currentIndex = currentStepIndex(status);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Timeline",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 14),
          if (currentIndex == -1)
            Row(
              children: [
                const Icon(Icons.cancel_rounded, color: Color(0xFFC62828)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "This report was rejected.",
                    style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            )
          else
            _timelineSteps(currentIndex),
        ],
      ),
    );
  }

  Widget _timelineSteps(int currentIndex) {
    final steps = [
      {"icon": Icons.check_circle_rounded, "label": "Report Submitted"},
      {"icon": Icons.visibility_rounded, "label": "Under Review"},
      {"icon": Icons.autorenew_rounded, "label": "In Progress"},
      {"icon": Icons.flag_rounded, "label": "Resolved"},
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        final bool done = i <= currentIndex;
        final bool isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: done ? navy : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: done ? navy : Colors.black26,
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    steps[i]["icon"] as IconData,
                    size: 15,
                    color: done ? gold : Colors.black26,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 32,
                    color: i < currentIndex ? navy : Colors.black12,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                steps[i]["label"] as String,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                  color: done ? navy : Colors.black45,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= SHARED CARD WRAPPER =================
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}