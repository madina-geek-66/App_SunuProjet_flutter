import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/constants_color.dart';

class ThemeController extends GetxController {
  final RxBool _isDarkMode = false.obs;

  bool get isDarkMode => _isDarkMode.value;

  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

ThemeData lightThemeData(BuildContext context) {
  return ThemeData(
    brightness: Brightness.light,
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: kPrimaryColor,
      iconTheme: const IconThemeData(color: kWhiteColor),
      titleTextStyle: const TextStyle(
          color: kWhiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 20
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: const TextStyle(color: Colors.black87),
      bodySmall: const TextStyle(color: Colors.black54),
      titleMedium: TextStyle(color: Colors.black.withOpacity(0.8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.grey[600]),
      labelStyle: const TextStyle(color: Colors.black54),
      filled: true,
      fillColor: kWhiteColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Colors.black87,
      subtitleTextStyle: TextStyle(color: Colors.black54),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kPrimaryColor,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      background: backgroundColor,
    ),
  );
}

ThemeData darkThemeData(BuildContext context) {
  return ThemeData.dark().copyWith(
    primaryColor: kPrimaryColor,
    scaffoldBackgroundColor: kDarkColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      iconTheme: const IconThemeData(color: kWhiteColor),
      titleTextStyle: const TextStyle(
          color: kWhiteColor,
          fontWeight: FontWeight.bold,
          fontSize: 20
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(color: kWhiteColor.withOpacity(0.87)),
      bodySmall: TextStyle(color: kWhiteColor.withOpacity(0.6)),
      titleMedium: TextStyle(color: kWhiteColor.withOpacity(0.8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(color: kDarkColor.withOpacity(0.6)),
      labelStyle: TextStyle(color: kDarkColor.withOpacity(0.7)),
      filled: true,
      fillColor: Colors.grey[900],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
    cardTheme: CardTheme(
      color: kCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: ListTileThemeData(
      textColor: Colors.white.withOpacity(0.87),
      subtitleTextStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: kWhiteColor,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: kPrimaryColor,
      secondary: kSecondaryColor,
      background: Colors.black,
    ),
  );
}