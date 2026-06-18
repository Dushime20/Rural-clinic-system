import 'package:flutter/material.dart';
import '../../data/models/clinic_models.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/app_localizations.dart';

/// Clinic Specialty Filter Widget
/// Allows users to filter clinic recommendations by medical specialty
class ClinicSpecialtyFilter extends StatefulWidget {
  final List<ClinicRecommendation> clinics;
  final List<String> selectedSpecialties;
  final Function(List<String>) onFilterChanged;

  const ClinicSpecialtyFilter({
    super.key,
    required this.clinics,
    required this.selectedSpecialties,
    required this.onFilterChanged,
  });

  @override
  State<ClinicSpecialtyFilter> createState() => _ClinicSpecialtyFilterState();
}

class _ClinicSpecialtyFilterState extends State<ClinicSpecialtyFilter> {
  late List<String> _selectedSpecialties;

  @override
  void initState() {
    super.initState();
    _selectedSpecialties = List.from(widget.selectedSpecialties);
  }

  @override
  void didUpdateWidget(ClinicSpecialtyFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSpecialties != oldWidget.selectedSpecialties) {
      _selectedSpecialties = List.from(widget.selectedSpecialties);
    }
  }

  /// Get all unique specialties from clinics with counts
  Map<String, int> _getSpecialtyCounts() {
    final Map<String, int> counts = {};
    for (final clinic in widget.clinics) {
      for (final specialty in clinic.specialties) {
        counts[specialty] = (counts[specialty] ?? 0) + 1;
      }
    }
    // Sort by count descending
    final sortedEntries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  void _toggleSpecialty(String specialty) {
    setState(() {
      if (_selectedSpecialties.contains(specialty)) {
        _selectedSpecialties.remove(specialty);
      } else {
        _selectedSpecialties.add(specialty);
      }
    });
    widget.onFilterChanged(_selectedSpecialties);
  }

  void _clearFilters() {
    setState(() {
      _selectedSpecialties.clear();
    });
    widget.onFilterChanged(_selectedSpecialties);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final specialtyCounts = _getSpecialtyCounts();

    if (specialtyCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with clear filters button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.filterBySpecialty,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              if (_selectedSpecialties.isNotEmpty)
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.infoColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Specialty chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                specialtyCounts.entries.map((entry) {
                  final specialty = entry.key;
                  final count = entry.value;
                  final isSelected = _selectedSpecialties.contains(specialty);

                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          specialty.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            color:
                                isSelected
                                    ? Colors.white
                                    : context.adaptiveColor(
                                        lightColor: const Color(0xFF1565C0),
                                        darkColor: const Color(0xFF64B5F6),
                                      ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : context.adaptiveColor(
                                        lightColor: const Color(0xFFE3F2FD),
                                        darkColor: const Color(0xFF1E2A3A),
                                      ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : context.adaptiveColor(
                                          lightColor: const Color(0xFF1565C0),
                                          darkColor: const Color(0xFF64B5F6),
                                        ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) => _toggleSpecialty(specialty),
                    selectedColor: context.adaptiveColor(
                      lightColor: const Color(0xFF1E88E5),
                      darkColor: const Color(0xFF1565C0),
                    ),
                    checkmarkColor: Colors.white,
                    backgroundColor: context.adaptiveColor(
                      lightColor: const Color(0xFFE3F2FD),
                      darkColor: const Color(0xFF1E2A3A),
                    ),
                    side: BorderSide(
                      color:
                          isSelected
                              ? context.adaptiveColor(
                                  lightColor: const Color(0xFF1E88E5),
                                  darkColor: const Color(0xFF1565C0),
                                )
                              : context.adaptiveColor(
                                  lightColor: const Color(0xFF90CAF9),
                                  darkColor: const Color(0xFF42A5F5).withValues(alpha: 0.5),
                                ),
                      width: isSelected ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  );
                }).toList(),
          ),
          // Selected count summary
          if (_selectedSpecialties.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.adaptiveColor(
                  lightColor: const Color(0xFFE3F2FD),
                  darkColor: const Color(0xFF1E2A3A),
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: context.adaptiveColor(
                    lightColor: const Color(0xFF90CAF9),
                    darkColor: const Color(0xFF42A5F5).withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 16,
                    color: context.adaptiveColor(
                      lightColor: const Color(0xFF1565C0),
                      darkColor: const Color(0xFF64B5F6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_getFilteredCount()} ${_getFilteredCount() == 1 ? 'clinic' : 'clinics'} with selected ${_selectedSpecialties.length == 1 ? 'specialty' : 'specialties'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: context.adaptiveColor(
                          lightColor: const Color(0xFF0D47A1),
                          darkColor: const Color(0xFF90CAF9),
                        ),
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

  int _getFilteredCount() {
    if (_selectedSpecialties.isEmpty) return widget.clinics.length;
    return widget.clinics
        .where(
          (clinic) => clinic.specialties.any(
            (s) => _selectedSpecialties.contains(s),
          ),
        )
        .length;
  }
}
