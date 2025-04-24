import 'package:flutter/material.dart';
import 'colors.dart';

final theme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      titleTextStyle: TextStyle(
        color: AppColors.lightText,
        fontSize: 20,
      ),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      )),
  textTheme: TextTheme(
      labelLarge: TextStyle(
        color: AppColors.lightText,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      labelMedium: TextStyle(
        color: AppColors.lightText,
        fontSize: 14,
      ),
      labelSmall: TextStyle(
        color: AppColors.lightTextFaded,
        fontSize: 10,
      ),
      titleMedium: TextStyle(
        color: AppColors.backgroundLight,
        fontSize: 14,
      )),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(AppColors.lightText),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightBackGround,
    hintStyle: TextStyle(color: AppColors.darkTextColor),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightTextFaded),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.accent, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.red),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.red, width: 2),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.lightText,
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
