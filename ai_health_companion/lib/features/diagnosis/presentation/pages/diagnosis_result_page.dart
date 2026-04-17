import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/animated_counter.dart';
import '../../../../shared/widgets/app_header.dart';

class DiagnosisResultPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> diagnosisData;

  const DiagnosisResultPage({super.key, required this.diagnosisData});

  @override
  ConsumerState<DiagnosisResultPage> createState() =>
      _DiagnosisResultPageState();
}

class _DiagnosisResultPageState extends ConsumerState<DiagnosisResultPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = ['Results', 'Details', 'Recommendations'];

  // Mock AI prediction results
  final List<Map<String, dynamic>> _predictions = [
    {
      'disease': 'Common Cold',
      'confidence': 85.2,
      'description': 'Viral infection of the upper respiratory tract',
      'symptoms': ['Runny nose', 'Cough', 'Sore throat'],
      'severity': 'Mild',
      'color': AppTheme.primaryColor,
    },
    {
      'disease': 'Influenza',
      'confidence': 72.8,
      'description': 'Viral infection affecting the respiratory system',
      'symptoms': ['Fever', 'Body aches', 'Fatigue'],
      'severity': 'Moderate',
      'color': AppTheme.secondaryColor,
    },
    {
      'disease': 'Allergic Rhinitis',
      'confidence': 68.5,
      'description': 'Allergic reaction causing nasal inflammation',
      'symptoms': ['Sneezing', 'Itchy eyes', 'Runny nose'],
      'severity': 'Mild',
      'color': AppTheme.accentColor,
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: 'AI Diagnosis Results',
        subtitle: 'Confidence: ${_predictions[0]['confidence']}%',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareResults,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportResults,
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
                  // Header Section
                  _buildHeaderSection(),

                  // Tab Bar
                  _buildTabBar(),

                  // Content
                  Expanded(child: _buildTabContent()),

                  // Action Buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology,
              color: AppTheme.primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'AI Diagnosis Complete',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analysis completed with ${_predictions.length} possible conditions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children:
            _tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = _selectedTab == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppTheme.primaryColor
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildResultsTab();
      case 1:
        return _buildDetailsTab();
      case 2:
        return _buildRecommendationsTab();
      default:
        return _buildResultsTab();
    }
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Top Prediction
          _buildTopPredictionCard(),
          const SizedBox(height: 20),

          // Other Predictions
          _buildOtherPredictions(),
        ],
      ),
    );
  }

  Widget _buildTopPredictionCard() {
    final topPrediction = _predictions[0];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.mediumShadow,
        border: Border.all(color: topPrediction['color'], width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: topPrediction['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.medical_services,
                  color: topPrediction['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topPrediction['disease'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      topPrediction['severity'],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: topPrediction['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedCounter(
                  value: topPrediction['confidence'].toInt(),
                  suffix: '%',
                  style: TextStyle(
                    color: topPrediction['color'],
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            topPrediction['description'],
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(
            'Key Symptoms:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                (topPrediction['symptoms'] as List<String>).map((symptom) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: topPrediction['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      symptom,
                      style: TextStyle(
                        color: topPrediction['color'],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherPredictions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other Possible Conditions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        ...(_predictions.skip(1).map((prediction) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildPredictionCard(prediction),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: prediction['color'],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction['disease'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  prediction['severity'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: prediction['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${prediction['confidence'].toStringAsFixed(1)}%',
              style: TextStyle(
                color: prediction['color'],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnosis Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Patient Information
          _buildDetailSection('Patient Information', [
            'Age: ${widget.diagnosisData['age'] ?? 'N/A'}',
            'Gender: ${widget.diagnosisData['gender'] ?? 'N/A'}',
            'Weight: ${widget.diagnosisData['weight'] ?? 'N/A'} kg',
            'Height: ${widget.diagnosisData['height'] ?? 'N/A'} cm',
          ]),

          const SizedBox(height: 20),

          // Vital Signs
          _buildDetailSection('Vital Signs', [
            'Temperature: ${widget.diagnosisData['temperature'] ?? 'N/A'}°C',
            'Blood Pressure: ${widget.diagnosisData['blood_pressure_systolic'] ?? 'N/A'}/${widget.diagnosisData['blood_pressure_diastolic'] ?? 'N/A'} mmHg',
            'Heart Rate: ${widget.diagnosisData['heart_rate'] ?? 'N/A'} bpm',
            'Respiratory Rate: ${widget.diagnosisData['respiratory_rate'] ?? 'N/A'} breaths/min',
            'Oxygen Saturation: ${widget.diagnosisData['oxygen_saturation'] ?? 'N/A'}%',
          ]),

          const SizedBox(height: 20),

          // Selected Symptoms
          _buildDetailSection(
            'Selected Symptoms',
            (widget.diagnosisData['symptoms'] as List<String>?)
                    ?.map((symptom) => '• $symptom')
                    .toList() ??
                ['No symptoms selected'],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(item, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendations',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          // Immediate Actions
          _buildRecommendationCard(
            'Immediate Actions',
            [
              'Rest and get plenty of sleep',
              'Stay hydrated by drinking fluids',
              'Use saline nasal spray for congestion',
              'Gargle with warm salt water for sore throat',
            ],
            Icons.warning,
            AppTheme.warningColor,
          ),

          const SizedBox(height: 16),

          // Medications
          _buildRecommendationCard(
            'Recommended Medications',
            [
              'Acetaminophen for fever and pain',
              'Ibuprofen for inflammation',
              'Antihistamines for allergy symptoms',
              'Cough suppressants if needed',
            ],
            Icons.medication,
            AppTheme.primaryColor,
          ),

          const SizedBox(height: 16),

          // Follow-up
          _buildRecommendationCard(
            'Follow-up Care',
            [
              'Monitor symptoms for 3-5 days',
              'Seek medical attention if symptoms worsen',
              'Return if fever persists beyond 3 days',
              'Consider allergy testing if symptoms recur',
            ],
            Icons.schedule,
            AppTheme.secondaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    String title,
    List<String> recommendations,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.map(
            (recommendation) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.go('/diagnosis'),
              icon: const Icon(Icons.refresh),
              label: const Text('New Diagnosis'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveDiagnosis,
              icon: const Icon(Icons.save),
              label: const Text('Save Results'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing diagnosis results...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _exportResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting diagnosis report...'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _saveDiagnosis() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Diagnosis results saved successfully'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}
