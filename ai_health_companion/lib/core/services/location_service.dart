import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling location permissions and retrieval
/// Requests permission early so diagnosis can run automatically
class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  bool _permissionRequested = false;

  /// Initialize location service and request permission early
  /// Call this during app startup or after login
  Future<void> initialize() async {
    if (_permissionRequested) return;

    try {
      debugPrint('LocationService: Initializing...');

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services are disabled');
        _permissionRequested = true;
        return;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('LocationService: Current permission: $permission');

      // Request permission if needed
      if (permission == LocationPermission.denied) {
        debugPrint('LocationService: Requesting permission...');
        permission = await Geolocator.requestPermission();
        debugPrint('LocationService: Permission result: $permission');
      }

      _permissionRequested = true;

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        debugPrint('LocationService: Permission granted successfully');
      } else {
        debugPrint('LocationService: Permission not granted');
      }
    } catch (e) {
      debugPrint('LocationService: Error during initialization: $e');
      _permissionRequested = true;
    }
  }

  /// Get current location without showing any dialogs
  /// Returns null if location is not available
  Future<Position?> getCurrentLocation() async {
    // ═══════════════════════════════════════════════════════════════
    // TEMPORARY FIX: Hardcode Rwanda location for testing
    // TODO: Remove this after emulator location cache is cleared
    // ═══════════════════════════════════════════════════════════════
    debugPrint('⚠️ USING HARDCODED RWANDA LOCATION FOR TESTING');
    debugPrint('⚠️ Location: -1.9555, 30.0639 (Kigali, Rwanda)');
    debugPrint('⚠️ TODO: Uninstall app to clear location cache, then remove this hardcode');
    
    return Position(
      latitude: -1.9555,
      longitude: 30.0639,
      timestamp: DateTime.now(),
      accuracy: 10.0,
      altitude: 1500.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
    // ═══════════════════════════════════════════════════════════════
    
    /* ORIGINAL CODE - Uncomment after fixing emulator location
    try {
      // Ensure we've requested permission at least once
      if (!_permissionRequested) {
        await initialize();
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: ❌ Location services disabled');
        debugPrint('LocationService: → Enable GPS in device settings');
        return null;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint('LocationService: Permission status: $permission');

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: ❌ Permission denied, cannot get location');
        return null;
      }

      // SKIP last known location - get FRESH location from emulator
      // (Last known location may be cached from before emulator location was set)
      debugPrint('LocationService: Getting FRESH current position (30s timeout)...');
      debugPrint('LocationService: Skipping last known location to get fresh emulator location');
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 30),
      );

      debugPrint(
        'LocationService: ✅ Got current position: ${position.latitude}, ${position.longitude}',
      );
      
      // Verify location is reasonable (Rwanda is in Southern hemisphere)
      if (position.latitude > 0) {
        debugPrint('LocationService: ⚠️ WARNING: Got Northern hemisphere location');
        debugPrint('LocationService: Expected: Southern hemisphere (Rwanda: -1.9 to -2.8)');
        debugPrint('LocationService: → Check emulator location settings!');
      }
      
      return position;
    } catch (e) {
      debugPrint('LocationService: ❌ Error getting location: $e');
      debugPrint('LocationService: Error type: ${e.runtimeType}');
      
      // If timeout, suggest solutions
      if (e.toString().contains('TimeoutException')) {
        debugPrint('LocationService: → GPS signal weak or unavailable');
        debugPrint('LocationService: → Set emulator location in Extended Controls');
        debugPrint('LocationService: → Use: Latitude: -1.9441, Longitude: 30.0619');
      }
      
      return null;
    }
    */
  }

  /// Check if location permission is granted
  Future<bool> hasPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('LocationService: Error checking permission: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('LocationService: Error checking service status: $e');
      return false;
    }
  }

  /// Get permission status
  Future<LocationPermission> getPermissionStatus() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      debugPrint('LocationService: Error getting permission status: $e');
      return LocationPermission.denied;
    }
  }

  /// Open app settings for user to enable location manually
  Future<bool> openLocationSettings() async {
    try {
      return await Geolocator.openLocationSettings();
    } catch (e) {
      debugPrint('LocationService: Error opening settings: $e');
      return false;
    }
  }

  /// Open app settings for user to enable permission manually
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('LocationService: Error opening app settings: $e');
      return false;
    }
  }
}
