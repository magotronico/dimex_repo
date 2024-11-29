import 'package:flutter/material.dart';

class AppTheme {
  static const Color green = Color(0xFF63A532);
  static const Color greenBg = Color.fromARGB(255, 183, 210, 171);
  static const Color background = Color(0xFFF2F2F2);
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color letterBlack = Color(0xFF213333);

  static ThemeData get theme {
    return ThemeData(
      primaryColor: green,
      scaffoldBackgroundColor: background,
      cardColor: foreground,
      colorScheme: ColorScheme.light(
        primary: green,
        onPrimary: foreground,
        secondary: greenBg,
        onSecondary: foreground,
        surface: foreground,
        onSurface: letterBlack,
        error: Colors.red,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: letterBlack),
        bodyMedium: TextStyle(color: letterBlack, fontWeight: FontWeight.bold, fontSize: 15),
        bodySmall: TextStyle(color: letterBlack, fontWeight: FontWeight.w500)
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: green,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: foreground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: foreground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: letterBlack.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: green),
        ),
        labelStyle: TextStyle(color: letterBlack),
      ),
    );
  }
}
