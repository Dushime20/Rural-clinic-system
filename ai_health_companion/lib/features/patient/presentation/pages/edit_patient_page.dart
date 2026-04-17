import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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

  // Form field controllers
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _allergiesController;
  late TextEditingController _chronicConditionsController;

  String? _selectedGender;
  String? _selectedBloodType;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing patient data
    _nameController = TextEditingController(
      text: widget.patientData?['name'] ?? '',
    );
    _ageController = TextEditingController(
      text: widget.patientData?['age']?.toString() ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.patientData?['phone'] ?? '',
    );
    _emailController = TextEditingController(
      text: widget.patientData?['email'] ?? '',
    );
    _addressController = TextEditingController(
      text: widget.patientData?['address'] ?? '',
    );
    _weightController = TextEditingController(
      text:
          widget.patientData?['weight']?.toString().replaceAll(' kg', '') ?? '',
    );
    _heightController = TextEditingController(
      text:
          widget.patientData?['height']?.toString().replaceAll(' cm', '') ?? '',
    );

    // Handle allergies array
    if (widget.patientData?['allergies'] is List) {
      _allergiesController = TextEditingController(
        text: (widget.patientData!['allergies'] as List).join(', '),
      );
    } else {
      _allergiesController = TextEditingController(
        text: widget.patientData?['allergies'] ?? '',
      );
    }

    // Handle chronic conditions array
    if (widget.patientData?['chronicConditions'] is List) {
      _chronicConditionsController = TextEditingController(
        text: (widget.patientData!['chronicConditions'] as List).join(', '),
      );
    } else {
      _chronicConditionsController = TextEditingController(
        text: widget.patientData?['chronicConditions'] ?? '',
      );
    }

    _selectedGender = widget.patientData?['gender'];
    _selectedBloodType = widget.patientData?['bloodType'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
    super.dispose();
  }

  void _updatePatient() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement patient update logic (e.g., update in local DB)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient updated successfully!')),
      );
      // Navigate back to patient detail page
      context.go('/patient/${widget.patientId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Edit Patient',
        subtitle: 'Update patient information',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePatient,
            tooltip: 'Save Changes',
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
              _buildSectionTitle('Personal Information'),
              _buildTextFormField(
                controller: _nameController,
                label: 'Full Name',
                icon: Icons.person,
                validator:
                    (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _ageController,
                      label: 'Age',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Enter age' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdownFormField(
                      value: _selectedGender,
                      label: 'Gender',
                      icon: Icons.person_outline,
                      items: _genders,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator:
                          (value) => value == null ? 'Select gender' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Contact Information'),
              _buildTextFormField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email Address (Optional)',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Medical Information'),
              _buildDropdownFormField(
                value: _selectedBloodType,
                label: 'Blood Type',
                icon: Icons.bloodtype,
                items: _bloodTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedBloodType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextFormField(
                      controller: _weightController,
                      label: 'Weight (kg)',
                      icon: Icons.monitor_weight,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextFormField(
                      controller: _heightController,
                      label: 'Height (cm)',
                      icon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _allergiesController,
                label: 'Allergies (comma-separated)',
                icon: Icons.warning_amber,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _chronicConditionsController,
                label: 'Chronic Conditions (comma-separated)',
                icon: Icons.local_hospital,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updatePatient,
                  icon: const Icon(Icons.save),
                  label: const Text('Update Patient'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
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

  Widget _buildDropdownFormField<T>({
    required T? value,
    required String label,
    required IconData icon,
    required List<T> items,
    required void Function(T?)? onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items:
          items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
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
