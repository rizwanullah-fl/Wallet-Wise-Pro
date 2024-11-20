import 'package:currency_picker/currency_picker.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/controller/font_controller.dart';
import 'package:expenses/language/local_service.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class Setting extends StatefulWidget {
  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> _languages = [
      {'name': 'Arabic', 'locale': Locale('ar', 'SA')},
      {'name': 'Urdu', 'locale': Locale('ur', 'PK')},
      {'name': 'English', 'locale': Locale('en', 'US')},
    ];
    Map<String, dynamic>? _selectedLanguage;
    @override
    void initState() {
      super.initState();
      _selectedLanguage = _languages[2]; // Default to English
    }

    final CurrencyController currencyController = Get.put(CurrencyController());
    final FontController fontController = Get.put(FontController());
    TextStyler textStyler = TextStyler();
    final HomeController _controller = Get.put(HomeController());
    final LocaleService _localeService = LocaleService();

    return GetBuilder<ColorController>(
      init: ColorController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'setting'.tr,
              style: textStyler.mediumTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _controller.currentTheme.value == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          body: Column(
            children: [
              Obx(() {
                return ListTile(
                  leading: Icon(Icons.color_lens),
                  title: Text(
                    'colorappchange'.tr,
                    style: GoogleFonts.getFont(
                        fontController.selectedFontFamily.value),
                  ),
                  onTap: () {
                    _showColorPickerDialog(context, controller);
                  },
                );
              }),
              Obx(() {
                return ListTile(
                  leading: Icon(Icons.currency_exchange),
                  title: Text(
                    'currency'.tr,
                    style: GoogleFonts.getFont(
                        fontController.selectedFontFamily.value),
                  ),
                  onTap: () {
                    showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      onSelect: (Currency currency) {
                        print('Select currency: ${currency.symbol}');
                        currencyController.setSelectedCurrency(currency.symbol);
                        Navigator.of(context).pop(); // Close the dialog
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }),
              Obx(() {
                return ListTile(
                  leading: Icon(Icons.font_download_rounded),
                  title: Text(
                    'fontstyle'.tr,
                    style: GoogleFonts.getFont(
                      fontController.selectedFontFamily.value,
                    ),
                  ),
                  onTap: () {
                    _showFontPickerDialog(context, fontController);
                  },
                );
              }),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: DropdownButton<Map<String, dynamic>>(
                  value: _selectedLanguage,

                  hint: Row(
                    children: [
                      const Icon(Icons.language),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        'select a language'.tr,
                        style: GoogleFonts.getFont(
                            fontController.selectedFontFamily.value),
                      ),
                    ],
                  ),
                  onChanged: (selectedLanguage) async {
                    if (selectedLanguage != null) {
                      setState(() {
                        _selectedLanguage = selectedLanguage;
                      });
                      await _localeService
                          .saveLocale(selectedLanguage['locale']);
                      Get.updateLocale(selectedLanguage['locale']);
                    }
                  },
                  items: _languages.map((language) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: language,
                      child: Text(
                        language['name'],
                      ),
                    );
                  }).toList(),
                  underline: Container(),
                  // icon: const Icon(Icons.language),
                  isExpanded: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontPickerDialog(
      BuildContext context, FontController fontController) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Font'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                children: _myGoogleFonts.map((font) {
                  return ListTile(
                    title: Text(
                      font,
                      style: GoogleFonts.getFont(font),
                    ),
                    onTap: () {
                      fontController.selectFontFamily(font);
                      print(
                          'Selected Font: ${fontController.selectedFontFamily.value}');
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  final List<String> _myGoogleFonts = [
    "Abril Fatface",
    "Aclonica",
    "Alegreya Sans",
    "Architects Daughter",
    "Archivo",
    "Archivo Narrow",
    "Bebas Neue",
    "Bitter",
    "Bree Serif",
    "Bungee",
    "Cabin",
    "Cairo",
    "Coda",
    "Comfortaa",
    "Comic Neue",
    "Cousine",
    "Croissant One",
    "Faster One",
    "Forum",
    "Great Vibes",
    "Heebo",
    "Inconsolata",
    "Josefin Slab",
    "Lato",
    "Libre Baskerville",
    "Lobster",
    "Lora",
    "Merriweather",
    "Montserrat",
    "Mukta",
    "Nunito",
    "Offside",
    "Open Sans",
    "Oswald",
    "Overlock",
    "Pacifico",
    "Playfair Display",
    "Poppins",
    "Raleway",
    "Roboto",
    "Roboto Mono",
    "Source Sans Pro",
    "Space Mono",
    "Spicy Rice",
    "Squada One",
    "Sue Ellen Francisco",
    "Trade Winds",
    "Ubuntu",
    "Varela",
    "Vollkorn",
    "Work Sans",
    "Zilla Slab",
  ];

  List<Map<String, String>> fontList = [
    {'family': 'Italic', 'asset': 'fonts/Italic.ttf'},
    {'family': 'Jacquard', 'asset': 'fonts/Jacquard.ttf'},
    {'family': 'jersey', 'asset': 'fonts/jersey.ttf'},
    {'family': 'Oswald', 'asset': 'fonts/Oswald.ttf'},
  ];

  void _showColorPickerDialog(
      BuildContext context, ColorController controller) {
    Color? newColor = controller.getSelectedColor();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: controller.getSelectedColor(),
              onColorChanged: (color) {
                newColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                controller.setSelectedColor(newColor!);
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
