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
    chipTheme: ThemeData.dark().chipTheme.copyWith(
          backgroundColor: AppPallete.backgroundColor,
          labelStyle: const TextStyle(
            color: AppPallete.whiteColor,
          ),
          side: BorderSide.none,
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
      border: _boarder(),
      enabledBorder: _boarder(color: AppPallete.borderColor),
      focusedBorder: _boarder(color: AppPallete.gradient2),
      errorBorder: _boarder(color: AppPallete.errorColor),
    ),
    tabBarTheme: ThemeData.dark().tabBarTheme.copyWith(
          tabAlignment: TabAlignment.start,
          labelColor: AppPallete.whiteColor,
          unselectedLabelColor: AppPallete.tabText,
          dividerColor: AppPallete.transparentColor,
          indicatorColor: AppPallete.transparentColor,
          labelStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overlayColor: WidgetStateColor.resolveWith(
            (states) => AppPallete.backgroundColor,
          ),
        ),
  );
}
