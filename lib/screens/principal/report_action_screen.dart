import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/report_service.dart';

class ReportActionScreen extends StatefulWidget {
  final dynamic report;

  const ReportActionScreen({super.key, required this.report});

  @override
  State<ReportActionScreen> createState() => _ReportActionScreenState();
}

class _ReportActionScreenState extends State<ReportActionScreen> {
  // Brand colors
  static const Color navy = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgGrey = Color(0xFFF5F6F8);

  static const List<String> statusOptions = [
    "Pending",
    "Under Review",
    "In Progress",
    "Resolved",
  ];

  final reportService = ReportService();
  final commentController = TextEditingController();

  String selectedStatus = "Pending";
  bool updating = false;

  @override
  void initState() {
    super.initState();
    final currentStatus = widget.report['status'];
    selectedStatus =
        statusOptions.contains(currentStatus) ? currentStatus : "Pending";
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved":
        return const Color(0xFF2E7D32);
      case "In Progress":
        return gold;
      case "Under Review":
        return navy;
      default:
        return navy.withOpacity(0.55);
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "Resolved":
        return Icons.check_circle_rounded;
      case "In Progress":
        return Icons.autorenew_rounded;
      case "Under Review":
        return Icons.visibility_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  Future<void> updateReport() async {
    setState(() => updating = true);

    try {
      await reportService.updateReportStatus(
        reportId: widget.report['id'],
        status: selectedStatus,
        comment: commentController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Updated successfully"),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("UPDATE ERROR: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to update report. Please try again."),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    } finally {
      if (mounted) setState(() => updating = false);
    }
  }

  Future<void> _openUrl(String url) async {
    if (url.isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not open file"),
          backgroundColor: Color(0xFFC62828),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = widget.report;
    final String status = report['status'] ?? 'Pending';

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Report Action",
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
            _buildHeaderCard(report, status),
            const SizedBox(height: 16),
            _buildInfoCard(report),
            const SizedBox(height: 16),
            _buildEvidenceCard(report),
            const SizedBox(height: 16),
            _buildUpdateCard(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeaderCard(dynamic report, String status) {
    final statusColor = getStatusColor(status);

    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              report['reference_no'] ?? '-',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
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
  Widget _buildInfoCard(dynamic report) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            icon: Icons.category_outlined,
            label: "Type",
            value: report['report_type'] ?? '-',
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.notes_rounded,
            label: "Description",
            value: report['description'] ?? '-',
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.comment_outlined,
            label: "Principal Comment",
            value: report['principal_remark'] ?? "No comment yet",
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
          child: Icon(icon, size: 16, color: navy),
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
  Widget _buildEvidenceCard(dynamic report) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Evidence",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 10),
          FutureBuilder(
            future: Supabase.instance.client
                .from('report_evidence')
                .select()
                .eq('report_id', report['id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: navy),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return _evidencePlaceholder("No evidence provided");
              }

              final data = snapshot.data as List;

              if (data.isEmpty) {
                return _evidencePlaceholder("No evidence provided");
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

  Widget _evidencePlaceholder(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.folder_off_outlined, size: 26, color: Colors.black26),
            const SizedBox(height: 6),
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

    final IconData icon = type == 'video'
        ? Icons.videocam_rounded
        : type == 'image'
            ? Icons.image_rounded
            : Icons.insert_drive_file_rounded;

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
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 42,
                      height: 42,
                      color: gold.withOpacity(0.15),
                      child: Icon(icon, size: 18, color: navy),
                    ),
                  )
                : Container(
                    width: 42,
                    height: 42,
                    color: gold.withOpacity(0.15),
                    child: Icon(icon, size: 18, color: navy),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.isNotEmpty ? type[0].toUpperCase() + type.substring(1) : 'File',
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
          IconButton(
            icon: const Icon(Icons.open_in_new_rounded, size: 19, color: navy),
            onPressed: () => _openUrl(url),
          ),
        ],
      ),
    );
  }

  // ================= UPDATE STATUS =================
  Widget _buildUpdateCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Update Status",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: selectedStatus,
            items: statusOptions
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => selectedStatus = value);
            },
            decoration: InputDecoration(
              labelText: "Status",
              labelStyle: const TextStyle(color: navy, fontSize: 13),
              filled: true,
              fillColor: bgGrey,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: navy, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Principal Comment",
              hintText: "Add a remark for this report",
              labelStyle: const TextStyle(color: navy, fontSize: 13),
              filled: true,
              fillColor: bgGrey,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: navy, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: updating ? null : updateReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                disabledBackgroundColor: navy.withOpacity(0.4),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: updating
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("Updating...", style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 19),
                        SizedBox(width: 8),
                        Text(
                          "Update Report",
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
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