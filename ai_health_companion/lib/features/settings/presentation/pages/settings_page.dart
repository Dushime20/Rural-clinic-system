import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/app_header.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _userService = UserService();
  final _auth = AuthService();

  bool _isLoading = true;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final result = await _userService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _profile = result['data'] as Map<String, dynamic>;
      }
    });
  }

  String get _initials {
    final first =
        (_profile?['firstName'] ?? _auth.currentUser?.firstName ?? '')
            .toString();
    final last =
        (_profile?['lastName'] ?? _auth.currentUser?.lastName ?? '').toString();
    return '${first.isNotEmpty ? first[0] : ''}${last.isNotEmpty ? last[0] : ''}'
        .toUpperCase();
  }

  String get _fullName {
    final first = _profile?['firstName'] ?? _auth.currentUser?.firstName ?? '';
    final last = _profile?['lastName'] ?? _auth.currentUser?.lastName ?? '';
    return '$first $last'.trim();
  }

  String get _email => _profile?['email'] ?? _auth.currentUser?.email ?? '';
  String get _role => _profile?['role'] ?? _auth.currentUser?.role.name ?? '';
  String get _phone => _profile?['phoneNumber'] ?? '';
  String get _clinicId =>
      _profile?['clinicId'] ?? _auth.currentUser?.clinicId ?? '';

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'System Administrator';
      case 'health_worker':
        return 'Health Worker';
      case 'clinic_staff':
        return 'Clinic Staff';
      case 'supervisor':
        return 'Supervisor';
      default:
        return role;
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      await _auth.logout();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Settings',
        subtitle: 'Manage your account',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildProfileCard(context),
                    const SizedBox(height: 24),
                    _buildAccountSection(context),
                    const SizedBox(height: 16),
                    _buildAppSection(context),
                    const SizedBox(height: 16),
                    _buildDangerSection(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white,
              child: Text(
                _initials,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _fullName.isEmpty ? 'Loading...' : _fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _email,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatRole(_role),
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (_phone.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                _phone,
                style: const TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
            if (_clinicId.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Clinic: $_clinicId',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditProfileSheet(context),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection('Account', [
      _tile(
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your password',
        onTap: () => context.push('/change-password'),
      ),
      _tile(
        icon: Icons.verified_user_outlined,
        title: 'Account Status',
        subtitle: _profile?['isActive'] == true ? 'Active' : 'Inactive',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color:
                _profile?['isActive'] == true
                    ? AppTheme.successColor.withAlpha(26)
                    : AppTheme.errorColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _profile?['isActive'] == true ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color:
                  _profile?['isActive'] == true
                      ? AppTheme.successColor
                      : AppTheme.errorColor,
            ),
          ),
        ),
        onTap: null,
      ),
      _tile(
        icon: Icons.access_time,
        title: 'Last Login',
        subtitle: _formatDate(_profile?['lastLogin']),
        onTap: null,
        showArrow: false,
      ),
      _tile(
        icon: Icons.calendar_today_outlined,
        title: 'Member Since',
        subtitle: _formatDate(_profile?['createdAt']),
        onTap: null,
        showArrow: false,
      ),
    ]);
  }

  Widget _buildAppSection(BuildContext context) {
    return _buildSection('App', [
      _tile(
        icon: Icons.sync,
        title: 'Sync Status',
        subtitle: 'Manage offline data sync',
        onTap: () => context.go('/sync'),
      ),
      _tile(
        icon: Icons.help_outline,
        title: 'Help & Support',
        subtitle: 'Get help and contact support',
        onTap: () => context.go('/help'),
      ),
      _tile(
        icon: Icons.info_outline,
        title: 'App Version',
        subtitle: AppConstants.appVersion,
        onTap: null,
        showArrow: false,
      ),
    ]);
  }

  Widget _buildDangerSection(BuildContext context) {
    return _buildSection('', [
      _tile(
        icon: Icons.logout,
        title: 'Logout',
        subtitle: 'Sign out of your account',
        color: AppTheme.errorColor,
        onTap: _logout,
      ),
    ]);
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children:
                tiles.asMap().entries.map((e) {
                  return Column(
                    children: [
                      if (e.key > 0) const Divider(height: 1, indent: 56),
                      e.value,
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? color,
    VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryColor).withAlpha(26),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              )
              : null,
      trailing:
          trailing ??
          (showArrow && onTap != null
              ? const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppTheme.textSecondary,
              )
              : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '—';
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  // ── Edit Profile Bottom Sheet ──────────────────────────────────────────────

  void _showEditProfileSheet(BuildContext context) {
    final firstNameCtrl = TextEditingController(
      text: _profile?['firstName'] ?? '',
    );
    final lastNameCtrl = TextEditingController(
      text: _profile?['lastName'] ?? '',
    );
    final phoneCtrl = TextEditingController(
      text: _profile?['phoneNumber'] ?? '',
    );
    final formKey = GlobalKey<FormState>();
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (ctx, setSheetState) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: firstNameCtrl,
                                decoration: InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v!.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: lastNameCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v!.trim().isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed:
                                saving
                                    ? null
                                    : () async {
                                      if (!formKey.currentState!.validate())
                                        return;
                                      setSheetState(() => saving = true);

                                      final result = await _userService
                                          .updateCurrentUser({
                                            'firstName':
                                                firstNameCtrl.text.trim(),
                                            'lastName':
                                                lastNameCtrl.text.trim(),
                                            'phoneNumber':
                                                phoneCtrl.text.trim(),
                                          });

                                      setSheetState(() => saving = false);

                                      if (!mounted) return;
                                      Navigator.pop(ctx);

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['success'] == true
                                                ? 'Profile updated successfully'
                                                : result['message'] ??
                                                    'Update failed',
                                          ),
                                          backgroundColor:
                                              result['success'] == true
                                                  ? AppTheme.successColor
                                                  : AppTheme.errorColor,
                                        ),
                                      );

                                      if (result['success'] == true) {
                                        // Update local auth cache
                                        _auth.updateLocalProfile(
                                          firstName: firstNameCtrl.text.trim(),
                                          lastName: lastNameCtrl.text.trim(),
                                        );
                                        _loadProfile();
                                      }
                                    },
                            icon:
                                saving
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                    : const Icon(Icons.save),
                            label: Text(saving ? 'Saving...' : 'Save Changes'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }
}
