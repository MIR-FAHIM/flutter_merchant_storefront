import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static final primaryColor = HexColor("#1F85E2"); // Vibrant orange
  static final primaryLightColor = HexColor("#BDEFEE"); // Softer orange

  // Backgrounds
  static final backgroundColor = HexColor("#1F222D"); // True dark background

  static final secondbackgroundColor = HexColor("#333749"); // Slightly lighter
  static final thirdbackgroundColor = HexColor("#1F222D"); // Card backgrounds
  static final backgroundBlueColor = HexColor("#00007c");
  // Text colors
  static final homeTextColor1 = HexColor("#FFFFFF"); // White text
  static final homeTextColor2 = HexColor("#E0E0E0"); // Slightly dimmed white
  static final homeTextColor3 = HexColor("#B0B0B0"); // Hint text color

  // Status colors
  static final redTextColor = HexColor("#FF5252"); // Alert red
  static final greenTextColor = HexColor("#00C853"); // Success green

  // Accent
  static final redColor = HexColor("#B70614"); // Amber for highlights

  // Cards and Containers
  static final homeCardBg = HexColor("#1E1E1E"); // Match secondary bg
  static final SectionCardBg = HexColor("#2A2A2A");
  static final tableRowColor = HexColor("#1A1A1A");
  static final SectionHighLightCardBg = HexColor("#333333");

  // Decorative / Gradients
  static final primarydeepLightColor = HexColor("#FFAB40"); // Light orange
  static final dividerColor = HexColor("#2D2D2D"); // Subtle divider

  // Highlight
  static final golden = HexColor("#FFC107"); // Golden yellow

  // Gradient Colors
  static final gradientOne = HexColor("#FF6F00"); // Strong orange
  static final gradientTwo = HexColor("#FF8F00"); // Lighter orange

  // Soft Accents
  static final softPink = HexColor("#FFCDD2"); // Soft warm contrast
  static final softBrwn = HexColor("#4E342E"); // Earthy dark brown

  // Text Utilities
  static Color textAlt = HexColor("#CCCCCC"); // Faded text
  static Color textColorBlack = HexColor("#000000"); // Absolute black
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
