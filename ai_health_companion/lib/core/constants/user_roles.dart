/// User Roles and Permissions
/// Defines all user roles and their associated permissions
/// Compliant with HIPAA, GDPR, and Rwanda Health Data Protection

enum UserRole { admin, healthWorker, clinicStaff, supervisor }

extension UserRoleExtension on UserRole {
  String get name {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.healthWorker:
        return 'HEALTH_WORKER';
      case UserRole.clinicStaff:
        return 'CLINIC_STAFF';
      case UserRole.supervisor:
        return 'SUPERVISOR';
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'System Administrator';
      case UserRole.healthWorker:
        return 'Health Worker';
      case UserRole.clinicStaff:
        return 'Clinic Staff';
      case UserRole.supervisor:
        return 'Supervisor';
    }
  }

  String get description {
    switch (this) {
      case UserRole.admin:
        return 'Full system access and user management';
      case UserRole.healthWorker:
        return 'Doctor, Nurse, or Clinical Officer';
      case UserRole.clinicStaff:
        return 'Receptionist or Pharmacist';
      case UserRole.supervisor:
        return 'Clinical Manager or MoH Official';
    }
  }

  int get hierarchyLevel {
    switch (this) {
      case UserRole.admin:
        return 4;
      case UserRole.supervisor:
        return 3;
      case UserRole.healthWorker:
        return 2;
      case UserRole.clinicStaff:
        return 1;
    }
  }
}

/// Permission types for granular access control
enum Permission {
  // Patient Management
  patientCreate,
  patientRead,
  patientUpdate,
  patientDelete,
  patientExport,

  // Diagnosis
  diagnosisCreate,
  diagnosisRead,
  diagnosisUpdate,
  diagnosisDelete,

  // Prescription
  prescriptionCreate,
  prescriptionRead,
  prescriptionUpdate,
  prescriptionCancel,
  prescriptionDispense,

  // Lab
  labOrderCreate,
  labOrderRead,
  labOrderUpdate,
  labResultCreate,
  labResultRead,
  labResultReview,

  // Appointment
  appointmentCreate,
  appointmentRead,
  appointmentUpdate,
  appointmentCancel,

  // Medication
  medicationCreate,
  medicationRead,
  medicationUpdate,
  medicationStockUpdate,

  // Pharmacy
  pharmacyCheckAvailability,
  pharmacyReserve,

  // User Management
  userCreate,
  userRead,
  userUpdate,
  userDelete,

  // Reports & Analytics
  reportGenerate,
  reportView,
  analyticsView,
  auditLogView,

  // System
  systemConfig,
  notificationSend,
  fhirAccess,
}

/// Permission matrix for each role
class RolePermissions {
  static final Map<UserRole, Set<Permission>> _permissions = {
    UserRole.admin: {
      // Full access
      Permission.patientCreate,
      Permission.patientRead,
      Permission.patientUpdate,
      Permission.patientDelete,
      Permission.patientExport,
      Permission.diagnosisCreate,
      Permission.diagnosisRead,
      Permission.diagnosisUpdate,
      Permission.diagnosisDelete,
      Permission.prescriptionCreate,
      Permission.prescriptionRead,
      Permission.prescriptionUpdate,
      Permission.prescriptionCancel,
      Permission.prescriptionDispense,
      Permission.labOrderCreate,
      Permission.labOrderRead,
      Permission.labOrderUpdate,
      Permission.labResultCreate,
      Permission.labResultRead,
      Permission.labResultReview,
      Permission.appointmentCreate,
      Permission.appointmentRead,
      Permission.appointmentUpdate,
      Permission.appointmentCancel,
      Permission.medicationCreate,
      Permission.medicationRead,
      Permission.medicationUpdate,
      Permission.medicationStockUpdate,
      Permission.pharmacyCheckAvailability,
      Permission.pharmacyReserve,
      Permission.userCreate,
      Permission.userRead,
      Permission.userUpdate,
      Permission.userDelete,
      Permission.reportGenerate,
      Permission.reportView,
      Permission.analyticsView,
      Permission.auditLogView,
      Permission.systemConfig,
      Permission.notificationSend,
      Permission.fhirAccess,
    },
    UserRole.healthWorker: {
      Permission.patientCreate,
      Permission.patientRead,
      Permission.patientUpdate,
      Permission.diagnosisCreate,
      Permission.diagnosisRead,
      Permission.diagnosisUpdate,
      Permission.prescriptionCreate,
      Permission.prescriptionRead,
      Permission.prescriptionUpdate,
      Permission.prescriptionCancel,
      Permission.labOrderCreate,
      Permission.labOrderRead,
      Permission.labOrderUpdate,
      Permission.labResultCreate,
      Permission.labResultRead,
      Permission.appointmentCreate,
      Permission.appointmentRead,
      Permission.appointmentUpdate,
      Permission.appointmentCancel,
      Permission.pharmacyCheckAvailability,
      Permission.pharmacyReserve,
      Permission.notificationSend,
      Permission.fhirAccess,
    },
    UserRole.clinicStaff: {
      Permission.patientCreate,
      Permission.patientRead,
      Permission.patientUpdate,
      Permission.appointmentCreate,
      Permission.appointmentRead,
      Permission.appointmentUpdate,
      Permission.medicationCreate,
      Permission.medicationRead,
      Permission.medicationUpdate,
      Permission.medicationStockUpdate,
      Permission.prescriptionRead,
      Permission.prescriptionDispense,
      Permission.pharmacyCheckAvailability,
      Permission.pharmacyReserve,
      Permission.labOrderRead,
      Permission.labOrderUpdate,
      Permission.notificationSend,
      Permission.fhirAccess,
    },
    UserRole.supervisor: {
      Permission.patientRead,
      Permission.diagnosisRead,
      Permission.prescriptionRead,
      Permission.labOrderRead,
      Permission.labResultRead,
      Permission.labResultReview,
      Permission.appointmentRead,
      Permission.reportGenerate,
      Permission.reportView,
      Permission.analyticsView,
      Permission.auditLogView,
      Permission.fhirAccess,
    },
  };

  static bool hasPermission(UserRole role, Permission permission) {
    return _permissions[role]?.contains(permission) ?? false;
  }

  static Set<Permission> getPermissions(UserRole role) {
    return _permissions[role] ?? {};
  }

  static bool canAccessFeature(UserRole role, String feature) {
    switch (feature) {
      case 'diagnosis':
        return hasPermission(role, Permission.diagnosisCreate);
      case 'prescription':
        return hasPermission(role, Permission.prescriptionCreate);
      case 'lab':
        return hasPermission(role, Permission.labOrderCreate);
      case 'pharmacy':
        return hasPermission(role, Permission.pharmacyCheckAvailability);
      case 'analytics':
        return hasPermission(role, Permission.analyticsView);
      case 'reports':
        return hasPermission(role, Permission.reportGenerate);
      case 'users':
        return hasPermission(role, Permission.userCreate);
      case 'audit':
        return hasPermission(role, Permission.auditLogView);
      default:
        return false;
    }
  }
}
