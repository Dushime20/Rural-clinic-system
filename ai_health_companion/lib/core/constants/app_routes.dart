class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String diagnosis = '/diagnosis';
  static const String patients = '/patients';
  static const String patientDetail = '/patient';
  static const String settings = '/settings';
  
  // Helper methods
  static String getPatientDetailRoute(String patientId) => '/patient/$patientId';
}
