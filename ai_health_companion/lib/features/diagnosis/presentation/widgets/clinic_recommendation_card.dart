import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/clinic_models.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/app_localizations.dart';

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
        side: BorderSide(
          color: context.adaptiveColor(
            lightColor: Colors.blue.shade100,
            darkColor: Colors.blue.withOpacity(0.3),
          ),
          width: 1,
        ),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
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
                                  color: context.infoColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  clinic.distanceText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: context.secondaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  _buildReasonBadge(context),
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
                      .map((specialty) => _buildSpecialtyChip(context, specialty))
                      .toList(),
                ),

              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: context.secondaryTextColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      clinic.fullAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.secondaryTextColor,
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
                      color: clinic.isOpenNow! ? context.successColor : context.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      clinic.openingStatusText,
                      style: TextStyle(
                        fontSize: 14,
                        color: clinic.isOpenNow! ? context.successColor : context.errorColor,
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
                          foregroundColor: context.infoColor,
                          side: BorderSide(color: context.infoColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 18),
                            SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)!.call,
                              style: TextStyle(fontSize: 14),
                            ),
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
                        backgroundColor: context.infoColor,
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
                          Text(
                            AppLocalizations.of(context)!.navigate,
                            style: TextStyle(fontSize: 14),
                          ),
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

  Widget _buildReasonBadge(BuildContext context) {
    final badgeText = clinic.reasonBadgeText;
    
    Color badgeColor;
    Color textColor;

    // Determine colors based on badge text
    if (badgeText.contains('Recurring')) {
      badgeColor = context.adaptiveColor(
        lightColor: Colors.orange.shade50,
        darkColor: const Color(0xFF3A2A1E),
      );
      textColor = context.adaptiveColor(
        lightColor: Colors.orange.shade700,
        darkColor: const Color(0xFFFFB74D),
      );
    } else if (badgeText.contains('Persistent')) {
      badgeColor = context.adaptiveColor(
        lightColor: Colors.amber.shade50,
        darkColor: const Color(0xFF3A321E),
      );
      textColor = context.adaptiveColor(
        lightColor: Colors.amber.shade800,
        darkColor: const Color(0xFFFFD54F),
      );
    } else if (badgeText.contains('Chronic')) {
      badgeColor = context.adaptiveColor(
        lightColor: Colors.red.shade50,
        darkColor: const Color(0xFF3A1E1E),
      );
      textColor = context.adaptiveColor(
        lightColor: Colors.red.shade700,
        darkColor: const Color(0xFFE57373),
      );
    } else {
      // Default for 'Specialist Care' or other
      badgeColor = context.adaptiveColor(
        lightColor: Colors.blue.shade50,
        darkColor: const Color(0xFF1E2A3A),
      );
      textColor = context.adaptiveColor(
        lightColor: Colors.blue.shade700,
        darkColor: const Color(0xFF64B5F6),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSpecialtyChip(BuildContext context, String specialty) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.chipBackground(context.infoColor),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.adaptiveColor(
            lightColor: Colors.blue.shade200,
            darkColor: context.infoColor.withOpacity(0.5),
          ),
        ),
      ),
      child: Text(
        specialty.replaceAll('_', ' '),
        style: TextStyle(
          fontSize: 12,
          color: context.adaptiveColor(
            lightColor: Colors.blue.shade700,
            darkColor: const Color(0xFF64B5F6),
          ),
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
    final l10n = AppLocalizations.of(context)!;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.modalBackgroundColor,
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
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                clinic.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),

              const SizedBox(height: 8),

              // Distance
              if (clinic.distance != null)
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: context.infoColor),
                    const SizedBox(width: 4),
                    Text(
                      clinic.distanceText,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Specialties section
              Text(
                l10n.specialties,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: clinic.specialties
                    .map((specialty) => _buildSpecialtyChip(context, specialty))
                    .toList(),
              ),

              const SizedBox(height: 20),

              // Address section
              Text(
                l10n.address,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                clinic.fullAddress,
                style: TextStyle(fontSize: 16, color: context.textColor),
              ),

              // Phone section
              if (clinic.phoneNumber != null) ...[
                const SizedBox(height: 20),
                Text(
                  l10n.phoneNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clinic.phoneNumber!,
                  style: TextStyle(fontSize: 16, color: context.textColor),
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
                      color: clinic.isOpenNow! ? context.successColor : context.errorColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      clinic.openingStatusText,
                      style: TextStyle(
                        fontSize: 16,
                        color: clinic.isOpenNow! ? context.successColor : context.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // Reason section
              if (clinic.reason != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Why Recommended',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  clinic.reasonExplanation,
                  style: TextStyle(fontSize: 16, color: context.textColor),
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
                        label: Text(l10n.call),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.infoColor,
                          side: BorderSide(color: context.infoColor),
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
                      label: Text(l10n.getDirections),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.infoColor,
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
