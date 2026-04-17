import 'package:flutter/material.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/services/auth_service.dart';
import 'admin_dashboard.dart';
import 'health_worker_dashboard.dart';
import 'clinic_staff_dashboard.dart';
import 'supervisor_dashboard.dart';

class RoleBasedDashboard extends StatelessWidget {
  final AuthService authService;

  const RoleBasedDashboard({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }

    // Route to appropriate dashboard based on role
    switch (user.role) {
      case UserRole.admin:
        return AdminDashboard(user: user);
      case UserRole.healthWorker:
        return HealthWorkerDashboard(user: user);
      case UserRole.clinicStaff:
        return ClinicStaffDashboard(user: user);
      case UserRole.supervisor:
        return SupervisorDashboard(user: user);
    }
  }
}
