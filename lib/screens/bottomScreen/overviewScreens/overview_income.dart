import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/overviewScreens/transactions_by_category.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class IncomeScreen extends StatefulWidget {
  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final dbHelper = DatabaseHelper();
  // Instantiate your DatabaseHelper class
  final CurrencyController currencyController = Get.find<CurrencyController>();

  final HomeController _controller = Get.put(HomeController());

  TextStyler textStyler = TextStyler();

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color secondarycolor = colorShades[3];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  _showBottomSheet(context);
                },
                icon: Icon(Icons.accessible_forward_rounded),
              ),
              SizedBox(width: 10),
              Container(
                decoration: BoxDecoration(
                  color: lightcolor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black),
                ),
                padding: EdgeInsets.all(10),
                child: Text(
                  _selectedOption.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  _getCategoriesWithTotalIncome(), // Fetch categories with total transactions
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final categories = snapshot.data!;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      double totalIncome = 0.0;
                      double categoryBudget = 0.0;

                      // Check if the values are already of type double
                      if (category['total_income'] is double) {
                        totalIncome = category['total_income'];
                      } else if (category['total_income'] is String) {
                        totalIncome =
                            double.tryParse(category['total_income']) ?? 0.0;
                      }

                      if (category['category_budget'] is double) {
                        categoryBudget = category['category_budget'];
                      } else if (category['category_budget'] is String) {
                        categoryBudget =
                            double.tryParse(category['category_budget']) ?? 0.0;
                      }

                      IconData iconData = IconData(
                          int.parse(category['category_icon']),
                          fontFamily: 'MaterialIcons');
                      return GestureDetector(
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionsScreen(
                                  categoryId: category['category_id'],
                                  type: 'income',
                                  totalIncome: category['total_income']),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    iconData,
                                    size: 30,
                                    color: Color(
                                        int.parse(category['category_color'])),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Adjust spacing between icon and title
                                  Obx(
                                    () => Text(
                                      category['category_name'],
                                      style: textStyler.mediumTextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color:
                                              _controller.currentTheme.value ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 8,
                                      child: LinearProgressIndicator(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(30)),
                                        value: categoryBudget > 0
                                            ? totalIncome / categoryBudget
                                            : 0.0,
                                        color: Color(int.parse(
                                            category['category_color'])),
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => Text(
                                      ' ${currencyController.selectedCurrency.value}${category['total_income']}',
                                      style: textStyler.mediumTextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                          color:
                                              _controller.currentTheme.value ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getCategoriesWithTotalIncome() async {
    final categories = await dbHelper.getCategories(); // Fetch all categories
    final List<Map<String, dynamic>> categoriesWithTotalIncome = [];

    for (final category in categories) {
      final totalIncome =
          await dbHelper.getTotalIncomeForCategory(category.id!.toInt());
      categoriesWithTotalIncome.add({
        'category_name': category.holderName.toString(),
        'total_income': totalIncome,
        'category_icon': category.iconName,
        'category_color': category.colorName,
        'category_id': category.id,
        'category_budget': category.budget,
      });
    }

    return categoriesWithTotalIncome;
  }

  String _selectedOption = 'daily';

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                  'Filter List',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              SizedBox(height: 16.0),
              _buildSelectableOption(
                  context, 'daily', _selectedOption == 'daily'),
              _buildSelectableOption(
                  context, 'weekly', _selectedOption == 'weekly'),
              _buildSelectableOption(
                  context, 'monthly', _selectedOption == 'monthly'),
              _buildSelectableOption(
                  context, 'yearly', _selectedOption == 'yearly'),
              _buildSelectableOption(context, 'All', _selectedOption == 'All'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectableOption(
      BuildContext context, String option, bool isSelected) {
    final HomeController _controller = Get.put(HomeController());
    TextStyler textStyler = TextStyler();

    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[2];
    final Color secondarycolor = colorShades[3];
    return GestureDetector(
      onTap: () {
        // Handle selection of the option here
        setState(() {
          _selectedOption = option;
        });
        print('Selected: $_selectedOption');
        Navigator.pop(context); // Close the bottom sheet
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 100,
        decoration: BoxDecoration(
          color: isSelected ? lightcolor : Colors.transparent,
          border: Border.all(
              color: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
        child: Text(
          option.tr,
          style: textStyler.mediumTextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black),
        ),
      ),
    );
  }
}
