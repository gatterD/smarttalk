import 'package:flutter/material.dart';

final theme = ThemeData(
  scaffoldBackgroundColor: Color.fromRGBO(19, 41, 61, 1),
  appBarTheme: AppBarTheme(
      backgroundColor: Color.fromRGBO(0, 100, 148, 1),
      titleTextStyle: TextStyle(
        color: Color.fromRGBO(232, 241, 242, 1),
        fontSize: 20,
      )),
  buttonTheme: ButtonThemeData(),
  textTheme: TextTheme(
      labelLarge: TextStyle(
          color: Color.fromRGBO(232, 241, 242, 1),
          fontSize: 16,
          fontWeight: FontWeight.bold),
      labelMedium:
          TextStyle(color: Color.fromRGBO(232, 241, 242, 1), fontSize: 14),
      labelSmall: TextStyle(
        color: Color.fromRGBO(232, 241, 242, 0.6),
        fontSize: 10,
      )),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Color.fromRGBO(36, 123, 160, 1); // Цвет иконки при нажатии
          }
          return Color.fromRGBO(232, 241, 242, 1); // Цвет иконки по умолчанию
        },
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.blue),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide:
          BorderSide(color: const Color.fromRGBO(0, 100, 148, 1), width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.red),
    ),
    filled: true,
    fillColor: Colors.grey[200],
    labelStyle: TextStyle(color: Colors.blue),
    hintStyle: TextStyle(color: Colors.grey),
    errorStyle: TextStyle(color: Colors.red),
  ),
);
