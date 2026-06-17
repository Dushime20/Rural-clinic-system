import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/analytics_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/app_localizations.dart';

class DemographicsChart extends StatelessWidget {
  final PatientDemographics demographics;

  const DemographicsChart({
    super.key,
    required this.demographics,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        // Gender Distribution
        _buildSection(
          title: '${l10n.gender} ${l10n.info}',
          child: _buildGenderChart(l10n),
        ),
        const SizedBox(height: 32),
        // Age Distribution
        _buildSection(
          title: '${l10n.age} ${l10n.info}',
          child: _buildAgeChart(l10n),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildGenderChart(AppLocalizations l10n) {
    final total = demographics.genderDistribution.total;
    if (total == 0) {
      return Center(
        child: Text(l10n.noData),
      );
    }

    final sections = [
      PieChartSectionData(
        color: AppTheme.primaryColor,
        value: demographics.genderDistribution.male.toDouble(),
        title:
            '${((demographics.genderDistribution.male / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        color: AppTheme.secondaryColor,
        value: demographics.genderDistribution.female.toDouble(),
        title:
            '${((demographics.genderDistribution.female / total) * 100).toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      if (demographics.genderDistribution.other > 0)
        PieChartSectionData(
          color: AppTheme.accentColor,
          value: demographics.genderDistribution.other.toDouble(),
          title:
              '${((demographics.genderDistribution.other / total) * 100).toStringAsFixed(0)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];

    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  l10n.male,
                  demographics.genderDistribution.male,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 6),
                _buildLegendItem(
                  l10n.female,
                  demographics.genderDistribution.female,
                  AppTheme.secondaryColor,
                ),
                if (demographics.genderDistribution.other > 0) ...[
                  const SizedBox(height: 6),
                  _buildLegendItem(
                    l10n.other,
                    demographics.genderDistribution.other,
                    AppTheme.accentColor,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeChart(AppLocalizations l10n) {
    final ageData = demographics.ageDistribution;
    if (ageData.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(l10n.noData),
        ),
      );
    }

    final sortedEntries = ageData.entries.toList()
      ..sort((a, b) => _getAgeGroupOrder(a.key).compareTo(_getAgeGroupOrder(b.key)));

    final maxValue = sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 110,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: (maxValue * 1.3).toDouble(),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          sortedEntries[value.toInt()].key,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 9,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                  reservedSize: 22,
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: maxValue > 3 ? (maxValue / 3).ceilToDouble() : 1,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 9,
                        ),
                      ),
                    );
                  },
                  reservedSize: 22,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: AppTheme.textDisabled.withOpacity(0.2),
                width: 1,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxValue > 3 ? (maxValue / 3).ceilToDouble() : 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppTheme.textDisabled.withOpacity(0.2),
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: List.generate(
              sortedEntries.length,
              (index) => BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: sortedEntries[index].value.toDouble(),
                    color: AppTheme.primaryColor,
                    width: 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '$label: $count',
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  int _getAgeGroupOrder(String ageGroup) {
    const order = {
      '0-18': 0,
      '19-35': 1,
      '36-50': 2,
      '51-65': 3,
      '65+': 4,
    };
    return order[ageGroup] ?? 999;
  }
}
