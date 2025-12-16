import 'package:flutter/material.dart';

import '../colors/app_colors.dart';

class AppDarkTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'SegoeUI',
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.darkSecondary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.whiteColor;
        }
        return Colors.grey.shade400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.darkPrimary;
        }
        return Colors.grey.shade300;
      }),
      trackOutlineColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.transparent;
        }
        return Colors.grey.shade400;
      }),
      overlayColor: MaterialStateProperty.all(
        AppColors.darkPrimary.withOpacity(0.15),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontSize: 16),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
