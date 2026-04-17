import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/app_header.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Settings',
        subtitle: 'Manage your preferences',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppTheme.primaryColor,
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          'Dr. John Smith',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'john.smith@clinic.com',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            // TODO: Navigate to profile edit page
          },
          child: const Text('Edit Profile'),
        ),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildSettingsTile(
          context,
          icon: Icons.sync,
          title: 'Sync Status',
          subtitle: 'Last synced: 2 hours ago',
          onTap: () => context.go('/sync'),
        ),
        _buildSettingsTile(
          context,
          icon: Icons.notifications,
          title: 'Notifications',
          subtitle: 'Manage push notifications',
          onTap: () {},
        ),
        _buildSettingsTile(
          context,
          icon: Icons.color_lens,
          title: 'Theme',
          subtitle: 'Switch between light and dark mode',
          trailing: Switch(
            value: false,
            onChanged: (value) {},
          ), // TODO: Implement theme switching
          onTap: () {},
        ),
        _buildSettingsTile(
          context,
          icon: Icons.language,
          title: 'Language',
          subtitle: 'English',
          onTap: () {},
        ),
        _buildSettingsTile(
          context,
          icon: Icons.security,
          title: 'Security',
          subtitle: 'Manage password and security settings',
          onTap: () {},
        ),
        _buildSettingsTile(
          context,
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () => context.go('/help'),
        ),
        _buildSettingsTile(
          context,
          icon: Icons.info_outline,
          title: 'About',
          onTap: () {},
        ),
        const SizedBox(height: 24),
        _buildSettingsTile(
          context,
          icon: Icons.logout,
          title: 'Logout',
          color: AppTheme.errorColor,
          onTap: () => context.go('/login'),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primaryColor),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: const TextStyle(color: AppTheme.textSecondary),
              )
              : null,
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
