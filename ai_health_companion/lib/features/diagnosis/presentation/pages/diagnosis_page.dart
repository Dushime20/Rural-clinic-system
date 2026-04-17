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

class _DiagnosisPageState extends ConsumerState<DiagnosisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Patient Selection
  Map<String, dynamic>? _selectedPatient;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock patient data
  final List<Map<String, dynamic>> _patients = [
    {
      'id': '1',
      'name': 'John Doe',
      'age': 45,
      'gender': 'Male',
      'bloodType': 'O+',
      'phone': '+250 788 123 456',
      'lastVisit': '2024-01-15',
      'status': 'Follow-up',
      'diagnosis': 'Hypertension',
    },
    {
      'id': '2',
      'name': 'Mary Johnson',
      'age': 32,
      'gender': 'Female',
      'bloodType': 'A+',
      'phone': '+250 788 234 567',
      'lastVisit': '2024-01-14',
      'status': 'Recent',
      'diagnosis': 'Diabetes Type 2',
    },
    {
      'id': '3',
      'name': 'Robert Smith',
      'age': 28,
      'gender': 'Male',
      'bloodType': 'B+',
      'phone': '+250 788 345 678',
      'lastVisit': '2024-01-13',
      'status': 'Recent',
      'diagnosis': 'Common Cold',
    },
  ];

  // Symptoms
  final List<String> _selectedSymptoms = [];
  final List<String> _selectedMedicalHistory = [];
  final _additionalNotesController = TextEditingController();

  // Vital Signs
  final _temperatureController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _oxygenSaturationController = TextEditingController();

  // Voice Recording
  bool _isRecording = false;
  String _recordedText = '';

  final List<String> _commonSymptoms = [
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
    'Abdominal pain',
    'Chest pain',
    'Loss of appetite',
  ];

  final List<String> _medicalHistoryOptions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'Kidney Disease',
    'HIV/AIDS',
    'Tuberculosis',
    'Malaria (Previous)',
    'Allergies',
    'Pregnancy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _additionalNotesController.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _respiratoryRateController.dispose();
    _oxygenSaturationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    return _patients
        .where(
          (p) => p['name'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  void _selectPatient(Map<String, dynamic> patient) {
    setState(() {
      _selectedPatient = patient;
      _tabController.animateTo(1); // Move to patient info tab
    });
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_selectedSymptoms.contains(symptom)) {
        _selectedSymptoms.remove(symptom);
      } else {
        _selectedSymptoms.add(symptom);
      }
    });
  }

  void _toggleMedicalHistory(String condition) {
    setState(() {
      if (_selectedMedicalHistory.contains(condition)) {
        _selectedMedicalHistory.remove(condition);
      } else {
        _selectedMedicalHistory.add(condition);
      }
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (!_isRecording) {
        _recordedText =
            'Patient complains of fever, headache, and body aches for 3 days.';
      }
    });
  }

  void _runDiagnosis() {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a patient first'),
          backgroundColor: Colors.orange,
        ),
      );
      _tabController.animateTo(0);
      return;
    }

    if (_selectedSymptoms.isEmpty && _recordedText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide symptoms or voice input'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final diagnosisData = {
      'patientId': _selectedPatient!['id'],
      'patientName': _selectedPatient!['name'],
      'patientAge': _selectedPatient!['age'],
      'gender': _selectedPatient!['gender'],
      'symptoms': _selectedSymptoms,
      'vitalSigns': {
        'temperature': _temperatureController.text,
        'bloodPressure': _bloodPressureController.text,
        'heartRate': _heartRateController.text,
        'respiratoryRate': _respiratoryRateController.text,
        'oxygenSaturation': _oxygenSaturationController.text,
      },
      'medicalHistory': _selectedMedicalHistory,
      'notes': _additionalNotesController.text,
      'voiceNotes': _recordedText,
      'prediction': 'Malaria',
      'confidence': 0.85,
    };

    context.go('/diagnosis/result', extra: diagnosisData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'AI Diagnosis Assistant',
        subtitle:
            _selectedPatient != null
                ? 'Patient: ${_selectedPatient!['name']}'
                : 'Select a patient to begin',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push('/diagnosis/history'),
            tooltip: 'History',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Select Patient'),
            Tab(icon: Icon(Icons.person), text: 'Patient Info'),
            Tab(icon: Icon(Icons.sick), text: 'Symptoms'),
            Tab(icon: Icon(Icons.favorite), text: 'Vital Signs'),
            Tab(icon: Icon(Icons.mic), text: 'Voice Input'),
            Tab(icon: Icon(Icons.preview), text: 'Review'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPatientSelectionTab(),
            _buildPatientInfoTab(),
            _buildSymptomsTab(),
            _buildVitalSignsTab(),
            _buildVoiceInputTab(),
            _buildReviewTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton.icon(
            onPressed: _runDiagnosis,
            icon: const Icon(Icons.psychology),
            label: const Text('Run AI Diagnosis'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tab 1: Patient Selection
  Widget _buildPatientSelectionTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search patients...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child:
              _filteredPatients.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No patients found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = _filteredPatients[index];
                      final isSelected =
                          _selectedPatient?['id'] == patient['id'];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: isSelected ? 4 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                            child: Text(
                              patient['name'].toString().substring(0, 1),
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            patient['name'],
                            style: TextStyle(
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${patient['age']} years • ${patient['gender']} • ${patient['bloodType']}',
                          ),
                          trailing:
                              isSelected
                                  ? const Icon(
                                    Icons.check_circle,
                                    color: AppTheme.primaryColor,
                                  )
                                  : const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                  ),
                          onTap: () => _selectPatient(patient),
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // Tab 2: Patient Info (Read-only)
  Widget _buildPatientInfoTab() {
    if (_selectedPatient == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No patient selected',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select a patient from the first tab',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Select Patient'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      _selectedPatient!['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedPatient!['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildInfoChip(
                        '${_selectedPatient!['age']} years',
                        Icons.cake,
                      ),
                      _buildInfoChip(_selectedPatient!['gender'], Icons.person),
                      _buildInfoChip(
                        _selectedPatient!['bloodType'],
                        Icons.bloodtype,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    Icons.phone,
                    'Phone',
                    _selectedPatient!['phone'],
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Last Visit',
                    _selectedPatient!['lastVisit'],
                  ),
                  const Divider(),
                  _buildDetailRow(
                    Icons.medical_services,
                    'Last Diagnosis',
                    _selectedPatient!['diagnosis'],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Patient information is read-only. Proceed to next tabs to record symptoms and vital signs.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 3: Symptoms
  Widget _buildSymptomsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Symptoms Assessment',
            'Select all symptoms the patient is experiencing',
            Icons.sick,
          ),
          const SizedBox(height: 20),
          _buildSymptomCounter(),
          const SizedBox(height: 20),
          _buildSymptomGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('Medical History'),
          const SizedBox(height: 12),
          _buildMedicalHistoryGrid(),
          const SizedBox(height: 24),
          _buildSectionTitle('Additional Notes'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _additionalNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Any additional observations or patient complaints...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 4: Vital Signs
  Widget _buildVitalSignsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Vital Signs',
            'Record patient\'s vital measurements',
            Icons.favorite,
          ),
          const SizedBox(height: 20),
          _buildVitalSignCard(
            'Temperature',
            _temperatureController,
            '°C',
            Icons.thermostat,
            'Normal: 36.5-37.5°C',
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildVitalSignCard(
            'Blood Pressure',
            _bloodPressureController,
            'mmHg',
            Icons.favorite,
            'Normal: 120/80 mmHg',
            Colors.pink,
          ),
          const SizedBox(height: 16),
          _buildVitalSignCard(
            'Heart Rate',
            _heartRateController,
            'bpm',
            Icons.monitor_heart,
            'Normal: 60-100 bpm',
            Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildVitalSignCard(
            'Respiratory Rate',
            _respiratoryRateController,
            'breaths/min',
            Icons.air,
            'Normal: 12-20 breaths/min',
            Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildVitalSignCard(
            'Oxygen Saturation',
            _oxygenSaturationController,
            '%',
            Icons.water_drop,
            'Normal: 95-100%',
            Colors.cyan,
          ),
        ],
      ),
    );
  }

  // Tab 5: Voice Input
  Widget _buildVoiceInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Voice Input',
            'Alternative: Record patient consultation in your language',
            Icons.mic,
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleRecording,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.red : AppTheme.primaryColor,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording
                                  ? Colors.red
                                  : AppTheme.primaryColor)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isRecording ? 'Recording...' : 'Tap to start recording',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _isRecording ? Colors.red : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isRecording
                      ? 'Speak clearly about patient symptoms'
                      : 'Voice will be transcribed automatically',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_recordedText.isNotEmpty) ...[
            _buildSectionTitle('Transcription'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Voice recorded successfully',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _recordedText,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.language, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Input Benefits',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voice input allows you to quickly document patient consultations in your local language. The AI will analyze the transcription.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab 6: Review
  Widget _buildReviewTab() {
    if (_selectedPatient == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, size: 80, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'No patient selected',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'Review & Submit',
            'Review all information before running diagnosis',
            Icons.preview,
          ),
          const SizedBox(height: 20),
          _buildReviewSection('Patient Information', Icons.person, [
            'Name: ${_selectedPatient!['name']}',
            'Age: ${_selectedPatient!['age']} years',
            'Gender: ${_selectedPatient!['gender']}',
            'Blood Type: ${_selectedPatient!['bloodType']}',
          ]),
          const SizedBox(height: 16),
          _buildReviewSection(
            'Symptoms (${_selectedSymptoms.length})',
            Icons.sick,
            _selectedSymptoms.isEmpty
                ? ['No symptoms selected']
                : _selectedSymptoms,
          ),
          const SizedBox(height: 16),
          _buildReviewSection(
            'Medical History (${_selectedMedicalHistory.length})',
            Icons.history,
            _selectedMedicalHistory.isEmpty
                ? ['No medical history selected']
                : _selectedMedicalHistory,
          ),
          const SizedBox(height: 16),
          _buildReviewSection('Vital Signs', Icons.favorite, [
            'Temperature: ${_temperatureController.text.isEmpty ? 'Not recorded' : '${_temperatureController.text}°C'}',
            'Blood Pressure: ${_bloodPressureController.text.isEmpty ? 'Not recorded' : '${_bloodPressureController.text} mmHg'}',
            'Heart Rate: ${_heartRateController.text.isEmpty ? 'Not recorded' : '${_heartRateController.text} bpm'}',
            'Respiratory Rate: ${_respiratoryRateController.text.isEmpty ? 'Not recorded' : '${_respiratoryRateController.text} breaths/min'}',
            'Oxygen Saturation: ${_oxygenSaturationController.text.isEmpty ? 'Not recorded' : '${_oxygenSaturationController.text}%'}',
          ]),
          if (_recordedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReviewSection('Voice Notes', Icons.mic, [_recordedText]),
          ],
          if (_additionalNotesController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildReviewSection('Additional Notes', Icons.note, [
              _additionalNotesController.text,
            ]),
          ],
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Click "Run AI Diagnosis" button below to get AI-powered diagnosis prediction.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.1),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildSymptomCounter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Selected Symptoms',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_selectedSymptoms.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _commonSymptoms.length,
      itemBuilder: (context, index) {
        final symptom = _commonSymptoms[index];
        final isSelected = _selectedSymptoms.contains(symptom);
        return InkWell(
          onTap: () => _toggleSymptom(symptom),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    symptom,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMedicalHistoryGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          _medicalHistoryOptions.map((condition) {
            final isSelected = _selectedMedicalHistory.contains(condition);
            return FilterChip(
              label: Text(condition),
              selected: isSelected,
              onSelected: (_) => _toggleMedicalHistory(condition),
              selectedColor: AppTheme.secondaryColor.withValues(alpha: 0.3),
              checkmarkColor: AppTheme.secondaryColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.secondaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
    );
  }

  Widget _buildVitalSignCard(
    String label,
    TextEditingController controller,
    String unit,
    IconData icon,
    String normalRange,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      normalRange,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: unit,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(String title, IconData icon, List<String> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
