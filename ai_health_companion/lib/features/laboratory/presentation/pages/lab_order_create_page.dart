import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class LabOrderCreatePage extends StatefulWidget {
  final String patientId;
  final String? patientName;
  final String? diagnosisId;

  const LabOrderCreatePage({
    super.key,
    required this.patientId,
    this.patientName,
    this.diagnosisId,
  });

  @override
  State<LabOrderCreatePage> createState() => _LabOrderCreatePageState();
}

class _LabOrderCreatePageState extends State<LabOrderCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final List<Map<String, dynamic>> _selectedTests = [];
  String _priority = 'Routine';
  final _clinicalNotesController = TextEditingController();

  // Mock lab test catalog (LOINC codes)
  final Map<String, List<Map<String, dynamic>>> _testCatalog = {
    'Hematology': [
      {
        'name': 'Complete Blood Count (CBC)',
        'code': '58410-2',
        'price': '5000 RWF',
      },
      {'name': 'Hemoglobin', 'code': '718-7', 'price': '2000 RWF'},
      {'name': 'White Blood Cell Count', 'code': '6690-2', 'price': '2000 RWF'},
      {'name': 'Platelet Count', 'code': '777-3', 'price': '2000 RWF'},
    ],
    'Chemistry': [
      {'name': 'Blood Glucose', 'code': '2345-7', 'price': '1500 RWF'},
      {'name': 'Creatinine', 'code': '2160-0', 'price': '2500 RWF'},
      {
        'name': 'Liver Function Tests (LFT)',
        'code': '24325-3',
        'price': '8000 RWF',
      },
      {'name': 'Lipid Profile', 'code': '24331-1', 'price': '6000 RWF'},
    ],
    'Microbiology': [
      {'name': 'Malaria Test', 'code': '32700-7', 'price': '3000 RWF'},
      {'name': 'Urine Culture', 'code': '630-4', 'price': '5000 RWF'},
      {'name': 'Blood Culture', 'code': '600-7', 'price': '8000 RWF'},
      {'name': 'Stool Analysis', 'code': '6503-7', 'price': '3500 RWF'},
    ],
    'Serology': [
      {'name': 'HIV Test', 'code': '75622-1', 'price': '2000 RWF'},
      {
        'name': 'Hepatitis B Surface Antigen',
        'code': '5196-1',
        'price': '4000 RWF',
      },
      {'name': 'Pregnancy Test', 'code': '2118-8', 'price': '1500 RWF'},
    ],
  };

  // Common test panels
  final List<Map<String, dynamic>> _testPanels = [
    {
      'name': 'Basic Metabolic Panel',
      'tests': ['Blood Glucose', 'Creatinine'],
      'icon': Icons.science,
    },
    {
      'name': 'Anemia Workup',
      'tests': ['Complete Blood Count (CBC)', 'Hemoglobin'],
      'icon': Icons.bloodtype,
    },
    {
      'name': 'Diabetes Screening',
      'tests': ['Blood Glucose', 'Lipid Profile'],
      'icon': Icons.monitor_heart,
    },
  ];

  void _addTest(Map<String, dynamic> test) {
    if (!_selectedTests.any((t) => t['code'] == test['code'])) {
      setState(() {
        _selectedTests.add(test);
      });
    }
  }

  void _removeTest(int index) {
    setState(() {
      _selectedTests.removeAt(index);
    });
  }

  void _addPanel(Map<String, dynamic> panel) {
    for (var category in _testCatalog.values) {
      for (var test in category) {
        if (panel['tests'].contains(test['name'])) {
          _addTest(test);
        }
      }
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate() && _selectedTests.isNotEmpty) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirm Lab Order'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient: ${widget.patientName}'),
                  Text('Tests: ${_selectedTests.length}'),
                  Text('Priority: $_priority'),
                  const SizedBox(height: 8),
                  const Text(
                    'Submit this lab order?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Lab order submitted successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
      );
    } else if (_selectedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one test'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Create Lab Order',
        subtitle:
            widget.patientName != null
                ? 'For ${widget.patientName}'
                : 'New lab order',
        actions: [
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _submitOrder,
            tooltip: 'Submit Order',
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
              // Patient Info
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

              // Priority Selection
              const Text(
                'Priority',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildPriorityChip('Routine', Icons.schedule),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPriorityChip('Urgent', Icons.priority_high),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Panels
              const Text(
                'Quick Panels',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _testPanels.length,
                  itemBuilder: (context, index) {
                    final panel = _testPanels[index];
                    return Card(
                      margin: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => _addPanel(panel),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                panel['icon'],
                                color: AppTheme.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                panel['name'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Selected Tests
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Selected Tests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_selectedTests.length} tests',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_selectedTests.isEmpty)
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
                            Icons.science_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No tests selected',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._selectedTests.asMap().entries.map((entry) {
                  final index = entry.key;
                  final test = entry.value;
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
                        test['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'LOINC: ${test['code']} • ${test['price']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeTest(index),
                      ),
                    ),
                  );
                }),

              const SizedBox(height: 24),

              // Browse Tests
              const Text(
                'Browse Tests',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ..._testCatalog.entries.map((category) {
                return ExpansionTile(
                  title: Text(
                    category.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children:
                      category.value.map((test) {
                        final isSelected = _selectedTests.any(
                          (t) => t['code'] == test['code'],
                        );
                        return ListTile(
                          title: Text(test['name']),
                          subtitle: Text(
                            'LOINC: ${test['code']} • ${test['price']}',
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                  : const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.primaryColor,
                                  ),
                          onTap: () => _addTest(test),
                        );
                      }).toList(),
                );
              }),

              const SizedBox(height: 24),

              // Clinical Notes
              const Text(
                'Clinical Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _clinicalNotesController,
                decoration: InputDecoration(
                  hintText:
                      'Add clinical indication or special instructions...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Submit Lab Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String label, IconData icon) {
    final isSelected = _priority == label;
    return InkWell(
      onTap: () => setState(() => _priority = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _clinicalNotesController.dispose();
    super.dispose();
  }
}
