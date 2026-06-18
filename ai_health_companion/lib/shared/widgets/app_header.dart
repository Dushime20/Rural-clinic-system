import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_extensions.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed:
                    onBackPressed ??
                    () {
                      context.go('/home');
                    },
              )
              : null),
      title:
          subtitle != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                    ),
                  ),
                ],
              )
              : Text(title),
      actions: actions,
      bottom: bottom,
      elevation: 2,
      backgroundColor: context.adaptiveColor(
        lightColor: AppTheme.primaryColor,
        darkColor: const Color(0xFF1E1E1E),
      ),
      foregroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
