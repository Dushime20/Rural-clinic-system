import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../shared/widgets/app_header.dart';

class DiagnosisHistoryPage extends ConsumerStatefulWidget {
  const DiagnosisHistoryPage({super.key});

  @override
  ConsumerState<DiagnosisHistoryPage> createState() =>
      _DiagnosisHistoryPageState();
}

class _DiagnosisHistoryPageState extends ConsumerState<DiagnosisHistoryPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  String _searchQuery = '';
  String _selectedFilter = 'All';
  final String _selectedTimeRange = 'All';

  final List<String> _filters = ['All', 'Recent', 'Critical', 'Follow-up'];
  final List<String> _timeRanges = ['All', 'Today', 'Week', 'Month', 'Year'];

  // Mock diagnosis history data
  final List<Map<String, dynamic>> _diagnosisHistory = [
    {
      'id': '1',
      'patientName': 'John Doe',
      'patientId': 'P001',
      'date': '2024-01-15',
      'time': '14:30',
      'primaryDiagnosis': 'Common Cold',
      'confidence': 85.2,
      'severity': 'Mild',
      'symptoms': ['Runny nose', 'Cough', 'Sore throat'],
      'status': 'Completed',
      'isCritical': false,
      'followUpRequired': false,
    },
    {
      'id': '2',
      'patientName': 'Mary Johnson',
      'patientId': 'P002',
      'date': '2024-01-14',
      'time': '10:15',
      'primaryDiagnosis': 'Hypertension',
      'confidence': 92.8,
      'severity': 'Moderate',
      'symptoms': ['Headache', 'Dizziness', 'High blood pressure'],
      'status': 'Follow-up Required',
      'isCritical': true,
      'followUpRequired': true,
    },
    {
      'id': '3',
      'patientName': 'Robert Smith',
      'patientId': 'P003',
      'date': '2024-01-13',
      'time': '16:45',
      'primaryDiagnosis': 'Allergic Rhinitis',
      'confidence': 78.5,
      'severity': 'Mild',
      'symptoms': ['Sneezing', 'Itchy eyes', 'Runny nose'],
      'status': 'Completed',
      'isCritical': false,
      'followUpRequired': false,
    },
    {
      'id': '4',
      'patientName': 'Sarah Wilson',
      'patientId': 'P004',
      'date': '2024-01-12',
      'time': '09:20',
      'primaryDiagnosis': 'Diabetes Type 2',
      'confidence': 89.3,
      'severity': 'Moderate',
      'symptoms': ['Increased thirst', 'Frequent urination', 'Fatigue'],
      'status': 'Under Treatment',
      'isCritical': true,
      'followUpRequired': true,
    },
    {
      'id': '5',
      'patientName': 'Michael Brown',
      'patientId': 'P005',
      'date': '2024-01-11',
      'time': '13:10',
      'primaryDiagnosis': 'Pneumonia',
      'confidence': 94.7,
      'severity': 'Severe',
      'symptoms': ['Cough', 'Fever', 'Difficulty breathing', 'Chest pain'],
      'status': 'Hospitalized',
      'isCritical': true,
      'followUpRequired': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filteredDiagnoses = _getFilteredDiagnoses();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: l10n.diagnosisHistory,
        subtitle: l10n.recordsFound(_diagnosisHistory.length),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: l10n.filterTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportHistory,
            tooltip: l10n.exportTooltip,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: SearchBarWidget(
                      hintText: l10n.searchDiagnoses,
                      onChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  ),

                  // Filter Chips
                  _buildFilterChips(),

                  const SizedBox(height: 8),

                  // Statistics
                  _buildStatistics(),

                  const SizedBox(height: 16),

                  // Diagnosis List
                  Expanded(
                    child:
                        filteredDiagnoses.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: filteredDiagnoses.length,
                              itemBuilder: (context, index) {
                                final diagnosis = filteredDiagnoses[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDiagnosisCard(diagnosis),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;
    final filterLabels = {
      'All': l10n.filterAll,
      'Recent': l10n.filterRecent,
      'Critical': l10n.filterCritical,
      'Follow-up': l10n.filterFollowUp,
    };
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filterLabels[filter] ?? filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.2),
              checkmarkColor: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    final l10n = AppLocalizations.of(context)!;
    final totalDiagnoses = _diagnosisHistory.length;
    final criticalDiagnoses =
        _diagnosisHistory.where((d) => d['isCritical']).length;
    final followUpRequired =
        _diagnosisHistory.where((d) => d['followUpRequired']).length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              l10n.total,
              totalDiagnoses.toString(),
              AppTheme.primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: AppTheme.textDisabled.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              l10n.critical,
              criticalDiagnoses.toString(),
              AppTheme.errorColor,
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: AppTheme.textDisabled.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              l10n.followUp,
              followUpRequired.toString(),
              AppTheme.warningColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildDiagnosisCard(Map<String, dynamic> diagnosis) {
    final l10n = AppLocalizations.of(context)!;
    
    // Get localized status
    String getLocalizedStatus(String status) {
      switch (status) {
        case 'Completed':
          return l10n.statusCompleted;
        case 'Follow-up Required':
          return l10n.statusFollowUpRequired;
        case 'Under Treatment':
          return l10n.statusUnderTreatment;
        case 'Hospitalized':
          return l10n.statusHospitalized;
        default:
          return status;
      }
    }
    
    // Get localized severity
    String getLocalizedSeverity(String severity) {
      switch (severity) {
        case 'Mild':
          return l10n.severityMild;
        case 'Moderate':
          return l10n.severityModerate;
        case 'Severe':
          return l10n.severitySevere;
        default:
          return severity;
      }
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:
            diagnosis['isCritical']
                ? const BorderSide(color: AppTheme.errorColor, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _viewDiagnosisDetails(diagnosis),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis['patientName'],
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${l10n.idPrefix} ${diagnosis['patientId']}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          diagnosis['isCritical']
                              ? AppTheme.errorColor.withOpacity(0.1)
                              : AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getLocalizedStatus(diagnosis['status']),
                      style: TextStyle(
                        color:
                            diagnosis['isCritical']
                                ? AppTheme.errorColor
                                : AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Diagnosis Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis['primaryDiagnosis'],
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '${l10n.confidenceLabel} ${l10n.confidencePercentage(diagnosis['confidence'].toStringAsFixed(1))}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(
                        diagnosis['severity'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      getLocalizedSeverity(diagnosis['severity']),
                      style: TextStyle(
                        color: _getSeverityColor(diagnosis['severity']),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Symptoms
              Text(
                '${l10n.symptomsLabel} ${(diagnosis['symptoms'] as List<String>).join(', ')}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${diagnosis['date']} at ${diagnosis['time']}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (diagnosis['followUpRequired'])
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                            color: AppTheme.warningColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.filterFollowUp,
                            style: TextStyle(
                              color: AppTheme.warningColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
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

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            l10n.noDiagnosesFound,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tryAdjustingSearch,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredDiagnoses() {
    var filtered =
        _diagnosisHistory.where((diagnosis) {
          final matchesSearch =
              diagnosis['patientName'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              diagnosis['primaryDiagnosis'].toString().toLowerCase().contains(
                _searchQuery.toLowerCase(),
              );

          final matchesFilter =
              _selectedFilter == 'All' ||
              (_selectedFilter == 'Recent' && _isRecent(diagnosis['date'])) ||
              (_selectedFilter == 'Critical' && diagnosis['isCritical']) ||
              (_selectedFilter == 'Follow-up' && diagnosis['followUpRequired']);

          return matchesSearch && matchesFilter;
        }).toList();

    // Sort by date (most recent first)
    filtered.sort((a, b) => b['date'].compareTo(a['date']));

    return filtered;
  }

  bool _isRecent(String date) {
    final diagnosisDate = DateTime.parse(date);
    final now = DateTime.now();
    final difference = now.difference(diagnosisDate).inDays;
    return difference <= 7; // Within last week
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return AppTheme.successColor;
      case 'moderate':
        return AppTheme.warningColor;
      case 'severe':
        return AppTheme.errorColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _viewDiagnosisDetails(Map<String, dynamic> diagnosis) async {
    // Navigate to DiagnosisResultPage with historical diagnosis data
    // This will trigger re-evaluation of pattern detection and real-time clinic search
    // using the patient's current location (not the historical location)
    
    // Show loading indicator while fetching updated data
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // TODO: In production, use DiagnosisService to re-evaluate with current location
      // final diagnosisService = ref.read(diagnosisServiceProvider);
      // final updatedDiagnosis = await diagnosisService.reevaluateHistoricalDiagnosis(
      //   diagnosis['id'],
      //   latitude: currentLatitude,
      //   longitude: currentLongitude,
      // );
      
      // For now, using mock data structure
      if (mounted) Navigator.of(context).pop(); // Close loading dialog
      
      if (mounted) {
        context.push(
          '/diagnosis/result',
          extra: {
            'diagnosis': _buildDiagnosisResponseFromHistory(diagnosis),
            'patient': _buildPatientDataFromHistory(diagnosis),
            'nearbyPharmacies': [], // Will be fetched with current location by backend
            'isHistorical': true, // Flag to indicate this is historical data
          },
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); // Close loading dialog
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToLoadDetails(e.toString())),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Build DiagnosisResponse model from historical diagnosis data
  /// This creates a structure compatible with DiagnosisResultPage
  Map<String, dynamic> _buildDiagnosisResponseFromHistory(
    Map<String, dynamic> diagnosis,
  ) {
    return {
      'id': diagnosis['id'],
      'diagnosisId': diagnosis['id'],
      'patientId': diagnosis['patientId'],
      'aiPredictions': [
        {
          'disease': diagnosis['primaryDiagnosis'],
          'confidence': diagnosis['confidence'] / 100.0,
          'icd10Code': null,
          'recommendations': [
            'Follow up with healthcare provider',
            'Monitor symptoms',
          ],
          'description':
              'This is a historical diagnosis. Current recommendations based on your present location.',
          'precautions': [],
          'medications': [],
          'diet': [],
          'workout': [],
        },
      ],
      'selectedDiagnosis': {
        'disease': diagnosis['primaryDiagnosis'],
        'confidence': diagnosis['confidence'] / 100.0,
        'icd10Code': null,
      },
      'prescriptions': [], // Historical prescriptions not available in mock data
      'symptoms':
          (diagnosis['symptoms'] as List<String>)
              .map(
                (s) => {
                  'name': s,
                  'severity': diagnosis['severity'],
                  'duration': null,
                  'category': null,
                },
              )
              .toList(),
      'vitalSigns': {
        'temperature': null,
        'bloodPressureSystolic': null,
        'bloodPressureDiastolic': null,
        'heartRate': null,
        'respiratoryRate': null,
        'oxygenSaturation': null,
        'weight': null,
        'height': null,
      },
      'diagnosisDate':
          '${diagnosis['date']}T${diagnosis['time']}:00.000Z',
      'notes':
          'Historical diagnosis - Clinic recommendations are based on your current location',
      'followUpRequired': diagnosis['followUpRequired'],
      'followUpDate': null,
      // Recommendations will be fetched with current location
      // The backend should re-evaluate pattern detection when viewing historical diagnoses
      'recommendations': null, // Backend will populate this
      'patternAnalysis': null, // Backend will populate this
    };
  }

  /// Build patient data from historical diagnosis
  Map<String, dynamic> _buildPatientDataFromHistory(
    Map<String, dynamic> diagnosis,
  ) {
    // Extract first name and last name from patientName
    final nameParts = (diagnosis['patientName'] as String).split(' ');
    return {
      'id': diagnosis['patientId'],
      'firstName': nameParts.first,
      'lastName': nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      'dateOfBirth':
          '2000-01-01', // Not available in mock data, using placeholder
      'gender': 'Unknown', // Not available in mock data
      'phoneNumber': 'N/A', // Not available in mock data
    };
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final l10n = AppLocalizations.of(context)!;
    final filterLabels = {
      'All': l10n.filterAll,
      'Recent': l10n.filterRecent,
      'Critical': l10n.filterCritical,
      'Follow-up': l10n.filterFollowUp,
    };
    
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.filterTooltip + ' ' + l10n.diagnosisHistory),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.filter}:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._filters.map((filter) {
                  return RadioListTile<String>(
                    title: Text(filterLabels[filter] ?? filter),
                    value: filter,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
    );
  }

  void _exportHistory() {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.exportingHistory),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
