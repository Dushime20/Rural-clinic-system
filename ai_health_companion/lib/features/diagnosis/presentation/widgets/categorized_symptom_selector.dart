import 'package:flutter/material.dart';
import '../../../../core/constants/symptoms_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/l10n/symptom_translations_data.dart';

class CategorizedSymptomSelector extends StatefulWidget {
  final List<String> selectedSymptoms;
  final Function(String) onSymptomToggle;

  const CategorizedSymptomSelector({
    super.key,
    required this.selectedSymptoms,
    required this.onSymptomToggle,
  });

  @override
  State<CategorizedSymptomSelector> createState() =>
      _CategorizedSymptomSelectorState();
}

class _CategorizedSymptomSelectorState
    extends State<CategorizedSymptomSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _expandedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredSymptoms {
    if (_searchQuery.isEmpty) return [];
    final query = _searchQuery.toLowerCase();
    return SymptomsConstants.allSymptoms
        .where((symptom) => symptom.toLowerCase().contains(query))
        .toList();
  }

  IconData _getCategoryIcon(String category) {
    final metadata = SymptomsConstants.categoryMetadata[category];
    if (metadata == null) return Icons.category;

    final iconName = metadata['icon'] as String;
    switch (iconName) {
      case 'thermostat':
        return Icons.thermostat;
      case 'air':
        return Icons.air;
      case 'restaurant':
        return Icons.restaurant;
      case 'face':
        return Icons.face;
      case 'healing':
        return Icons.healing;
      case 'psychology':
        return Icons.psychology;
      case 'visibility':
        return Icons.visibility;
      case 'water_drop':
        return Icons.water_drop;
      case 'favorite':
        return Icons.favorite;
      case 'mood':
        return Icons.mood;
      case 'biotech':
        return Icons.biotech;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'science':
        return Icons.science;
      default:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor(String category) {
    final metadata = SymptomsConstants.categoryMetadata[category];
    if (metadata == null) return Colors.grey;
    return Color(metadata['color'] as int);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        _buildSearchBar(),
        const SizedBox(height: 16),

        // Symptom Counter with Guidance
        _buildSymptomCounter(),
        const SizedBox(height: 20),

        // Search Results or Categories
        if (_searchQuery.isNotEmpty)
          _buildSearchResults()
        else
          _buildCategorizedSymptoms(),
      ],
    );
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: l10n.searchSymptomsPlaceholder,
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  Widget _buildSymptomCounter() {
    final l10n = AppLocalizations.of(context)!;
    final count = widget.selectedSymptoms.length;
    final isGoodCount = count >= 8 && count <= 12;
    final isFewSymptoms = count < 8;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoodCount
              ? [Colors.green.shade50, Colors.green.shade100]
              : isFewSymptoms
                  ? [Colors.orange.shade50, Colors.orange.shade100]
                  : [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGoodCount
              ? Colors.green.shade300
              : isFewSymptoms
                  ? Colors.orange.shade300
                  : Colors.blue.shade300,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isGoodCount
                  ? Colors.green
                  : isFewSymptoms
                      ? Colors.orange
                      : Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGoodCount
                      ? l10n.goodSelection
                      : isFewSymptoms
                          ? l10n.selectMoreSymptoms
                          : l10n.symptomsSelected,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isGoodCount
                        ? Colors.green.shade900
                        : isFewSymptoms
                            ? Colors.orange.shade900
                            : Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isGoodCount
                      ? l10n.accurateResultsExpected
                      : isFewSymptoms
                          ? l10n.selectEightToTenSymptoms
                          : l10n.canAddMoreSymptoms,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isGoodCount
                ? Icons.check_circle
                : isFewSymptoms
                    ? Icons.info_outline
                    : Icons.check_circle_outline,
            color: isGoodCount
                ? Colors.green
                : isFewSymptoms
                    ? Colors.orange
                    : Colors.blue,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context)!;
    final results = _filteredSymptoms;

    if (results.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noSymptomsFound,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryDifferentKeywords,
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            l10n.searchResultsCount(results.length),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: results.map((symptom) {
            final isSelected = widget.selectedSymptoms.contains(symptom);
            return _buildSymptomChip(symptom, isSelected);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategorizedSymptoms() {
    final l10n = AppLocalizations.of(context)!;
    
    return Column(
      children: SymptomsConstants.symptomsByCategory.entries.map((entry) {
        final category = entry.key;
        final symptoms = entry.value;
        final isExpanded = _expandedCategory == category;
        final selectedCount =
            symptoms.where((s) => widget.selectedSymptoms.contains(s)).length;

        // Translate category name
        final translatedCategory = _getCategoryTranslation(context, category);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _expandedCategory = isExpanded ? null : category;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          color: _getCategoryColor(category),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translatedCategory,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.symptomsCategoryCount(symptoms.length),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selectedCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$selectedCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptoms.map((symptom) {
                      final isSelected =
                          widget.selectedSymptoms.contains(symptom);
                      return _buildSymptomChip(symptom, isSelected);
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Helper method to get translated category name
  String _getCategoryTranslation(BuildContext context, String englishCategory) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (englishCategory) {
      case 'General':
        return l10n.categoryGeneral;
      case 'Respiratory':
        return l10n.categoryRespiratory;
      case 'Digestive':
        return l10n.categoryDigestive;
      case 'Skin & Nails':
        return l10n.categorySkinNails;
      case 'Pain & Discomfort':
        return l10n.categoryPainDiscomfort;
      case 'Neurological':
        return l10n.categoryNeurological;
      case 'Eyes & Vision':
        return l10n.categoryEyesVision;
      case 'Urinary':
        return l10n.categoryUrinary;
      case 'Cardiovascular':
        return l10n.categoryCardiovascular;
      case 'Mental & Behavioral':
        return l10n.categoryMentalBehavioral;
      case 'Liver & Digestive System':
        return l10n.categoryLiverDigestive;
      case 'Throat & Mouth':
        return l10n.categoryThroatMouth;
      case 'Endocrine & Metabolic':
        return l10n.categoryEndocrineMetabolic;
      case 'Other':
        return l10n.categoryOther;
      default:
        return englishCategory; // Fallback
    }
  }

  /// Helper method to get translated symptom name for display
  /// Returns translated name for UI, but selectedSymptoms list keeps English names
  String _getSymptomTranslation(BuildContext context, String englishSymptom) {
    final locale = Localizations.localeOf(context);
    
    if (locale.languageCode == 'fr') {
      return SymptomTranslationsData.frenchTranslations[englishSymptom] ?? englishSymptom;
    } else if (locale.languageCode == 'rw') {
      return SymptomTranslationsData.kinyarwandaTranslations[englishSymptom] ?? englishSymptom;
    }
    
    // Default to English
    return englishSymptom;
  }

  Widget _buildSymptomChip(String symptom, bool isSelected) {
    // Get translated symptom name for display
    final translatedSymptom = _getSymptomTranslation(context, symptom);
    
    return InkWell(
      onTap: () => widget.onSymptomToggle(symptom), // Still passes English name to parent
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              translatedSymptom, // Show translated name
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
