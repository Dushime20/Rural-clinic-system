import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

class SymptomInputCard extends StatelessWidget {
  final String title;
  final List<String> symptoms;
  final Map<String, bool> selectedSymptoms;
  final Function(String, bool) onSymptomChanged;

  const SymptomInputCard({
    super.key,
    required this.title,
    required this.symptoms,
    required this.selectedSymptoms,
    required this.onSymptomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptoms.map((symptom) {
                final isSelected = selectedSymptoms[symptom] ?? false;
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) => onSymptomChanged(symptom, selected),
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
