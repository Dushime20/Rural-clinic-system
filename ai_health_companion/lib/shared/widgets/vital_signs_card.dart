import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VitalSignsCard extends StatelessWidget {
  final Map<String, dynamic> vitalSigns;
  final Function(String key, dynamic value) onChanged;

  const VitalSignsCard({
    super.key,
    required this.vitalSigns,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Vital Signs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Temperature
            _buildVitalSignInput(
              context,
              'Temperature',
              vitalSigns['temperature'],
              '°C',
              Icons.thermostat,
              AppTheme.errorColor,
              (value) => onChanged('temperature', value),
            ),
            
            const SizedBox(height: 16),
            
            // Blood Pressure
            Row(
              children: [
                Expanded(
                  child: _buildVitalSignInput(
                    context,
                    'Systolic BP',
                    vitalSigns['blood_pressure_systolic'],
                    'mmHg',
                    Icons.favorite,
                    AppTheme.primaryColor,
                    (value) => onChanged('blood_pressure_systolic', value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildVitalSignInput(
                    context,
                    'Diastolic BP',
                    vitalSigns['blood_pressure_diastolic'],
                    'mmHg',
                    Icons.favorite,
                    AppTheme.primaryColor,
                    (value) => onChanged('blood_pressure_diastolic', value),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Heart Rate
            _buildVitalSignInput(
              context,
              'Heart Rate',
              vitalSigns['heart_rate'],
              'bpm',
              Icons.favorite,
              AppTheme.errorColor,
              (value) => onChanged('heart_rate', value),
            ),
            
            const SizedBox(height: 16),
            
            // Respiratory Rate
            _buildVitalSignInput(
              context,
              'Respiratory Rate',
              vitalSigns['respiratory_rate'],
              'breaths/min',
              Icons.air,
              AppTheme.secondaryColor,
              (value) => onChanged('respiratory_rate', value),
            ),
            
            const SizedBox(height: 16),
            
            // Oxygen Saturation
            _buildVitalSignInput(
              context,
              'Oxygen Saturation',
              vitalSigns['oxygen_saturation'],
              '%',
              Icons.air,
              AppTheme.successColor,
              (value) => onChanged('oxygen_saturation', value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalSignInput(
    BuildContext context,
    String label,
    dynamic value,
    String unit,
    IconData icon,
    Color color,
    Function(dynamic) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.toString(),
          decoration: InputDecoration(
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color),
            ),
          ),
          keyboardType: TextInputType.number,
          onChanged: (text) {
            final numValue = double.tryParse(text);
            if (numValue != null) {
              onChanged(numValue);
            }
          },
        ),
      ],
    );
  }
}

