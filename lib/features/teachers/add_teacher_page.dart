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
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final repo = TeacherRepository();

  final fullName = TextEditingController();
  final icNumber = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final postcode = TextEditingController();
  File? imageFile;
  final picker = ImagePicker();
  final password = TextEditingController();

  String? gender;
  String? maritalStatus;
  String? selectedState;

  bool isLoading = false;

  final List<String> states = [
    "Johor",
    "Kedah",
    "Kelantan",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perak",
    "Perlis",
    "Pulau Pinang",
    "Sabah",
    "Sarawak",
    "Selangor",
    "Terengganu",
    "Kuala Lumpur",
    "Labuan",
    "Putrajaya",
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
  if (imageFile == null) return null;

  final fileName = DateTime.now().millisecondsSinceEpoch.toString();

  await Supabase.instance.client.storage
      .from('teacher-avatars')
      .upload(fileName, imageFile!);

  final url = Supabase.instance.client.storage
      .from('teacher-avatars')
      .getPublicUrl(fileName);

  return url;
}

  Future<void> submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);

    try {
      final imageUrl = await uploadImage();

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

      setState(() => isLoading = false);

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $error"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Teacher added successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
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
    address.dispose();
    postcode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Teacher"),
        backgroundColor: AppTheme.gold,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              const Text(
                "Personal Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

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
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Full Name is required" : null,
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
                validator: (v) {
                  if (v == null || v.isEmpty) return "IC required";
                  if (!isValidIC(v)) return "IC must be 12 digits";

                  final dob = v.substring(0, 6);
                  final day = int.parse(dob.substring(4, 6));
                  final month = int.parse(dob.substring(2, 4));

                  if (month < 1 || month > 12 || day < 1 || day > 31) {
                    return "Invalid IC format";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(
                  labelText: "Gender",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (v) => setState(() => gender = v),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
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
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  if (!isValidEmail(v)) return "Invalid email";
                  return null;
                },
              ),

              TextFormField(
                controller: password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return "Password must be at least 6 characters";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: address,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: postcode,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Postcode",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v != null &&
                      v.isNotEmpty &&
                      !RegExp(r'^\d{5}$').hasMatch(v)) {
                    return "Postcode must be 5 digits";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: const InputDecoration(
                  labelText: "State",
                  border: OutlineInputBorder(),
                ),
                items: states
                    .map((e) =>
                        DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedState = v),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: maritalStatus,
                decoration: const InputDecoration(
                  labelText: "Marital Status",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Single", child: Text("Single")),
                  DropdownMenuItem(value: "Married", child: Text("Married")),
                ],
                onChanged: (v) => setState(() => maritalStatus = v),
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
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "SAVE TEACHER",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}