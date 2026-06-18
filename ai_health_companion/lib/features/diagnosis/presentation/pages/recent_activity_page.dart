import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/dashboard_service.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../../generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final recentDiagnoses = (_stats['recentDiagnoses'] as List?) ?? [];
    final recentPatients = (_stats['recentPatients'] as List?) ?? [];

    // Build all activity items
    final activities = <Map<String, dynamic>>[];
    
    for (final d in recentDiagnoses) {
      activities.add({
        'title': l10n.diagnosisRecorded,
        'subtitle': d['disease'] ?? d['selectedDiagnosis']?['disease'] ?? l10n.unknown,
        'time': _formatTime(d['diagnosisDate'] ?? d['createdAt'], l10n),
        'date': d['diagnosisDate'] ?? d['createdAt'],
        'icon': Icons.psychology,
        'color': AppTheme.primaryColor,
        'type': 'diagnosis',
      });
    }
    
    for (final p in recentPatients) {
      activities.add({
        'title': l10n.patientAdded,
        'subtitle': '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim(),
        'time': _formatTime(p['createdAt'], l10n),
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
      backgroundColor: context.backgroundColor,
      appBar: AppHeader(
        title: l10n.recentActivity,
        subtitle: l10n.viewAll,
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
                            color: context.secondaryTextColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noRecentActivity,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: context.secondaryTextColor,
                                ),
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
                            if (!isLast) Divider(height: 32, color: context.borderColor),
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: context.isDarkMode ? [] : AppTheme.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.chipBackground(color),
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
                        color: context.textColor,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.secondaryTextColor,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.secondaryTextColor,
                ),
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic dateStr, AppLocalizations l10n) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return l10n.minutesAgo(diff.inMinutes);
      if (diff.inHours < 24) return l10n.hoursAgo(diff.inHours);
      return l10n.daysAgo(diff.inDays);
    } catch (_) {
      return '';
    }
  }
}
