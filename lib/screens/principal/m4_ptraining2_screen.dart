import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../models/m4_training_model.dart';
import '../../services/m4_training_service.dart';
import '../../utils/theme_constants.dart';

// ── Fix #5: some existing training options were saved with a category
// (or mode) value that is no longer part of AppConstants.trainingCategories
// (e.g. "Technology" was removed/renamed). DropdownButtonFormField throws
// an assertion if `value` isn't found among `items`. This helper builds
// the item list from the canonical list *plus* the current value if it's
// missing, so editing an "old" option never crashes. ──
List<DropdownMenuItem<String>> _safeDropdownItems(
    List<String> canonical, String currentValue) {
  final values = [
    ...canonical,
    if (currentValue.isNotEmpty && !canonical.contains(currentValue))
      currentValue,
  ];
  return values
      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
      .toList();
}

const List<String> _trainingModes = ['Online', 'Physical', 'Hybrid'];

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

  final _dateDisplayCtrl = TextEditingController();

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
      // TODO(notifications): notify all teachers that a new training
      // option was published.

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
                items: _safeDropdownItems(
                    AppConstants.trainingCategories, _category),
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
                items: _safeDropdownItems(_trainingModes, _mode),
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

// ── Fix #4: rebuilt to match AddTrainingOptionScreen's UI (same field
// widgets, spacing, colors, conditional meeting-link field, loading
// button) instead of the old plain/undecorated form. Existing values are
// still prefilled in initState, same as before. ──
class _EditTrainingOptionScreenState extends State<EditTrainingOptionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _organizerCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _meetingLinkCtrl = TextEditingController();
  final _dateDisplayCtrl = TextEditingController();

  final _svc = TrainingService();

  late String _category;
  late String _mode;
  DateTime? _date;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.option;

    _titleCtrl.text = o.title;
    _organizerCtrl.text = o.organizer;
    _venueCtrl.text = o.venue;
    _durationCtrl.text = o.durationHours.toString();
    _meetingLinkCtrl.text = o.meetingLink ?? '';
    _category = o.category;
    _mode = o.mode;
    _date = o.trainingDate;
    _dateDisplayCtrl.text = DateFormat('d MMM yyyy').format(o.trainingDate);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _organizerCtrl.dispose();
    _venueCtrl.dispose();
    _durationCtrl.dispose();
    _meetingLinkCtrl.dispose();
    _dateDisplayCtrl.dispose();
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
      final updated = TrainingOption(
        id: widget.option.id,
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

      await _svc.updateTrainingOption(updated);
      // TODO(notifications): notify existing applicants that the training
      // details (date/venue/link/etc.) were changed.

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
        title: const Text('Edit Training Option'),
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
                // Fix #5: won't crash even if this option's saved category
                // (e.g. "Technology") no longer exists in the canonical list.
                items: _safeDropdownItems(
                    AppConstants.trainingCategories, _category),
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
                    initialDate: _date ?? DateTime.now(),
                    firstDate: DateTime(2020),
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
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Must be a number';
                    return null;
                  }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _mode,
                decoration: InputDecoration(
                    labelText: 'Mode',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12))),
                items: _safeDropdownItems(_trainingModes, _mode),
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
                label: 'Save Changes',
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