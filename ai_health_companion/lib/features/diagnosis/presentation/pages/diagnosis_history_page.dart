import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
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
    final filteredDiagnoses = _getFilteredDiagnoses();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: 'Diagnosis History',
        subtitle: '${_diagnosisHistory.length} records found',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportHistory,
            tooltip: 'Export',
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
                      hintText: 'Search diagnoses...',
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
              label: Text(filter),
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
              'Total',
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
              'Critical',
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
              'Follow-up',
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
                          'ID: ${diagnosis['patientId']}',
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
                      diagnosis['status'],
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
                          'Confidence: ${diagnosis['confidence'].toStringAsFixed(1)}%',
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
                      diagnosis['severity'],
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
                'Symptoms: ${(diagnosis['symptoms'] as List<String>).join(', ')}',
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
                            'Follow-up',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No diagnoses found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
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

  void _viewDiagnosisDetails(Map<String, dynamic> diagnosis) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Diagnosis Details - ${diagnosis['patientName']}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Patient ID', diagnosis['patientId']),
                  _buildDetailRow('Date', diagnosis['date']),
                  _buildDetailRow('Time', diagnosis['time']),
                  _buildDetailRow(
                    'Primary Diagnosis',
                    diagnosis['primaryDiagnosis'],
                  ),
                  _buildDetailRow(
                    'Confidence',
                    '${diagnosis['confidence'].toStringAsFixed(1)}%',
                  ),
                  _buildDetailRow('Severity', diagnosis['severity']),
                  _buildDetailRow('Status', diagnosis['status']),
                  const SizedBox(height: 8),
                  Text(
                    'Symptoms:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ...(diagnosis['symptoms'] as List<String>).map(
                    (symptom) => Text(
                      '• $symptom',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to full diagnosis report
                },
                child: const Text('View Full Report'),
              ),
            ],
          ),
    );
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
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filter Diagnoses'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter by Status:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                ..._filters.map((filter) {
                  return RadioListTile<String>(
                    title: Text(filter),
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
                child: const Text('Cancel'),
              ),
            ],
          ),
    );
  }

  void _exportHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting diagnosis history...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
