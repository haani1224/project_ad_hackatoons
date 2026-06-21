// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../../utils/constants.dart';
// import '../../widgets/custom_button.dart';
// import '../../widgets/custom_textfield.dart';
// import '../../models/training_model.dart';          // Added missing training model import
// import '../../services/training_service.dart'; // 🟢 FIXED: Point to split service file

// class AddTrainingOptionScreen extends StatefulWidget {
//   const AddTrainingOptionScreen({super.key});

//   @override
//   State<AddTrainingOptionScreen> createState() =>
//       _AddTrainingOptionScreenState();
// }

// class _AddTrainingOptionScreenState extends State<AddTrainingOptionScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleCtrl = TextEditingController();
//   final _organizerCtrl = TextEditingController();
//   final _venueCtrl = TextEditingController();
//   final _durationCtrl = TextEditingController();
  
//   // 🟢 FIXED: Extracted date display out of build() context to prevent UI rendering leaks
//   final _dateDisplayCtrl = TextEditingController(); 

//   // 🟢 FIXED: Instantiated the isolated specialized service class
//   final _trainingSvc = TrainingService();

//   String _category = AppConstants.trainingCategories.first;
//   String _mode = 'Online';
//   DateTime? _date;
//   bool _saving = false;

//   @override
//   void dispose() {
//     _titleCtrl.dispose();
//     _organizerCtrl.dispose();
//     _venueCtrl.dispose();
//     _durationCtrl.dispose();
//     _dateDisplayCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _save() async {
//     if (!_formKey.currentState!.validate() || _date == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Please fill all fields and select a date.')));
//       return;
//     }
//     setState(() => _saving = true);
//     try {
//       // 🟢 FIXED: Replaced raw inline query payload with split service method
//       final newOption = TrainingOption(
//         id: null, // Leave blank if your database generates UUIDs natively on insert
//         title: _titleCtrl.text.trim(),
//         category: _category,
//         organizer: _organizerCtrl.text.trim(),
//         trainingDate: _date!,
//         durationHours: double.tryParse(_durationCtrl.text.trim()) ?? 1.0,
//         mode: _mode,
//         venue: _venueCtrl.text.trim(),
//       );

//       await _trainingSvc.createTrainingOption(newOption);

//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       if (mounted) setState(() => _saving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Training Option')),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               CustomTextField(
//                   label: 'Training Title',
//                   controller: _titleCtrl,
//                   validator: (v) => v!.isEmpty ? 'Required' : null),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: _category,
//                 decoration: InputDecoration(
//                     labelText: 'Category',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12))),
//                 items: AppConstants.trainingCategories
//                     .map((c) => DropdownMenuItem(value: c, child: Text(c)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _category = v!),
//               ),
//               const SizedBox(height: 12),
//               CustomTextField(
//                   label: 'Organizer',
//                   controller: _organizerCtrl,
//                   validator: (v) => v!.isEmpty ? 'Required' : null),
//               const SizedBox(height: 12),
//               InkWell(
//                 onTap: () async {
//                   final d = await showDatePicker(
//                     context: context,
//                     initialDate: DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime(2030),
//                   );
//                   if (d != null) {
//                     setState(() {
//                       _date = d;
//                       _dateDisplayCtrl.text = DateFormat('d MMM yyyy').format(d);
//                     });
//                   }
//                 },
//                 child: IgnorePointer(
//                   child: TextFormField(
//                     // 🟢 FIXED: Connected to decoupled layout reference controller
//                     controller: _dateDisplayCtrl,
//                     decoration: InputDecoration(
//                       labelText: 'Training Date',
//                       hintText: 'Select date',
//                       prefixIcon:
//                           const Icon(Icons.calendar_today, size: 20),
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     validator: (_) => _date == null ? 'Required' : null,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               CustomTextField(
//                   label: 'Duration (hours)',
//                   controller: _durationCtrl,
//                   keyboardType: TextInputType.number,
//                   validator: (v) => v!.isEmpty ? 'Required' : null),
//               const SizedBox(height: 12),
//               DropdownButtonFormField<String>(
//                 value: _mode,
//                 decoration: InputDecoration(
//                     labelText: 'Mode',
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12))),
//                 items: ['Online', 'Physical', 'Hybrid']
//                     .map((m) => DropdownMenuItem(value: m, child: Text(m)))
//                     .toList(),
//                 onChanged: (v) => setState(() => _mode = v!),
//               ),
//               const SizedBox(height: 12),
//               CustomTextField(
//                   label: 'Venue / Platform',
//                   controller: _venueCtrl,
//                   validator: (v) => v!.isEmpty ? 'Required' : null),
//               const SizedBox(height: 24),
//               CustomButton(
//                   label: 'Publish Training Option',
//                   onPressed: _save,
//                   isLoading: _saving),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }