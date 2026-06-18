import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';

class PatientMedicalHistoryPage extends ConsumerStatefulWidget {
  final String patientId;

  const PatientMedicalHistoryPage({super.key, required this.patientId});

  @override
  ConsumerState<PatientMedicalHistoryPage> createState() =>
      _PatientMedicalHistoryPageState();
}

class _PatientMedicalHistoryPageState
    extends ConsumerState<PatientMedicalHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late TabController _tabController;

  // Mock patient data
  final Map<String, dynamic> _patient = {
    'id': 'P001',
    'name': 'John Doe',
    'age': 45,
    'gender': 'Male',
    'bloodType': 'O+',
    'allergies': ['Penicillin', 'Shellfish'],
    'currentMedications': ['Metformin 500mg', 'Lisinopril 10mg'],
    'chronicConditions': ['Diabetes Type 2', 'Hypertension'],
  };

  // Mock medical history data
  final List<Map<String, dynamic>> _medicalHistory = [
    {
      'id': '1',
      'date': '2024-01-15',
      'type': 'Diagnosis',
      'title': 'Common Cold',
      'description': 'Viral infection of the upper respiratory tract',
      'provider': 'Dr. Smith',
      'status': 'Resolved',
      'medications': ['Acetaminophen', 'Nasal spray'],
      'notes': 'Patient responded well to treatment',
    },
    {
      'id': '2',
      'date': '2024-01-10',
      'type': 'Lab Test',
      'title': 'Blood Sugar Test',
      'description': 'Fasting blood glucose level check',
      'provider': 'Lab Technician',
      'status': 'Completed',
      'results': 'Fasting glucose: 120 mg/dL (Normal range: 70-100)',
      'notes': 'Slightly elevated, continue monitoring',
    },
    {
      'id': '3',
      'date': '2024-01-05',
      'type': 'Medication',
      'title': 'Medication Adjustment',
      'description': 'Increased Metformin dosage',
      'provider': 'Dr. Johnson',
      'status': 'Active',
      'medications': ['Metformin 1000mg'],
      'notes': 'Patient tolerating well, no side effects',
    },
    {
      'id': '4',
      'date': '2023-12-20',
      'type': 'Diagnosis',
      'title': 'Hypertension',
      'description': 'High blood pressure diagnosis',
      'provider': 'Dr. Smith',
      'status': 'Under Treatment',
      'medications': ['Lisinopril 10mg'],
      'notes': 'Blood pressure controlled with medication',
    },
    {
      'id': '5',
      'date': '2023-12-15',
      'type': 'Lab Test',
      'title': 'Complete Blood Count',
      'description': 'Routine blood work',
      'provider': 'Lab Technician',
      'status': 'Completed',
      'results': 'All values within normal range',
      'notes': 'No abnormalities detected',
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  void _startAnimations() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: '${_patient['name']} - ${l10n.medicalHistoryTitle}',
        subtitle: l10n.patientIdLabel(widget.patientId),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNewEntry,
            tooltip: l10n.addEntryTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportHistory,
            tooltip: l10n.exportTooltip,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: context.adaptiveColor(
            lightColor: Colors.white,
            darkColor: Colors.white,
          ),
          unselectedLabelColor: context.adaptiveColor(
            lightColor: Colors.white70,
            darkColor: Colors.white60,
          ),
          indicatorColor: context.adaptiveColor(
            lightColor: Colors.white,
            darkColor: Colors.white,
          ),
          tabs: [
            Tab(text: l10n.timelineTab, icon: const Icon(Icons.timeline)),
            Tab(text: l10n.medicationsTab, icon: const Icon(Icons.medication)),
            Tab(text: l10n.labResultsTab, icon: const Icon(Icons.science)),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTimelineTab(),
                  _buildMedicationsTab(),
                  _buildLabResultsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineTab() {
    final l10n = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Summary Card
          _buildPatientSummaryCard(),

          const SizedBox(height: 24),

          // Timeline Header
          Row(
            children: [
              Text(
                l10n.medicalTimeline,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                l10n.entriesCount(_medicalHistory.length),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Timeline
          _buildTimeline(),
        ],
      ),
    );
  }

  Widget _buildPatientSummaryCard() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: context.adaptiveColor(
                    lightColor: Colors.white,
                    darkColor: Colors.white.withOpacity(0.95),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _patient['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: context.adaptiveColor(
                          lightColor: Colors.white,
                          darkColor: Colors.white,
                        ),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${l10n.yearsOld(_patient['age'])} • ${_patient['gender']}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStat(
                  l10n.bloodTypeLabel,
                  _patient['bloodType'],
                  Icons.bloodtype,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  l10n.allergiesLabel,
                  '${_patient['allergies'].length}',
                  Icons.warning,
                ),
              ),
              Expanded(
                child: _buildQuickStat(
                  l10n.medicationsLabel,
                  '${_patient['currentMedications'].length}',
                  Icons.medication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildTimeline() {
    return Column(
      children:
          _medicalHistory.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTimelineEntry(entry),
            );
          }).toList(),
    );
  }

  Widget _buildTimelineEntry(Map<String, dynamic> entry) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(entry['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(entry['type']),
                  color: _getTypeColor(entry['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      entry['date'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(entry['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(entry['status'], l10n),
                  style: TextStyle(
                    color: _getStatusColor(entry['status']),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            entry['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          if (entry['provider'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.providerLabel(entry['provider']),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],

          if (entry['medications'] != null &&
              (entry['medications'] as List).isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              l10n.medicationsColon,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  (entry['medications'] as List<String>).map((med) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        med,
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],

          if (entry['results'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resultsColon,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry['results'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          if (entry['notes'] != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.notesColon,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              entry['notes'],
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    final l10n = AppLocalizations.of(context)!;
    final currentMeds = _patient['currentMedications'] as List<String>;
    final historicalMeds =
        _medicalHistory
            .where((entry) => entry['medications'] != null)
            .expand((entry) => entry['medications'] as List<String>)
            .toSet()
            .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Medications
          Text(
            l10n.currentMedications,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          if (currentMeds.isEmpty)
            _buildEmptyState(l10n.noCurrentMedications)
          else
            ...currentMeds.map((med) => _buildMedicationCard(med, true)),

          const SizedBox(height: 24),

          // Medication History
          Text(
            l10n.medicationHistory,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          if (historicalMeds.isEmpty)
            _buildEmptyState(l10n.noMedicationHistory)
          else
            ...historicalMeds.map((med) => _buildMedicationCard(med, false)),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(String medication, bool isCurrent) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border:
            isCurrent
                ? Border.all(color: AppTheme.successColor, width: 2)
                : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  isCurrent
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication,
              color: isCurrent ? AppTheme.successColor : AppTheme.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  isCurrent ? l10n.currentlyTaking : l10n.previouslyPrescribed,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.activeStatus,
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabResultsTab() {
    final l10n = AppLocalizations.of(context)!;
    final labResults =
        _medicalHistory.where((entry) => entry['type'] == 'Lab Test').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.labResults,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          if (labResults.isEmpty)
            _buildEmptyState(l10n.noLabResultsAvailable)
          else
            ...labResults.map((result) => _buildLabResultCard(result)),
        ],
      ),
    );
  }

  Widget _buildLabResultCard(Map<String, dynamic> result) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.science,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result['title'],
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      result['date'],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusLabel(result['status'], l10n),
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            result['description'],
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          if (result['results'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.resultsColon,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result['results'],
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],

          if (result['notes'] != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n.notesColon,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              result['notes'],
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'diagnosis':
        return AppTheme.primaryColor;
      case 'lab test':
        return AppTheme.accentColor;
      case 'medication':
        return AppTheme.secondaryColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'diagnosis':
        return Icons.medical_services;
      case 'lab test':
        return Icons.science;
      case 'medication':
        return Icons.medication;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'resolved':
        return AppTheme.successColor;
      case 'active':
      case 'under treatment':
        return AppTheme.warningColor;
      case 'hospitalized':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _addNewEntry() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.addNewEntry),
            content: Text(
              l10n.addNewEntryFormWillBeImplemented,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.newEntryAddedSuccessfully),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: Text(l10n.add),
              ),
            ],
          ),
    );
  }

  void _exportHistory() {
    final l10n = AppLocalizations.of(context)!;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.exportingMedicalHistory),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
  
  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toLowerCase()) {
      case 'completed':
        return l10n.completedStatus;
      case 'resolved':
        return l10n.resolvedStatus;
      case 'active':
        return l10n.activeStatus;
      case 'under treatment':
        return l10n.underTreatmentStatus;
      case 'hospitalized':
        return l10n.hospitalizedStatus;
      default:
        return status;
    }
  }
}
