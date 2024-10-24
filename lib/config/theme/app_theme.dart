import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const colorSeed = Color(0xff424CB8);
const scaffoldBackgroundColor = Color(0xFFF9F7F7);

class AppTheme {
  ThemeData getTheme() {
    return ThemeData(useMaterial3: true, colorSchemeSeed: colorSeed);
  }
}
