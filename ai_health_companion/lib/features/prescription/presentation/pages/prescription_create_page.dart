import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class PrescriptionCreatePage extends StatefulWidget {
  final String patientId;
  final String? patientName;
  final String? diagnosisId;

  const PrescriptionCreatePage({
    super.key,
    required this.patientId,
    this.patientName,
    this.diagnosisId,
  });

  @override
  State<PrescriptionCreatePage> createState() => _PrescriptionCreatePageState();
}

class _PrescriptionCreatePageState extends State<PrescriptionCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _medications = [];
  bool _isSearching = false;

  // Mock drug database
  final List<Map<String, dynamic>> _drugDatabase = [
    {'name': 'Amoxicillin 500mg', 'category': 'Antibiotic', 'form': 'Capsule'},
    {'name': 'Paracetamol 500mg', 'category': 'Analgesic', 'form': 'Tablet'},
    {'name': 'Ibuprofen 400mg', 'category': 'NSAID', 'form': 'Tablet'},
    {'name': 'Metformin 850mg', 'category': 'Antidiabetic', 'form': 'Tablet'},
    {
      'name': 'Lisinopril 10mg',
      'category': 'Antihypertensive',
      'form': 'Tablet',
    },
    {'name': 'Omeprazole 20mg', 'category': 'PPI', 'form': 'Capsule'},
  ];

  void _addMedication() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildMedicationSelector(),
    );
  }

  Widget _buildMedicationSelector() {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Medication',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search medications...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _isSearching = value.isNotEmpty);
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _drugDatabase.length,
                itemBuilder: (context, index) {
                  final drug = _drugDatabase[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.medication,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    title: Text(drug['name']),
                    subtitle: Text('${drug['category']} • ${drug['form']}'),
                    trailing: const Icon(
                      Icons.add_circle,
                      color: AppTheme.primaryColor,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showDosageDialog(drug);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDosageDialog(Map<String, dynamic> drug) {
    final dosageController = TextEditingController(text: '1');
    final frequencyController = TextEditingController(text: 'Twice daily');
    final durationController = TextEditingController(text: '7');
    final instructionsController = TextEditingController(
      text: 'Take after meals',
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(drug['name']),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                      labelText: 'Dosage',
                      hintText: 'e.g., 1 tablet',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: frequencyController,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      hintText: 'e.g., Twice daily',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: durationController,
                    decoration: const InputDecoration(
                      labelText: 'Duration (days)',
                      hintText: 'e.g., 7',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instructionsController,
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      hintText: 'e.g., Take after meals',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _medications.add({
                      'drug': drug['name'],
                      'dosage': dosageController.text,
                      'frequency': frequencyController.text,
                      'duration': durationController.text,
                      'instructions': instructionsController.text,
                    });
                  });
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _savePrescription() {
    if (_formKey.currentState!.validate() && _medications.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Prescription saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else if (_medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one medication'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Create Prescription',
        subtitle:
            widget.patientName != null
                ? 'For ${widget.patientName}'
                : 'New prescription',
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePrescription,
            tooltip: 'Save Prescription',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.patientName ?? 'Patient',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'ID: ${widget.patientId}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Medications Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Medications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_medications.isEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No medications added',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap "Add" to add medications',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._medications.asMap().entries.map((entry) {
                  final index = entry.key;
                  final med = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.secondaryColor.withOpacity(
                          0.1,
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.secondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        med['drug'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${med['dosage']} • ${med['frequency']}'),
                          Text('Duration: ${med['duration']} days'),
                          Text('Instructions: ${med['instructions']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _medications.removeAt(index);
                          });
                        },
                      ),
                      isThreeLine: true,
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Additional Notes
              const Text(
                'Additional Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Add any additional instructions or notes...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _savePrescription,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save & Print'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
