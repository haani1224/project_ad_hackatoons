import 'package:flutter/material.dart';
import '../../data/models/teacher_model.dart';
import '../../data/repositories/teacher_repository.dart';

class EditTeacherPage extends StatefulWidget {
  final TeacherModel teacher;

  const EditTeacherPage({super.key, required this.teacher});

  @override
  State<EditTeacherPage> createState() => _EditTeacherPageState();
}

class _EditTeacherPageState extends State<EditTeacherPage> {
  final repo = TeacherRepository();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController fullName;
  late TextEditingController icNumber;
  late TextEditingController phone;
  late TextEditingController email;
  late TextEditingController address;

  String? gender;
  String? maritalStatus;

  @override
  void initState() {
    super.initState();

    fullName = TextEditingController(text: widget.teacher.fullName);
    icNumber = TextEditingController(text: widget.teacher.icNumber);
    phone = TextEditingController(text: widget.teacher.phone);
    email = TextEditingController(text: widget.teacher.email);
    address = TextEditingController(text: widget.teacher.address);

    gender = widget.teacher.gender;
    maritalStatus = widget.teacher.maritalStatus;
  }

  Future update() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = TeacherModel(
      id: widget.teacher.id,
      fullName: fullName.text,
      icNumber: icNumber.text,
      phone: phone.text,
      email: email.text,
      address: address.text,
      gender: gender,
      maritalStatus: maritalStatus,
    );

    await repo.updateTeacher(widget.teacher.id!, updated);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Teacher")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [

              TextFormField(
                controller: fullName,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),

              TextFormField(
                controller: icNumber,
                decoration: const InputDecoration(labelText: "IC Number"),
              ),

              TextFormField(
                controller: phone,
                decoration: const InputDecoration(labelText: "Phone"),
              ),

              TextFormField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
              ),

              TextFormField(
                controller: address,
                decoration: const InputDecoration(labelText: "Address"),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: update,
                child: const Text("UPDATE TEACHER"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}