import 'package:flutter/material.dart';
import '../../../../generated/app_localizations.dart';
import '../../data/models/clinic_models.dart';

/// Pattern Analysis Notice Widget
/// Displays a notice explaining why clinics are recommended based on detected patterns
class PatternAnalysisNotice extends StatelessWidget {
  final PatternAnalysis patternAnalysis;

  const PatternAnalysisNotice({
    super.key,
    required this.patternAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (!patternAnalysis.hasPattern) {
      return const SizedBox.shrink();
    }

    final colorScheme = _getColorScheme();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIcon(),
                color: colorScheme.iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getTitle(l10n),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getMessage(l10n),
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.textColor.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          if (_getDetails(l10n) != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: colorScheme.textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getDetails(l10n)!,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  _ColorScheme _getColorScheme() {
    if (patternAnalysis.matchesChronicCondition) {
      return _ColorScheme(
        backgroundColor: Colors.red.shade50,
        borderColor: Colors.red.shade300,
        iconColor: Colors.red.shade700,
        textColor: Colors.red.shade900,
      );
    } else if (patternAnalysis.isPersistent) {
      return _ColorScheme(
        backgroundColor: Colors.amber.shade50,
        borderColor: Colors.amber.shade300,
        iconColor: Colors.amber.shade700,
        textColor: Colors.amber.shade900,
      );
    } else if (patternAnalysis.isRecurring) {
      return _ColorScheme(
        backgroundColor: Colors.orange.shade50,
        borderColor: Colors.orange.shade300,
        iconColor: Colors.orange.shade700,
        textColor: Colors.orange.shade900,
      );
    }
    return _ColorScheme(
      backgroundColor: Colors.blue.shade50,
      borderColor: Colors.blue.shade300,
      iconColor: Colors.blue.shade700,
      textColor: Colors.blue.shade900,
    );
  }

  IconData _getIcon() {
    if (patternAnalysis.matchesChronicCondition) {
      return Icons.warning_rounded;
    } else if (patternAnalysis.isPersistent) {
      return Icons.trending_up_rounded;
    } else if (patternAnalysis.isRecurring) {
      return Icons.repeat_rounded;
    }
    return Icons.info_rounded;
  }

  String _getTitle(AppLocalizations l10n) {
    if (patternAnalysis.matchesChronicCondition) {
      return l10n.chronicConditionDetected;
    } else if (patternAnalysis.isPersistent) {
      return l10n.persistentConditionDetected;
    } else if (patternAnalysis.isRecurring) {
      return l10n.recurringConditionDetected;
    }
    return l10n.patternDetected;
  }

  String _getMessage(AppLocalizations l10n) {
    if (patternAnalysis.matchesChronicCondition) {
      return l10n.chronicConditionMessage;
    } else if (patternAnalysis.isPersistent) {
      return l10n.persistentConditionMessage;
    } else if (patternAnalysis.isRecurring) {
      return l10n.recurringConditionMessage;
    }
    return l10n.patternDetectedMessage;
  }

  String? _getDetails(AppLocalizations l10n) {
    if (patternAnalysis.matchesChronicCondition &&
        patternAnalysis.matchedCondition != null) {
      return l10n.matchedCondition(patternAnalysis.matchedCondition!);
    } else if (patternAnalysis.isPersistent &&
        patternAnalysis.durationDays != null) {
      final days = patternAnalysis.durationDays!;
      if (days > 60) {
        return l10n.activeForDaysMonths(days, (days / 30).floor());
      }
      return l10n.activeForDays(days);
    } else if (patternAnalysis.isRecurring &&
        patternAnalysis.occurrenceCount != null) {
      return l10n.occurrencesInLast90Days(patternAnalysis.occurrenceCount!);
    }
    return null;
  }
}

class _ColorScheme {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _ColorScheme({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}
