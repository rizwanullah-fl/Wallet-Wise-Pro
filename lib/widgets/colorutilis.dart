import 'package:expenses/controller/color_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ColorUtils {
  static List<Color> generateShades(Color color, int shadeValue) {
    List<Color> shades = [];

    for (int i = 1; i <= 5; i++) {
      Color shade = color.withOpacity(shadeValue * i / 1000);
      shades.add(shade);
    }
    return shades;
  }
}

// final Color selectedColor = Get.find<ColorController>().getSelectedColor();
// final List<Color> colorShades = ColorUtils.generateShades(selectedColor, 200);
// final Color lightcolor = colorShades[0];
// final Color lightprocolor = colorShades[1];
// final Color secondarycolor = colorShades[3];
// final Color firstcolor = colorShades[2];
