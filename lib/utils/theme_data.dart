import 'package:flutter/material.dart';

getThemeData() {
  return ThemeData(
    appBarTheme: AppBarTheme(
      toolbarHeight: 100,
      elevation: 0,
      titleTextStyle: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 20,
          fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(
        color: Colors.grey.shade800, //change your color here
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
          borderRadius: BorderRadius.circular(100.0),
        ),
      ),
    ),
    primarySwatch: Colors.blue,
  );
}
