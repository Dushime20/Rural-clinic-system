import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/clinic_models.dart';

/// Clinic Recommendation Card Widget
/// Displays a clinic recommendation with blue theme to differentiate from pharmacy cards
class ClinicRecommendationCard extends StatelessWidget {
  final ClinicRecommendation clinic;
  final VoidCallback? onTap;

  const ClinicRecommendationCard({
    super.key,
    required this.clinic,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: InkWell(
        onTap: onTap ?? () => _showClinicDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and reason badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clinic.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (clinic.distance != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.blue.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  clinic.distanceText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildReasonBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // Specialties chips
              if (clinic.specialties.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: clinic.specialties
                      .take(3)
                      .map((specialty) => _buildSpecialtyChip(specialty))
                      .toList(),
                ),

              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      clinic.fullAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Opening status
              if (clinic.isOpenNow != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: clinic.isOpenNow! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      clinic.openingStatusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: clinic.isOpenNow! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  if (clinic.phoneNumber != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _makePhoneCall(clinic.phoneNumber!),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 18),
                            SizedBox(width: 6),
                            Text('Call', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  if (clinic.phoneNumber != null) const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _openMaps(clinic.latitude, clinic.longitude),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions, size: 18),
                          SizedBox(width: 6),
                          Text('Navigate', style: TextStyle(fontSize: 14)),
                        ],
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

  Widget _buildReasonBadge() {
    Color badgeColor;
    Color textColor;

    switch (clinic.reasonBadgeText) {
      case 'Recurring':
        badgeColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'Persistent':
        badgeColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        break;
      case 'Chronic':
        badgeColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
      default:
        badgeColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        clinic.reasonBadgeText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip(String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Text(
        specialty.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openMaps(double latitude, double longitude) async {
    // Try Google Maps first, fallback to Apple Maps on iOS
    final googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    }
  }

  void _showClinicDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                clinic.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // Distance
              if (clinic.distance != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text(
                      clinic.distanceText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Specialties section
              const Text(
                'Specialties',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: clinic.specialties
                    .map((specialty) => _buildSpecialtyChip(specialty))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Address section
              const Text(
                'Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                clinic.fullAddress,
                style: const TextStyle(fontSize: 16),
              ),

              // Phone section
              if (clinic.phoneNumber != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Contact',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clinic.phoneNumber!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],

              // Opening hours section
              if (clinic.isOpenNow != null) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 20,
                      color: clinic.isOpenNow! ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      clinic.openingStatusText,
                      style: TextStyle(
                        fontSize: 16,
                        color: clinic.isOpenNow! ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Reason section
              if (clinic.reason != null) ...[
                const SizedBox(height: 20),
                const Text(
                  'Why Recommended',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clinic.reasonExplanation,
                  style: const TextStyle(fontSize: 16),
                ),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  if (clinic.phoneNumber != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _makePhoneCall(clinic.phoneNumber!);
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Clinic'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue.shade700,
                          side: BorderSide(color: Colors.blue.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  if (clinic.phoneNumber != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openMaps(clinic.latitude, clinic.longitude);
                      },
                      icon: const Icon(Icons.directions),
                      label: const Text('Get Directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
}
