import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../data/providers/analytics_provider.dart';
import '../widgets/disease_trends_chart.dart';
import '../widgets/demographics_chart.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardAnalyticsProvider);
    final demographicsAsync = ref.watch(patientDemographicsProvider);

    return Scaffold(
      appBar: AppHeader(
        title: 'Analytics Dashboard',
        subtitle: 'View health statistics and trends',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardAnalyticsProvider);
              ref.invalidate(patientDemographicsProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              _buildSummarySection(dashboard),
              const SizedBox(height: 24),

              // Disease Trends
              _buildChartCard(
                title: 'Disease Trends (Last 6 Months)',
                chart: DiseaseTrendsChart(
                  trends: dashboard.diseaseTrends,
                  topDiseases: dashboard.topDiseases,
                ),
              ),
              const SizedBox(height: 24),

              // Patient Demographics
              demographicsAsync.when(
                data: (demographics) => _buildChartCard(
                  title: 'Patient Demographics',
                  chart: DemographicsChart(demographics: demographics),
                ),
                loading: () => _buildChartCard(
                  title: 'Patient Demographics',
                  chart: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => _buildChartCard(
                  title: 'Patient Demographics',
                  chart: Center(
                    child: Text(
                      'Error loading demographics: ${error.toString()}',
                      style: const TextStyle(color: AppTheme.errorColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load analytics',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(dashboardAnalyticsProvider);
                    ref.invalidate(patientDemographicsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(dashboard) {
    // Get the most common disease
    final topDisease = dashboard.topDiseases.isNotEmpty 
        ? dashboard.topDiseases.first.name 
        : 'N/A';

    return Column(
      children: [
        // Top row with 2 cards
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Diagnoses',
                  dashboard.totalDiagnoses.toString(),
                  Icons.psychology,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  'Total Patients',
                  dashboard.totalPatients.toString(),
                  Icons.people,
                  AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Bottom row with 1 card
        SizedBox(
          height: 100,
          child: _buildTextSummaryCard(
            'Top Disease',
            topDisease,
            Icons.coronavirus,
            AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget chart}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            chart,
          ],
        ),
      ),
    );
  }
}
