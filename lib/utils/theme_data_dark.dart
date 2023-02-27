import 'package:flutter/material.dart';

getThemeDataDark() {
  return ThemeData.dark().copyWith(
    textTheme: const TextTheme(
        bodyMedium: TextStyle(height: 1.6), titleSmall: TextStyle(height: 1.6)),
    appBarTheme: AppBarTheme(
      elevation: 0,
      titleTextStyle:
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      iconTheme: const IconThemeData(
          // color: Colors.grey.shade800, //change your color here
          ),
      surfaceTintColor: Colors.grey.shade800,
      foregroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
  );
}
