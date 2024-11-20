import 'package:expenses/controller/font_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

final FontController fontController = Get.find<FontController>();

class TextStyler {
  TextStyle largeTextStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 20,
    Color color = Colors.black,
  }) {
    return GoogleFonts.getFont(
      fontController.selectedFontFamily.value,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }

  TextStyle mediumTextStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 16,
    Color color = Colors.black,
    int maxLines = 1, // Add maxLines parameter to limit the number of lines
    TextOverflow overflow = TextOverflow.ellipsis, // Add overflow parameter
  }) {
    return GoogleFonts.getFont(
      fontController.selectedFontFamily.value,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    ).copyWith(
      overflow: overflow, // Apply overflow property
    );
  }

  TextStyle smallTextStyle({
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 12,
    Color color = Colors.black,
  }) {
    return GoogleFonts.getFont(
      fontController.selectedFontFamily.value,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
