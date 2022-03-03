import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

late String? _fontFamily = GoogleFonts.poppins().fontFamily;

var themeLight = FlexThemeData.light(
  primary: const Color(0xFF005691),
  secondary: const Color(0xFF005691),
  scaffoldBackground: const Color(0xFFFAFAFA),
  textTheme: _textTheme,
  fontFamily: _fontFamily,
);

var themeDark = FlexThemeData.dark();

const TextTheme _textTheme = TextTheme(
  headline2: TextStyle(
    fontSize: 26,
  ),
  headline3: TextStyle(
    fontSize: 22,
  ),
  headline4: TextStyle(
    fontSize: 16,
  ),
  headline5: TextStyle(
    fontSize: 14,
  ),
  headline6: TextStyle(
    fontSize: 12,
  ),
  overline: TextStyle(fontSize: 11, letterSpacing: 0.5),
);
