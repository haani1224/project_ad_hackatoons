import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../core/theme/app_theme.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State {
  final _formKey = GlobalKey<FormState>();
  final repo = TeacherRepository();

  final fullName = TextEditingController();
  final icNumber = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final address = TextEditingController();
  final postcode = TextEditingController();

  File? imageFile;
  final picker = ImagePicker();

  String? gender;
  String? maritalStatus;
  String? selectedState;

  bool isLoading = false;

  final List<String> states = [
    "Johor","Kedah","Kelantan","Melaka","Negeri Sembilan",
    "Pahang","Perak","Perlis","Pulau Pinang","Sabah","Sarawak",
    "Selangor","Terengganu","Kuala Lumpur","Labuan","Putrajaya",
  ];

  String capitalize(String text) {
    return text
        .split(' ')
        .map((e) => e.isEmpty
            ? ''
            : e[0].toUpperCase() + e.substring(1).toLowerCase())
        .join(' ');
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  bool isValidIC(String ic) {
    return RegExp(r'^\d{12}$').hasMatch(ic);
  }

  String? getDobFromIc(String ic) {
    if (ic.length != 12) return null;

    final yy = int.parse(ic.substring(0, 2));
    final mm = ic.substring(2, 4);
    final dd = ic.substring(4, 6);

    final year = yy > 30 ? '19$yy' : '20$yy';
    return '$year-$mm-$dd';
  }

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  } 

  Future<String?> uploadImage() async {
    if (imageFile == null) {
      debugPrint("NO IMAGE SELECTED");
      return null;
    }

    try {
      final fileName =
          'teacher_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final storage = Supabase.instance.client.storage.from('teacher-avatars');

      debugPrint("START UPLOAD: $fileName");

      await storage.upload(fileName, imageFile!);

      final url = storage.getPublicUrl(fileName);

      debugPrint("UPLOAD SUCCESS: $url");

      return url;
    } catch (e) {
      debugPrint("UPLOAD FAILED: $e");
      return null;
    }
    
  }

  Future submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      final imageUrl = await uploadImage();
      // final imageUrl = null;

      final teacher = TeacherModel(
        fullName: capitalize(fullName.text),
        icNumber: icNumber.text.trim(),
        dob: getDobFromIc(icNumber.text.trim()),
        gender: gender,
        address: address.text.trim(),
        postcode: postcode.text.trim(),
        state: selectedState,
        phone: phone.text.trim(),
        email: email.text.trim(),
        maritalStatus: maritalStatus,
        avatarUrl: imageUrl,
        status: "pending",
      );

      final error = await repo.registerTeacher(
        email: email.text.trim(),
        password: password.text.trim(),
        teacher: teacher,
      );

      if (!mounted) return;

      setState(() => isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration submitted (pending approval)"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    }

    on AuthException catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("AUTH ERROR: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }

    on PostgrestException catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("DATABASE ERROR: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    }

    catch (e) {
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
    postcode.dispose();
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
                "Register Teacher Account",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Center(
                child: GestureDetector(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        imageFile != null ? FileImage(imageFile!) : null,
                    child: imageFile == null
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: fullName,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: icNumber,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: const InputDecoration(
                  labelText: "IC Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: isLoading ? null : submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("SUBMIT REGISTRATION"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}