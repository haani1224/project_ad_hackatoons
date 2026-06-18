import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/evidence_service.dart';
import 'upload_evidence.dart';

class UploadEvidenceScreen extends StatefulWidget {
  final String reportId;

  const UploadEvidenceScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<UploadEvidenceScreen> createState() => _UploadEvidenceScreenState();
}

class _UploadEvidenceScreenState extends State<UploadEvidenceScreen> {
  // Brand colors
  static const Color navy = Color(0xFF2E4365);
  static const Color gold = Color(0xFFE59D2C);
  static const Color bgGrey = Color(0xFFF5F6F8);

  File? file;
  String? fileType;
  bool loading = false;

  final service = EvidenceService();

  // IMAGE
  Future pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        file = File(picked.path);
        fileType = "image";
      });
    }
  }

  // VIDEO
  Future pickVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        file = File(picked.path);
        fileType = "video";
      });
    }
  }

  // PDF
  Future pickPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        file = File(result.files.single.path!);
        fileType = "raw";
      });
    }
  }

  void clearFile() {
    setState(() {
      file = null;
      fileType = null;
    });
  }

  Future upload() async {
    if (file == null || fileType == null) return;

    setState(() => loading = true);

    final url = await service.uploadFile(file!, fileType!);

    if (url == null) {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Upload failed. Please try again."),
            backgroundColor: Color(0xFFC62828),
          ),
        );
      }
      return;
    }

    await Supabase.instance.client.from('report_evidence').insert({
      'report_id': widget.reportId,
      'file_url': url,
      'file_type': fileType,
    });

    setState(() => loading = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Upload Evidence",
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select evidence type",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 22),
            const Text(
              "Preview",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: navy,
              ),
            ),
            const SizedBox(height: 12),
            _buildPreviewArea(),
            const SizedBox(height: 28),
            _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: _typeButton(
            icon: Icons.image_rounded,
            label: "Image",
            type: "image",
            onTap: pickImage,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _typeButton(
            icon: Icons.videocam_rounded,
            label: "Video",
            type: "video",
            onTap: pickVideo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _typeButton(
            icon: Icons.picture_as_pdf_rounded,
            label: "PDF",
            type: "raw",
            onTap: pickPDF,
          ),
        ),
      ],
    );
  }

  Widget _typeButton({
    required IconData icon,
    required String label,
    required String type,
    required VoidCallback onTap,
  }) {
    final bool selected = fileType == type;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? navy : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? navy : navy.withOpacity(0.2),
          ),
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
            Icon(
              icon,
              size: 24,
              color: selected ? gold : navy,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : navy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: navy.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: file == null ? _emptyPreview() : _filledPreview(),
    );
  }

  Widget _emptyPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: navy.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              size: 36,
              color: navy,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "No file selected yet",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: navy,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Choose Image, Video or PDF above",
            style: TextStyle(color: Colors.black45, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _filledPreview() {
    final fileName = file!.path.split('/').last;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              if (fileType == "image")
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    file!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      fileType == "video"
                          ? Icons.videocam_rounded
                          : Icons.picture_as_pdf_rounded,
                      size: 44,
                      color: navy,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 16,
                    color: navy.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: clearFile,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton() {
    final bool enabled = file != null && !loading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? upload : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          disabledBackgroundColor: navy.withOpacity(0.35),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
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
                  Text(
                    "Uploading...",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Upload Evidence",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}