import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class PatientDetailPage extends StatefulWidget {
  final String patientId;

  const PatientDetailPage({super.key, required this.patientId});

  @override
  State<PatientDetailPage> createState() => _PatientDetailPageState();
}

class _PatientDetailPageState extends State<PatientDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock patient data
  final Map<String, dynamic> _patientData = {
    'name': 'John Doe',
    'age': 45,
    'gender': 'Male',
    'bloodType': 'O+',
    'phone': '+250 788 123 456',
    'email': 'john.doe@email.com',
    'address': 'Kigali, Gasabo District',
    'weight': '75 kg',
    'height': '175 cm',
    'allergies': ['Penicillin', 'Peanuts'],
    'chronicConditions': ['Hypertension', 'Type 2 Diabetes'],
  };

  final List<Map<String, dynamic>> _recentVisits = [
    {
      'date': '2026-02-01',
      'diagnosis': 'Common Cold',
      'doctor': 'Dr. Smith',
      'status': 'Completed',
    },
    {
      'date': '2026-01-15',
      'diagnosis': 'Hypertension Follow-up',
      'doctor': 'Dr. Johnson',
      'status': 'Completed',
    },
    {
      'date': '2025-12-20',
      'diagnosis': 'Diabetes Check',
      'doctor': 'Dr. Williams',
      'status': 'Completed',
    },
  ];

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Metformin 850mg',
      'dosage': '1 tablet twice daily',
      'startDate': '2025-06-01',
      'status': 'Active',
    },
    {
      'name': 'Lisinopril 10mg',
      'dosage': '1 tablet daily',
      'startDate': '2025-08-15',
      'status': 'Active',
    },
  ];

  final List<Map<String, dynamic>> _pharmacyData = [
    {
      'name': 'Kigali Pharmacy',
      'distance': '2.5 km',
      'stock': ['Metformin 850mg', 'Lisinopril 10mg', 'Amoxicillin'],
    },
    {
      'name': 'Unity Pharmacy',
      'distance': '3.1 km',
      'stock': ['Lisinopril 10mg', 'Ibuprofen'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: _patientData['name'],
        subtitle: 'Patient ID: ${widget.patientId}',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.go(
                '/patient/${widget.patientId}/edit',
                extra: _patientData,
              );
            },
            tooltip: 'Edit Patient',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'History'),
            Tab(text: 'Medications'),
            Tab(text: 'Pharmacy'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildHistoryTab(),
          _buildMedicationsTab(),
          _buildPharmacyTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
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
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withAlpha(26),
                    child: Text(
                      _patientData['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _patientData['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoChip(
                        '${_patientData['age']} years',
                        Icons.cake,
                      ),
                      const SizedBox(width: 8),
                      _buildInfoChip(_patientData['gender'], Icons.person),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                        _patientData['bloodType'],
                        Icons.bloodtype,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 16),

          // Contact Information
          _buildSectionTitle('Contact Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(Icons.phone, 'Phone', _patientData['phone']),
                  const Divider(),
                  _buildDetailRow(Icons.email, 'Email', _patientData['email']),
                  const Divider(),
                  _buildDetailRow(
                    Icons.location_on,
                    'Address',
                    _patientData['address'],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Physical Information
          _buildSectionTitle('Physical Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    Icons.monitor_weight,
                    'Weight',
                    _patientData['weight'],
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.height,
                    'Height',
                    _patientData['height'],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Medical Information
          _buildSectionTitle('Medical Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Allergies',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        (_patientData['allergies'] as List)
                            .map(
                              (allergy) => Chip(
                                label: Text(allergy),
                                backgroundColor: Colors.red[100],
                                labelStyle: const TextStyle(color: Colors.red),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chronic Conditions',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        (_patientData['chronicConditions'] as List)
                            .map(
                              (condition) => Chip(
                                label: Text(condition),
                                backgroundColor: Colors.orange[100],
                                labelStyle: const TextStyle(
                                  color: Colors.orange,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentVisits.length,
      itemBuilder: (context, index) {
        final visit = _recentVisits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withAlpha(26),
              child: const Icon(
                Icons.medical_services,
                color: AppTheme.primaryColor,
              ),
            ),
            title: Text(
              visit['diagnosis'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Doctor: ${visit['doctor']}'),
                Text('Date: ${visit['date']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                visit['status'],
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () {
              // View visit details
            },
          ),
        );
      },
    );
  }

  Widget _buildMedicationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.secondaryColor.withAlpha(26),
              child: const Icon(
                Icons.medication,
                color: AppTheme.secondaryColor,
              ),
            ),
            title: Text(
              medication['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Dosage: ${medication['dosage']}'),
                Text('Since: ${medication['startDate']}'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                medication['status'],
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPharmacyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pharmacyData.length,
      itemBuilder: (context, index) {
        final pharmacy = _pharmacyData[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.teal.withAlpha(26),
              child: const Icon(Icons.local_pharmacy, color: Colors.teal),
            ),
            title: Text(
              pharmacy['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${pharmacy['distance']} away'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to pharmacy details page
            },
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.playlist_add_check,
              label: 'New Diagnosis',
              onPressed: () {
                // TODO: Navigate to new diagnosis page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New Diagnosis not implemented yet.'),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              icon: Icons.mic,
              label: 'Voice Input',
              onPressed: () {
                // TODO: Implement voice input functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice input not implemented yet.'),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          side: BorderSide(color: AppTheme.primaryColor.withAlpha(50)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
