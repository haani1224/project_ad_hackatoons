import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'create_report_screen.dart';
import 'my_reports_screen.dart';

// ── Color tokens ──────────────────────────────────────────────────────────────
const kNavy      = Color(0xFF2E4365);
const kNavyLight = Color(0xFF3A5480);
const kGold      = Color(0xFFE59D2C);
const kGoldLight = Color(0xFFFFF3DC);
const kWhite     = Colors.white;
const kBg        = Color(0xFFF5F7FA);
const kTextSub   = Color(0xFF7A8BA6);
const kDivider   = Color(0xFFE2E8F0);

// ── Data model ────────────────────────────────────────────────────────────────
class ReportItem {
  final String id;
  final String reportType;
  final DateTime createdAt;
  final String status;
  final String? fileUrl; // from report_evidence.file_url (Cloudinary)

  ReportItem({
    required this.id,
    required this.reportType,
    required this.createdAt,
    required this.status,
    this.fileUrl,
  });

  factory ReportItem.fromMap(Map<String, dynamic> map) {
    // report_evidence is a joined list; take first file_url if exists
    String? url;
    final evidence = map['report_evidence'];
    if (evidence is List && evidence.isNotEmpty) {
      url = evidence.first['file_url'] as String?;
    }

    return ReportItem(
      id: map['id'].toString(),
      reportType: map['report_type'] ?? 'Unknown',
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'] ?? 'draft',
      fileUrl: url,
    );
  }

