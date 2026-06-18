import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../generated/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/theme_extensions.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  final bool isFirstTime;

  const ChangePasswordPage({super.key, this.isFirstTime = true});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getPasswordStrength(String password, AppLocalizations l10n) {
    if (password.isEmpty) return '';
    if (password.length < 6) return l10n.passwordWeak;
    if (password.length < 8) return l10n.passwordFair;

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    int strength = 0;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigits) strength++;
    if (hasSpecialCharacters) strength++;

    if (strength >= 3 && password.length >= 10) return l10n.passwordStrong;
    if (strength >= 2 && password.length >= 8) return l10n.passwordGood;
    return l10n.passwordFair;
  }

  Color _getStrengthColor(String strength, AppLocalizations l10n) {
    if (strength == l10n.passwordWeak) return AppTheme.errorColor;
    if (strength == l10n.passwordFair) return Colors.orange;
    if (strength == l10n.passwordGood) return Colors.blue;
    if (strength == l10n.passwordStrong) return AppTheme.successColor;
    return Colors.grey;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final authService = AuthService();
    final result = await authService.changePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.passwordChanged),
                ],
              ),
              content: Text(
                l10n.passwordChangedSuccessMessage,
                style: const TextStyle(fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: Text(l10n.continueButton),
                ),
              ],
            ),
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? l10n.failedToChangePassword),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final passwordStrength = _getPasswordStrength(_newPasswordController.text, l10n);

    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation if first-time password change
        if (widget.isFirstTime) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.mustChangePasswordBeforeContinuing),
              backgroundColor: AppTheme.warningColor,
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back button (only if not first time)
                    if (!widget.isFirstTime)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          iconSize: 28,
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: AppTheme.glowShadow,
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 50,
                        color: AppTheme.primaryColor,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      widget.isFirstTime
                          ? l10n.changeYourPassword
                          : l10n.updatePassword,
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      widget.isFirstTime
                          ? l10n.forSecurityChangePassword
                          : l10n.enterCurrentPasswordChooseNew,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.isFirstTime) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.requiredForFirstTimeLogin,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),

                    // Form
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Current password field
                            TextFormField(
                              controller: _currentPasswordController,
                              obscureText: !_isCurrentPasswordVisible,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.currentPasswordLabel,
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isCurrentPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isCurrentPasswordVisible =
                                          !_isCurrentPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterCurrentPassword;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // New password field
                            TextFormField(
                              controller: _newPasswordController,
                              obscureText: !_isNewPasswordVisible,
                              enabled: !_isLoading,
                              onChanged: (value) => setState(() {}),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.newPasswordLabel,
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isNewPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isNewPasswordVisible =
                                          !_isNewPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterNewPassword;
                                }
                                if (value.length < 8) {
                                  return l10n.passwordMinLength8;
                                }
                                if (value == _currentPasswordController.text) {
                                  return l10n.newPasswordMustBeDifferent;
                                }
                                return null;
                              },
                            ),

                            // Password strength indicator
                            if (_newPasswordController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    l10n.strengthLabel,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    passwordStrength,
                                    style: TextStyle(
                                      color: _getStrengthColor(
                                        passwordStrength,
                                        l10n,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Confirm password field
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              enabled: !_isLoading,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                labelText: l10n.confirmNewPassword,
                                labelStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseConfirmPassword;
                                }
                                if (value != _newPasswordController.text) {
                                  return l10n.passwordsDoNotMatch;
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Submit button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.surfaceColor,
                                    context.cardColor,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSubmit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child:
                                    _isLoading
                                        ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.primaryColor,
                                                ),
                                          ),
                                        )
                                        : Text(
                                          l10n.changePassword,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium?.copyWith(
                                            color: AppTheme.primaryColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
