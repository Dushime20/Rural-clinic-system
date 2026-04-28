import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/patient_service.dart';
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
  final _patientService = PatientService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _patient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPatient();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await _patientService.getPatientById(widget.patientId);
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _patient = result['data'] as Map<String, dynamic>;
      } else {
        _error = result['message'];
      }
    });
  }

  String _getAge() {
    final dob = _patient?['dateOfBirth'];
    if (dob == null) return '—';
    try {
      final birth = DateTime.parse(dob.toString());
      return '${DateTime.now().difference(birth).inDays ~/ 365} yrs';
    } catch (_) {
      return '—';
    }
  }

  String _initials() {
    final first = (_patient?['firstName'] ?? '').toString();
    final last = (_patient?['lastName'] ?? '').toString();
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppHeader(title: 'Patient Details', subtitle: ''),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _patient == null) {
      return Scaffold(
        appBar: AppHeader(title: 'Patient Details', subtitle: ''),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(_error ?? 'Patient not found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPatient,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final name =
        '${_patient!['firstName'] ?? ''} ${_patient!['lastName'] ?? ''}'.trim();

    return Scaffold(
      appBar: AppHeader(
        title: name,
        subtitle: 'ID: ${_patient!['patientId'] ?? widget.patientId}',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await context.push(
                '/patient/${widget.patientId}/edit',
                extra: _patient,
              );
              _loadPatient();
            },
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatient,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Medical'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(name),
          _buildMedicalTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primaryColor.withAlpha(26),
                    child: Text(
                      _initials(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _chip(_getAge(), Icons.cake),
                      _chip(
                        (_patient!['gender'] ?? '—').toString(),
                        Icons.person,
                      ),
                      _chip(
                        (_patient!['bloodType'] ?? '—').toString(),
                        Icons.bloodtype,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/diagnosis'),
                  icon: const Icon(Icons.psychology, size: 18),
                  label: const Text('New Diagnosis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.push(
                      '/patient/${widget.patientId}/edit',
                      extra: _patient,
                    );
                    _loadPatient();
                  },
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Patient'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contact info
          _sectionTitle('Contact Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detailRow(
                    Icons.phone,
                    'Phone',
                    _patient!['phoneNumber'] ?? '—',
                  ),
                  const Divider(),
                  _detailRow(Icons.email, 'Email', _patient!['email'] ?? '—'),
                  const Divider(),
                  _detailRow(
                    Icons.location_on,
                    'Address',
                    _formatAddress(_patient!['address']),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Physical info
          _sectionTitle('Physical Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detailRow(
                    Icons.monitor_weight,
                    'Weight',
                    _patient!['weight'] != null
                        ? '${_patient!['weight']} kg'
                        : '—',
                  ),
                  const Divider(),
                  _detailRow(
                    Icons.height,
                    'Height',
                    _patient!['height'] != null
                        ? '${_patient!['height']} cm'
                        : '—',
                  ),
                  const Divider(),
                  _detailRow(
                    Icons.calendar_today,
                    'Date of Birth',
                    _patient!['dateOfBirth']?.toString().split('T')[0] ?? '—',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalTab() {
    final allergies = (_patient!['allergies'] as List?) ?? [];
    final chronic = (_patient!['chronicConditions'] as List?) ?? [];
    final medications = (_patient!['currentMedications'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Allergies'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  allergies.isEmpty
                      ? const Text(
                        'No allergies recorded',
                        style: TextStyle(color: AppTheme.textSecondary),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            allergies
                                .map(
                                  (a) => Chip(
                                    label: Text(a.toString()),
                                    backgroundColor: Colors.red.shade50,
                                    labelStyle: const TextStyle(
                                      color: Colors.red,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ),
          const SizedBox(height: 16),

          _sectionTitle('Chronic Conditions'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  chronic.isEmpty
                      ? const Text(
                        'No chronic conditions recorded',
                        style: TextStyle(color: AppTheme.textSecondary),
                      )
                      : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            chronic
                                .map(
                                  (c) => Chip(
                                    label: Text(c.toString()),
                                    backgroundColor: Colors.orange.shade50,
                                    labelStyle: const TextStyle(
                                      color: Colors.orange,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ),
          const SizedBox(height: 16),

          _sectionTitle('Current Medications'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  medications.isEmpty
                      ? const Text(
                        'No current medications',
                        style: TextStyle(color: AppTheme.textSecondary),
                      )
                      : Column(
                        children:
                            medications
                                .map(
                                  (m) => ListTile(
                                    leading: const Icon(
                                      Icons.medication,
                                      color: AppTheme.secondaryColor,
                                    ),
                                    title: Text(m.toString()),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                )
                                .toList(),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final lastVisit = _patient!['lastVisit'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Visit Information'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _detailRow(
                    Icons.access_time,
                    'Last Visit',
                    lastVisit?.toString().split('T')[0] ?? 'No visits recorded',
                  ),
                  const Divider(),
                  _detailRow(
                    Icons.calendar_today,
                    'Registered',
                    _patient!['createdAt']?.toString().split('T')[0] ?? '—',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.history,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Full diagnosis history coming soon',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/diagnosis'),
                  icon: const Icon(Icons.psychology),
                  label: const Text('Start New Diagnosis'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(dynamic address) {
    if (address == null) return '—';
    if (address is Map) {
      final parts =
          [
            address['street'],
            address['city'],
            address['country'],
          ].where((e) => e != null && e.toString().isNotEmpty).toList();
      return parts.isEmpty ? '—' : parts.join(', ');
    }
    return address.toString();
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget _chip(String label, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: AppTheme.primaryColor.withAlpha(26),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _detailRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
