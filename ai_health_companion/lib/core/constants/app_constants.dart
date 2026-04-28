class AppConstants {
  // App Information
  static const String appName = 'AI Health Companion';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'AI-powered disease diagnosis for rural clinics';

  // API Configuration
  // For Android Emulator: Use 10.0.2.2
  // For iOS Simulator: Use localhost
  // For Physical Device: Use your computer's IP (e.g., 192.168.1.100)
  // For production: Use your actual API URL
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Database Configuration
  static const String databaseName = 'health_companion.db';
  static const int databaseVersion = 1;

  // Hive Box Names
  static const String patientBox = 'patients';
  static const String diagnosisBox = 'diagnoses';
  static const String settingsBox = 'settings';
  static const String syncBox = 'sync_queue';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String lastSyncKey = 'last_sync';
  static const String offlineModeKey = 'offline_mode';

  // AI Model Configuration
  static const String modelPath = 'assets/models/disease_prediction.tflite';
  static const String modelLabelsPath = 'assets/models/labels.txt';
  static const int modelInputSize = 224;
  static const int maxPredictions = 3;

  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 5);

  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxSymptomsPerDiagnosis = 20;
  static const int maxPatientHistoryDays = 365;

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double cardRadius = 12.0;
  static const double buttonRadius = 8.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String offlineError = 'App is in offline mode';
  static const String syncError = 'Failed to sync data';

  // Success Messages
  static const String syncSuccess = 'Data synced successfully';
  static const String diagnosisSuccess = 'Diagnosis completed';
  static const String patientSaved = 'Patient information saved';

  // User Roles
  static const String doctorRole = 'doctor';
  static const String healthWorkerRole = 'health_worker';
  static const String adminRole = 'admin';

  // Disease Categories
  static const List<String> diseaseCategories = [
    'Infectious Diseases',
    'Respiratory Conditions',
    'Cardiovascular Diseases',
    'Digestive Disorders',
    'Neurological Conditions',
    'Skin Conditions',
    'Musculoskeletal Disorders',
    'Endocrine Disorders',
    'Mental Health',
    'Other',
  ];

  // Vital Signs Ranges
  static const Map<String, Map<String, double>> vitalRanges = {
    'temperature': {
      'min': 35.0,
      'max': 42.0,
      'normal_min': 36.1,
      'normal_max': 37.2,
    },
    'blood_pressure_systolic': {
      'min': 70,
      'max': 200,
      'normal_min': 90,
      'normal_max': 120,
    },
    'blood_pressure_diastolic': {
      'min': 40,
      'max': 120,
      'normal_min': 60,
      'normal_max': 80,
    },
    'heart_rate': {'min': 40, 'max': 200, 'normal_min': 60, 'normal_max': 100},
    'respiratory_rate': {
      'min': 8,
      'max': 40,
      'normal_min': 12,
      'normal_max': 20,
    },
    'oxygen_saturation': {
      'min': 70,
      'max': 100,
      'normal_min': 95,
      'normal_max': 100,
    },
  };
}
