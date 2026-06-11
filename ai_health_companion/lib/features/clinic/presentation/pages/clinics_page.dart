import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/custom_drawer.dart';
import '../../../diagnosis/data/models/clinic_models.dart';
import '../../../diagnosis/data/services/diagnosis_service.dart';

class ClinicsPage extends StatefulWidget {
  const ClinicsPage({super.key});

  @override
  State<ClinicsPage> createState() => _ClinicsPageState();
}

class _ClinicsPageState extends State<ClinicsPage> {
  late final DiagnosisService _diagnosisService;
  List<ClinicRecommendation> _clinics = [];
  List<ClinicRecommendation> _filteredClinics = [];
  bool _isLoading = true;
  String? _error;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _diagnosisService = DiagnosisService(ApiService());
    _loadClinics();
    _searchController.addListener(_filterClinics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClinics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final clinics = await _diagnosisService.getAllClinics();
      
      setState(() {
        _clinics = clinics;
        _filteredClinics = clinics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterClinics() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClinics = _clinics;
      } else {
        _filteredClinics = _clinics.where((clinic) {
          // Search by clinic name
          if (clinic.name.toLowerCase().contains(query)) return true;
          
          // Search by location (address, city, district)
          if (clinic.address.toLowerCase().contains(query)) return true;
          if (clinic.city?.toLowerCase().contains(query) ?? false) return true;
          if (clinic.district?.toLowerCase().contains(query) ?? false) return true;
          
          // Search by specialty
          final hasSpecialty = clinic.specialties.any((specialty) {
            return specialty.toLowerCase().contains(query);
          });
          
          return hasSpecialty;
        }).toList();
      }
    });
  }

  Future<void> _callClinic(String phoneNumber) async {
    try {
      final uri = Uri.parse('tel:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cannot open phone dialer'),
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
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToClinic(double latitude, double longitude) async {
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
            const SnackBar(
              content: Text('Cannot open maps'),
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
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showClinicDetails(ClinicRecommendation clinic) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Clinic name
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_hospital,
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
                          clinic.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (clinic.isOpenNow != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: (clinic.isOpenNow!
                                      ? Colors.green
                                      : Colors.red)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              clinic.openingStatusText,
                              style: TextStyle(
                                fontSize: 11,
                                color: clinic.isOpenNow!
                                    ? Colors.green
                                    : Colors.red,
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
                'Address',
                clinic.fullAddress,
              ),
              const SizedBox(height: 12),
              if (clinic.phoneNumber != null)
                _buildDetailRow(
                  Icons.phone,
                  'Phone',
                  clinic.phoneNumber!,
                ),
              if (clinic.phoneNumber != null) const SizedBox(height: 12),
              if (clinic.openingHours != null)
                _buildDetailRow(
                  Icons.access_time,
                  'Opening Hours',
                  _formatOpeningHours(clinic.openingHours!),
                ),
              if (clinic.openingHours != null) const SizedBox(height: 12),
              if (clinic.distance != null)
                _buildDetailRow(
                  Icons.navigation,
                  'Distance',
                  clinic.distanceText,
                ),

              // Specialties Section
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Specialties',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Empty state or specialties list
              if (clinic.specialties.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'General Medicine',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: clinic.specialties.map((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        specialty.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (clinic.phoneNumber != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(modalContext);
                          _callClinic(clinic.phoneNumber!);
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (clinic.phoneNumber != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(modalContext);
                        _navigateToClinic(
                          clinic.latitude,
                          clinic.longitude,
                        );
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
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
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
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

  String _formatOpeningHours(Map<String, dynamic> openingHours) {
    // Extract opening hours info
    // This is a simple formatter - adjust based on actual data structure
    if (openingHours.isEmpty) return 'Not specified';
    
    // Try to extract common patterns
    if (openingHours['open'] != null && openingHours['close'] != null) {
      return '${openingHours['open']} - ${openingHours['close']}';
    }
    
    // Fallback to string representation
    return openingHours.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: 'Clinics',
        subtitle: '${_filteredClinics.length} clinics available',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadClinics,
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, specialty, or location...',
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
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Clinic list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading clinics...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Error loading clinics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadClinics,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredClinics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No clinics found'
                  : 'No matching clinics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadClinics,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredClinics.length,
        itemBuilder: (context, index) {
          final clinic = _filteredClinics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showClinicDetails(clinic),
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
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
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
                                clinic.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                clinic.specialtiesText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            clinic.fullAddress,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (clinic.phoneNumber != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            clinic.phoneNumber!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
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
