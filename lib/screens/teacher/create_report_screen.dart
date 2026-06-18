import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:math';
import '../../services/evidence_service.dart';

// ── Color tokens (same system as TeacherHome) ─────────────────────────────────
const kNavy      = Color(0xFF2E4365);
const kNavyLight = Color(0xFF3A5480);
const kGold      = Color(0xFFE59D2C);
const kGoldLight = Color(0xFFFFF3DC);
const kWhite     = Colors.white;
const kBg        = Color(0xFFF5F7FA);
const kTextSub   = Color(0xFF7A8BA6);
const kDivider   = Color(0xFFE2E8F0);
const kError     = Color(0xFFDC2626);

// ── Report type model ─────────────────────────────────────────────────────────
class ReportType {
  final String value;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;

  const ReportType({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

const List<ReportType> kReportTypes = [
  ReportType(
    value: 'Sexual Harassment',
    label: 'Sexual Harassment',
    subtitle: 'Unwanted sexual behaviour or advances',
    icon: Icons.shield_outlined,
    color: Color(0xFFDC2626),
  ),
  ReportType(
    value: 'Bullying',
    label: 'Bullying',
    subtitle: 'Physical, emotional or social media',
    icon: Icons.warning_amber_rounded,
    color: Color(0xFFEA580C),
  ),
  ReportType(
    value: 'Conflict between Staff',
    label: 'Conflict between Staff',
    subtitle: 'Disputes or tension between staff members',
    icon: Icons.people_alt_outlined,
    color: Color(0xFFD97706),
  ),
  ReportType(
    value: 'SOP Violation',
    label: 'SOP Violation',
    subtitle: 'Failure to follow standard procedures',
    icon: Icons.gavel_rounded,
    color: Color(0xFF7C3AED),
  ),
  ReportType(
    value: 'Workload Stress',
    label: 'Workload Stress',
    subtitle: 'Excessive or unmanageable workload',
    icon: Icons.psychology_outlined,
    color: Color(0xFF0891B2),
  ),
  ReportType(
    value: 'Teacher Misconduct',
    label: 'Teacher Misconduct',
    subtitle: 'Inappropriate conduct by a teacher',
    icon: Icons.person_off_outlined,
    color: Color(0xFFBE185D),
  ),
  ReportType(
    value: 'Facility Maintenance',
    label: 'Facility Maintenance',
    subtitle: 'Broken or damaged school facilities',
    icon: Icons.construction_outlined,
    color: Color(0xFF059669),
  ),
  ReportType(
    value: 'Teaching Material Shortage',
    label: 'Teaching Material Shortage',
    subtitle: 'Lack of textbooks or learning materials',
    icon: Icons.menu_book_outlined,
    color: Color(0xFF2563EB),
  ),
  ReportType(
    value: 'Safety Hazard',
    label: 'Safety Hazard',
    subtitle: 'Potential risks to safety on premises',
    icon: Icons.report_problem_outlined,
    color: Color(0xFFD97706),
  ),
  ReportType(
    value: 'IT/System Problem',
    label: 'IT / System Problem',
    subtitle: 'Computer, network or software issues',
    icon: Icons.computer_outlined,
    color: Color(0xFF6366F1),
  ),
];

// ── Main widget ───────────────────────────────────────────────────────────────
class CreateReportScreen extends StatefulWidget {
  final int userId;
  const CreateReportScreen({super.key, required this.userId});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _scrollController = ScrollController();

  ReportType? _selectedType;
  bool _isAnonymous = false;
  bool _loading = false;

  File? _file;
  String? _fileType;
  String? _fileName;
  String? _referenceNo;

  final _evidenceService = EvidenceService();

  // ── Step tracking (type → details → evidence → review) ───────────────────
  int _currentStep = 0; // 0 = type, 1 = details, 2 = evidence

  @override
  void dispose() {
    _descController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Pickers ───────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _file = File(picked.path);
        _fileType = 'image';
        _fileName = picked.name;
      });
    }
  }

