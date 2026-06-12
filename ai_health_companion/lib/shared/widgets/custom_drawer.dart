import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../generated/app_localizations.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Drawer(
      child: Column(
        children: [
          // Simple header with app branding
          Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.medical_services,
                      size: 32,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        l10n.appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.psychology,
                  title: l10n.aiDiagnosis,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/diagnosis');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.people,
                  title: l10n.patientList,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/patients');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_pharmacy,
                  title: l10n.nearbyPharmacies,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/pharmacies');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.local_hospital,
                  title: l10n.clinics,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/clinics');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.analytics,
                  title: l10n.analytics,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/analytics');
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  context,
                  icon: Icons.help_outline,
                  title: l10n.help,
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/help');
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline,
                  title: l10n.about,
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.logout,
                  title: l10n.logout,
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Footer with app version only
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 4),
                Text(
                  'v${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showAboutDialog(
      context: context,
      applicationName: l10n.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.medical_services,
        size: 48,
        color: AppTheme.primaryColor,
      ),
      children: [
        Text(l10n.appDescription),
        const SizedBox(height: 16),
        const Text(
          'This application is designed to assist health workers in rural clinics with AI-powered disease diagnosis.',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }
}

