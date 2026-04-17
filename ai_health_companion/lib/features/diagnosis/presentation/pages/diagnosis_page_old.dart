import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class DiagnosisPage extends ConsumerStatefulWidget {
  const DiagnosisPage({super.key});

  @override
  ConsumerState<DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends ConsumerState<DiagnosisPage> {
  final _formKey = GlobalKey<FormState>();
  final _symptomsController = TextEditingController();

  // Mock data for suggestions
  final List<String> _symptomSuggestions = [
    'Fever',
    'Cough',
    'Headache',
    'Fatigue',
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Sore throat',
    'Shortness of breath',
    'Dizziness',
    'Joint pain',
    'Muscle ache',
    'Chills',
  ];

  List<String> _selectedSymptoms = [];

  void _onSymptomSelected(String symptom) {
    setState(() {
      if (!_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.add(symptom);
      }
      _symptomsController.clear();
    });
  }

  void _onSymptomRemoved(String symptom) {
    setState(() {
      _selectedSymptoms.remove(symptom);
    });
  }

  void _startDiagnosis() {
    if (_formKey.currentState!.validate() && _selectedSymptoms.isNotEmpty) {
      final diagnosisData = {
        'symptoms': _selectedSymptoms,
        'prediction': 'Malaria', // Mock prediction
        'confidence': 0.85,
      };
      context.go('/diagnosis/result', extra: diagnosisData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'AI Diagnosis',
        subtitle: 'Symptom-based disease prediction',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/diagnosis/history'),
            tooltip: 'History',
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
              // Title and description
              Text(
                'Symptom Checker',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the patient\'s symptoms below to get an AI-powered diagnosis prediction.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 32),

              // Symptom input field
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  return _symptomSuggestions.where((String option) {
                    return option.toLowerCase().contains(
                      textEditingValue.text.toLowerCase(),
                    );
                  });
                },
                onSelected: _onSymptomSelected,
                fieldViewBuilder: (
                  context,
                  controller,
                  focusNode,
                  onEditingComplete,
                ) {
                  _symptomsController.text = controller.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    onEditingComplete: onEditingComplete,
                    decoration: InputDecoration(
                      labelText: 'Type a symptom (e.g., Fever)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Selected symptoms
              _buildSelectedSymptoms(),
              const SizedBox(height: 32),

              // Diagnosis button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _startDiagnosis,
                  icon: const Icon(Icons.psychology),
                  label: const Text('Run Diagnosis'),
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

  Widget _buildSelectedSymptoms() {
    if (_selectedSymptoms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            'No symptoms added yet.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Symptoms',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _selectedSymptoms.map((symptom) {
                return Chip(
                  label: Text(symptom),
                  onDeleted: () => _onSymptomRemoved(symptom),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  backgroundColor: AppTheme.primaryColor.withAlpha(26),
                  labelStyle: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
