import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

abstract class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    fontFamily: 'Cairo',
    useMaterial3: true,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    focusColor: AppColors.primary,
    canvasColor: AppColors.whiteColor,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.whiteColor,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.whiteColor,
    ),

    appBarTheme: appBarTheme,

    textTheme: TextTheme(
      headlineLarge: AppStyles.bold22Black,
      headlineMedium: AppStyles.bold20Black,
      headlineSmall: AppStyles.bold18Black,
      titleLarge: AppStyles.semi16Black,
      titleMedium: AppStyles.regular16Black,
      bodyLarge: AppStyles.regular16Grey,
      bodyMedium: AppStyles.regular14Black,
      bodySmall: AppStyles.regular14Grey,
      labelLarge: AppStyles.bold16White,
      labelMedium: AppStyles.bold14Primary,
      labelSmall: AppStyles.regular12Grey,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.whiteColor,
        minimumSize: const Size(double.infinity, 52),
        textStyle: AppStyles.bold16White,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(double.infinity, 52),
        textStyle: AppStyles.bold16Primary,
        side: const BorderSide(color: AppColors.primary, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppStyles.semi14Primary,
        minimumSize: const Size(0, 48),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.whiteColor,
      hintStyle: AppStyles.hint14,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.whiteColor,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.whiteColor;
      }),
      checkColor: WidgetStateProperty.all(AppColors.whiteColor),
      side: const BorderSide(color: AppColors.borderColor, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.whiteColor,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textHint,
      selectedLabelStyle: AppStyles.bold12Grey,
      unselectedLabelStyle: AppStyles.regular12Grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    dividerTheme: const DividerThemeData(
      color: AppColors.borderColor,
      thickness: 1,
      space: 16,
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.primaryLighter,
      linearMinHeight: 6,
    ),
  );

  static final AppBarTheme appBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: AppColors.whiteColor,
    titleTextStyle: AppStyles.bold20Black,
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    actionsIconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
  );
}
