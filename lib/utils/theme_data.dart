import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

getThemeData() {
  return ThemeData(
    appBarTheme: AppBarTheme(
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
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
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    ),
    primarySwatch: Colors.blue,
  );
}
