import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/dashboard_service.dart';
import '../../../../shared/widgets/app_header.dart';

class RecentActivityPage extends ConsumerStatefulWidget {
  const RecentActivityPage({super.key});

  @override
  ConsumerState<RecentActivityPage> createState() => _RecentActivityPageState();
}

class _RecentActivityPageState extends ConsumerState<RecentActivityPage> {
  final _dashboardService = DashboardService();
  bool _isLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() => _isLoading = true);
    final result = await _dashboardService.getDashboardStats();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _stats = result['data'] as Map<String, dynamic>;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentDiagnoses = (_stats['recentDiagnoses'] as List?) ?? [];
    final recentPatients = (_stats['recentPatients'] as List?) ?? [];

    // Build all activity items
    final activities = <Map<String, dynamic>>[];
    
    for (final d in recentDiagnoses) {
      activities.add({
        'title': 'Diagnosis recorded',
        'subtitle': d['disease'] ?? d['selectedDiagnosis']?['disease'] ?? 'Unknown',
        'time': _formatTime(d['diagnosisDate'] ?? d['createdAt']),
        'date': d['diagnosisDate'] ?? d['createdAt'],
        'icon': Icons.psychology,
        'color': AppTheme.primaryColor,
        'type': 'diagnosis',
      });
    }
    
    for (final p in recentPatients) {
      activities.add({
        'title': 'Patient added',
        'subtitle': '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim(),
        'time': _formatTime(p['createdAt']),
        'date': p['createdAt'],
        'icon': Icons.person_add,
        'color': AppTheme.secondaryColor,
        'type': 'patient',
      });
    }

    // Sort by date (most recent first)
    activities.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['date'].toString());
        final dateB = DateTime.parse(b['date'].toString());
        return dateB.compareTo(dateA);
      } catch (_) {
        return 0;
      }
    });

    return Scaffold(
      appBar: AppHeader(
        title: 'Recent Activity',
        subtitle: 'View all recent actions',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadActivity,
              child: activities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: AppTheme.textDisabled,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No recent activity',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your recent diagnoses and patients will appear here',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textDisabled,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];
                        final isLast = index == activities.length - 1;
                        
                        return Column(
                          children: [
                            _buildActivityItem(
                              activity['title'],
                              activity['subtitle'],
                              activity['time'],
                              activity['icon'],
                              activity['color'],
                            ),
                            if (!isLast) const Divider(height: 32),
                          ],
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textDisabled,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (_) {
      return '';
    }
  }
}
