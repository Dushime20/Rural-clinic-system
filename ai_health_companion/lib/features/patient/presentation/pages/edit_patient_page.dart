import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/patient_service.dart';
import '../../../../shared/widgets/app_header.dart';

class EditPatientPage extends ConsumerStatefulWidget {
  final String patientId;
  final Map<String, dynamic>? patientData;

  const EditPatientPage({super.key, required this.patientId, this.patientData});

  @override
  ConsumerState<EditPatientPage> createState() => _EditPatientPageState();
}

class _EditPatientPageState extends ConsumerState<EditPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final _patientService = PatientService();
  bool _isLoading = false;
  bool _isFetching = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _allergiesController;
  late TextEditingController _chronicController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;

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
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _allergiesController = TextEditingController();
    _chronicController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();

    if (widget.patientData != null) {
      _populateFields(widget.patientData!);
    } else {
      _fetchPatient();
    }
  }

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

  Future<void> _fetchPatient() async {
    setState(() => _isFetching = true);
    final result = await _patientService.getPatientById(widget.patientId);
    if (!mounted) return;
    setState(() => _isFetching = false);
    if (result['success'] == true) {
      _populateFields(result['data'] as Map<String, dynamic>);
    }
  }

  void _populateFields(Map<String, dynamic> p) {
    _firstNameController.text = p['firstName'] ?? '';
    _lastNameController.text = p['lastName'] ?? '';
    _phoneController.text = p['phoneNumber'] ?? '';
    _emailController.text = p['email'] ?? '';
    _weightController.text = p['weight']?.toString() ?? '';
    _heightController.text = p['height']?.toString() ?? '';
    _allergiesController.text = ((p['allergies'] as List?)?.join(', ')) ?? '';
    _chronicController.text =
        ((p['chronicConditions'] as List?)?.join(', ')) ?? '';
    _streetController.text = p['address']?['street'] ?? '';
    _cityController.text = p['address']?['city'] ?? '';

    final gender = p['gender']?.toString().toLowerCase();
    if (_genders.contains(gender)) _selectedGender = gender;

    final blood = p['bloodType']?.toString();
    if (_bloodTypes.contains(blood)) _selectedBloodType = blood;

    final dob = p['dateOfBirth'];
    if (dob != null) {
      try {
        _dateOfBirth = DateTime.parse(dob.toString());
      } catch (_) {}
    }
    setState(() {});
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final patientData = <String, dynamic>{
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      if (_dateOfBirth != null)
        'dateOfBirth': _dateOfBirth!.toIso8601String().split('T')[0],
      if (_selectedGender != null) 'gender': _selectedGender,
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

    final result = await _patientService.updatePatient(
      widget.patientId,
      patientData,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success'] == true
              ? 'Patient updated successfully'
              : result['message'] ?? 'Update failed',
        ),
        backgroundColor:
            result['success'] == true
                ? AppTheme.successColor
                : AppTheme.errorColor,
      ),
    );

    if (result['success'] == true) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetching) {
      return Scaffold(
        appBar: AppHeader(title: 'Edit Patient', subtitle: 'Loading...'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppHeader(
        title: 'Edit Patient',
        subtitle:
            '${_firstNameController.text} ${_lastNameController.text}'.trim(),
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
              tooltip: 'Save',
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
              _sectionTitle('Personal Information'),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _firstNameController,
                      'First Name',
                      Icons.person,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _lastNameController,
                      'Last Name',
                      Icons.person,
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

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
                            ? 'Date of Birth'
                            : 'DOB: ${_dateOfBirth!.toIso8601String().split('T')[0]}',
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
                label: 'Gender',
                icon: Icons.person_outline,
                items: _genders,
                onChanged: (v) => setState(() => _selectedGender = v),
              ),
              const SizedBox(height: 24),

              _sectionTitle('Contact Information'),
              _textField(
                _phoneController,
                'Phone Number',
                Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _textField(
                _emailController,
                'Email',
                Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _streetController,
                      'Street',
                      Icons.location_on,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _cityController,
                      'City',
                      Icons.location_city,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _sectionTitle('Medical Information'),
              _dropdown<String>(
                value: _selectedBloodType,
                label: 'Blood Type',
                icon: Icons.bloodtype,
                items: _bloodTypes,
                onChanged: (v) => setState(() => _selectedBloodType = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      _weightController,
                      'Weight (kg)',
                      Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      _heightController,
                      'Height (cm)',
                      Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _textField(
                _allergiesController,
                'Allergies (comma-separated)',
                Icons.warning_amber,
              ),
              const SizedBox(height: 16),
              _textField(
                _chronicController,
                'Chronic Conditions (comma-separated)',
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
                  label: Text(_isLoading ? 'Saving...' : 'Update Patient'),
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
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items:
          items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(item.toString()),
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
