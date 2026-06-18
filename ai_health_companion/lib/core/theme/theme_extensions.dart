import 'package:flutter/material.dart';

/// Extension to get theme-aware colors
extension ThemeExtension on BuildContext {
  /// Get brightness
  Brightness get brightness => Theme.of(this).brightness;

  /// Check if dark mode
  bool get isDarkMode => brightness == Brightness.dark;

  /// Get theme-aware surface color
  Color get surfaceColor => Theme.of(this).colorScheme.surface;

  /// Get theme-aware background color  
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  /// Get theme-aware card color
  Color get cardColor => Theme.of(this).cardTheme.color ?? surfaceColor;

  /// Get theme-aware text color
  Color get textColor => Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;

  /// Get theme-aware secondary text color
  Color get secondaryTextColor =>
      Theme.of(this).textTheme.bodySmall?.color ?? Colors.grey;

  /// Get theme-aware primary color
  Color get primaryColor => Theme.of(this).colorScheme.primary;

  /// Get theme-aware secondary color
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;

  /// Get theme-aware error color
  Color get errorColor => Theme.of(this).colorScheme.error;

  /// Get theme-aware divider color
  Color get dividerColor => Theme.of(this).dividerColor;

  /// Get adaptive color (light/dark mode aware)
  Color adaptiveColor({
    required Color lightColor,
    required Color darkColor,
  }) {
    return isDarkMode ? darkColor : lightColor;
  }

  /// Get theme-aware container color
  Color get containerColor => adaptiveColor(
        lightColor: Colors.grey.shade100,
        darkColor: const Color(0xFF2C2C2C),
      );

  /// Get theme-aware border color
  Color get borderColor => adaptiveColor(
        lightColor: Colors.grey.shade200,
        darkColor: const Color(0xFF3C3C3C),
      );

  /// Get theme-aware icon color
  Color get iconColor => adaptiveColor(
        lightColor: Colors.grey.shade600,
        darkColor: Colors.grey.shade400,
      );

  /// Get theme-aware success color
  Color get successColor => adaptiveColor(
        lightColor: const Color(0xFF388E3C),
        darkColor: const Color(0xFF66BB6A),
      );

  /// Get theme-aware warning color
  Color get warningColor => adaptiveColor(
        lightColor: const Color(0xFFF57C00),
        darkColor: const Color(0xFFFFB74D),
      );

  /// Get theme-aware info color
  Color get infoColor => adaptiveColor(
        lightColor: const Color(0xFF2196F3),
        darkColor: const Color(0xFF64B5F6),
      );

  /// Get theme-aware chip background
  Color chipBackground(Color baseColor) {
    return isDarkMode
        ? baseColor.withOpacity(0.2)
        : baseColor.withOpacity(0.1);
  }

  /// Get theme-aware overlay color
  Color get overlayColor => adaptiveColor(
        lightColor: Colors.black.withOpacity(0.5),
        darkColor: Colors.black.withOpacity(0.7),
      );

  /// Get theme-aware modal background
  Color get modalBackgroundColor => adaptiveColor(
        lightColor: Colors.white,
        darkColor: const Color(0xFF1E1E1E),
      );

  /// Get theme-aware search field color
  Color get searchFieldColor => adaptiveColor(
        lightColor: Colors.grey.shade100,
        darkColor: const Color(0xFF2C2C2C),
      );

  /// Get theme-aware avatar background
  Color get avatarBackgroundColor => adaptiveColor(
        lightColor: Colors.white,
        darkColor: const Color(0xFF2C2C2C),
      );

  /// Get theme-aware shadow color
  Color get shadowColor => adaptiveColor(
        lightColor: Colors.black.withOpacity(0.1),
        darkColor: Colors.transparent,
      );

  /// Get theme-aware snackbar background based on type
  Color snackbarBackground(SnackbarType type) {
    switch (type) {
      case SnackbarType.error:
        return errorColor;
      case SnackbarType.success:
        return successColor;
      case SnackbarType.warning:
        return warningColor;
      case SnackbarType.info:
        return infoColor;
    }
  }

  /// Get theme-aware primary gradient (for headers, banners, etc.)
  LinearGradient get primaryGradient {
    if (isDarkMode) {
      // In dark mode, use dark surface colors instead of green
      return LinearGradient(
        colors: [
          const Color(0xFF1E1E1E),
          const Color(0xFF2C2C2C),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    } else {
      // Light mode - keep the green gradient
      return const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF4CAF50), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.5, 1.0],
      );
    }
  }

  /// Get theme-aware elevated button background
  Color elevatedButtonBackground(Color baseColor) {
    return isDarkMode ? baseColor.withOpacity(0.9) : baseColor;
  }

  /// Get theme-aware outlined button border
  Color outlinedButtonBorder(Color baseColor) {
    return isDarkMode ? baseColor.withOpacity(0.8) : baseColor;
  }
}

/// Snackbar types
enum SnackbarType {
  error,
  success,
  warning,
  info,
}

/// Extension for color adaptations
extension ColorExtension on Color {
  /// Make color theme-aware for backgrounds
  Color forBackground(BuildContext context) {
    return context.isDarkMode ? withOpacity(0.2) : withOpacity(0.1);
  }

  /// Make color theme-aware for text
  Color forText(BuildContext context) {
    return context.isDarkMode ? withOpacity(0.9) : this;
  }

  /// Make color darker/lighter based on theme
  Color adaptive(BuildContext context) {
    if (context.isDarkMode) {
      // Lighten color in dark mode
      return Color.lerp(this, Colors.white, 0.2) ?? this;
    } else {
      // Keep original in light mode
      return this;
    }
  }
}
