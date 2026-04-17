import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/chart_widget.dart';
import '../../../../shared/widgets/app_header.dart';

class AnalyticsDashboardPage extends ConsumerWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Analytics Dashboard',
        subtitle: 'View health statistics and trends',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummarySection(),
            const SizedBox(height: 24),

            // Disease Trends
            _buildChartCard(
              title: 'Disease Trends',
              chart: ChartWidget(), // Replace with actual disease chart
            ),
            const SizedBox(height: 24),

            // Demographic Breakdown
            _buildChartCard(
              title: 'Patient Demographics',
              chart: ChartWidget(), // Replace with actual demographics chart
            ),
            const SizedBox(height: 24),

            // Diagnosis Accuracy
            _buildChartCard(
              title: 'Diagnosis Accuracy Over Time',
              chart: ChartWidget(), // Replace with actual accuracy chart
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8, // Make cards taller
      children: [
        _buildSummaryCard(
          'Total Diagnoses',
          '452',
          Icons.psychology,
          AppTheme.primaryColor,
        ),
        _buildSummaryCard(
          'Total Patients',
          '152',
          Icons.people,
          AppTheme.secondaryColor,
        ),
        _buildSummaryCard(
          'Avg. Accuracy',
          '92.5%',
          Icons.check_circle,
          AppTheme.successColor,
        ),
        _buildSummaryCard(
          'Syncs Today',
          '12',
          Icons.sync,
          AppTheme.accentColor,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: color, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(), // Use a Spacer to push the value to the bottom
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
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
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }
}
