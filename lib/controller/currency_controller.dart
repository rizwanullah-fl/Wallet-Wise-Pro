import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyController extends GetxController {
  RxString selectedCurrency = 'Rs'.obs;

  @override
  void onInit() {
    super.onInit();
    // Load the selected currency from SharedPreferences when the controller is initialized
    loadSelectedCurrency();
  }

  Future<void> loadSelectedCurrency() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedCurrency.value = prefs.getString('selectedCurrency') ?? '';
  }

  Future<void> saveSelectedCurrency(String currency) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCurrency', currency);
    selectedCurrency.value = currency;
  }

  void setSelectedCurrency(String currency) {
    saveSelectedCurrency(currency);
  }
}
