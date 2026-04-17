import 'package:flutter/material.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/constants/user_roles.dart';
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

  final List<Map<String, dynamic>> _todayStats = [
    {
      'label': 'Patients Today',
      'value': '12',
      'icon': Icons.people,
      'color': AppTheme.primaryColor,
    },
    {
      'label': 'Pending Diagnoses',
      'value': '3',
      'icon': Icons.pending_actions,
      'color': AppTheme.warningColor,
    },
    {
      'label': 'Prescriptions',
      'value': '8',
      'icon': Icons.medication,
      'color': AppTheme.secondaryColor,
    },
    {
      'label': 'Lab Orders',
      'value': '5',
      'icon': Icons.science,
      'color': AppTheme.accentColor,
    },
  ];

  final List<Map<String, dynamic>> _upcomingAppointments = [
    {
      'time': '09:00 AM',
      'patient': 'Marie Uwase',
      'type': 'Follow-up',
      'status': 'Confirmed',
    },
    {
      'time': '10:30 AM',
      'patient': 'Jean Mugabo',
      'type': 'New Patient',
      'status': 'Waiting',
    },
    {
      'time': '02:00 PM',
      'patient': 'Grace Mutesi',
      'type': 'Check-up',
      'status': 'Confirmed',
    },
  ];

  final List<Map<String, dynamic>> _criticalAlerts = [
    {
      'title': 'Critical Lab Result',
      'patient': 'John Doe',
      'message': 'High blood glucose level detected',
      'time': '30 min ago',
      'priority': 'high',
    },
    {
      'title': 'Medication Stock Low',
      'patient': null,
      'message': 'Amoxicillin stock below threshold',
      'time': '1 hour ago',
      'priority': 'medium',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Health Worker Dashboard',
        subtitle: widget.user.clinicName ?? 'Clinic',
        showBackButton: false,
        actions: [
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
    if (_selectedIndex == 0) {
      return _buildHomeTab();
    } else if (_selectedIndex == 1) {
      return _buildPatientsTab();
    } else if (_selectedIndex == 2) {
      return _buildAppointmentsTab();
    } else {
      return _buildProfileTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
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
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dr. ${widget.user.firstName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You have ${_upcomingAppointments.length} appointments today',
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
            'Today\'s Overview',
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
            itemCount: _todayStats.length,
            itemBuilder: (context, index) {
              final stat = _todayStats[index];
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
                      Icon(stat['icon'], color: stat['color'], size: 32),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['value'],
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: stat['color'],
                            ),
                          ),
                          Text(
                            stat['label'],
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

          // Critical Alerts
          if (_criticalAlerts.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Critical Alerts',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text('View All')),
              ],
            ),
            const SizedBox(height: 12),
            ..._criticalAlerts.map((alert) => _buildAlertCard(alert)),
          ],
          const SizedBox(height: 24),

          // Upcoming Appointments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Appointments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => _selectedIndex = 2),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._upcomingAppointments.map((apt) => _buildAppointmentCard(apt)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    final color = alert['priority'] == 'high' ? Colors.red : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.warning, color: color),
        ),
        title: Text(
          alert['title'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alert['patient'] != null) Text('Patient: ${alert['patient']}'),
            Text(alert['message']),
            Text(
              alert['time'],
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: () {},
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> apt) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: const Icon(Icons.person, color: AppTheme.primaryColor),
        ),
        title: Text(
          apt['patient'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${apt['time']} • ${apt['type']}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                apt['status'] == 'Confirmed'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            apt['status'],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color:
                  apt['status'] == 'Confirmed' ? Colors.green : Colors.orange,
            ),
          ),
        ),
        onTap: () {},
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 16),
          const Text(
            'Appointments',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Manage your appointments'),
        ],
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
          const SizedBox(height: 24),
          _buildProfileOption(Icons.settings, 'Settings', () {
            Navigator.pushNamed(context, '/settings');
          }),
          _buildProfileOption(Icons.help, 'Help & Support', () {
            Navigator.pushNamed(context, '/help-support');
          }),
          _buildProfileOption(Icons.logout, 'Logout', () {}, color: Colors.red),
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
