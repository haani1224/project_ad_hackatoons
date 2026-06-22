import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../models/m4_training_model.dart';         
import '../../services/m4_training_service.dart';
import '../../utils/theme_constants.dart';

class AddTrainingOptionScreen extends StatefulWidget {
  const AddTrainingOptionScreen({super.key});

  @override
  State<AddTrainingOptionScreen> createState() =>
      _AddTrainingOptionScreenState();
}

class _AddTrainingOptionScreenState extends State<AddTrainingOptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _meetingLinkCtrl = TextEditingController();
  
  // 🟢 FIXED: Extracted date display out of build() context to prevent UI rendering leaks
  final _dateDisplayCtrl = TextEditingController(); 

  // 🟢 FIXED: Instantiated the isolated specialized service class
  final _trainingSvc = TrainingService();

  String _category = AppConstants.trainingCategories.first;
  String _mode = 'Online';
  DateTime? _date;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _organizerCtrl.dispose();
    _venueCtrl.dispose();
    _durationCtrl.dispose();
    _dateDisplayCtrl.dispose();
    _meetingLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a date.')),
      );
      return;
    }

    final duration = double.tryParse(_durationCtrl.text);
    if (duration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duration must be a valid number')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final newOption = TrainingOption(
        id: null,
        title: _titleCtrl.text.trim(),
        category: _category,
        organizer: _organizerCtrl.text.trim(),
        trainingDate: _date!,
        durationHours: duration,
        mode: _mode,
        venue: _venueCtrl.text.trim(),
        meetingLink: _meetingLinkCtrl.text.trim().isEmpty
            ? null
            : _meetingLinkCtrl.text.trim(),
      );

      await _trainingSvc.createTrainingOption(newOption);

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        title: const Text('Training Option'),
        backgroundColor: navyDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                  label: 'Training Title',
                  controller: _titleCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                items: AppConstants.trainingCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Organizer',
                  controller: _organizerCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) {
                    setState(() {
                      _date = d;
                      _dateDisplayCtrl.text = DateFormat('d MMM yyyy').format(d);
                    });
                  }
                },
                child: IgnorePointer(
                  child: TextFormField(
                    // 🟢 FIXED: Connected to decoupled layout reference controller
                    controller: _dateDisplayCtrl,
                    decoration: InputDecoration(
                      labelText: 'Training Date',
                      hintText: 'Select date',
                      prefixIcon:
                          const Icon(Icons.calendar_today, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (_) => _date == null ? 'Required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                  label: 'Duration (hours)',
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _mode,
                decoration: InputDecoration(
                    labelText: 'Mode',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                items: ['Online', 'Physical', 'Hybrid']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _mode = v!),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'Venue / Platform',
                controller: _venueCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              if (_mode != 'Physical') ...[
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Meeting Link',
                  controller: _meetingLinkCtrl,
                  validator: (v) {
                    if (_mode != 'Physical' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Required';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 24),
              CustomButton(
                label: 'Publish Training Option',
                onPressed: _save,
                isLoading: _saving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditTrainingOptionScreen extends StatefulWidget {
  final TrainingOption option;

  const EditTrainingOptionScreen({super.key, required this.option});

  @override
  State<EditTrainingOptionScreen> createState() =>
      _EditTrainingOptionScreenState();
}

class _EditTrainingOptionScreenState extends State<EditTrainingOptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _svc = TrainingService();

  String _category = '';
  String _mode = '';
  DateTime? _date;
  final _dateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final o = widget.option;

    _titleCtrl.text = o.title;
    _orgCtrl.text = o.organizer;
    _venueCtrl.text = o.venue;
    _durationCtrl.text = o.durationHours.toString();
    _linkCtrl.text = o.meetingLink ?? '';
    _category = o.category;
    _mode = o.mode;
    _date = o.trainingDate;
    _dateCtrl.text = DateFormat('d MMM yyyy').format(o.trainingDate);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = TrainingOption(
      id: widget.option.id,
      title: _titleCtrl.text,
      category: _category,
      organizer: _orgCtrl.text,
      trainingDate: _date!,
      durationHours: double.tryParse(_durationCtrl.text) ?? 1,
      mode: _mode,
      venue: _venueCtrl.text,
      meetingLink: _linkCtrl.text.trim().isEmpty
        ? null
        : _linkCtrl.text.trim(),
      );

    await _svc.updateTrainingOption(updated);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Training Option")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: _orgCtrl,
                decoration: const InputDecoration(labelText: "Organizer"),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: "Category"),
                items: AppConstants.trainingCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),

              DropdownButtonFormField<String>(
                value: _mode,
                decoration: const InputDecoration(labelText: "Mode"),
                items: const ['Online', 'Physical', 'Hybrid']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _mode = v!),
              ),

              TextFormField(
                controller: _venueCtrl,
                decoration: const InputDecoration(labelText: "Venue"),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_dateCtrl.text),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  if (picked != null) {
                    setState(() {
                      _date = picked;
                      _dateCtrl.text = DateFormat('d MMM yyyy').format(picked);
                    });
                  }
                },
              ),
              TextFormField(
                controller: _durationCtrl,
                decoration: const InputDecoration(labelText: "Duration"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Must be a number';
                  return null;
                },
              ),
              TextFormField(controller: _linkCtrl, decoration: const InputDecoration(labelText: "Meeting Link")),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _save,
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}