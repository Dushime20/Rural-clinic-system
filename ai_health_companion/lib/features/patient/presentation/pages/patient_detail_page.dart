import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/patient_service.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../diagnosis/data/models/diagnosis_models.dart';
import '../../../diagnosis/data/services/diagnosis_service.dart';
import '../../../../core/services/api_service.dart';

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
  late final DiagnosisService _diagnosisService;

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _patient;
  
  // Diagnosis history state
  List<DiagnosisResponse> _diagnoses = [];
  bool _isLoadingDiagnoses = false;
  String? _diagnosisError;
  int _currentPage = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _diagnosisService = DiagnosisService(ApiService());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadPatient();
  }
  
  void _onTabChanged() {
    // Load diagnoses when History tab or Medical tab is selected
    if ((_tabController.index == 1 || _tabController.index == 2) && 
        _diagnoses.isEmpty && 
        !_isLoadingDiagnoses) {
      _loadDiagnoses();
    }
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
  
  Future<void> _loadDiagnoses({int page = 1}) async {
    setState(() {
      _isLoadingDiagnoses = true;
      _diagnosisError = null;
    });
    
    try {
      final diagnoses = await _diagnosisService.getPatientDiagnoses(
        widget.patientId,
        page: page,
        limit: 10,
      );
      
      if (!mounted) return;
      
      setState(() {
        _diagnoses = diagnoses;
        _currentPage = page;
        _isLoadingDiagnoses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _diagnosisError = e.toString().replaceAll('Exception: ', '');
        _isLoadingDiagnoses = false;
      });
    }
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
    
    // Get medications from last diagnosis
    final lastDiagnosisMedications = _diagnoses.isNotEmpty && 
                                     _diagnoses[0].prescriptions != null
        ? _diagnoses[0].prescriptions!
        : <Prescription>[];

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Current Medications'),
              if (lastDiagnosisMedications.isNotEmpty)
                Text(
                  'From last diagnosis',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child:
                  lastDiagnosisMedications.isEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (medications.isEmpty)
                              const Text(
                                'No current medications',
                                style: TextStyle(color: AppTheme.textSecondary),
                              )
                            else
                              Column(
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
                          ],
                        )
                      : Column(
                          children: lastDiagnosisMedications.map((prescription) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.shade100,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.medication,
                                        color: AppTheme.primaryColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          prescription.medication,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _medicationInfoRow(
                                    Icons.medical_services,
                                    'Dosage',
                                    prescription.dosage,
                                  ),
                                  _medicationInfoRow(
                                    Icons.schedule,
                                    'Frequency',
                                    prescription.frequency,
                                  ),
                                  _medicationInfoRow(
                                    Icons.calendar_today,
                                    'Duration',
                                    prescription.duration,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _medicationInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
          
          // Diagnosis History Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Diagnosis History'),
              if (_diagnoses.isNotEmpty)
                TextButton.icon(
                  onPressed: _loadDiagnoses,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
            ],
          ),
          
          if (_isLoadingDiagnoses)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_diagnosisError != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppTheme.errorColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _diagnosisError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDiagnoses,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_diagnoses.isEmpty)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(
                      Icons.history,
                      size: 64,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No diagnosis history found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start a new diagnosis to see it here',
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
            )
          else
            ..._diagnoses.map((diagnosis) => _buildDiagnosisCard(diagnosis)),
        ],
      ),
    );
  }
  
  Widget _buildDiagnosisCard(DiagnosisResponse diagnosis) {
    final primaryPrediction = diagnosis.aiPredictions.isNotEmpty 
        ? diagnosis.aiPredictions[0] 
        : null;
    final selectedDiagnosis = diagnosis.selectedDiagnosis;
    
    // Use selected diagnosis if available, otherwise use primary prediction
    final displayDisease = selectedDiagnosis?.disease ?? primaryPrediction?.disease ?? 'Unknown';
    final displayConfidence = selectedDiagnosis?.confidence ?? primaryPrediction?.confidence ?? 0.0;
    final displayIcd10 = selectedDiagnosis?.icd10Code ?? primaryPrediction?.icd10Code;
    
    final date = diagnosis.diagnosisDate;
    final formattedDate = '${date.day}/${date.month}/${date.year}';
    final formattedTime = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showDiagnosisDetails(diagnosis),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.medical_information,
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayDisease,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'ID: ${diagnosis.diagnosisId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (displayIcd10 != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  displayIcd10,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getConfidenceColor(displayConfidence).withAlpha(26),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(displayConfidence * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _getConfidenceColor(displayConfidence),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _infoChip(
                      Icons.calendar_today,
                      formattedDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _infoChip(
                      Icons.access_time,
                      formattedTime,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _infoChip(
                      Icons.medication,
                      '${diagnosis.prescriptions?.length ?? 0} Rx',
                    ),
                  ),
                ],
              ),
              if (diagnosis.symptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...diagnosis.symptoms.take(3).map((symptom) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          symptom.name,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      );
                    }),
                    if (diagnosis.symptoms.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '+${diagnosis.symptoms.length - 3} more',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showDiagnosisDetails(diagnosis),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
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
  
  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }
  
  void _showDiagnosisDetails(DiagnosisResponse diagnosis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Diagnosis Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: _buildDiagnosisDetailsContent(diagnosis),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDiagnosisDetailsContent(DiagnosisResponse diagnosis) {
    final primaryPrediction = diagnosis.aiPredictions.isNotEmpty 
        ? diagnosis.aiPredictions[0] 
        : null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diagnosis Info
        _detailSection(
          'Diagnosis Information',
          [
            _detailItem('Diagnosis ID', diagnosis.diagnosisId),
            _detailItem('Date', diagnosis.diagnosisDate.toString().split('.')[0]),
          ],
        ),
        
        // AI Predictions
        if (diagnosis.aiPredictions.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'AI Predictions',
            diagnosis.aiPredictions.map((pred) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pred.disease,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(pred.confidence).withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pred.confidencePercentage,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getConfidenceColor(pred.confidence),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (pred.icd10Code != null)
                    Text(
                      'ICD-10: ${pred.icd10Code}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ),
        ],
        
        // Disease Description (from primary prediction)
        if (primaryPrediction?.description != null && 
            primaryPrediction!.description!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'About ${primaryPrediction.disease}',
            [
              Text(
                primaryPrediction.description!,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ],
        
        // Symptoms
        if (diagnosis.symptoms.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Symptoms (${diagnosis.symptoms.length})',
            [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: diagnosis.symptoms.map((symptom) {
                  return Chip(
                    label: Text(symptom.name),
                    backgroundColor: Colors.orange.shade50,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
        
        // Vital Signs
        if (diagnosis.vitalSigns.hasAnyData) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Vital Signs',
            [
              if (diagnosis.vitalSigns.temperature != null)
                _detailItem('Temperature', '${diagnosis.vitalSigns.temperature}°C'),
              if (diagnosis.vitalSigns.bloodPressureSystolic != null)
                _detailItem(
                  'Blood Pressure',
                  '${diagnosis.vitalSigns.bloodPressureSystolic}/${diagnosis.vitalSigns.bloodPressureDiastolic} mmHg',
                ),
              if (diagnosis.vitalSigns.heartRate != null)
                _detailItem('Heart Rate', '${diagnosis.vitalSigns.heartRate} bpm'),
              if (diagnosis.vitalSigns.respiratoryRate != null)
                _detailItem('Respiratory Rate', '${diagnosis.vitalSigns.respiratoryRate} /min'),
              if (diagnosis.vitalSigns.oxygenSaturation != null)
                _detailItem('Oxygen Saturation', '${diagnosis.vitalSigns.oxygenSaturation}%'),
            ],
          ),
        ],
        
        // Precautions (from primary prediction)
        if (primaryPrediction?.precautions != null && 
            primaryPrediction!.precautions!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Precautions',
            primaryPrediction.precautions!.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_rounded,
                        size: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        
        // Medications/Prescriptions
        if (diagnosis.prescriptions != null && diagnosis.prescriptions!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Prescribed Medications (${diagnosis.prescriptions!.length})',
            diagnosis.prescriptions!.map((rx) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              rx.medication,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _medicationDetail(Icons.medical_services, 'Dosage', rx.dosage),
                      _medicationDetail(Icons.schedule, 'Frequency', rx.frequency),
                      _medicationDetail(Icons.calendar_today, 'Duration', rx.duration),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else if (primaryPrediction?.medications != null && 
                   primaryPrediction!.medications!.isNotEmpty) ...[
          // Show medications from AI prediction if no prescriptions
          const SizedBox(height: 16),
          _detailSection(
            'Recommended Medications',
            primaryPrediction.medications!.map((med) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.medication,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        med,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        
        // Recommended Diet
        if (primaryPrediction?.diet != null && 
            primaryPrediction!.diet!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Recommended Diet',
            primaryPrediction.diet!.map((dietItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 14,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dietItem,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        
        // Lifestyle & Exercise
        if (primaryPrediction?.workout != null && 
            primaryPrediction!.workout!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Lifestyle & Exercise',
            primaryPrediction.workout!.map((workoutItem) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        size: 14,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        workoutItem,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        
        // Recommendations
        if (primaryPrediction?.recommendations != null && 
            primaryPrediction!.recommendations!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Additional Recommendations',
            primaryPrediction.recommendations!.map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec, style: const TextStyle(fontSize: 13, height: 1.4))),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        
        // Clinical Notes
        if (diagnosis.notes != null && diagnosis.notes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _detailSection(
            'Clinical Notes',
            [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  diagnosis.notes!,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _medicationDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _detailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
  
  Widget _detailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
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
