import 'package:flutter/material.dart';

abstract class ThemeManager {
  static String fontFamily = "Inter";
  static Color seedColor = Colors.blue;

  static ThemeData generateLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      fontFamily: fontFamily,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  static ThemeData generateDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      fontFamily: fontFamily,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
