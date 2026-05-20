class DashboardAnalytics {
  final int totalUsers;
  final int activeUsers;
  final int totalPatients;
  final int totalDiagnoses;
  final int totalAppointments;
  final int todayAppointments;
  final int totalMedications;
  final int lowStockCount;
  final int pendingPrescriptions;
  final int criticalLabResults;
  final List<DiseaseTrend> diseaseTrends;
  final List<TopDisease> topDiseases;
  final List<RoleDistribution> roleDistribution;
  final List<AppointmentTrend> appointmentTrends;
  final List<RecentDiagnosis> recentDiagnoses;
  final List<RecentPatient> recentPatients;

  DashboardAnalytics({
    required this.totalUsers,
    required this.activeUsers,
    required this.totalPatients,
    required this.totalDiagnoses,
    required this.totalAppointments,
    required this.todayAppointments,
    required this.totalMedications,
    required this.lowStockCount,
    required this.pendingPrescriptions,
    required this.criticalLabResults,
    required this.diseaseTrends,
    required this.topDiseases,
    required this.roleDistribution,
    required this.appointmentTrends,
    required this.recentDiagnoses,
    required this.recentPatients,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      totalUsers: json['totalUsers'] ?? 0,
      activeUsers: json['activeUsers'] ?? 0,
      totalPatients: json['totalPatients'] ?? 0,
      totalDiagnoses: json['totalDiagnoses'] ?? 0,
      totalAppointments: json['totalAppointments'] ?? 0,
      todayAppointments: json['todayAppointments'] ?? 0,
      totalMedications: json['totalMedications'] ?? 0,
      lowStockCount: json['lowStockCount'] ?? 0,
      pendingPrescriptions: json['pendingPrescriptions'] ?? 0,
      criticalLabResults: json['criticalLabResults'] ?? 0,
      diseaseTrends: (json['diseaseTrends'] as List?)
              ?.map((e) => DiseaseTrend.fromJson(e))
              .toList() ??
          [],
      topDiseases: (json['topDiseases'] as List?)
              ?.map((e) => TopDisease.fromJson(e))
              .toList() ??
          [],
      roleDistribution: (json['roleDistribution'] as List?)
              ?.map((e) => RoleDistribution.fromJson(e))
              .toList() ??
          [],
      appointmentTrends: (json['appointmentTrends'] as List?)
              ?.map((e) => AppointmentTrend.fromJson(e))
              .toList() ??
          [],
      recentDiagnoses: (json['recentDiagnoses'] as List?)
              ?.map((e) => RecentDiagnosis.fromJson(e))
              .toList() ??
          [],
      recentPatients: (json['recentPatients'] as List?)
              ?.map((e) => RecentPatient.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DiseaseTrend {
  final String month;
  final Map<String, int> diseaseCounts;

  DiseaseTrend({
    required this.month,
    required this.diseaseCounts,
  });

  factory DiseaseTrend.fromJson(Map<String, dynamic> json) {
    final month = json['month'] as String;
    final diseaseCounts = <String, int>{};
    
    json.forEach((key, value) {
      if (key != 'month' && value is int) {
        diseaseCounts[key] = value;
      }
    });

    return DiseaseTrend(
      month: month,
      diseaseCounts: diseaseCounts,
    );
  }
}

class TopDisease {
  final String name;
  final String key;

  TopDisease({
    required this.name,
    required this.key,
  });

  factory TopDisease.fromJson(Map<String, dynamic> json) {
    return TopDisease(
      name: json['name'] ?? '',
      key: json['key'] ?? '',
    );
  }
}

class RoleDistribution {
  final String name;
  final int value;
  final String color;

  RoleDistribution({
    required this.name,
    required this.value,
    required this.color,
  });

  factory RoleDistribution.fromJson(Map<String, dynamic> json) {
    return RoleDistribution(
      name: json['name'] ?? '',
      value: json['value'] ?? 0,
      color: json['color'] ?? '#000000',
    );
  }
}

class AppointmentTrend {
  final String day;
  final int scheduled;
  final int completed;
  final int cancelled;

  AppointmentTrend({
    required this.day,
    required this.scheduled,
    required this.completed,
    required this.cancelled,
  });

  factory AppointmentTrend.fromJson(Map<String, dynamic> json) {
    return AppointmentTrend(
      day: json['day'] ?? '',
      scheduled: json['scheduled'] ?? 0,
      completed: json['completed'] ?? 0,
      cancelled: json['cancelled'] ?? 0,
    );
  }
}

class RecentDiagnosis {
  final String disease;
  final String diagnosisDate;
  final String createdAt;

  RecentDiagnosis({
    required this.disease,
    required this.diagnosisDate,
    required this.createdAt,
  });

  factory RecentDiagnosis.fromJson(Map<String, dynamic> json) {
    return RecentDiagnosis(
      disease: json['disease'] ?? 'Unknown',
      diagnosisDate: json['diagnosisDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class RecentPatient {
  final String firstName;
  final String lastName;
  final String createdAt;

  RecentPatient({
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  factory RecentPatient.fromJson(Map<String, dynamic> json) {
    return RecentPatient(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}

class PatientDemographics {
  final int totalPatients;
  final GenderDistribution genderDistribution;
  final Map<String, int> ageDistribution;

  PatientDemographics({
    required this.totalPatients,
    required this.genderDistribution,
    required this.ageDistribution,
  });

  factory PatientDemographics.fromJson(Map<String, dynamic> json) {
    return PatientDemographics(
      totalPatients: json['totalPatients'] ?? 0,
      genderDistribution: GenderDistribution.fromJson(
        json['genderDistribution'] ?? {},
      ),
      ageDistribution: Map<String, int>.from(json['ageDistribution'] ?? {}),
    );
  }
}

class GenderDistribution {
  final int male;
  final int female;
  final int other;

  GenderDistribution({
    required this.male,
    required this.female,
    required this.other,
  });

  factory GenderDistribution.fromJson(Map<String, dynamic> json) {
    return GenderDistribution(
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
      other: json['other'] ?? 0,
    );
  }

  int get total => male + female + other;
}
