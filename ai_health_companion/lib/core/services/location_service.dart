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
    try {
      // Ensure we've requested permission at least once
      if (!_permissionRequested) {
        await initialize();
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationService: Location services disabled');
        return null;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('LocationService: Permission denied, cannot get location');
        return null;
      }

      // Get current position
      debugPrint('LocationService: Getting current position...');
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
        'LocationService: Got position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      debugPrint('LocationService: Error getting location: $e');
      return null;
    }
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
