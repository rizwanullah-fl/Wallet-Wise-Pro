import 'package:expenses/main.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorController extends GetxController {
  Rx<Color> selectedColor = Rx<Color>(Colors.blue);

  @override
  void onInit() {
    super.onInit();
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorHex = prefs.getString('selectedColor') ?? '#FF0000';
    selectedColor.value = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
  }

  Future<void> setSelectedColor(Color color) async {
    selectedColor.value = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'selectedColor', '#${color.value.toRadixString(16).substring(2)}');
    // Rebuild the app after setting the new color
    runApp(MyApp());
  }

  Color getSelectedColor() {
    return selectedColor.value;
  }
}
