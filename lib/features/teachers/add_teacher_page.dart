import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../../models/teacher_model.dart';
import '../../core/theme/app_theme.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State {
  final _formKey = GlobalKey<FormState>();

  final supabase = Supabase.instance.client;

  // ===== BASIC INFO =====
  final fullName = TextEditingController();
  final icNumber = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final address = TextEditingController();

  // ===== EMERGENCY CONTACT =====
  final emergencyName = TextEditingController();
  final emergencyRelation = TextEditingController();
  final emergencyPhone = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();

  bool isLoading = false;

  // ================= PICK IMAGE =================
  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  // ================= UPLOAD =================
  Future<String?> uploadImage(String path) async {
    try {
      final fileName = 'teacher_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storage = supabase.storage.from('teacher-docs');

      await storage.upload(fileName, File(path));

      return storage.getPublicUrl(fileName);
    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      return null;
    }
  }

  // ================= SUBMIT =================
  Future submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      // 1. CREATE AUTH USER (NO PASSWORD IN DB)
      final authRes = await supabase.auth.signUp(
        email: email.text.trim(),
        password: password.text.trim(),
      );

      final userId = authRes.user?.id;

      if (userId == null) {
        throw Exception("Auth failed");
      }

      // 2. UPLOAD IMAGE (optional)
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile!.path);
      }

      // 3. INSERT INTO teacher_records
      await supabase.from('teacher_records').insert({
        "ic_number": icNumber.text.trim(),
        "user_id": userId,
        "full_name": fullName.text.trim(),
        "gender": null,
        "date_of_birth": null,
        "address": address.text.trim(),
        "phone_number": phone.text.trim(),
        "email": email.text.trim(),
        "marital_status": null,

        "emergency_contact_name": emergencyName.text.trim(),
        "emergency_contact_relationship": emergencyRelation.text.trim(),
        "emergency_contact_phone": emergencyPhone.text.trim(),

        "doc_mykad_url": imageUrl,
        "document_statuses": {
          "profile": "pending"
        }
      });

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration submitted"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("ERROR: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    fullName.dispose();
    icNumber.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    address.dispose();
    emergencyName.dispose();
    emergencyRelation.dispose();
    emergencyPhone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teacher Registration"),
        backgroundColor: AppTheme.gold,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              const Text(
                "Teacher Registration Form",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      imageFile != null ? FileImage(imageFile!) : null,
                  child: imageFile == null
                      ? const Icon(Icons.camera_alt)
                      : null,
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(controller: fullName, decoration: const InputDecoration(labelText: "Full Name")),
              TextFormField(controller: icNumber, decoration: const InputDecoration(labelText: "IC Number")),
              TextFormField(controller: phone, decoration: const InputDecoration(labelText: "Phone")),
              TextFormField(controller: email, decoration: const InputDecoration(labelText: "Email")),
              TextFormField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
              TextFormField(controller: address, decoration: const InputDecoration(labelText: "Address")),

              const SizedBox(height: 20),

              const Text("Emergency Contact", style: TextStyle(fontWeight: FontWeight.bold)),

              TextFormField(controller: emergencyName, decoration: const InputDecoration(labelText: "Contact Name")),
              TextFormField(controller: emergencyRelation, decoration: const InputDecoration(labelText: "Relationship")),
              TextFormField(controller: emergencyPhone, decoration: const InputDecoration(labelText: "Contact Phone")),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("SUBMIT"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}