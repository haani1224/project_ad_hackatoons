import 'report_action_screen.dart'
    show ReportActionScreen;
import 'package:flutter/material.dart';
import '../../services/report_service.dart';

class PrincipalDashboard extends StatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  State<PrincipalDashboard> createState() => _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  // Brand colors
  static const Color navy = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgGrey = Color(0xFFF5F6F8);

  final reportService = ReportService();
  final searchController = TextEditingController();

  List<Map<String, dynamic>> reports = [];
  bool loading = true;
  String searchQuery = '';
  String selectedStatus = 'All';

  static const List<String> statusOptions = [
    'All',
    'Pending',
    'Under Review',
    'In Progress',
    'Resolved',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadReports() async {
    final data = await reportService.getAllReports();

    setState(() {
      reports = List<Map<String, dynamic>>.from(data);
      loading = false;
    });
  }

  Color getColor(String status) {
    switch (status) {
      case "Resolved":
        return const Color(0xFF2E7D32);
      case "In Progress":
        return gold;
      case "Under Review":
        return navy;
      case "Rejected":
        return const Color(0xFFC62828);
      default:
        return navy.withOpacity(0.55);
    }
  }

  String formatDate(String? raw) {
    if (raw == null) return 'No date';
    try {
      final dt = DateTime.parse(raw);
      return "${dt.day.toString().padLeft(2, '0')}/"
          "${dt.month.toString().padLeft(2, '0')}/"
          "${dt.year} "
          "${dt.hour.toString().padLeft(2, '0')}:"
          "${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return 'No date';
    }
  }

  // reports table only stores reporter_id (uuid). If your reportService
  // join includes the related user row (e.g. users:reporter_id(staff_id)),
  // this will pick it up automatically under a few common key shapes.
  String extractStaffId(Map r) {
    if (r['staff_id'] != null) return r['staff_id'].toString();
    final candidates = ['users', 'user', 'reporter'];
    for (final key in candidates) {
      final value = r[key];
      if (value is Map && value['staff_id'] != null) {
        return value['staff_id'].toString();
      }
    }
    return '';
  }

  bool matchesSearch(Map r, String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    final ref = (r['reference_no'] ?? '').toString().toLowerCase();
    final type = (r['report_type'] ?? '').toString().toLowerCase();
    final staffId = extractStaffId(r).toLowerCase();
    return ref.contains(q) || type.contains(q) || staffId.contains(q);
  }

  List<Map<String, dynamic>> get filteredReports {
    return reports.where((r) {
      final status = r['status'] ?? 'Pending';
      final matchesStatus = selectedStatus == 'All' || status == selectedStatus;
      return matchesStatus && matchesSearch(r, searchQuery);
    }).toList();
  }

  int countByStatus(String status) =>
      reports.where((r) => (r['status'] ?? 'Pending') == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Principal Dashboard",
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
      body: loading
          ? const Center(child: CircularProgressIndicator(color: navy))
          : Column(
              children: [
                _buildStatsRow(),
                const SizedBox(height: 4),
                _buildSearchBar(),
                const SizedBox(height: 10),
                _buildStatusFilterChips(),
                const SizedBox(height: 6),
                Expanded(
                  child: filteredReports.isEmpty
                      ? _buildNoResults()
                      : RefreshIndicator(
                          color: navy,
                          onRefresh: loadReports,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                            itemCount: filteredReports.length,
                            itemBuilder: (context, index) {
                              return _buildReportCard(
                                  context, filteredReports[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // ================= STATS ROW =================
  Widget _buildStatsRow() {
    final stats = [
      {"label": "Total", "value": reports.length, "color": navy},
      {"label": "Pending", "value": countByStatus("Pending"), "color": navy.withOpacity(0.55)},
      {"label": "In Progress", "value": countByStatus("In Progress"), "color": gold},
      {"label": "Resolved", "value": countByStatus("Resolved"), "color": const Color(0xFF2E7D32)},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: navy.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "${s['value']}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: s['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= SEARCH BAR =================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (value) => setState(() => searchQuery = value),
          style: const TextStyle(fontSize: 14, color: navy),
          decoration: InputDecoration(
            hintText: "Search by reference no, type or staff ID",
            hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
            prefixIcon: const Icon(Icons.search_rounded, color: navy, size: 22),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.black45),
                    onPressed: () {
                      searchController.clear();
                      setState(() => searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // ================= STATUS FILTER CHIPS =================
  Widget _buildStatusFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: statusOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statusOptions[index];
          final selected = status == selectedStatus;

          return GestureDetector(
            onTap: () => setState(() => selectedStatus = status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? navy : navy.withOpacity(0.25),
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : navy,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 52, color: Colors.grey.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text(
              "No matching reports found",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: navy),
            ),
            const SizedBox(height: 4),
            const Text(
              "Try a different search term or filter.",
              style: TextStyle(color: Colors.black45, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ================= REPORT CARD =================
  Widget _buildReportCard(BuildContext context, Map<String, dynamic> r) {
    final String status = r['status'] ?? 'Pending';
    final String referenceNo = r['reference_no'] ?? 'No Ref';
    final String reportType = r['report_type'] ?? 'No Type';
    final String? description = r['description'];
    final String staffId = extractStaffId(r);
    final statusColor = getColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReportActionScreen(report: r),
              ),
            ).then((_) => loadReports());
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.assignment_outlined, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              referenceNo,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: navy,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.4)),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.category_outlined, size: 13, color: Colors.black45),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reportType,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                      if (staffId.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 13, color: Colors.black45),
                            const SizedBox(width: 4),
                            Text(
                              "Staff ID: $staffId",
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                      if (description != null && description.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 12, color: Colors.black38),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(r['created_at']),
                            style: const TextStyle(fontSize: 11, color: Colors.black38),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}