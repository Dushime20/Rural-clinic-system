import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/custom_drawer.dart';
import '../../../diagnosis/data/models/diagnosis_models.dart';
import '../../../diagnosis/data/services/diagnosis_service.dart';
import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/theme_extensions.dart';

class PharmaciesPage extends StatefulWidget {
  const PharmaciesPage({super.key});

  @override
  State<PharmaciesPage> createState() => _PharmaciesPageState();
}

class _PharmaciesPageState extends State<PharmaciesPage> {
  late final DiagnosisService _diagnosisService;
  List<NearbyPharmacy> _pharmacies = [];
  List<NearbyPharmacy> _filteredPharmacies = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _diagnosisService = DiagnosisService(ApiService());
    _loadPharmacies();
    _searchController.addListener(_filterPharmacies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPharmacies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pharmacies = await _diagnosisService.getAllPharmacies();
      
      // Fetch full details (with medicines) for each pharmacy
      final pharmaciesWithMedicines = <NearbyPharmacy>[];
      for (final pharmacy in pharmacies) {
        try {
          final fullDetails = await _diagnosisService.getPharmacyById(pharmacy.id);
          pharmaciesWithMedicines.add(fullDetails);
        } catch (e) {
          // If fetching details fails, use the basic pharmacy data
          debugPrint('Failed to fetch details for ${pharmacy.name}: $e');
          pharmaciesWithMedicines.add(pharmacy);
        }
      }
      
      setState(() {
        _pharmacies = pharmaciesWithMedicines;
        _filteredPharmacies = pharmaciesWithMedicines;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPharmacies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPharmacies = _pharmacies;
      } else {
        _filteredPharmacies = _pharmacies.where((pharmacy) {
          // Search by pharmacy name
          if (pharmacy.name.toLowerCase().contains(query)) return true;
          
          // Search by location (address, city, district)
          if (pharmacy.address.toLowerCase().contains(query)) return true;
          if (pharmacy.city?.toLowerCase().contains(query) ?? false) return true;
          if (pharmacy.district?.toLowerCase().contains(query) ?? false) return true;
          
          // Search by medicine name (generic name, brand name, medication name)
          final hasMedicine = pharmacy.medicines.any((medicine) {
            return medicine.medicationName.toLowerCase().contains(query) ||
                (medicine.genericName?.toLowerCase().contains(query) ?? false) ||
                (medicine.brandName?.toLowerCase().contains(query) ?? false);
          });
          
          return hasMedicine;
        }).toList();
      }
    });
  }

  Future<void> _callPharmacy(String phoneNumber) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotOpenDialer),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching phone dialer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToPharmacy(double latitude, double longitude) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final uri = Uri.parse(
        'https://maps.google.com/?q=$latitude,$longitude',
      );
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.cannotOpenMaps),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPharmacyDetails(NearbyPharmacy pharmacy) async {
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.modalBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Pharmacy name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.chipBackground(AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pharmacy.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (pharmacy.isActive)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.active,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 16),

              // Details
              _buildDetailRow(
                Icons.location_on,
                l10n.address,
                pharmacy.fullAddress,
              ),
              const SizedBox(height: 12),
              if (pharmacy.phoneNumber != null)
                _buildDetailRow(
                  Icons.phone,
                  l10n.phoneNumber,
                  pharmacy.phoneNumber!,
                ),
              if (pharmacy.phoneNumber != null) const SizedBox(height: 12),
              if (pharmacy.openingHours != null)
                _buildDetailRow(
                  Icons.access_time,
                  l10n.openingHours,
                  pharmacy.openingHours!,
                ),
              if (pharmacy.openingHours != null) const SizedBox(height: 12),

              // Medicines Section
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                l10n.availableMedicines,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Empty state or medicines list
              if (pharmacy.medicines.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.containerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.secondaryTextColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.noMedicinesAvailable,
                        style: TextStyle(
                          color: context.secondaryTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...pharmacy.medicines.map((medicine) => _buildMedicineCard(medicine)),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (pharmacy.phoneNumber != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          _callPharmacy(pharmacy.phoneNumber!);
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: Text(l10n.call),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (pharmacy.phoneNumber != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        _navigateToPharmacy(
                          pharmacy.latitude,
                          pharmacy.longitude,
                        );
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: Text(l10n.navigate),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.successColor,
                        foregroundColor: context.adaptiveColor(
                          lightColor: Colors.white,
                          darkColor: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: context.secondaryTextColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: context.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicineCard(PharmacyMedicine medicine) {
    // Determine stock status color
    Color stockColor;
    if (!medicine.isAvailable || medicine.stockQuantity <= 0) {
      stockColor = Colors.red;
    } else if (medicine.stockQuantity <= 10) {
      stockColor = Colors.orange;
    } else {
      stockColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.containerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Medicine name
          Text(
            medicine.displayName,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          
          // Strength and form
          if (medicine.strength != null || medicine.form != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                [
                  if (medicine.strength != null) medicine.strength!,
                  if (medicine.form != null) medicine.form!,
                ].join(' '),
                style: TextStyle(
                  fontSize: 12,
                  color: context.secondaryTextColor,
                ),
              ),
            ),
          
          // Price and stock status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: context.secondaryTextColor,
                  ),
                  Text(
                    medicine.priceText,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              
              // Stock status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  medicine.stockText,
                  style: TextStyle(
                    fontSize: 11,
                    color: stockColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppHeader(
        title: l10n.pharmacies,
        subtitle: '${_filteredPharmacies.length} ${l10n.pharmaciesAvailable}',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPharmacies,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: context.surfaceColor,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchPharmacies,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                filled: true,
                fillColor: context.searchFieldColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Pharmacy list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;
    
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingPharmacies),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingPharmacies,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.secondaryTextColor),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPharmacies,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_filteredPharmacies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_pharmacy, size: 80, color: context.secondaryTextColor),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? l10n.noPharmaciesFound
                  : l10n.noMatchingPharmacies,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.tryDifferentSearch,
                style: TextStyle(color: context.secondaryTextColor),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPharmacies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPharmacies.length,
        itemBuilder: (context, index) {
          final pharmacy = _filteredPharmacies[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showPharmacyDetails(pharmacy),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: context.chipBackground(AppTheme.primaryColor),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_pharmacy,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pharmacy.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (pharmacy.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l10n.active,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pharmacy.fullAddress,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.secondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (pharmacy.phoneNumber != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            pharmacy.phoneNumber!,
                            style: TextStyle(
                              fontSize: 13,
                              color: context.secondaryTextColor,
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
    );
  }
}
