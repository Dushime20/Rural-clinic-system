import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/patient_service.dart';
import '../../../../core/constants/symptoms_constants.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/models/diagnosis_models.dart';
import '../../data/providers/diagnosis_provider.dart';
import '../widgets/categorized_symptom_selector.dart';

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

  // Real patient data from API
  final _patientService = PatientService();
  List<dynamic> _patients = [];
  bool _patientsLoading = true;
  String? _patientsError;

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

  // Voice Recording - REMOVED (not needed)
  // bool _isRecording = false;
  // String _recordedText = '';

  // Use all symptoms from constants (132 total)
  final List<String> _commonSymptoms = SymptomsConstants.allSymptoms;

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
    _tabController = TabController(length: 5, vsync: this); // Changed from 6 to 5 (removed voice tab)
    _loadPatients();

    // Rebuild when vital sign values change so the Review tab stays in sync
    _temperatureController.addListener(_onVitalsChanged);
    _bloodPressureController.addListener(_onVitalsChanged);
    _heartRateController.addListener(_onVitalsChanged);
    _respiratoryRateController.addListener(_onVitalsChanged);
    _oxygenSaturationController.addListener(_onVitalsChanged);
    _additionalNotesController.addListener(_onVitalsChanged);
  }

  void _onVitalsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPatients({bool reset = false}) async {
    if (reset) {
      setState(() {
        _patients = [];
      });
    }
    setState(() {
      _patientsLoading = true;
      _patientsError = null;
    });

    final result = await _patientService.getPatients(
      search: _searchQuery.isEmpty ? null : _searchQuery,
      limit: 100, // load enough for the list
    );

    if (!mounted) return;
    setState(() {
      _patientsLoading = false;
      if (result['success'] == true) {
        _patients = result['data']['patients'] as List? ?? [];
      } else {
        _patientsError = result['message'] as String?;
      }
    });
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

  List<dynamic> get _filteredPatients {
    if (_searchQuery.isEmpty) return _patients;
    final q = _searchQuery.toLowerCase();
    return _patients.where((p) {
      final name =
          '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.toLowerCase();
      return name.contains(q);
    }).toList();
  }

  void _selectPatient(dynamic patient) {
    setState(() {
      _selectedPatient = Map<String, dynamic>.from(patient as Map);
      _tabController.animateTo(1); // Move to patient info tab
    });
  }

  /// Helpers to read real API patient fields safely
  String _patientFullName(dynamic p) =>
      '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim();

  int _patientAge(dynamic p) {
    final dob = p['dateOfBirth'];
    if (dob == null) return 0;
    try {
      return DateTime.now().difference(DateTime.parse(dob.toString())).inDays ~/
          365;
    } catch (_) {
      return 0;
    }
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

  // Voice recording method removed - not needed

  Future<void> _runDiagnosis() async {
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

    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide symptoms'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: Card(
              margin: EdgeInsets.all(24),
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Running AI Diagnosis...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'This may take a few moments',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );

    try {
      // Prepare diagnosis request
      final symptoms =
          _selectedSymptoms
              .map((s) => Symptom(name: s, category: 'general'))
              .toList();

      // Parse vital signs
      VitalSigns vitalSigns = VitalSigns(
        temperature:
            _temperatureController.text.isNotEmpty
                ? double.tryParse(_temperatureController.text)
                : null,
        heartRate:
            _heartRateController.text.isNotEmpty
                ? int.tryParse(_heartRateController.text)
                : null,
        respiratoryRate:
            _respiratoryRateController.text.isNotEmpty
                ? int.tryParse(_respiratoryRateController.text)
                : null,
        oxygenSaturation:
            _oxygenSaturationController.text.isNotEmpty
                ? int.tryParse(_oxygenSaturationController.text)
                : null,
      );

      // Parse blood pressure if provided
      if (_bloodPressureController.text.isNotEmpty) {
        final bpParts = _bloodPressureController.text.split('/');
        if (bpParts.length == 2) {
          final systolic = int.tryParse(bpParts[0].trim());
          final diastolic = int.tryParse(bpParts[1].trim());
          vitalSigns = VitalSigns(
            temperature: vitalSigns.temperature,
            bloodPressureSystolic: systolic,
            bloodPressureDiastolic: diastolic,
            heartRate: vitalSigns.heartRate,
            respiratoryRate: vitalSigns.respiratoryRate,
            oxygenSaturation: vitalSigns.oxygenSaturation,
          );
        }
      }

      final request = DiagnosisRequest(
        patientId: _selectedPatient!['id'],
        symptoms: symptoms,
        vitalSigns: vitalSigns,
        age: _patientAge(_selectedPatient),
        gender:
            (_selectedPatient!['gender'] ?? 'unknown').toString().toLowerCase(),
        medicalHistory:
            _selectedMedicalHistory.isNotEmpty ? _selectedMedicalHistory : null,
        notes:
            _additionalNotesController.text.isNotEmpty
                ? _additionalNotesController.text
                : null,
      );

      // Call diagnosis service
      final diagnosisService = ref.read(diagnosisServiceProvider);
      final result = await diagnosisService.createDiagnosis(request);

      // Get user location automatically (no dialogs)
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      // Find nearby pharmacies with prescribed medicines
      List<NearbyPharmacy> nearbyPharmacies = [];
      if (position != null &&
          result.prescriptions != null &&
          result.prescriptions!.isNotEmpty) {
        try {
          debugPrint('Finding nearby pharmacies...');
          // Get unique medicine names
          final medicineNames =
              result.prescriptions!.map((p) => p.medication).toSet().toList();

          // Search for each medicine
          for (final medicineName in medicineNames) {
            final pharmacies = await diagnosisService.findNearbyPharmacies(
              latitude: position.latitude,
              longitude: position.longitude,
              medicineName: medicineName,
              radius: 50, // 50 km radius
            );
            nearbyPharmacies.addAll(pharmacies);
          }

          // Remove duplicates by pharmacy ID
          final uniquePharmacies = <String, NearbyPharmacy>{};
          for (final pharmacy in nearbyPharmacies) {
            uniquePharmacies[pharmacy.id] = pharmacy;
          }
          nearbyPharmacies = uniquePharmacies.values.toList();

          // Sort by distance
          nearbyPharmacies.sort((a, b) {
            final distA = a.distance ?? double.infinity;
            final distB = b.distance ?? double.infinity;
            return distA.compareTo(distB);
          });

          debugPrint('Found ${nearbyPharmacies.length} nearby pharmacies');
        } catch (e) {
          debugPrint('Pharmacy search error: $e');
          // Continue without pharmacies
        }
      } else {
        if (position == null) {
          debugPrint('Location not available, skipping pharmacy search');
        }
      }

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to result page
      if (mounted) {
        context.go(
          '/diagnosis/result',
          extra: {
            'diagnosis': result,
            'patient': _selectedPatient,
            'nearbyPharmacies': nearbyPharmacies,
          },
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Diagnosis failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _runDiagnosis,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'AI Diagnosis Assistant',
        subtitle:
            _selectedPatient != null
                ? 'Patient: ${_patientFullName(_selectedPatient)}'
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
            _buildReviewTab(),
          ],
        ),
      ),
      bottomNavigationBar: null,
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
              suffixIcon:
                  _searchQuery.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadPatients(reset: true);
                        },
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              // Debounce: re-fetch from API after typing stops
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_searchQuery == value) _loadPatients(reset: true);
              });
            },
          ),
        ),
        Expanded(child: _buildPatientList()),
      ],
    );
  }

  Widget _buildPatientList() {
    if (_patientsLoading && _patients.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_patientsError != null && _patients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _patientsError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadPatients(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final filtered = _filteredPatients;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No patients found'
                  : 'No matching patients',
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

    return RefreshIndicator(
      onRefresh: () => _loadPatients(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final patient = filtered[index];
          final isSelected = _selectedPatient?['id'] == patient['id'];
          final name = _patientFullName(patient);
          final age = _patientAge(patient);
          final gender = patient['gender'] ?? '—';
          final bloodType = patient['bloodType'] ?? '—';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              subtitle: Text('$age yrs • $gender • $bloodType'),
              trailing:
                  isSelected
                      ? const Icon(
                        Icons.check_circle,
                        color: AppTheme.primaryColor,
                      )
                      : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectPatient(patient),
            ),
          );
        },
      ),
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

    final p = _selectedPatient!;
    final name = _patientFullName(p);
    final age = _patientAge(p);
    final gender = p['gender'] ?? '—';
    final bloodType = p['bloodType'] ?? '—';
    final phone = p['phoneNumber'] ?? p['phone'] ?? '—';
    final lastVisit =
        p['lastVisit'] != null ? p['lastVisit'].toString().split('T')[0] : '—';
    final patientId = p['patientId'] ?? '—';

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
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
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
                      _buildInfoChip('$age yrs', Icons.cake),
                      _buildInfoChip(gender, Icons.person),
                      _buildInfoChip(bloodType, Icons.bloodtype),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(Icons.phone, 'Phone', phone),
                  const Divider(),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Last Visit',
                    lastVisit,
                  ),
                  const Divider(),
                  _buildDetailRow(Icons.badge, 'Patient ID', patientId),
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
                    'Patient information is read-only. Proceed to next tab to record symptoms.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(2), // Go to Symptoms tab
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next: Record Symptoms'),
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
          
          // Use the new categorized symptom selector
          CategorizedSymptomSelector(
            selectedSymptoms: _selectedSymptoms,
            onSymptomToggle: _toggleSymptom,
          ),
          
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
          const SizedBox(height: 24),
          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(3), // Go to Vital Signs tab
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next: Record Vital Signs'),
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
          const SizedBox(height: 24),
          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(4), // Go to Review tab
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next: Review & Submit'),
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
    );
  }

  // Voice Input tab removed - not needed for MVP

  // Tab 5: Review
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
            'Name: ${_patientFullName(_selectedPatient)}',
            'Age: ${_patientAge(_selectedPatient)} years',
            'Gender: ${_selectedPatient!['gender'] ?? '—'}',
            'Blood Type: ${_selectedPatient!['bloodType'] ?? '—'}',
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
                    'Review the information above, then tap the button to run the AI diagnosis.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
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
          const SizedBox(height: 8),
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
