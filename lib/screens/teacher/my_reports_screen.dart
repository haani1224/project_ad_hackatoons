import 'package:flutter/material.dart';
import '../../services/report_service.dart';
import 'package:intl/intl.dart';
import 'report_details_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final int userId;

  const MyReportsScreen({super.key, required this.userId});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  // Brand colors
  static const Color navy = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);

  final reportService = ReportService();
  List reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {
    final data = await reportService.getReportsByUser(widget.userId.toString());

    setState(() {
      reports = data;
      loading = false;
    });
  }

  Color getStatusColor(String status) {
    switch (status) {
      case "Resolved":
        return const Color(0xFF2E7D32);
      case "In Progress":
        return gold;
      case "Rejected":
        return const Color(0xFFC62828);
      default:
        return navy.withOpacity(0.55);
    }
  }

  String formatDate(String? raw) {
    if (raw == null) return 'No date';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return 'No date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0.5,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "My Reports",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            if (!loading)
              Text(
                "${reports.length} report${reports.length == 1 ? '' : 's'} submitted",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: navy))
          : reports.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: navy,
                  onRefresh: loadReports,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 76,
                      endIndent: 20,
                      color: Colors.grey.withOpacity(0.15),
                    ),
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      return _buildReportRow(context, report);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 14),
            const Text(
              "No reports yet",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: navy),
            ),
            const SizedBox(height: 4),
            const Text(
              "Reports you submit will show up here.",
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportRow(BuildContext context, Map<String, dynamic> report) {
    final String status = report['status'] ?? 'Pending';
    final String referenceNo = report['reference_no'] ?? 'No Ref';
    final String reportType = report['report_type'] ?? 'No Type';
    final statusColor = getStatusColor(status);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailsScreen(report: report),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: navy.withOpacity(0.08),
              child: const Icon(Icons.description_outlined, color: navy, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    referenceNo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    reportType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.withOpacity(0.8)),
                      const SizedBox(width: 4),
                      Text(
                        formatDate(report['created_at']),
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey.withOpacity(0.6)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}