import 'package:flutter/material.dart';
import '../../core/services/location_service.dart';

/// Location Permission Dialog
/// Shows when location permission is needed for clinic/pharmacy search
class LocationPermissionDialog {
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _LocationPermissionDialogContent(),
    );
    return result ?? false;
  }

  static Future<void> showServiceDisabled(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange),
            SizedBox(width: 12),
            Text('Location Services Disabled'),
          ],
        ),
        content: const Text(
          'Location services are turned off. Please enable location services in your device settings to find nearby clinics and pharmacies.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationService().openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  static Future<void> showPermissionDenied(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_disabled_outlined, color: Colors.red),
            SizedBox(width: 12),
            Text('Location Permission Required'),
          ],
        ),
        content: const Text(
          'Location permission is required to find nearby clinics and pharmacies. '
          'Without location access, we cannot show distance or provide navigation.\n\n'
          'You can still view clinics and pharmacies without distance information.',
          style: TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Without Location'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await LocationService().openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

class _LocationPermissionDialogContent extends StatelessWidget {
  const _LocationPermissionDialogContent();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(child: Text('Location Access')),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'We need your location to:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _buildBenefitItem(
            Icons.local_hospital,
            'Find nearby specialized clinics',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            Icons.local_pharmacy,
            'Locate pharmacies with your medicines',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            Icons.navigation,
            'Calculate distance and provide directions',
          ),
          const SizedBox(height: 8),
          _buildBenefitItem(
            Icons.sort,
            'Sort results by proximity',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.privacy_tip_outlined, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your location is only used for search and is never stored or shared.',
                    style: TextStyle(fontSize: 12, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context, true);
            // Permission request will be handled by LocationService
            await LocationService().initialize();
          },
          child: const Text('Allow Location'),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),
        ),
      ],
    );
  }
}
