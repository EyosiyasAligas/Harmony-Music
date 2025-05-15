import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The [AppTheme] class defines the light and dark themes for the application,
class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.onPrimaryLight,
      secondary: AppColors.secondaryLight,
      onSecondary: AppColors.onSecondaryLight,
      tertiary: AppColors.tertiaryLight,
      onTertiary: AppColors.onTertiaryLight,
      surface: AppColors.scaffoldBackgroundLight,
      onSurface: AppColors.primaryTextLight,
      error: AppColors.errorLight,
      onError: AppColors.white,
    ),

    scaffoldBackgroundColor: AppColors.scaffoldBackgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarBackgroundLight,
      foregroundColor: AppColors.primaryTextLight,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primaryTextLight),
      titleTextStyle: TextStyle(
        color: AppColors.primaryTextLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBackgroundLight,
      selectedItemColor: AppColors.primaryLight,
      unselectedItemColor: AppColors.secondaryTextLight,
    ),
    dividerColor: AppColors.dividerLight,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.onPrimaryLight,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.onPrimaryDark,
      secondary: AppColors.secondaryDark,
      onSecondary: AppColors.onSecondaryDark,
      tertiary: AppColors.tertiaryDark,
      onTertiary: AppColors.onTertiaryDark,
      surface: AppColors.scaffoldBackgroundDark,
      onSurface: AppColors.primaryTextDark,
      error: AppColors.errorDark,
      onError: AppColors.black,
    ),

    scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarBackgroundDark,
      foregroundColor: AppColors.primaryTextDark,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.primaryTextDark),
      titleTextStyle: TextStyle(
        color: AppColors.primaryTextDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.bottomNavBackgroundDark,
      selectedItemColor: AppColors.primaryDark,
      unselectedItemColor: AppColors.secondaryTextDark,
    ),
    dividerColor: AppColors.dividerDark,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
      ),
    ),
  );
}
