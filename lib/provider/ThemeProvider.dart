import 'package:flutter/material.dart';
import 'package:smarttalk/theme/colors.dart';
import 'package:smarttalk/theme/theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = AppThemes.darkTheme(AppColors.dark);
  AppColors _currentColorTheme = AppColors.dark;

  ThemeData get currentTheme => _currentTheme;
  AppColors get currentColorTheme => _currentColorTheme;

  void setTheme(ThemeData theme, AppColors colors) {
    _currentTheme = theme;
    _currentColorTheme = colors;
    notifyListeners();
  }
}
