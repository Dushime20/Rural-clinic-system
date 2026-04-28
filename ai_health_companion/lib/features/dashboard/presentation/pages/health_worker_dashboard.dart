import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/dashboard_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/quick_action_button.dart';
import '../../../../shared/widgets/app_header.dart';

class HealthWorkerDashboard extends StatefulWidget {
  final UserModel user;

  const HealthWorkerDashboard({super.key, required this.user});

  @override
  State<HealthWorkerDashboard> createState() => _HealthWorkerDashboardState();
}

class _HealthWorkerDashboardState extends State<HealthWorkerDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _error;

  // Real data from API
  Map<String, dynamic> _stats = {};
  List<dynamic> _appointments = [];

  final _dashboardService = DashboardService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait([
      _dashboardService.getDashboardStats(),
      _dashboardService.getTodayAppointments(),
    ]);

    if (!mounted) return;

    final statsResult = results[0];
    final apptResult = results[1];

    setState(() {
      _isLoading = false;
      if (statsResult['success'] == true) {
        _stats = statsResult['data'] as Map<String, dynamic>;
      } else {
        _error = statsResult['message'];
      }
      if (apptResult['success'] == true) {
        final apptData = apptResult['data'];
        _appointments =
            (apptData is List)
                ? apptData
                : (apptData?['appointments'] as List? ?? []);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Health Worker Dashboard',
        subtitle: widget.user.clinicName ?? 'Clinic',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
            tooltip: 'Notifications',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.user.initials,
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Patients'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildPatientsTab();
      case 2:
        return _buildAppointmentsTab();
      default:
        return _buildProfileTab();
    }
  }

  Widget _buildHomeTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final todayAppointments = _stats['todayAppointments'] ?? 0;
    final totalPatients = _stats['totalPatients'] ?? 0;
    final pendingPrescriptions = _stats['pendingPrescriptions'] ?? 0;
    final criticalLabResults = _stats['criticalLabResults'] ?? 0;

    final statCards = [
      {
        'label': 'Patients',
        'value': '$totalPatients',
        'icon': Icons.people,
        'color': AppTheme.primaryColor,
      },
      {
        'label': 'Appts Today',
        'value': '$todayAppointments',
        'icon': Icons.calendar_today,
        'color': AppTheme.warningColor,
      },
      {
        'label': 'Prescriptions',
        'value': '$pendingPrescriptions',
        'icon': Icons.medication,
        'color': AppTheme.secondaryColor,
      },
      {
        'label': 'Critical Labs',
        'value': '$criticalLabResults',
        'icon': Icons.science,
        'color': AppTheme.accentColor,
      },
    ];

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back,',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.user.firstName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$todayAppointments appointment${todayAppointments == 1 ? '' : 's'} today',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.medical_services,
                      size: 60,
                      color: Colors.white24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Today's Stats
            const Text(
              "Today's Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: statCards.length,
              itemBuilder: (context, index) {
                final stat = statCards[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          stat['icon'] as IconData,
                          color: stat['color'] as Color,
                          size: 32,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat['value'] as String,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: stat['color'] as Color,
                              ),
                            ),
                            Text(
                              stat['label'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.person_add,
                    title: 'New Patient',
                    color: AppTheme.primaryColor,
                    onTap: () => Navigator.pushNamed(context, '/add-patient'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.psychology,
                    title: 'AI Diagnosis',
                    color: AppTheme.secondaryColor,
                    onTap: () => Navigator.pushNamed(context, '/diagnosis'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.medication,
                    title: 'Prescription',
                    color: AppTheme.accentColor,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionButton(
                    icon: Icons.science,
                    title: 'Lab Order',
                    color: AppTheme.successColor,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Appointments
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Appointments",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() => _selectedIndex = 2),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_appointments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No appointments today',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ..._appointments.take(5).map((apt) => _buildAppointmentCard(apt)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic apt) {
    final patientName =
        apt['patientName'] ??
        '${apt['patient']?['firstName'] ?? ''} ${apt['patient']?['lastName'] ?? ''}'
            .trim();
    final time = apt['appointmentTime'] ?? apt['time'] ?? '';
    final type = apt['appointmentType'] ?? apt['type'] ?? 'Appointment';
    final status = apt['status'] ?? 'Scheduled';

    final isConfirmed =
        status.toString().toLowerCase() == 'confirmed' ||
        status.toString().toLowerCase() == 'scheduled';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withAlpha(26),
          child: const Icon(Icons.person, color: AppTheme.primaryColor),
        ),
        title: Text(
          patientName.isEmpty ? 'Unknown Patient' : patientName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$time • $type'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                isConfirmed
                    ? Colors.green.withAlpha(26)
                    : Colors.orange.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isConfirmed ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPatientsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Patient List',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/patient-list'),
            child: const Text('View All Patients'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 80, color: AppTheme.textSecondary),
            SizedBox(height: 16),
            Text(
              'No appointments today',
              style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder:
            (context, index) => _buildAppointmentCard(_appointments[index]),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              widget.user.initials,
              style: const TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.user.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.user.role.displayName,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            widget.user.email,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
          if (widget.user.clinicId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Clinic ID: ${widget.user.clinicId}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildProfileOption(
            Icons.settings,
            'Settings',
            () => Navigator.pushNamed(context, '/settings'),
          ),
          _buildProfileOption(
            Icons.help,
            'Help & Support',
            () => Navigator.pushNamed(context, '/help-support'),
          ),
          _buildProfileOption(Icons.logout, 'Logout', () async {
            await AuthService().logout();
            if (mounted)
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (_) => false,
              );
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.primaryColor),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
