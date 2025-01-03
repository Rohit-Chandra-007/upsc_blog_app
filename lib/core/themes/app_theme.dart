import 'package:flutter/material.dart';

import 'app_color_pallete.dart';

class AppTheme {
  AppTheme._();

  static _boarder({Color color = AppPallete.borderColor}) => OutlineInputBorder(
        borderSide: BorderSide(
          width: 3,
          color: color,
        ),
        borderRadius: BorderRadius.circular(10),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    primaryColor: Colors.purple,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.backgroundColor,
      elevation: 0,
    ),
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Poppins',
        ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: const TextStyle(
        color: AppPallete.greyColor,
        fontSize: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 30,
      ),
      enabledBorder: _boarder(color: AppPallete.borderColor),
      focusedBorder: _boarder(color: AppPallete.gradient2),
      errorBorder: _boarder(color: AppPallete.errorColor),
    ),
  );
}
