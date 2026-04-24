import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle get display => GoogleFonts.sora(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
  );

  static TextStyle get headline => GoogleFonts.sora(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
  );

  static TextStyle get title => GoogleFonts.sora(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
  );

  static TextStyle get bodyLarge => GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get body => GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static TextStyle get caption => GoogleFonts.manrope(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static TextStyle get label => GoogleFonts.sora(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
  );

  static TextStyle get labelSmall => GoogleFonts.manrope(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
  );
}
