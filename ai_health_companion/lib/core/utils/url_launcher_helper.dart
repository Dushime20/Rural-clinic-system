import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

/// Helper class for launching external URLs, phone calls, and maps
class UrlLauncherHelper {
  /// Make a phone call to the given phone number
  static Future<void> makePhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    try {
      // Remove any spaces or special characters except + and digits
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not launch phone dialer');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error making phone call: $e');
      }
    }
  }

  /// Open Google Maps with the given coordinates
  static Future<void> openMaps(
    BuildContext context,
    double latitude,
    double longitude, {
    String? label,
  }) async {
    try {
      // Try Google Maps app first (Android/iOS)
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      // Alternative: Apple Maps for iOS
      final appleMapsUrl = Uri.parse(
        'https://maps.apple.com/?q=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open maps application');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening maps: $e');
      }
    }
  }

  /// Open navigation to the given coordinates
  static Future<void> navigateTo(
    BuildContext context,
    double latitude,
    double longitude, {
    String? destinationName,
  }) async {
    try {
      // Google Maps navigation URL
      final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open navigation');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening navigation: $e');
      }
    }
  }

  /// Send an SMS to the given phone number
  static Future<void> sendSMS(
    BuildContext context,
    String phoneNumber, {
    String? message,
  }) async {
    try {
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final uri = Uri(
        scheme: 'sms',
        path: cleanNumber,
        queryParameters: message != null ? {'body': message} : null,
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open SMS app');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error sending SMS: $e');
      }
    }
  }

  /// Open a website URL
  static Future<void> openWebsite(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open website');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening website: $e');
      }
    }
  }

  /// Open email client
  static Future<void> sendEmail(
    BuildContext context,
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          if (subject != null) 'subject': subject,
          if (body != null) 'body': body,
        },
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showError(context, 'Could not open email app');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'Error opening email: $e');
      }
    }
  }

  /// Show error message to user
  static void _showError(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show confirmation dialog before making a call
  static Future<bool> confirmPhoneCall(
    BuildContext context,
    String phoneNumber,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Make Phone Call'),
                content: Text('Call $phoneNumber?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Call'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  /// Show options dialog for contacting pharmacy
  static Future<void> showContactOptions(
    BuildContext context, {
    required String pharmacyName,
    String? phoneNumber,
    required double latitude,
    required double longitude,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder:
          (bottomSheetContext) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    pharmacyName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                if (phoneNumber != null)
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: const Text('Call Pharmacy'),
                    subtitle: Text(phoneNumber),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      if (context.mounted) {
                        makePhoneCall(context, phoneNumber);
                      }
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.blue),
                  title: const Text('View on Map'),
                  subtitle: const Text('Open in maps app'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    if (context.mounted) {
                      openMaps(
                        context,
                        latitude,
                        longitude,
                        label: pharmacyName,
                      );
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.navigation, color: Colors.orange),
                  title: const Text('Get Directions'),
                  subtitle: const Text('Navigate to pharmacy'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    if (context.mounted) {
                      navigateTo(
                        context,
                        latitude,
                        longitude,
                        destinationName: pharmacyName,
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}
