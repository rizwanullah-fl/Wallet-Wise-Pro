import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontController extends GetxController {
  RxString selectedFontFamily = 'Roboto'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSelectedFontFamily();
  }

  Future<void> loadSelectedFontFamily() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedFontFamily.value =
        prefs.getString('selectedFontFamily') ?? 'Roboto';
  }

  Future<void> saveSelectedFontFamily(String fontFamily) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFontFamily', fontFamily);
    selectedFontFamily.value = fontFamily;
  }

  void selectFontFamily(String fontFamily) {
    selectedFontFamily.value = fontFamily;
    saveSelectedFontFamily(fontFamily);
  }
}
