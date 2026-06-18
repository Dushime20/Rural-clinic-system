import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';

class PharmacySearchPage extends StatefulWidget {
  const PharmacySearchPage({super.key});

  @override
  State<PharmacySearchPage> createState() => _PharmacySearchPageState();
}

class _PharmacySearchPageState extends State<PharmacySearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedHealthCenter = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = [];

  List<String> _getHealthCenters(AppLocalizations l10n) {
    return [
      l10n.allHealthCenters,
      'Kigali Health Center',
      'Nyarugenge Clinic',
      'Gasabo Medical Center',
      'Kicukiro Health Post',
      'Remera Clinic',
    ];
  }

  @override
  void initState() {
    super.initState();
    // Initialize with localized value in build
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // Simulate API call to e-LMIS
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSearching = false;
        _searchResults = _getMockResults(_searchController.text, l10n.allHealthCenters);
      });
    });
  }

  List<Map<String, dynamic>> _getMockResults(String query, String allHealthCentersLabel) {
    // Mock e-LMIS data
    final allMedications = [
      {
        'name': 'Amoxicillin 500mg',
        'category': 'Antibiotic',
        'location': 'Kigali Health Center',
        'stock': 150,
        'status': 'In Stock',
        'expiryDate': '2026-12-31',
      },
      {
        'name': 'Amoxicillin 500mg',
        'category': 'Antibiotic',
        'location': 'Gasabo Medical Center',
        'stock': 45,
        'status': 'Low Stock',
        'expiryDate': '2026-10-15',
      },
      {
        'name': 'Paracetamol 500mg',
        'category': 'Analgesic',
        'location': 'Kigali Health Center',
        'stock': 300,
        'status': 'In Stock',
        'expiryDate': '2027-03-20',
      },
      {
        'name': 'Metformin 850mg',
        'category': 'Antidiabetic',
        'location': 'Nyarugenge Clinic',
        'stock': 0,
        'status': 'Out of Stock',
        'expiryDate': 'N/A',
      },
      {
        'name': 'Ibuprofen 400mg',
        'category': 'Anti-inflammatory',
        'location': 'Remera Clinic',
        'stock': 200,
        'status': 'In Stock',
        'expiryDate': '2026-08-10',
      },
    ];

    return allMedications
        .where(
          (med) =>
              med['name'].toString().toLowerCase().contains(
                query.toLowerCase(),
              ) &&
              (_selectedHealthCenter == allHealthCentersLabel ||
                  med['location'] == _selectedHealthCenter),
        )
        .toList();
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'In Stock':
        return context.successColor;
      case 'Low Stock':
        return context.warningColor;
      case 'Out of Stock':
        return context.errorColor;
      default:
        return context.iconColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final healthCenters = _getHealthCenters(l10n);
    
    // Initialize selected health center if not set
    if (_selectedHealthCenter.isEmpty) {
      _selectedHealthCenter = healthCenters[0];
    }
    
    return Scaffold(
      appBar: AppHeader(
        title: l10n.pharmacySearchTitle,
        subtitle: l10n.searchMedicationAvailability,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
            tooltip: l10n.scanBarcodeTooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: TextStyle(color: context.adaptiveColor(
                    lightColor: Colors.white,
                    darkColor: Colors.white,
                  )),
                  decoration: InputDecoration(
                    hintText: l10n.searchMedicationPlaceholder,
                    hintStyle: TextStyle(
                      color: context.adaptiveColor(
                        lightColor: Colors.white.withOpacity(0.7),
                        darkColor: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: context.adaptiveColor(
                        lightColor: Colors.white,
                        darkColor: Colors.white,
                      ),
                    ),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: context.adaptiveColor(
                                  lightColor: Colors.white,
                                  darkColor: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults = [];
                                });
                              },
                            )
                            : null,
                    filled: true,
                    fillColor: context.adaptiveColor(
                      lightColor: Colors.white.withOpacity(0.2),
                      darkColor: Colors.white.withOpacity(0.2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 12),
                // Health Center Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: context.adaptiveColor(
                      lightColor: Colors.white.withOpacity(0.2),
                      darkColor: Colors.white.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedHealthCenter,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).primaryColor,
                      style: TextStyle(
                        color: context.adaptiveColor(
                          lightColor: Colors.white,
                          darkColor: Colors.white,
                        ),
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: context.adaptiveColor(
                          lightColor: Colors.white,
                          darkColor: Colors.white,
                        ),
                      ),
                      items:
                          healthCenters.map((center) {
                            return DropdownMenuItem(
                              value: center,
                              child: Text(center),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedHealthCenter = value!;
                          if (_searchController.text.isNotEmpty) {
                            _performSearch();
                          }
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Search Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSearching ? null : _performSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.adaptiveColor(
                        lightColor: Colors.white,
                        darkColor: Colors.white.withOpacity(0.95),
                      ),
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                        _isSearching
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : Text(
                              l10n.searchELMIS,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child:
                _searchResults.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 80,
                            color: context.iconColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? l10n.searchForMedications
                                : l10n.noResultsFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: context.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.enterMedicationNameToCheck,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.secondaryTextColor.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final medication = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              _showMedicationDetails(medication);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              medication['name'],
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              medication['category'],
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: context.secondaryTextColor,
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
                                          color: _getStatusColor(
                                            context,
                                            medication['status'],
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          medication['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              context,
                                              medication['status'],
                                            ),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 16,
                                        color: context.iconColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          medication['location'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: context.textColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.inventory_2,
                                        size: 16,
                                        color: context.iconColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.stockUnits.replaceAll('{stock}', '${medication['stock']}'),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: context.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (medication['expiryDate'] != 'N/A') ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 16,
                                          color: context.iconColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.expiresDate.replaceAll('{date}', medication['expiryDate']),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: context.textColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  void _showMedicationDetails(Map<String, dynamic> medication) {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        medication['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(l10n.categoryLabel, medication['category']),
                _buildDetailRow(l10n.locationLabel, medication['location']),
                _buildDetailRow(l10n.stockLevelLabel, '${medication['stock']} units'),
                _buildDetailRow(l10n.statusLabel, medication['status']),
                if (medication['expiryDate'] != 'N/A')
                  _buildDetailRow(l10n.expiryDateLabel, medication['expiryDate']),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.directionsFeatureComingSoon),
                        ),
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: Text(l10n.getDirections),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: context.secondaryTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
