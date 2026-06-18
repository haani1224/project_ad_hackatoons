import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/teacher_model.dart';
import '../../services/teacher_record_service.dart';
import '../../services/docstorage_service.dart'; // Assumed this exposes StorageService
import '../../widgets/loading_widget.dart';

class PrincipalRecordsScreen extends StatefulWidget {
  const PrincipalRecordsScreen({super.key});

  @override
  State<PrincipalRecordsScreen> createState() => _PrincipalRecordsScreenState();
}

class _PrincipalRecordsScreenState extends State<PrincipalRecordsScreen> {
  // ── Unified Service Initializations ──
  final _recordSvc = TeacherRecordService();
  List<TeacherRecord> _teachers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await _recordSvc.getAllRecords();
    setState(() {
      _teachers = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Records')),
      body: _teachers.isEmpty
          ? const Center(child: Text('No teacher records.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _teachers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final t = _teachers[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(t.fullName),
                    subtitle: Text('${t.gender} · ${t.maritalStatus}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TeacherRecordViewScreen(record: t),
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
}

class TeacherRecordViewScreen extends StatefulWidget {
  final TeacherRecord record;
  const TeacherRecordViewScreen({super.key, required this.record});

  @override
  State<TeacherRecordViewScreen> createState() => _TeacherRecordViewScreenState();
}

class _TeacherRecordViewScreenState extends State<TeacherRecordViewScreen> {
  late TeacherRecord _currentRecord;
  
  // 🟢 FIXED: Both instances are now correctly initialized in this state context
  final _recordSvc = TeacherRecordService();
  final _storageSvc = StorageService(); 

  @override
  void initState() {
    super.initState();
    _currentRecord = widget.record;
  }

  String? _getPathByKey(String key) {
    if (key == 'mykad') return _currentRecord.docMyKadUrl;
    if (key == 'passport') return _currentRecord.docPassportPhotoUrl;
    if (key == 'resume') return _currentRecord.docResumeUrl;
    if (key == 'academic') return _currentRecord.docAcademicCertUrl;
    if (key == 'medical') return _currentRecord.docMedicalReportUrl;
    if (key == 'bank') return _currentRecord.docBankStatementUrl;
    return null;
  }

  Future<void> _updateSingleDocInDatabase(String docType, String status, {String? reason}) async {
    try {
      // 🟢 FIXED: Using consolidated local field reference _recordSvc
      await _recordSvc.updateSingleDocStatus(
        icNumber: _currentRecord.icNumber,
        docType: docType,
        status: status,
        reason: reason,
      );

      final allRecords = await _recordSvc.getAllRecords();
      final freshRecord = allRecords.firstWhere((r) => r.icNumber == _currentRecord.icNumber);

      setState(() { 
        _currentRecord = freshRecord; 
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Document updated to $status successfully!'))
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showRejectDocDialog(BuildContext context, String docLabel, String docType) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject $docLabel'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason for Revision'),
        ),
        // options: [ // Note: Flutter uses 'actions', assumed 'options' was custom or a slight typo, corrected back to actions
        // ],
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (reasonCtrl.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _updateSingleDocInDatabase(docType, 'change_requested', reason: reasonCtrl.text.trim());
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docKeys = ['mykad', 'passport', 'resume', 'academic', 'medical', 'bank'];
    
    bool areAllApproved = true;
    for (var key in docKeys) {
      final docData = _currentRecord.documentStatuses[key] as Map<String, dynamic>?;
      final status = docData?['status'] ?? 'pending';
      if (status != 'approved') {
        areAllApproved = false;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text("Teacher ${_currentRecord.fullName}'s Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Personal Details", style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          _tile('IC Number', _currentRecord.icNumber),
          _tile('Gender', _currentRecord.gender),
          _tile('Date of Birth', '${_currentRecord.dateOfBirth.day}/${_currentRecord.dateOfBirth.month}/${_currentRecord.dateOfBirth.year}'),
          _tile('Phone', _currentRecord.phoneNumber),
          _tile('Email', _currentRecord.email),
          _tile('Address', _currentRecord.address),
          _tile('Marital Status', _currentRecord.maritalStatus),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("Emergency Contact", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          _tile('Emergency Contact', _currentRecord.emergencyContactName),
          _tile('Relationship', _currentRecord.emergencyContactRelationship),
          _tile('Emergency Phone', _currentRecord.emergencyContactPhone),
          const Divider(),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Documents", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 2.0),
                Text("Click item to view", style: TextStyle(fontWeight: FontWeight.normal, color: Colors.grey)),
              ],
            ),
          ),

          _docViewTile(context, 'MyKad', _currentRecord.docMyKadUrl, 'mykad'),
          _docViewTile(context, 'Passport Photo', _currentRecord.docPassportPhotoUrl, 'passport'),
          _docViewTile(context, 'Resume/CV File', _currentRecord.docResumeUrl, 'resume'),
          _docViewTile(context, 'Academic Certs', _currentRecord.docAcademicCertUrl, 'academic'),
          _docViewTile(context, 'Medical Checkup Report', _currentRecord.docMedicalReportUrl, 'medical'),
          _docViewTile(context, 'Bank Statement Header', _currentRecord.docBankStatementUrl, 'bank'),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          if (!areAllApproved) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.check_circle),
              label: const Text('Approve Remaining Submitted Docs'),
              onPressed: () async {
                try {
                  int itemsApprovedCount = 0;
                  for (var key in docKeys) {
                    final docData = _currentRecord.documentStatuses[key] as Map<String, dynamic>?;
                    final currentStatus = docData?['status'] ?? 'pending';
                    final currentPath = _getPathByKey(key);

                    if (currentPath == null || currentStatus == 'change_requested' || currentStatus == 'approved') {
                      continue; 
                    }

                    // 🟢 FIXED: References accurate local _recordSvc field
                    await _recordSvc.updateSingleDocStatus(
                      icNumber: _currentRecord.icNumber,
                      docType: key,
                      status: 'approved',
                    );
                    itemsApprovedCount++;
                  }
                  
                  final allRecords = await _recordSvc.getAllRecords();
                  final freshRecord = allRecords.firstWhere((r) => r.icNumber == _currentRecord.icNumber);
                  
                  setState(() { 
                    _currentRecord = freshRecord; 
                  });

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(itemsApprovedCount > 0 
                        ? 'Eligible files approved successfully!' 
                        : 'No new eligible files to approve.'))
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
            )
          ] else ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: Colors.green),
                    SizedBox(width: 8),
                    Text('All Documents Approved & Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _tile(String label, String value) => ListTile(
        title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        subtitle: Text(value, style: const TextStyle(fontSize: 15)),
      );

  Widget _docViewTile(BuildContext context, String label, String? path, String docType) {
    final docData = _currentRecord.documentStatuses[docType] as Map<String, dynamic>?;
    final String status = docData?['status'] ?? 'pending';
    final String? reason = docData?['reason'];

    Color statusColor = Colors.orange;
    if (status == 'approved') statusColor = Colors.green;
    if (status == 'change_requested') statusColor = Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(label),
          subtitle: Row(
            children: [
              if (path == null)
                const Text('Not Submitted', style: TextStyle(color: Colors.grey))
              else ...[
                Text(
                  status == 'approved'
                      ? 'Approved ✓'
                      : status
                          .replaceAll('_', ' ')
                          .split(' ')
                          .map((word) => word.isNotEmpty
                              ? '${word[0].toUpperCase()}${word.substring(1)}'
                              : '')
                          .join(' '),
                  style: TextStyle(
                    color: status == 'change_requested' ? Colors.red.shade900 : statusColor, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.check_circle, color: status == 'approved' ? Colors.green : (path == null ? Colors.grey.shade300 : Colors.grey)),
                onPressed: (path == null) ? null : () => _updateSingleDocInDatabase(docType, 'approved'),
              ),
              IconButton(
                icon: Icon(Icons.cancel, color: status == 'change_requested' ? Colors.red : (path == null ? Colors.grey.shade300 : Colors.grey)),
                onPressed: (path == null) ? null : () {
                  _showRejectDocDialog(context, label, docType);
                },
              ),
            ],
          ),
          onTap: path == null ? null : () async {
            try {
              // 🟢 FIXED: Successfully resolves URL now via initialized local _storageSvc
              final urlString = await _storageSvc.getDownloadUrl(path);
              final Uri url = Uri.parse(urlString);
              await launchUrl(url, mode: LaunchMode.inAppBrowserView);
            } catch (e) {
              if (!context.mounted) return;
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cannot Open File'),
                  content: Text('Error system details: $e'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
                  ],
                ),
              );
            }
          },
        ),
        if (status == 'change_requested' && reason != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
            child: Text('⚠️ Correction needed: "$reason"', style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontStyle: FontStyle.italic)),
          ),
        const Divider(height: 1),
      ],
    );
  }
}