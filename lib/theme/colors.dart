import 'package:flutter/material.dart';

class AppColors {
  final Color white;
  final Color black;
  final Color gray;
  final Color background;
  final Color backgroundLight;
  final Color mediumbackground;
  final Color primary;
  final Color accent;
  final Color lightText;
  final Color lightTextFaded;
  final Color drawerDivider;
  final Color red;
  final Color lightBackGround;
  final Color darkTextColor;
  final Color mediumLightText;

  const AppColors({
    required this.white,
    required this.black,
    required this.gray,
    required this.background,
    required this.backgroundLight,
    required this.mediumbackground,
    required this.primary,
    required this.accent,
    required this.lightText,
    required this.lightTextFaded,
    required this.drawerDivider,
    required this.red,
    required this.lightBackGround,
    required this.darkTextColor,
    required this.mediumLightText,
  });

  static const AppColors dark = AppColors(
    white: Color.fromRGBO(255, 255, 255, 1),
    black: Color.fromRGBO(0, 0, 0, 1),
    gray: Color.fromRGBO(84, 84, 84, 1),
    background: Color.fromRGBO(19, 41, 61, 1),
    backgroundLight: Color.fromRGBO(19, 41, 61, 0.8),
    mediumbackground: Color.fromRGBO(47, 133, 170, 1),
    primary: Color.fromRGBO(0, 100, 148, 1),
    accent: Color.fromRGBO(36, 123, 160, 1),
    lightText: Color.fromRGBO(232, 241, 242, 1),
    lightTextFaded: Color.fromRGBO(232, 241, 242, 0.6),
    drawerDivider: Color.fromRGBO(232, 241, 242, 0.2),
    red: Color.fromRGBO(250, 70, 70, 1),
    lightBackGround: Color.fromRGBO(142, 204, 231, 1),
    darkTextColor: Color.fromRGBO(30, 66, 100, 1),
    mediumLightText: Color.fromRGBO(47, 133, 170, 1),
  );

  // Здесь можно добавить другие темы:
  static const AppColors light = AppColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    gray: Color(0xFFAAAAAA),
    background: Color(0xFFF0F0F0),
    backgroundLight: Color(0xFFE0E0E0),
    mediumbackground: Color(0xFFCCCCCC),
    primary: Color(0xFF1976D2),
    accent: Color(0xFF42A5F5),
    lightText: Color(0xFF000000),
    lightTextFaded: Color(0x99000000),
    drawerDivider: Color(0x33000000),
    red: Color(0xFFF44336),
    lightBackGround: Color(0xFFEEEEEE),
    darkTextColor: Color(0xFF333333),
    mediumLightText: Color(0xFF666666),
  );
}