  String get formattedDate => DateFormat('dd MMM yyyy').format(createdAt);

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'submitted':
        return const Color(0xFF16A34A);
      case 'approved':
        return const Color(0xFF2563EB);
      case 'rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706); // draft / amber
    }
  }

  IconData get typeIcon {
    switch (reportType.toLowerCase()) {
      case 'academic':
        return Icons.menu_book_rounded;
      case 'behaviour':
        return Icons.psychology_rounded;
      case 'activity':
        return Icons.sports_soccer_rounded;
      case 'medical':
        return Icons.medical_services_rounded;
      default:
        return Icons.description_rounded;
    }
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────
const List<String> _reportTypes = [
  'All',
  'Sexual Harassment',
  'Bullying',
  'Conflict between Staff',
  'SOP Violation',
  'Workload Stress',
  'Teacher Misconduct',
  'Facility Maintenance',
  'Teaching Material Shortage',
  'Safety Hazard',
  'IT / System Problem',
];

// ── Supabase client helper ────────────────────────────────────────────────────
final _supabase = Supabase.instance.client;

// ── Main Widget ───────────────────────────────────────────────────────────────
class TeacherHome extends StatefulWidget {
  final int userId;
  const TeacherHome({super.key, required this.userId});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'All';
  String _searchQuery   = '';

  // Supabase state
  List<ReportItem> _allReports  = [];
  bool  _isLoading = true;
  String? _error;

  // Stats derived from fetched data
  int get _totalReports    => _allReports.length;
  // int get _draftCount      => _allReports.where((r) => r.status.toLowerCase() == 'draft').length;
  // int get _submittedCount  => _allReports.where((r) => r.status.toLowerCase() == 'submitted').length;

  // Filtered + limited to 3 for "Recent Reports"
  List<ReportItem> get _filtered {
    return _allReports.where((r) {
      final matchType = _selectedType == 'All' ||
          r.reportType.toLowerCase() == _selectedType.toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          r.reportType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.formattedDate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.status.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchType && matchSearch;
    }).take(3).toList();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Supabase fetch ─────────────────────────────────────────────────────────
  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Join reports with report_evidence to get Cloudinary file_url
      // Filter by reporter_id = current userId
      // Order by latest first
      final response = await _supabase
          .from('reports')
          .select('''
            id,
            report_type,
            created_at,
            status,
            report_evidence (
              file_url
            )
          ''')
          .eq('reporter_id', widget.userId)
          .order('created_at', ascending: false);

      final List<ReportItem> items = (response as List)
          .map((row) => ReportItem.fromMap(row as Map<String, dynamic>))
          .toList();

      setState(() {
        _allReports = items;
        _isLoading  = false;
      });
    } on PostgrestException catch (e) {
      setState(() {
        _error     = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error     = 'Ralat tidak dijangka: $e';
        _isLoading = false;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: RefreshIndicator(
        color: kGold,
        onRefresh: _fetchReports,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(child: _buildSearchSection()),
            SliverToBoxAdapter(child: _buildReportsSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context),
    );
  }

  // ── App Bar ────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: kNavy,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              right: -40,
              top: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kNavyLight.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              right: 60,
              bottom: -50,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kGold.withOpacity(0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded,
                            color: kWhite, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to,',
                            style: TextStyle(
                              color: kWhite.withOpacity(0.7),
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const Text(
                            'Teacher Dashboard',
                            style: TextStyle(
                              color: kWhite,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_outlined,
                            color: kWhite),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Live stats from Supabase
                  _isLoading
                      ? const SizedBox(
                          height: 28,
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: kGold,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            _statPill(Icons.description_outlined,
                                '$_totalReports', 'Reports'),
                            const SizedBox(width: 10),
                            // _statPill(Icons.pending_actions_outlined,
                            //     '$_draftCount', 'Drafts'),
                            // const SizedBox(width: 10),
                            // _statPill(Icons.check_circle_outline,
                            //     '$_submittedCount', 'Submitted'),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(IconData icon, String count, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kWhite.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGold, size: 14),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: const TextStyle(
              color: kWhite,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions ──────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              color: kNavy,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _actionCard(
                  context,
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create Report',
                  sub: 'New submission',
                  color: kNavy,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateReportScreen(userId: widget.userId),
                    ),
                  ).then((_) => _fetchReports()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionCard(
                  context,
                  icon: Icons.folder_open_rounded,
                  label: 'My Reports',
                  sub: 'View all',
                  color: kGold,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MyReportsScreen(userId: widget.userId),
                    ),
                  ).then((_) => _fetchReports()),
                ),
              ),
              const SizedBox(width: 12),
              // Expanded(
              //   child: _actionCard(
              //     context,
              //     icon: Icons.edit_note_rounded,
              //     label: 'Drafts',
              //     sub: '$_draftCount pending',
              //     color: const Color(0xFF6366F1),
              //     onTap: () {},
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kNavy.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kNavy,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSub, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search & Filter ────────────────────────────────────────────────────────
  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kNavy.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(
                color: kNavy,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search by type of report, date or status...',
                hintStyle:
                    const TextStyle(color: kTextSub, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: kTextSub, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: kTextSub, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 16),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Filter chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _reportTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final type     = _reportTypes[i];
                final selected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:  selected ? kNavy : kWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: selected ? kNavy : kDivider),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: kNavy.withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        color: selected ? kWhite : kTextSub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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

  // ── Recent Reports ─────────────────────────────────────────────────────────
  Widget _buildReportsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  color: kNavy,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MyReportsScreen(userId: widget.userId),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View all →',
                  style: TextStyle(
                    color: kGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildReportsList(),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    // Loading state
    if (_isLoading) {
      return Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _skeletonCard(),
          ),
        ),
      );
    }

    // Error state
    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFDC2626), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gagal memuatkan data',
                    style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _error!,
                    style: const TextStyle(
                        color: Color(0xFF991B1B), fontSize: 11),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _fetchReports,
              child: const Text('Cuba lagi',
                  style: TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );
    }

    // Empty state
    final reports = _filtered;
    if (reports.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.inbox_rounded,
                color: kTextSub.withOpacity(0.35), size: 48),
            const SizedBox(height: 12),
            const Text(
              'No reports found',
              style: TextStyle(color: kTextSub, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: reports
          .map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _reportCard(r),
              ))
          .toList(),
    );
  }

  // ── Report Card (with Cloudinary thumbnail) ────────────────────────────────
  Widget _reportCard(ReportItem r) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // ── Cloudinary thumbnail or icon fallback ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: r.fileUrl != null
                      ? Image.network(
                          r.fileUrl!,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _iconFallback(r),
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return _shimmerBox(52, 52);
                          },
                        )
                      : _iconFallback(r),
                ),
                const SizedBox(width: 14),
                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.reportType,
                        style: const TextStyle(
                          color: kNavy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _tag(r.reportType,
                              kNavy.withOpacity(0.08), kNavy),
                          const SizedBox(width: 6),
                          _tag(r.formattedDate, kGoldLight, kGold),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // ── Status ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: r.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    r.status[0].toUpperCase() + r.status.substring(1),
                    style: TextStyle(
                      color: r.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconFallback(ReportItem r) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: kGoldLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(r.typeIcon, color: kGold, size: 24),
    );
  }

  // ── Skeleton shimmer card ──────────────────────────────────────────────────
  Widget _skeletonCard() {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _shimmerBox(52, 52, radius: 12),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _shimmerBox(16, double.infinity),
                  const SizedBox(height: 8),
                  _shimmerBox(12, 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double h, double w, {double radius = 6}) {
    return Container(
      height: h,
      width: w == double.infinity ? null : w,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  // ── Tag chip ───────────────────────────────────────────────────────────────
  Widget _tag(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── FAB ───────────────────────────────────────────────────────────────────
  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateReportScreen(userId: widget.userId),
        ),
      ).then((_) => _fetchReports()),
      backgroundColor: kGold,
      foregroundColor: kWhite,
      elevation: 4,
      icon: const Icon(Icons.add_rounded),
      label: const Text(
        'New Report',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}