import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/teacher_model.dart'; // Sesuaikan path

class TeacherProfile extends StatefulWidget {
  final TeacherModel teacher;

  const TeacherProfile({super.key, required this.teacher});

  @override
  State<TeacherProfile> createState() => _TeacherProfileState();
}

class _TeacherProfileState extends State<TeacherProfile> {
  static const Color navy = Color(0xFF1B2E4B);
  static const Color navyLight = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgColor = Color(0xFFF0F2F7);

  bool _isLoading = true;
  TeacherRecord? _record;

  @override
  void initState() {
    super.initState();
    _fetchTeacherRecord();
  }

  Future<void> _fetchTeacherRecord() async {
    try {
      // Narik data spesifik berdasarkan user_id guru yang di-klik
      final data = await Supabase.instance.client
          .from('teacher_records')
          .select()
          .eq('user_id', widget.teacher.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _record = TeacherRecord.fromMap(data);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching record: $e");
      setState(() => _isLoading = false);
    }
  }

  // Fungsi buat Principal nyetujuin atau nolak dokumen
  Future<void> _updateDocStatus(String docType, String status, {String? reason}) async {
    if (_record == null) return;
    
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final currentStatuses = Map<String, dynamic>.from(_record!.documentStatuses);
      currentStatuses[docType] = {
        'status': status,
        'reason': reason,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await Supabase.instance.client
          .from('teacher_records')
          .update({'document_statuses': currentStatuses})
          .eq('user_id', widget.teacher.id);

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document status updated to $status!'), backgroundColor: status == 'approved' ? Colors.green : Colors.red),
        );
        _fetchTeacherRecord(); // Refresh UI
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text("Staff Details", style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  if (_record == null)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Text(
                          "This teacher hasn't set up their profile yet.",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle("PERSONAL INFO"),
                          _buildInfoCard([
                            _buildInfoRow(Icons.badge_outlined, "IC Number", _record!.icNumber),
                            _buildInfoRow(Icons.phone_outlined, "Phone", _record!.phoneNumber),
                            _buildInfoRow(Icons.home_outlined, "Address", _record!.address),
                            _buildInfoRow(Icons.cake_outlined, "Date of Birth", "${_record!.dateOfBirth.day}/${_record!.dateOfBirth.month}/${_record!.dateOfBirth.year}"),
                          ]),
                          
                          const SizedBox(height: 24),
                          
                          _sectionTitle("EMERGENCY CONTACT"),
                          _buildInfoCard([
                            _buildInfoRow(Icons.person_outline, "Name", _record!.emergencyContactName),
                            _buildInfoRow(Icons.family_restroom, "Relationship", _record!.emergencyContactRelationship),
                            _buildInfoRow(Icons.phone_in_talk_outlined, "Phone", _record!.emergencyContactPhone),
                          ]),

                          const SizedBox(height: 24),

                          _sectionTitle("DOCUMENT VERIFICATION"),
                          _buildDocVerificationCard(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30, top: 20),
      decoration: const BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: gold,
            child: CircleAvatar(
              radius: 43,
              backgroundColor: navyLight,
              child: Text(
                widget.teacher.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(widget.teacher.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(widget.teacher.email, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7))),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: navyLight),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(value.isNotEmpty ? value : '-', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocVerificationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          _verifyDocTile("MyKad", _record!.docMyKadUrl, 'mykad'),
          const Divider(height: 1),
          _verifyDocTile("Passport Photo", _record!.docPassportPhotoUrl, 'passport'),
          const Divider(height: 1),
          _verifyDocTile("Resume / CV", _record!.docResumeUrl, 'resume'),
          const Divider(height: 1),
          _verifyDocTile("Academic Cert", _record!.docAcademicCertUrl, 'academic'),
          const Divider(height: 1),
          _verifyDocTile("Medical Report", _record!.docMedicalReportUrl, 'medical'),
        ],
      ),
    );
  }

  Widget _verifyDocTile(String title, String? url, String docKey) {
    final docData = _record!.documentStatuses[docKey] as Map<String, dynamic>?;
    final String status = docData?['status'] ?? 'pending';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: navy)),
      subtitle: Text(
        url == null ? "Not Uploaded" : "Status: ${status.toUpperCase()}",
        style: TextStyle(
          color: url == null ? Colors.redAccent : (status == 'approved' ? Colors.green : Colors.orange),
          fontWeight: FontWeight.bold, fontSize: 12,
        ),
      ),
      trailing: url == null 
          ? null 
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tombol Lihat Dokumen
                IconButton(
                  icon: const Icon(Icons.remove_red_eye, color: navyLight),
                  onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView),
                ),
                // Tombol Approve
                if (status != 'approved')
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    onPressed: () => _updateDocStatus(docKey, 'approved'),
                  ),
                // Tombol Reject
                if (status != 'change_requested')
                  IconButton(
                    icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                    onPressed: () => _showRejectDialog(docKey),
                  ),
              ],
            ),
    );
  }

  void _showRejectDialog(String docKey) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Request Change"),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(hintText: "Reason for rejection (e.g. Blur image)"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (reasonCtrl.text.isNotEmpty) {
                _updateDocStatus(docKey, 'change_requested', reason: reasonCtrl.text);
              }
            },
            child: const Text("Submit", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}