import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/language_provider.dart';
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
    final l10n = AppLocalizations.of(context)!;
    switch (role.toLowerCase()) {
      case 'admin':
        return l10n.systemAdministrator;
      case 'health_worker':
        return l10n.healthWorker;
      case 'clinic_staff':
        return l10n.clinicStaff;
      case 'supervisor':
        return l10n.supervisor;
      default:
        return role;
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(l10n.logout),
            content: Text(l10n.logoutConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: Text(l10n.logout),
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppHeader(
        title: l10n.settings,
        subtitle: l10n.manageYourAccount,
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
            tooltip: l10n.refresh,
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
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
    final l10n = AppLocalizations.of(context)!;
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
              _fullName.isEmpty ? l10n.loading : _fullName,
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
                '${l10n.clinic}: $_clinicId',
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEditProfileSheet(context),
                icon: const Icon(Icons.edit, size: 18),
                label: Text(l10n.editProfile),
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
    final l10n = AppLocalizations.of(context)!;
    return _buildSection(l10n.account, [
      _tile(
        icon: Icons.lock_outline,
        title: l10n.changePassword,
        subtitle: l10n.updateYourPassword,
        onTap: () => context.push('/change-password'),
      ),
      _tile(
        icon: Icons.verified_user_outlined,
        title: l10n.accountStatus,
        subtitle: _profile?['isActive'] == true ? l10n.active : l10n.inactive,
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
            _profile?['isActive'] == true ? l10n.active : l10n.inactive,
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
        title: l10n.lastLogin,
        subtitle: _formatDate(_profile?['lastLogin']),
        onTap: null,
        showArrow: false,
      ),
      _tile(
        icon: Icons.calendar_today_outlined,
        title: l10n.memberSince,
        subtitle: _formatDate(_profile?['createdAt']),
        onTap: null,
        showArrow: false,
      ),
    ]);
  }

  Widget _buildAppSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(isDarkModeProvider);
    final currentLanguage = ref.watch(currentLanguageProvider);

    return _buildSection(l10n.app, [
      _tile(
        icon: isDarkMode ? Icons.dark_mode : Icons.light_mode,
        title: l10n.theme,
        subtitle: isDarkMode ? l10n.darkMode : l10n.lightMode,
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) {
            ref.read(themeModeProvider.notifier).toggleTheme();
          },
          activeColor: AppTheme.primaryColor,
        ),
        onTap: null,
        showArrow: false,
      ),
      _tile(
        icon: Icons.language,
        title: l10n.language,
        subtitle: currentLanguage.nativeName,
        onTap: () => _showLanguageSelector(context),
      ),
      _tile(
        icon: Icons.help_outline,
        title: l10n.helpAndSupport,
        subtitle: l10n.getHelpContactSupport,
        onTap: () => context.go('/help'),
      ),
      _tile(
        icon: Icons.info_outline,
        title: l10n.appVersion,
        subtitle: AppConstants.appVersion,
        onTap: null,
        showArrow: false,
      ),
    ]);
  }

  Widget _buildDangerSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildSection('', [
      _tile(
        icon: Icons.logout,
        title: l10n.logout,
        subtitle: l10n.signOutOfAccount,
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
    final l10n = AppLocalizations.of(context)!;
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
                        Text(
                          l10n.editProfile,
                          style: const TextStyle(
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
                                  labelText: l10n.firstName,
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v!.trim().isEmpty ? l10n.required : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: lastNameCtrl,
                                decoration: InputDecoration(
                                  labelText: l10n.lastName,
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator:
                                    (v) =>
                                        v!.trim().isEmpty ? l10n.required : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: l10n.phoneNumber,
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
                                                ? l10n.profileUpdatedSuccessfully
                                                : result['message'] ??
                                                    l10n.updateFailed,
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
                            label: Text(saving ? l10n.saving : l10n.saveChanges),
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

  // ── Language Selector Bottom Sheet ────────────────────────────────────────

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = ref.read(currentLanguageProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
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
                Text(
                  l10n.selectLanguagePrompt,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.choosePreferredLanguage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Language options
                ...AppLanguage.values.map((language) {
                  final isSelected = currentLanguage == language;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.language,
                        color:
                            isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      language.nativeName,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      language.englishName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.primaryColor,
                            )
                            : null,
                    onTap: () {
                      ref.read(languageProvider.notifier).setLanguage(language);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.languageChangedTo(language.nativeName),
                          ),
                          backgroundColor: AppTheme.successColor,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}
