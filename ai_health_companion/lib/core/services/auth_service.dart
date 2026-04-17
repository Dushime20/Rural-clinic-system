import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../constants/user_roles.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  String? _token;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get userRole => _currentUser?.role;

  // Mock login - Replace with actual API call
  Future<bool> login(String email, String password) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock user data based on email
      UserRole role;
      if (email.contains('admin')) {
        role = UserRole.admin;
      } else if (email.contains('supervisor')) {
        role = UserRole.supervisor;
      } else if (email.contains('staff')) {
        role = UserRole.clinicStaff;
      } else {
        role = UserRole.healthWorker;
      }

      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        firstName: 'John',
        lastName: 'Doe',
        role: role,
        clinicId: 'clinic_001',
        clinicName: 'Kigali Health Center',
        phoneNumber: '+250788123456',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      _token = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      _isAuthenticated = true;

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  bool hasPermission(Permission permission) {
    if (_currentUser == null) return false;
    return _currentUser!.hasPermission(permission);
  }

  bool canAccessFeature(String feature) {
    if (_currentUser == null) return false;
    return _currentUser!.canAccessFeature(feature);
  }

  // Check if user can perform action on resource
  bool canPerformAction(String action, String resource) {
    if (_currentUser == null) return false;

    final permissionMap = {
      'create_patient': Permission.patientCreate,
      'read_patient': Permission.patientRead,
      'update_patient': Permission.patientUpdate,
      'delete_patient': Permission.patientDelete,
      'create_diagnosis': Permission.diagnosisCreate,
      'read_diagnosis': Permission.diagnosisRead,
      'create_prescription': Permission.prescriptionCreate,
      'dispense_prescription': Permission.prescriptionDispense,
      'create_lab_order': Permission.labOrderCreate,
      'view_analytics': Permission.analyticsView,
      'view_audit': Permission.auditLogView,
      'manage_users': Permission.userCreate,
    };

    final key = '${action}_$resource';
    final permission = permissionMap[key];

    if (permission == null) return false;
    return hasPermission(permission);
  }
}
