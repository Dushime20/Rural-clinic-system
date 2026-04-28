import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/dashboard_service.dart';
import '../../../../shared/widgets/feature_card.dart';
import '../../../../shared/widgets/quick_action_button.dart';
import '../../../../shared/widgets/animated_counter.dart';
import '../../../../shared/widgets/chart_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late AnimationController _floatingController;

  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  final _auth = AuthService();
  final _dashboardService = DashboardService();

  bool _statsLoading = true;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic),
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _cardsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _cardsController, curve: Curves.easeOutCubic),
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _startAnimations() {
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsController.forward();
    });
    _floatingController.repeat(reverse: true);
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _statsLoading = true);
    final result = await _dashboardService.getDashboardStats();
    if (!mounted) return;
    setState(() {
      _statsLoading = false;
      if (result['success'] == true) {
        _stats = result['data'] as Map<String, dynamic>;
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          _buildCustomAppBar(),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(),
                  const SizedBox(height: 32),

                  // Stats Cards
                  _buildStatsSection(),
                  const SizedBox(height: 32),

                  // Quick Actions
                  _buildQuickActionsSection(),
                  const SizedBox(height: 32),

                  // Main Features
                  _buildMainFeaturesSection(),
                  const SizedBox(height: 32),

                  // Analytics Chart
                  _buildAnalyticsSection(),
                  const SizedBox(height: 32),

                  // Recent Activity
                  _buildRecentActivitySection(),
                  const SizedBox(
                    height: 120,
                  ), // Bottom padding for FAB and navigation
                ],
              ),
            ),
          ),
        ],
      ),
      // floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile Avatar
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _headerAnimation.value,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Center(
                            child: Text(
                              _auth.currentUser?.initials ?? '?',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 16),

                  // Greeting
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _headerAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - _headerAnimation.value)),
                          child: Opacity(
                            opacity: _headerAnimation.value,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Good ${_getGreeting()}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withAlpha(230),
                                  ),
                                ),
                                Text(
                                  _auth.currentUser?.fullName ?? 'Welcome',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Notifications
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _headerAnimation.value,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.errorColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.mediumShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Diagnosis Ready',
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Your AI assistant is ready to help with patient diagnosis',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/diagnosis'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Start New Diagnosis',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    final totalPatients = _stats['totalPatients'] ?? 0;
    final totalDiagnoses = _stats['totalDiagnoses'] ?? 0;
    final todayAppointments = _stats['todayAppointments'] ?? 0;

    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child:
                _statsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Patients',
                            '$totalPatients',
                            Icons.people,
                            AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Diagnoses',
                            '$totalDiagnoses',
                            Icons.psychology,
                            AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatCard(
                            'Appts Today',
                            '$todayAppointments',
                            Icons.calendar_today,
                            AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          AnimatedCounter(
            value: int.tryParse(value.replaceAll('%', '')) ?? 0,
            suffix: value.contains('%') ? '%' : '',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: QuickActionButton(
                        title: 'New Patient',
                        icon: Icons.person_add,
                        color: AppTheme.primaryColor,
                        onTap: () {
                          context.go('/patient/add');
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: QuickActionButton(
                        title: 'View Patients',
                        icon: Icons.people,
                        color: AppTheme.secondaryColor,
                        onTap: () => context.go('/patients'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainFeaturesSection() {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 60 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Main Features',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                  children: [
                    FeatureCard(
                      title: 'AI Diagnosis',
                      description: 'Get AI-powered disease predictions',
                      icon: Icons.psychology,
                      color: AppTheme.primaryColor,
                      onTap: () => context.go('/diagnosis'),
                    ),
                    FeatureCard(
                      title: 'Patient Records',
                      description: 'Manage patient information',
                      icon: Icons.folder_shared,
                      color: AppTheme.secondaryColor,
                      onTap: () => context.go('/patients'),
                    ),
                    FeatureCard(
                      title: 'Offline Mode',
                      description: 'Work without internet',
                      icon: Icons.offline_bolt,
                      color: AppTheme.accentColor,
                      onTap: () {
                        context.go('/offline');
                      },
                    ),
                    FeatureCard(
                      title: 'Analytics',
                      description: 'View health statistics',
                      icon: Icons.analytics,
                      color: AppTheme.successColor,
                      onTap: () {
                        // TODO: Navigate to analytics
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection() {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 70 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics,
                        color: AppTheme.primaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Weekly Analytics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(height: 200, child: ChartWidget()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivitySection() {
    final recentDiagnoses = (_stats['recentDiagnoses'] as List?) ?? [];
    final recentPatients = (_stats['recentPatients'] as List?) ?? [];

    // Build activity items from real data
    final activities = <Map<String, dynamic>>[];
    for (final d in recentDiagnoses.take(2)) {
      activities.add({
        'title': 'Diagnosis recorded',
        'subtitle':
            d['disease'] ?? d['selectedDiagnosis']?['disease'] ?? 'Unknown',
        'time': _formatTime(d['diagnosisDate'] ?? d['createdAt']),
        'icon': Icons.psychology,
        'color': AppTheme.primaryColor,
      });
    }
    for (final p in recentPatients.take(2)) {
      activities.add({
        'title': 'Patient added',
        'subtitle': '${p['firstName'] ?? ''} ${p['lastName'] ?? ''}'.trim(),
        'time': _formatTime(p['createdAt']),
        'icon': Icons.person_add,
        'color': AppTheme.secondaryColor,
      });
    }

    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 80 * (1 - _cardsAnimation.value)),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(onPressed: () {}, child: const Text('View All')),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child:
                      activities.isEmpty
                          ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No recent activity',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ),
                          )
                          : Column(
                            children:
                                activities
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => Column(
                                        children: [
                                          if (e.key > 0) const Divider(),
                                          _buildActivityItem(
                                            e.value['title'],
                                            e.value['subtitle'],
                                            e.value['time'],
                                            e.value['icon'],
                                            e.value['color'],
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr.toString());
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  // Widget _buildFloatingActionButton() {
  //   return AnimatedBuilder(
  //     animation: _floatingController,
  //     builder: (context, child) {
  //       return Transform.scale(
  //         scale: 1.0 + (_floatingAnimation.value * 0.05),
  //         child: FloatingActionButton.extended(
  //           onPressed: () => context.go('/diagnosis'),
  //           backgroundColor: const Color.fromARGB(255, 125, 46, 66),
  //           icon: const Icon(Icons.add),
  //           label: const Text('New Diagnosis'),
  //           elevation: 8,
  //         ),
  //       );
  //     },
  //   );
  // }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
