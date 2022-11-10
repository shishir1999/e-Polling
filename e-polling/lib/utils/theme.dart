import 'package:e_polling/constants.dart';
import 'package:e_polling/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EPollingTheme {
  static const Color themeColor = kPrimaryColor;
  static ThemeData light() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xffF6FBFF),
      brightness: Brightness.light,
      primaryColor: themeColor,
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith(
          (states) {
            return kPrimaryColor;
          },
        ),
      ),
      fontFamily: GoogleFonts.raleway().fontFamily,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: themeColor,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.resolveWith((states) => primaryColor),
        ),
      ),
    );
  }
}
