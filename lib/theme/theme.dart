import 'package:flutter/material.dart';
import 'colors.dart';

class AppThemes {
  static ThemeData darkTheme(AppColors colors) => ThemeData(
        scaffoldBackgroundColor: colors.background,
        appBarTheme: AppBarTheme(
          backgroundColor: colors.primary,
          titleTextStyle: TextStyle(
            color: colors.lightText,
            fontSize: 20,
          ),
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
        ),
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: colors.lightText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          labelLarge: TextStyle(
            color: colors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          labelMedium: TextStyle(
            color: colors.lightText,
            fontSize: 14,
          ),
          labelSmall: TextStyle(
            color: colors.lightTextFaded,
            fontSize: 10,
          ),
          titleMedium: TextStyle(
            color: colors.backgroundLight,
            fontSize: 14,
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(colors.lightText),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.lightBackGround,
          hintStyle: TextStyle(color: colors.darkTextColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.lightTextFaded),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.accent, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.red),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.red, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.lightText,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            elevation: 4,
          ),
        ),
      );
}
