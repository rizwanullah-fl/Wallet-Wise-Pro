import 'package:expenses/screens/bottomScreen/Home.dart';
import 'package:expenses/splashscreen.dart';
import 'package:expenses/widgets/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:expenses/language/local_service.dart';
import 'package:expenses/language/translation.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/font_controller.dart';
import 'package:expenses/controller/transaction_controller.dart';
import 'package:expenses/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ColorController());
  Get.put(CurrencyController());
  Get.put(SummaryController());
  Get.put(FontController());
  Get.put(MyController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final LocaleController localeController = Get.put(LocaleController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        translations: Languages(),
        locale: localeController.locale.value,
        fallbackLocale: const Locale('en', 'US'),
        navigatorObservers: [routeObserver],
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: CustomTheme.lightTheme(),
        darkTheme: CustomTheme.darkTheme(),
        themeMode: ThemeMode.light,
        home: MyHomePage(),
      );
    });
  }
}

class LocaleController extends GetxController {
  var locale = Get.deviceLocale.obs;
  final LocaleService _localeService =
      LocaleService(); // Initialize the locale service

  @override
  void onInit() {
    super.onInit();
    _loadLocale();
  }

  void _loadLocale() async {
    Locale? savedLocale = await _localeService.getSavedLocale();
    locale.value = savedLocale ?? Get.deviceLocale;
  }

  void updateLocale(Locale newLocale) {
    locale.value = newLocale;
    _localeService.saveLocale(newLocale);
  }
}
