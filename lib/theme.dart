// lib/theme.dart
import 'package:flutter/material.dart';

// Brand Colors
const kBrandBlue = Color(0xFF003A60);
const kCardBlue = Color(0xFF0E3856);
const kSuccessGreen = Color(0xFF2E7D32);
const kErrorRed = Color(0xFFC62828);

// Text Colors
const kPrimaryText = Colors.black87;
const kSecondaryText = Colors.black54;

// Input Decoration Theme
InputDecorationTheme _inputDecorationTheme() {
  return InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[500]!, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: kBrandBlue),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1.5, color: kErrorRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 2, color: kErrorRed),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(color: kSecondaryText, fontSize: 14),
    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
    errorStyle: const TextStyle(color: kErrorRed, fontSize: 12),
    filled: true,
    fillColor: Colors.white,
  );
}

// Button Themes
FilledButtonThemeData _filledButtonTheme() {
  return FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey[400];
        return kBrandBlue;
      }),
      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
      minimumSize: WidgetStateProperty.all<Size>(const Size.fromHeight(56)),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}

TextButtonThemeData _textButtonTheme() {
  return TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(kBrandBlue),
      padding: WidgetStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}

OutlinedButtonThemeData _outlinedButtonTheme() {
  return OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all<Color>(kBrandBlue),
      side: WidgetStateProperty.all<BorderSide>(
        BorderSide(color: kBrandBlue, width: 1.5),
      ),
      minimumSize: WidgetStateProperty.all<Size>(const Size.fromHeight(48)),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textStyle: WidgetStateProperty.all<TextStyle>(
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}

// AppBar Theme
AppBarTheme _appBarTheme() {
  return const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: kPrimaryText,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: kBrandBlue, size: 24),
    actionsIconTheme: IconThemeData(color: kBrandBlue, size: 24),
    titleTextStyle: TextStyle(
      color: kBrandBlue,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}

// Dialog Theme Data - FIXED RETURN TYPE
DialogThemeData _dialogTheme() {
  return DialogThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    elevation: 8,
    backgroundColor: Colors.white,
    titleTextStyle: const TextStyle(
      color: kPrimaryText,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(
      color: kSecondaryText,
      fontSize: 14,
    ),
  );
}

// Card Theme Data - FIXED RETURN TYPE
CardThemeData _cardTheme() {
  return CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Colors.white,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    clipBehavior: Clip.antiAlias,
  );
}

// Progress Indicator Theme
ProgressIndicatorThemeData _progressIndicatorTheme() {
  return const ProgressIndicatorThemeData(
    color: kBrandBlue,
    circularTrackColor: Color(0xFFE3F2FD),
  );
}

// SnackBar Theme
SnackBarThemeData _snackBarTheme() {
  return SnackBarThemeData(
    backgroundColor: kBrandBlue,
    contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    behavior: SnackBarBehavior.floating,
    elevation: 6,
  );
}

// Main theme function
ThemeData hmsTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kBrandBlue,
      primary: kBrandBlue,
      secondary: kCardBlue,
      surface: Colors.white,
      background: Colors.grey[50]!,
      error: kErrorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: kPrimaryText,
      onBackground: kPrimaryText,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
  );

  return base.copyWith(
    // Text themes
    textTheme: base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(color: kPrimaryText),
      displayMedium:
          base.textTheme.displayMedium?.copyWith(color: kPrimaryText),
      headlineLarge:
          base.textTheme.headlineLarge?.copyWith(color: kPrimaryText),
      headlineMedium:
          base.textTheme.headlineMedium?.copyWith(color: kPrimaryText),
      headlineSmall:
          base.textTheme.headlineSmall?.copyWith(color: kPrimaryText),
      titleLarge: base.textTheme.titleLarge?.copyWith(color: kPrimaryText),
      titleMedium: base.textTheme.titleMedium?.copyWith(color: kPrimaryText),
      titleSmall: base.textTheme.titleSmall?.copyWith(color: kPrimaryText),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(color: kPrimaryText),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(color: kPrimaryText),
      bodySmall: base.textTheme.bodySmall?.copyWith(color: kSecondaryText),
      labelLarge: base.textTheme.labelLarge?.copyWith(color: kPrimaryText),
      labelMedium: base.textTheme.labelMedium?.copyWith(color: kSecondaryText),
      labelSmall: base.textTheme.labelSmall?.copyWith(color: kSecondaryText),
    ),

    // AppBar
    appBarTheme: _appBarTheme(),

    // Buttons
    filledButtonTheme: _filledButtonTheme(),
    textButtonTheme: _textButtonTheme(),
    outlinedButtonTheme: _outlinedButtonTheme(),

    // Inputs
    inputDecorationTheme: _inputDecorationTheme(),

    // Cards
    cardTheme: _cardTheme(),
    cardColor: Colors.white,

    // Dialogs
    dialogTheme: _dialogTheme(),

    // Snackbar
    snackBarTheme: _snackBarTheme(),

    // Progress indicators
    progressIndicatorTheme: _progressIndicatorTheme(),

    // Icons
    iconTheme: const IconThemeData(color: kBrandBlue, size: 24),
    primaryIconTheme: const IconThemeData(color: Colors.white, size: 24),

    // Divider
    dividerTheme: DividerThemeData(
      color: Colors.grey[300],
      thickness: 1,
      space: 1,
    ),

    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: kBrandBlue,
      unselectedItemColor: kSecondaryText,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    ),
  );
}

// Extension for easy access to theme colors
extension AppThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // Helper to get brand colors
  Color get brandBlue => kBrandBlue;
  Color get successGreen => kSuccessGreen;
  Color get errorRed => kErrorRed;
}
