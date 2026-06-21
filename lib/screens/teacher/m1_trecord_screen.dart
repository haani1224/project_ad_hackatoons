import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/m1_record_model.dart';
import '../../services/m1_record_service.dart';
import '../../services/m1_docstorage_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/theme_constants.dart';

class TeacherProfileScreen extends StatefulWidget {
  // const TeacherProfileScreen({super.key, required TeacherModel teacher});

  final String userId;

  const TeacherProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final _svc = TeacherRecordService();
  final _docStorageSvc = StorageService();
  TeacherRecord? _record;
  bool _loading = true;
  bool _editing = false;
  bool _editingDocs = false;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _icCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  
  String _gender = 'Female';
  String _maritalStatus = 'Single';
  DateTime? _dob;
  static const _relationships = [
    'Husband', 'Wife', 'Father', 'Mother',
    'Brother', 'Sister', 'Son', 'Daughter',
    'Friend', 'Other',
  ];
  String _emergencyRelationship = 'Mother';
  String? _myKadPath, _passportPath, _resumePath, _academicPath, _medicalPath, _bankPath;

  @override
  void initState() {
    super.initState();
    _loadRecord();
  }

  void _updateDobFromIc(String ic) {
    final digits = ic.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length < 6) return;

    try {
      final yy = int.parse(digits.substring(0, 2));
      final mm = int.parse(digits.substring(2, 4));
      final dd = int.parse(digits.substring(4, 6));

      final currentYear = DateTime.now().year % 100;

      final fullYear = yy <= currentYear
          ? 2000 + yy
          : 1900 + yy;

      final dob = DateTime(fullYear, mm, dd);

      setState(() {
        _dob = dob;
      });
    } catch (_) {
      // invalid IC format
    }
  }

  Future<void> _loadRecord() async {
    try {
      print('========== START LOAD ==========');

      print('userId = ${widget.userId}');

      final record =
          await _svc.getMyRecord(widget.userId);

      print('Record loaded');
      print(record);

      if (mounted) {
        setState(() {
          _record = record;
          _loading = false;
        });
        if (record != null) {
          _populate(record); // 👈 IMPORTANT FIX
        }
      }

      print('========== LOAD COMPLETE ==========');
    } catch (e, s) {
      print('========== ERROR ==========');
      print(e);
      print(s);

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _populate(TeacherRecord r) {
    _nameCtrl.text = r.fullName;
    _icCtrl.text = r.icNumber;
    _phoneCtrl.text = r.phoneNumber;
    _addressCtrl.text = r.address;
    _emailCtrl.text = r.email;
    _emergencyNameCtrl.text = r.emergencyContactName;
    _emergencyRelationship = r.emergencyContactRelationship;
    _emergencyPhoneCtrl.text = r.emergencyContactPhone;
    _gender = r.gender;
    _maritalStatus = r.maritalStatus;
    _dob = r.dateOfBirth;
    _myKadPath = r.docMyKadUrl;
    _passportPath = r.docPassportPhotoUrl;
    _resumePath = r.docResumeUrl;
    _academicPath = r.docAcademicCertUrl;
    _medicalPath = r.docMedicalReportUrl;
    _bankPath = r.docBankStatementUrl;
    
  }

  Future<void> _save() async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    if (userId == null) {
      throw Exception("User not logged in");
    }
    final uid = userId;
    final resolvedDob = _dob ?? DateTime(1990, 1, 1);

    // C. Check if record already exists
    final existing = await Supabase.instance.client
        .from('teacher_records')
        .select('ic_number, document_statuses, doc_mykad_url, doc_passport_photo_url, doc_resume_url, doc_academic_cert_url, doc_medical_report_url, doc_bank_statement_url')
        .eq('user_id', uid)
        .maybeSingle();

    // Preserve existing doc paths and statuses — don't overwrite them during profile save
    final existingStatuses = existing != null
        ? Map<String, dynamic>.from(existing['document_statuses'] as Map? ?? {})
        : <String, dynamic>{};

    final Map<String, dynamic> payload = {
      'user_id': uid,
      'ic_number': _icCtrl.text.trim(),
      'full_name': _nameCtrl.text.trim(),
      'gender': _gender,
      'date_of_birth': resolvedDob.toIso8601String().substring(0, 10),
      'address': _addressCtrl.text.trim(),
      'phone_number': _phoneCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'marital_status': _maritalStatus,
      'emergency_contact_name': _emergencyNameCtrl.text.trim(),
      'emergency_contact_relationship': _emergencyRelationship,
      'emergency_contact_phone': _emergencyPhoneCtrl.text.trim(),
      'document_statuses': existingStatuses,
      // Preserve existing doc paths
      if (existing != null) ...{
        'doc_mykad_url': existing['doc_mykad_url'],
        'doc_passport_photo_url': existing['doc_passport_photo_url'],
        'doc_resume_url': existing['doc_resume_url'],
        'doc_academic_cert_url': existing['doc_academic_cert_url'],
        'doc_medical_report_url': existing['doc_medical_report_url'],
        'doc_bank_statement_url': existing['doc_bank_statement_url'],
      },
    };

    // D. Upsert — inserts if new, updates if exists
    await Supabase.instance.client
        .from('teacher_records')
        .upsert(payload, onConflict: 'user_id');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: LoadingWidget());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_editing)
            IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _editing = true))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: Icon(
                  Icons.person,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 24),

            _section('Personal Information', [
              CustomTextField(
                  label: 'Full Name',
                  controller: _nameCtrl,
                  readOnly: !_editing,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'IC Number',
                controller: _icCtrl,
                readOnly: !_editing,
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onChanged: (value) {
                  _updateDobFromIc(value);
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Female', 'Male']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: _editing ? (v) => setState(() => _gender = v!) : null,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _editing
                    ? () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _dob ?? DateTime(1990),
                          firstDate: DateTime(1960),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _dob = d);
                      }
                    : null,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: _dob == null ? '' : '${_dob!.day}/${_dob!.month}/${_dob!.year}',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'Select your date of birth',
                      prefixIcon: const Icon(Icons.calendar_today, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabled: _editing, 
                    ),
                    validator: (_) => _dob == null ? 'Required' : null,
                  ),
                ),
              ),
              // const Divider(),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Address',
                  controller: _addressCtrl,
                  readOnly: !_editing,
                  maxLines: 3),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Phone Number',
                  controller: _phoneCtrl,
                  readOnly: !_editing,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Email',
                  controller: _emailCtrl,
                  readOnly: !_editing,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _maritalStatus,
                decoration: InputDecoration(
                    labelText: 'Marital Status',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['Single', 'Married', 'Divorced', 'Widowed']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: _editing ? (v) => setState(() => _maritalStatus = v!) : null,
              ),
            ]),
            const SizedBox(height: 16),

            _section('Emergency Contact', [
              CustomTextField(
                  label: 'Contact Person Name',
                  controller: _emergencyNameCtrl,
                  readOnly: !_editing),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _emergencyRelationship,
                decoration: InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: _relationships
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: _editing ? (v) => setState(() => _emergencyRelationship = v!) : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Contact Phone',
                  controller: _emergencyPhoneCtrl,
                  readOnly: !_editing,
                  keyboardType: TextInputType.phone),
            ]),
            const SizedBox(height: 16),

            // 🟢 MOVED HERE: Save & Cancel Buttons now live directly below the form fields
            if (_editing) ...[
              CustomButton(
                label: 'Save Record Details', 
                onPressed: () async {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    // 1. Core Upload & Database Row Patch Pipeline
                    await _save(); 

                    if (mounted) {
                      Navigator.pop(context); // Dismiss loading overlay
                      
                      setState(() {
                        _editing = false; // Gracefully step out of edit mode
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile saved successfully!'), 
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.pop(context); // Dismiss loading overlay
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Save Failed (Database Error)'),
                          content: SingleChildScrollView(child: Text(e.toString())),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))
                          ],
                        ),
                      );
                    }
                  }
                }
              ),
              const SizedBox(height: 8),
              CustomButton(
                label: 'Cancel',
                onPressed: () {
                  setState(() {
                    _editing = false;
                  });
                  if (_record != null) _populate(_record!); // Restores original database links
                },
                isOutlined: true,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // 📄 Document Section Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Documents Required', 
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton.filledTonal(
                  icon: Icon(_editingDocs ? Icons.check : Icons.edit),
                  tooltip: _editingDocs ? 'Done Managing' : 'Manage Documents',
                  onPressed: () {
                    // User is trying to close document editing mode
                    if (_editingDocs) {
                      final missingDocs = <String>[];

                        if (_myKadPath == null) missingDocs.add('MyKad');
                        if (_passportPath == null) missingDocs.add('Passport Photo');
                        if (_resumePath == null) missingDocs.add('Resume');
                        if (_academicPath == null) missingDocs.add('Academic Certificate');
                        // if (_medicalPath == null) missingDocs.add('Medical Report');
                        if (_bankPath == null) missingDocs.add('Bank Statement');

                        if (missingDocs.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Documents Missing'),
                              content: Text(
                                'Please upload the following required documents:\n\n'
                                '${missingDocs.join('\n')}\n\n'
                                'Note: Medical Check Up Report is required when available.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                    }
                    setState(() {
                      _editingDocs = !_editingDocs;
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: _editingDocs 
                        ? Colors.green.withOpacity(0.2) 
                        : Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: _editingDocs 
                        ? Colors.green.shade900 
                        : Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Document Tiles List
            _section('', [
              _docTile('1. MyKad (PDF/PNG/JPG)', _myKadPath, (p) => setState(() => _myKadPath = p), 'mykad'),
              _docTile('2. Passport Photo (PNG/JPG)', _passportPath, (p) => setState(() => _passportPath = p), 'passport'),
              _docTile('3. Resume/CV (PDF)', _resumePath, (p) => setState(() => _resumePath = p), 'resume'),
              _docTile('4. Latest Academic Certificates (PDF)', _academicPath, (p) => setState(() => _academicPath = p), 'academic'),
              _docTile('5. Medical Check Up Report (PDF)', _medicalPath, (p) => setState(() => _medicalPath = p), 'medical'),
              _docTile('6. Header of Bank Statement (PDF)', _bankPath, (p) => setState(() => _bankPath = p), 'bank'),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          ...children,
          const SizedBox(height: 8),
        ],
      );

  Widget _docTile(String label, String? currentPath, Function(String?) onUploaded, String type) {
    final uid = Supabase.instance.client.auth.currentUser?.id;

    final docData = (_record?.documentStatuses ?? {})[type] as Map<String, dynamic>?;
    final String status = docData?['status'] ?? 'pending';
    final String? reason = docData?['reason'];

    Color statusColor = Colors.orange;
    String statusText = 'Pending Verification';
    
    if (currentPath == null) {
      statusColor = Colors.red;
      statusText = 'Missing Document';
    } else if (status == 'approved') {
      statusColor = Colors.green;
      statusText = 'Approved ✓';
    } else if (status == 'change_requested') {
      statusColor = Colors.red.shade700;
      statusText = 'Correction Requested ⚠️';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          subtitle: Text(
            statusText,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // if (currentPath != null)
              //   IconButton(
              //     icon: const Icon(Icons.open_in_new),
              //     tooltip: 'View Document',
              //     onPressed: () async {
              //       print("VIEW BUTTON CLICKED");
              //       final urlString = await _docStorageSvc.getDownloadUrl(currentPath);
              //       final Uri url = Uri.parse(urlString);
              //       await launchUrl(url, mode: LaunchMode.inAppBrowserView);
              //     },
              //   ),
              if (currentPath != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'View Document',
                  onPressed: () async {
                    print("VIEW BUTTON CLICKED");
                    // FIX #14: Handle getDownloadUrl and launchUrl failures gracefully
                    try {
                      final urlString = await _docStorageSvc.getDownloadUrl(currentPath);
                      final Uri url = Uri.parse(urlString);
                      final launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      if (!launched && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not open document. No app available to handle this file.')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to open document: $e')),
                        );
                      }
                    }
                  },
                ),
              // if (_editingDocs && status != 'approved')
              //   IconButton(
              //     icon: Icon(currentPath == null ? Icons.upload_file : Icons.published_with_changes),
              //     onPressed: () async {
              //       print("UPLOAD1 BUTTON CLICKED");
              //       if (uid != null) {
              //         final path = await _docStorageSvc.uploadTeacherDocument(
              //           userId: uid, 
              //           docType: type,
              //           oldPath: currentPath, 
              //         );
                      
              //         if (path != null && mounted) {
              //           setState(() { onUploaded(path); });
                        
              //           try {
              //             await _svc.updateTeacherDocumentPath(
              //               userId: uid,
              //               docType: type,
              //               filePath: path,
              //             );
                          
              //             await _loadRecord(); 
                          
              //             if (mounted) {
              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 const SnackBar(content: Text('File uploaded and linked successfully!'))
              //               );
              //             }
              //           } catch (e) {
              //             if (mounted) {
              //               ScaffoldMessenger.of(context).showSnackBar(
              //                 SnackBar(content: Text('Failed to link file to profile table: $e'))
              //               );
              //             }
              //           }
              //         }
              //       }
              //     },
              //   ),
              if (_editingDocs && status != 'approved')
                IconButton(
                  icon: Icon(currentPath == null ? Icons.upload_file : Icons.published_with_changes),
                  onPressed: () async {
                    print("UPLOAD1 BUTTON CLICKED");
                    if (uid != null) {
                      final path = await _docStorageSvc.uploadTeacherDocument(
                        userId: uid,
                        docType: type,
                        oldPath: currentPath,
                      );

                      if (path != null && mounted) {
                        // FIX #13: Update DB first, then update UI only on success
                        try {
                          await _svc.updateTeacherDocumentPath(
                            userId: uid,
                            docType: type,
                            filePath: path,
                          );

                          // DB write succeeded — now safe to update local state
                          setState(() { onUploaded(path); });

                          await _loadRecord();

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('File uploaded and linked successfully!'))
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to link file to profile table: $e'))
                            );
                          }
                        }
                      }
                    }
                  },
                ),
              // if (_editingDocs && currentPath != null && status != 'approved')
              //   IconButton(
              //     icon: const Icon(Icons.delete_forever, color: Colors.red),
              //     tooltip: 'Delete Document',
              //     onPressed: () async {
              //       print("UPLOAD2 BUTTON CLICKED");
              //       final confirmed = await showDialog<bool>(
              //         context: context,
              //         builder: (context) => AlertDialog(
              //           title: const Text('Delete Document?'),
              //           content: const Text('This will permanently remove the file from storage.'),
              //           actions: [
              //             TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              //             TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
              //           ],
              //         ),
              //       );

              //       if (confirmed == true && uid != null) {
              //         // 1. Delete physical storage file
              //         await _docStorageSvc.deleteTeacherDocument(path: currentPath);
                      
              //         // 2. Wipe the local UI tracking variables immediately
              //         setState(() { 
              //           onUploaded(null); 
              //         });
                      
              //         // 3. Clear out the database file path column to null
              //         await _svc.updateTeacherDocumentPath(
              //           userId: uid, 
              //           docType: type, 
              //           filePath: null, // 🟢 Set explicitly to null instead of empty string
              //         );

              //         // 4. Update or clear out the approval status object entirely to null
              //         await _svc.updateSingleDocStatus(
              //           icNumber: _icCtrl.text.trim(),
              //           docType: type,
              //           status: null, // 🟢 Set to null directly
              //           reason: null,
              //         );

              //         // 5. Fresh fetch from database to sync all states
              //         await _loadRecord();
              //       }
              //     },
              //   ),
              if (_editingDocs && currentPath != null && status != 'approved')
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'Delete Document',
                  onPressed: () async {
                    print("UPLOAD2 BUTTON CLICKED");
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Document?'),
                        content: const Text('This will permanently remove the file from storage.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );

                    if (confirmed == true && uid != null) {
                      // FIX #11: Check storage deletion succeeded before touching the database
                      try {
                        await _docStorageSvc.deleteTeacherDocument(path: currentPath);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Storage deletion failed — file not removed: $e')),
                          );
                        }
                        return; // Abort — don't wipe DB path if the file wasn't actually deleted
                      }

                      // FIX #12: Guard against empty IC before calling updateSingleDocStatus
                      final ic = _icCtrl.text.trim();
                      if (ic.isEmpty) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot update document status: IC number is missing.')),
                          );
                        }
                        return;
                      }

                      // Storage confirmed deleted — now wipe local UI state
                      setState(() {
                        onUploaded(null);
                      });

                      // Clear DB path
                      await _svc.updateTeacherDocumentPath(
                        userId: uid,
                        docType: type,
                        filePath: null,
                      );

                      // Clear approval status
                      await _svc.updateSingleDocStatus(
                        icNumber: ic,
                        docType: type,
                        status: null,
                        reason: null,
                      );

                      // Sync from DB
                      await _loadRecord();
                    }
                  },
                ),
            ],
          ),
        ),
        if (status == 'change_requested' && reason != null && currentPath != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(bottom: 8, top: 4),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Text(
              '❌ Principal Request: "$reason"\n(Please click "Manage Documents" to replace this file)',
              style: TextStyle(color: Colors.red.shade900, fontSize: 12, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
            ),
          ),
        const Divider(height: 1),
      ],
    );
  }
}