  Future<void> _pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _file = File(picked.path);
        _fileType = 'video';
        _fileName = picked.name;
      });
    }
  }

  Future<void> _pickPDF() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _file = File(result.files.single.path!);
        _fileType = 'raw';
        _fileName = result.files.single.name;
      });
    }
  }

  void _removeFile() => setState(() {
        _file = null;
        _fileType = null;
        _fileName = null;
      });

  // ── Generate reference number ─────────────────────────────────────────────
  String _generateReferenceNo() {
    final now = DateTime.now();

    final date =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    final rand = Random().nextInt(9000) + 1000; // 1000–9999

    return 'RPT-$date-$rand';
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<void> _submitReport() async {
    if (_selectedType == null) return;
    setState(() => _loading = true);

    try {
      final refNo = _generateReferenceNo();
      final response = await Supabase.instance.client
          .from('reports')
          .insert({
            'reference_no': refNo,
            'report_type': _selectedType!.value,
            'description': _descController.text.trim(),
            'is_anonymous': _isAnonymous,
            'reporter_id': widget.userId,
            'status': 'Pending',
          })
          .select()
          .single();

      final reportId = response['id'];

      if (_file != null && _fileType != null) {
        final url = await _evidenceService.uploadFile(_file!, _fileType!);
        if (url != null) {
          await Supabase.instance.client.from('report_evidence').insert({
            'report_id': reportId,
            'file_url': url,
            'file_type': _fileType,
          });
        }
      }

      if (!mounted) return;
      setState(() => _referenceNo = refNo);
      _showSuccessSheet(refNo);
    } catch (e) {
      debugPrint('ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ralat: $e'),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() => _loading = false);
  }

  void _showSuccessSheet(String refNo) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF16A34A), size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              'Report Submitted',
              style: TextStyle(
                color: kNavy,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your report has been received.\nOur team will review it shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSub, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: kGoldLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGold.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Reference No.',
                    style: TextStyle(
                      color: kTextSub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    refNo,
                    style: const TextStyle(
                      color: kNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Save this number for follow-up',
                    style: TextStyle(color: kTextSub, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // close sheet
                  Navigator.of(context).pop(); // back to dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kNavy,
                  foregroundColor: kWhite,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Back to Dashboard',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 24),
                _buildSectionLabel('1', 'Select Report Type'),
                const SizedBox(height: 14),
                _buildTypeGrid(),
                const SizedBox(height: 28),
                _buildSectionLabel('2', 'Report Details'),
                const SizedBox(height: 14),
                _buildDescriptionField(),
                const SizedBox(height: 16),
                _buildAnonymousToggle(),
                const SizedBox(height: 28),
                _buildSectionLabel('3', 'Attach Evidence'),
                const SizedBox(height: 6),
                _buildEvidenceNote(),
                const SizedBox(height: 14),
                _buildEvidenceSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: kNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: kWhite, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kNavyLight.withOpacity(0.45),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: kGold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_document,
                            color: kWhite, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Create Report',
                        style: TextStyle(
                          color: kWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
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

  // ── Step indicator ────────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    final steps = ['Type', 'Details', 'Evidence'];
    final completed = _selectedType != null
        ? (_descController.text.isNotEmpty ? 2 : 1)
        : 0;

    return Row(
      children: List.generate(steps.length, (i) {
        final done = i < completed;
        final active = i == completed;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: done
                                ? kNavy
                                : active
                                    ? kGold
                                    : kDivider,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: done
                                ? const Icon(Icons.check_rounded,
                                    color: kWhite, size: 14)
                                : Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: active ? kWhite : kTextSub,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: done ? kNavy : kDivider,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          color: active ? kNavy : kTextSub,
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Section label ─────────────────────────────────────────────────────────
  Widget _buildSectionLabel(String num, String title) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: kNavy,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              num,
              style: const TextStyle(
                color: kWhite,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: kNavy,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  // ── Type chips — Wrap, each chip hugs its own text ───────────────────────
  Widget _buildTypeGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: kReportTypes.map((type) {
        final selected = _selectedType?.value == type.value;
        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? kNavy : kWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? kNavy : kDivider,
                width: 1.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: kNavy.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: kNavy.withOpacity(0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 13,
                  color: selected ? kGold : type.color,
                ),
                const SizedBox(width: 6),
                Text(
                  type.label,
                  style: TextStyle(
                    color: selected ? kWhite : kNavy,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(width: 5),
                  const Icon(Icons.check_circle_rounded,
                      color: kGold, size: 13),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Description field ─────────────────────────────────────────────────────
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descController,
        maxLines: 5,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(
          color: kNavy,
          fontSize: 14,
          height: 1.6,
        ),
        decoration: InputDecoration(
          hintText:
              'Describe the incident in detail — what happened, when, and who was involved…',
          hintStyle: const TextStyle(
              color: kTextSub, fontSize: 13, height: 1.6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kWhite,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Description is required' : null,
      ),
    );
  }

  // ── Anonymous toggle ──────────────────────────────────────────────────────
  Widget _buildAnonymousToggle() {
    return GestureDetector(
      onTap: () => setState(() => _isAnonymous = !_isAnonymous),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _isAnonymous ? kNavy.withOpacity(0.06) : kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isAnonymous ? kNavy.withOpacity(0.3) : kDivider,
          ),
          boxShadow: [
            BoxShadow(
              color: kNavy.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isAnonymous
                    ? kNavy.withOpacity(0.1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isAnonymous
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: _isAnonymous ? kNavy : kTextSub,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit anonymously',
                    style: TextStyle(
                      color: _isAnonymous ? kNavy : kNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your identity will not be disclosed to anyone',
                    style: TextStyle(
                      color: _isAnonymous ? kNavy.withOpacity(0.6) : kTextSub,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 26,
              decoration: BoxDecoration(
                color: _isAnonymous ? kNavy : kDivider,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    left: _isAnonymous ? 20 : 2,
                    top: 3,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: kWhite,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Evidence note ─────────────────────────────────────────────────────────
  Widget _buildEvidenceNote() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kGoldLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kGold.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: kGold, size: 16),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Optional — attach an image, video, or PDF to support your report.',
              style: TextStyle(
                  color: Color(0xFF92600A), fontSize: 11, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Evidence section ──────────────────────────────────────────────────────
  Widget _buildEvidenceSection() {
    return Column(
      children: [
        if (_file != null) ...[
          _buildFilePreview(),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            _evidenceButton(
              icon: Icons.image_outlined,
              label: 'Image',
              color: const Color(0xFF2563EB),
              onTap: _pickImage,
            ),
            const SizedBox(width: 10),
            _evidenceButton(
              icon: Icons.videocam_outlined,
              label: 'Video',
              color: const Color(0xFFDC2626),
              onTap: _pickVideo,
            ),
            const SizedBox(width: 10),
            _evidenceButton(
              icon: Icons.picture_as_pdf_outlined,
              label: 'PDF',
              color: const Color(0xFF059669),
              onTap: _pickPDF,
            ),
          ],
        ),
      ],
    );
  }

  Widget _evidenceButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kDivider),
            boxShadow: [
              BoxShadow(
                color: kNavy.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: kNavy,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    final isImage = _fileType == 'image';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kNavy.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.file(_file!,
                    width: 52, height: 52, fit: BoxFit.cover)
                : Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _fileType == 'video'
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _fileType == 'video'
                          ? Icons.videocam_rounded
                          : Icons.picture_as_pdf_rounded,
                      color: _fileType == 'video'
                          ? kError
                          : const Color(0xFF059669),
                      size: 24,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fileName ?? 'Attached file',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _fileType == 'image'
                      ? 'Image file'
                      : _fileType == 'video'
                          ? 'Video file'
                          : 'PDF document',
                  style: const TextStyle(color: kTextSub, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _removeFile,
            icon: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close_rounded,
                  color: kError, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom submit bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    final canSubmit = _selectedType != null &&
        _descController.text.trim().isNotEmpty &&
        !_loading;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: kNavy.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary pill
          if (_selectedType != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(_selectedType!.icon,
                      color: _selectedType!.color, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedType!.label,
                      style: const TextStyle(
                        color: kNavy,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_isAnonymous) ...[
                    const Icon(Icons.visibility_off_rounded,
                        color: kTextSub, size: 12),
                    const SizedBox(width: 4),
                    const Text(
                      'Anonymous',
                      style:
                          TextStyle(color: kTextSub, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          Row(
            children: [
              // Save as draft button
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kNavy,
                    side: const BorderSide(color: kDivider),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Submit button
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: canSubmit ? _submitReport : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canSubmit ? kNavy : kDivider,
                    foregroundColor: kWhite,
                    disabledBackgroundColor: kDivider,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: canSubmit ? 2 : 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: kWhite,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}