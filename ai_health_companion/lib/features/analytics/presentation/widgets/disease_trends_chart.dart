import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/analytics_models.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/l10n/disease_name_translations.dart';

class DiseaseTrendsChart extends StatelessWidget {
  final List<DiseaseTrend> trends;
  final List<TopDisease> topDiseases;

  const DiseaseTrendsChart({
    super.key,
    required this.trends,
    required this.topDiseases,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    
    if (trends.isEmpty || topDiseases.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(l10n.noData),
        ),
      );
    }

    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
    ];

    return SizedBox(
      height: 240,
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.textDisabled.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
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
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= 0 && value.toInt() < trends.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              trends[value.toInt()].month,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        );
                      },
                      reservedSize: 36,
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
                minX: 0,
                maxX: (trends.length - 1).toDouble(),
                minY: 0,
                maxY: _getMaxY(),
                lineBarsData: _buildLineBars(colors),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegend(colors, locale),
        ],
      ),
    );
  }

  double _getMaxY() {
    double max = 0;
    for (var trend in trends) {
      for (var count in trend.diseaseCounts.values) {
        if (count > max) max = count.toDouble();
      }
    }
    return (max * 1.2).ceilToDouble(); // Add 20% padding
  }

  List<LineChartBarData> _buildLineBars(List<Color> colors) {
    final bars = <LineChartBarData>[];

    for (int i = 0; i < topDiseases.length && i < 3; i++) {
      final disease = topDiseases[i];
      final spots = <FlSpot>[];

      for (int j = 0; j < trends.length; j++) {
        final count = trends[j].diseaseCounts[disease.key] ?? 0;
        spots.add(FlSpot(j.toDouble(), count.toDouble()));
      }

      bars.add(
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: colors[i],
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: colors[i],
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: colors[i].withOpacity(0.1),
          ),
        ),
      );
    }

    return bars;
  }

  Widget _buildLegend(List<Color> colors, Locale locale) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: List.generate(
        topDiseases.length > 3 ? 3 : topDiseases.length,
        (index) {
          final translatedName = translateDiseaseName(topDiseases[index].name, locale);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  translatedName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
