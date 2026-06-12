import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/patient_service.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../shared/widgets/app_header.dart';

class AddPatientPage extends ConsumerStatefulWidget {
  const AddPatientPage({super.key});

  @override
  ConsumerState<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends ConsumerState<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();
  bool _isLoading = false;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _dateOfBirth;

  final List<String> _genders = ['male', 'female', 'other'];
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
    'unknown',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _chronicController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectDateOfBirth),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final patientData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'dateOfBirth': _dateOfBirth!.toIso8601String().split('T')[0],
      'gender': _selectedGender,
      if (_selectedBloodType != null) 'bloodType': _selectedBloodType,
      if (_phoneController.text.isNotEmpty)
        'phoneNumber': _phoneController.text.trim(),
      if (_emailController.text.isNotEmpty)
        'email': _emailController.text.trim(),
      if (_weightController.text.isNotEmpty)
        'weight': double.tryParse(_weightController.text),
      if (_heightController.text.isNotEmpty)
        'height': double.tryParse(_heightController.text),
      if (_allergiesController.text.isNotEmpty)
        'allergies':
            _allergiesController.text.split(',').map((e) => e.trim()).toList(),
      if (_chronicController.text.isNotEmpty)
        'chronicConditions':
            _chronicController.text.split(',').map((e) => e.trim()).toList(),
      if (_streetController.text.isNotEmpty || _cityController.text.isNotEmpty)
        'address': {
          if (_streetController.text.isNotEmpty)
            'street': _streetController.text.trim(),
          if (_cityController.text.isNotEmpty)
            'city': _cityController.text.trim(),
        },
    };

    final result = await _patientService.createPatient(patientData);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.patientCreatedSuccessfully),
          backgroundColor: AppTheme.successColor,
        ),
      );
      context.go('/patients');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? l10n.failedToCreatePatient),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get localized gender labels
    String getLocalizedGender(String gender) {
      switch (gender) {
        case 'male':
          return l10n.male;
        case 'female':
          return l10n.female;
        case 'other':
          return l10n.other;
        default:
          return gender;
      }
    }
    
    return Scaffold(
      appBar: AppHeader(
        title: l10n.addNewPatient,
        subtitle: l10n.registerNewPatient,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _savePatient,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(l10n.personalInformation),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _firstNameController,
                      l10n.firstName,
                      Icons.person,
                      validator: (v) => v!.trim().isEmpty ? l10n.required : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _lastNameController,
                      l10n.lastName,
                      Icons.person,
                      validator: (v) => v!.trim().isEmpty ? l10n.required : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date of Birth
              GestureDetector(
                onTap: _pickDateOfBirth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cake, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _dateOfBirth == null
                            ? l10n.dateOfBirthRequired
                            : '${l10n.dobPrefix} ${_dateOfBirth!.toIso8601String().split('T')[0]}',
                        style: TextStyle(
                          color:
                              _dateOfBirth == null
                                  ? Colors.grey.shade600
                                  : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _dropdown<String>(
                value: _selectedGender,
                label: l10n.genderRequired,
                icon: Icons.person_outline,
                items: _genders,
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => v == null ? l10n.selectGender : null,
                displayText: getLocalizedGender,
              ),
              const SizedBox(height: 24),

              _sectionTitle(l10n.contactInformation),
              _textField(
                _phoneController,
                l10n.phoneNumber,
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _textField(
                _emailController,
                l10n.emailOptional,
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _streetController,
                      l10n.street,
                      Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _cityController,
                      l10n.city,
                      Icons.location_city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _sectionTitle(l10n.medicalInformation),
              _dropdown<String>(
                value: _selectedBloodType,
                label: l10n.bloodType,
                icon: Icons.bloodtype,
                items: _bloodTypes,
                onChanged: (v) => setState(() => _selectedBloodType = v),
                displayText: (bloodType) => bloodType == 'unknown' ? l10n.unknown : bloodType,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _weightController,
                      l10n.weightKg,
                      Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _heightController,
                      l10n.heightCm,
                      Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _textField(
                _allergiesController,
                l10n.allergiesCommaSeparated,
                Icons.warning_amber,
              ),
              const SizedBox(height: 16),
              _textField(
                _chronicController,
                l10n.chronicConditionsCommaSeparated,
                Icons.local_hospital,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _savePatient,
                  icon:
                      _isLoading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(Icons.save),
                  label: Text(_isLoading ? l10n.saving : l10n.savePatient),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryColor,
      ),
    ),
  );

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required void Function(T?) onChanged,
    String? Function(T?)? validator,
    String Function(T)? displayText,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(displayText != null ? displayText(item) : item.toString()),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }
}
