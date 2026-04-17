import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class OfflineModePage extends ConsumerStatefulWidget {
  const OfflineModePage({super.key});

  @override
  ConsumerState<OfflineModePage> createState() => _OfflineModePageState();
}

class _OfflineModePageState extends ConsumerState<OfflineModePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;

  bool _isOnline = false;
  int _offlineRecords = 15;
  int _syncedRecords = 1247;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppHeader(
        title: 'Offline Mode',
        subtitle: '$_offlineRecords records pending sync',
        actions: [
          IconButton(
            icon: Icon(_isOnline ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _toggleConnection,
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Card
                    _buildStatusCard(),

                    const SizedBox(height: 24),

                    // Offline Capabilities
                    _buildOfflineCapabilities(),

                    const SizedBox(height: 24),

                    // Data Management
                    _buildDataManagement(),

                    const SizedBox(height: 24),

                    // Sync Information
                    _buildSyncInformation(),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient:
            _isOnline
                ? const LinearGradient(
                  colors: [AppTheme.successColor, Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                : const LinearGradient(
                  colors: [AppTheme.warningColor, Color(0xFFFFB74D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.mediumShadow,
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color:
                        _isOnline
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _isOnline ? 'Online Mode' : 'Offline Mode',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isOnline
                ? 'All features available with cloud sync'
                : 'Working offline - data will sync when online',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineCapabilities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Offline Capabilities',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        _buildCapabilityCard(
          'AI Diagnosis',
          'Perform disease diagnosis using on-device AI model',
          Icons.psychology,
          AppTheme.primaryColor,
          true,
        ),

        const SizedBox(height: 12),

        _buildCapabilityCard(
          'Patient Records',
          'View and manage patient information locally',
          Icons.folder_shared,
          AppTheme.secondaryColor,
          true,
        ),

        const SizedBox(height: 12),

        _buildCapabilityCard(
          'Medical History',
          'Access complete patient medical timeline',
          Icons.history,
          AppTheme.accentColor,
          true,
        ),

        const SizedBox(height: 12),

        _buildCapabilityCard(
          'Data Storage',
          'All data stored securely on device',
          Icons.storage,
          AppTheme.successColor,
          true,
        ),
      ],
    );
  }

  Widget _buildCapabilityCard(
    String title,
    String description,
    IconData icon,
    Color color,
    bool isAvailable,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color:
              isAvailable
                  ? color.withOpacity(0.3)
                  : AppTheme.textDisabled.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  isAvailable
                      ? color.withOpacity(0.1)
                      : AppTheme.textDisabled.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isAvailable ? color : AppTheme.textDisabled,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAvailable ? null : AppTheme.textDisabled,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? AppTheme.successColor : AppTheme.errorColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Data Management',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            children: [
              _buildDataRow(
                'Offline Records',
                _offlineRecords.toString(),
                AppTheme.warningColor,
              ),
              const Divider(),
              _buildDataRow(
                'Synced Records',
                _syncedRecords.toString(),
                AppTheme.successColor,
              ),
              const Divider(),
              _buildDataRow('Storage Used', '2.3 GB', AppTheme.primaryColor),
              const Divider(),
              _buildDataRow(
                'Last Sync',
                _isOnline ? 'Just now' : '2 hours ago',
                _isOnline ? AppTheme.successColor : AppTheme.warningColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sync Information',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'How Sync Works',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildSyncStep(
                '1',
                'Data Collection',
                'All patient data and diagnoses are stored locally on your device',
                Icons.storage,
              ),

              const SizedBox(height: 16),

              _buildSyncStep(
                '2',
                'Automatic Sync',
                'When internet connection is available, data syncs automatically',
                Icons.sync,
              ),

              const SizedBox(height: 16),

              _buildSyncStep(
                '3',
                'Conflict Resolution',
                'Smart algorithms handle data conflicts and ensure data integrity',
                Icons.merge,
              ),

              const SizedBox(height: 16),

              _buildSyncStep(
                '4',
                'Backup & Security',
                'All data is encrypted and backed up to secure cloud servers',
                Icons.security,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStep(
    String number,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppTheme.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isOnline ? _goOffline : _goOnline,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isOnline ? AppTheme.warningColor : AppTheme.successColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: Icon(_isOnline ? Icons.cloud_off : Icons.cloud_done),
            label: Text(
              _isOnline ? 'Switch to Offline Mode' : 'Switch to Online Mode',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isOnline ? _forceSync : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.sync),
            label: const Text(
              'Force Sync Now',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showSyncSettings,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              side: BorderSide(color: AppTheme.textSecondary),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.settings),
            label: const Text(
              'Sync Settings',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleConnection() {
    setState(() {
      _isOnline = !_isOnline;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isOnline ? 'Switched to online mode' : 'Switched to offline mode',
        ),
        backgroundColor:
            _isOnline ? AppTheme.successColor : AppTheme.warningColor,
      ),
    );
  }

  void _goOffline() {
    setState(() {
      _isOnline = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched to offline mode'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  void _goOnline() {
    setState(() {
      _isOnline = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Switched to online mode'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _forceSync() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing data...'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );

    // Simulate sync process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _syncedRecords += _offlineRecords;
        _offlineRecords = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sync completed successfully'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    });
  }

  void _showSyncSettings() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sync Settings'),
            content: const Text('Sync settings will be implemented here.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
