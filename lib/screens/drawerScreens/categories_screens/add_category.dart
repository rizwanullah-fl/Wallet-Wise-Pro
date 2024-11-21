import 'package:expenses/controller/category_controller.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddCategoryScreen extends StatefulWidget {
  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final Color selectedColor2 = Get.find<ColorController>().getSelectedColor();
  bool showTextFormField = false;
  bool transferCategory = false;
  IconData? selectedIcon;
  Color selectedColor1 = Colors.black;
  final DatabaseHelper db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor2, 200);
    final Color secondarycolor = colorShades[3];
    final TextStyler textStyler = TextStyler();
    final HomeController _controller = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter Card Holder Name',
                controller: categoryController,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter your Description',
                controller: descriptionController,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => pickIcon(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      selectedIcon ?? Icons.search,
                      color: secondarycolor,
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Icon',
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        Text(
                          'Tap to select icon',
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PickColorListTile(
                icon: Icons.palette,
                color: secondarycolor,
                title: 'Pick Color',
                subtitle: 'Select color for your category',
                onPressed: () => showColorPickerDialog(context),
                selectedColor: selectedColor1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wallet,
                    color: secondarycolor,
                  ),
                  SizedBox(width: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Budget',
                          style: textStyler.largeTextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          )),
                      Text('Set budget for category',
                          style: textStyler.largeTextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          )),
                    ],
                  ),
                  Spacer(),
                  SwitchExample(
                    value: showTextFormField,
                    onChanged: (value) {
                      setState(() {
                        showTextFormField = value;
                      });
                    },
                  ),
                ],
              ),
              if (showTextFormField) ...[
                SizedBox(height: 20),
                CustomTextFormField(
                  hintText: 'Enter your Amount',
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  borderRadius: 10.0,
                ),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Transfer Category',
                      style: textStyler.largeTextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      )),
                  SwitchExample(
                    value: transferCategory,
                    onChanged: (value) {
                      setState(() {
                        transferCategory = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: showTextFormField
                    ? MediaQuery.of(context).size.height - 677
                    : MediaQuery.of(context).size.height - 593,
              ),
              CustomElevatedButton(
                onPressed: () async {
                  await saveCategory();
                },
                text: 'ADD',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickIcon(BuildContext context) async {
    // IconData? icon = await showIconPicker(
    //   context,
    //   adaptiveDialog: true,
    //   showTooltips: false,
    //   showSearchBar: true,
    //   iconPickerShape:
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    //   searchComparator: (String search, IconPickerIcon icon) =>
    //       search
    //           .toLowerCase()
    //           .contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
    //       icon.name.toLowerCase().contains(search.toLowerCase()),
    // );
   setState(() {
          selectedIcon = Icons.safety_check;

    });    // if (icon != null) {
    //   setState(() {
    //     selectedIcon = icon;
    //   });
    //   debugPrint('Picked Icon:  $icon');
    // }
  }

  Future<void> showColorPickerDialog(BuildContext context) async {
    Color currentColor = selectedColor1;
    Color? newColor = await showDialog(
      context: context,
      builder: (BuildContext context) {
        Color? pickedColor = currentColor;
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                pickedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(pickedColor);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );

    if (newColor != null) {
      setState(() {
        selectedColor1 = newColor;
      });
    }
  }

  Future<void> saveCategory() async {
    String holderName = categoryController.text;
    String description = descriptionController.text;
    String iconName =
        selectedIcon != null ? selectedIcon!.codePoint.toString() : '';
    String colorName = selectedColor1.value.toString();
    bool budget = showTextFormField;
    String amount = showTextFormField ? amountController.text : 'null';
    bool transfer = transferCategory;

    if (holderName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a name for your category'),
      ));
    } else if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a description for your category'),
      ));
    } else if (iconName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select an icon for your category'),
      ));
    } else if (colorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please select a color for your category'),
      ));
    } else {
      Category category = Category(
        holderName: holderName,
        description: description,
        iconName: iconName,
        colorName: colorName,
        budget: budget ? amount : '0',
        transferCategory: transfer ? 1 : 0,
      );

      try {
        int categoryId = await db.insertCategory(category);
        print('Category saved with id: $categoryId');
        Navigator.pop(context);
        db.loadCategories();
      } catch (e) {
        print('Error saving category: $e');
      }
    }
  }
}
