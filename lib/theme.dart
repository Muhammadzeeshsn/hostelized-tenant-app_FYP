import 'package:flutter/material.dart';

const kBrandBlue = Color(0xFF003A60); // prototype background
const kCardBlue = Color(
  0xFF0E3856,
); // darker card for gradients/shadows if needed

InputDecorationTheme _inputs(ColorScheme s) => const InputDecorationTheme(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: Color(0xFFB9C3CF)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(width: 1.8, color: kBrandBlue),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
);

ThemeData hmsTheme() {
  final base = ThemeData(useMaterial3: true, colorSchemeSeed: kBrandBlue);
  return base.copyWith(
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: _inputs(base.colorScheme),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kBrandBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: kBrandBlue),
    ),
  );
}
