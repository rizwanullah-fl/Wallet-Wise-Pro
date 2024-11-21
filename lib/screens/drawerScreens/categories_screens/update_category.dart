import 'package:expenses/controller/category_controller.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/screens/bottomScreen/home_widgets.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UpdateCategory extends StatefulWidget {
  final int index;

  const UpdateCategory({super.key, required this.index});

  @override
  State<UpdateCategory> createState() => _UpdateCategoryState();
}

class _UpdateCategoryState extends State<UpdateCategory> {
  bool isAdaptive = true;
  bool showTooltips = false;
  bool showSearch = true;
  bool transferCategory = false;

  IconData? selectedIcon;
  Color? selectedColor;
  final TextEditingController category = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final DatabaseHelper databaseHelper = DatabaseHelper();

  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();
  bool showTextFormField = false;
  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  Future<void> _loadCategoryData() async {
    // Fetch the category data based on the given index
    Category? categories = await databaseHelper.getcategoryByid(widget.index);
    print(categories);
    IconData iconData =
        IconData(int.parse(categories!.iconName), fontFamily: 'MaterialIcons');
    setState(() {
      category.text = categories.holderName;
      description.text = categories.description;
      selectedIcon = iconData;
      selectedColor = Color(int.parse(categories.colorName));
      if (categories.transferCategory == 1) {
        transferCategory = true;
      }
      if (categories.budget.toString() != '0.0') {
        showTextFormField = true;
        amount.text = categories.budget.toString();
      }
    });
  }

  void _showColorPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color currentColor = selectedColor ?? Colors.black;
        return AlertDialog(
          title: Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickIcon() async {
    // IconData? icon = await showIconPicker(
    //   context,
    //   adaptiveDialog: isAdaptive,
    //   showTooltips: showTooltips,
    //   showSearchBar: showSearch,
    //   iconPickerShape:
    //       RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    //   // iconPackModes: IconNotifier.starterPacks,
    setState(() {
          selectedIcon = Icons.safety_check;

    });

    //   searchComparator: (String search, IconPickerIcon icon) =>
    //       search
    //           .toLowerCase()
    //           .contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
    //       icon.name.toLowerCase().contains(search.toLowerCase()),
    // );

    // if (icon != null) {
    //   setState(() {
    //     selectedIcon = icon;
    //   });

    //   debugPrint(
    //       'Picked Icon:  $icon and saved it successfully in local hive db.');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor2 = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor2, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Update Category'),
        actions: [
          IconButton(
              onPressed: () async {
                DatabaseHelper databaseHelper = DatabaseHelper();

                await databaseHelper.deleteCategory(widget.index);
                await databaseHelper.loadAccounts();
                Get.back();
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter Card Holder Name',
                controller: category,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter your Descrition',
                controller: description,
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
                onPressed: () {
                  _showColorPickerDialog(context);
                },
                selectedColor: selectedColor,
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
                  controller: amount,
                  borderRadius: 10.0,
                  keyboardType: TextInputType.number,
                ),
              ],
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Transfer Category',
                    style: textStyler.largeTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
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
                onPressed: _updateCategory,
                text: 'Update',
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

    });
    // if (icon != null) {
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

  void _updateCategory() async {
    try {
      // Prepare updated category data
      Category updatedCategory = Category(
        id: widget.index, // Assuming Category model has an 'id' field
        holderName: category.text,
        description: description.text,
        iconName: selectedIcon!.codePoint.toString(),
        colorName: selectedColor!.value.toString(),
        transferCategory: transferCategory ? 1 : 0,
        budget: showTextFormField ? amount.text : '0.0',
      );
      CategorysController categorysController = Get.find<CategorysController>();
      categorysController.updateCategory(updatedCategory);
      // Update the category in the database
      // await databaseHelper.updateCategory(updatedCategory);
      Get.back();
      print('Category updated successfully');
    } catch (e) {
      // Handle any errors
      print('Error updating category: $e');
    }
  }

  Color selectedColor1 = Colors.black;
}
