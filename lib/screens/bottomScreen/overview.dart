import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/overviewScreens/calender.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/screens/bottomScreen/overviewScreens/overview_expense.dart';
import 'package:expenses/screens/bottomScreen/overviewScreens/overview_income.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

class Overview extends StatefulWidget {
  const Overview({Key? key});

  @override
  State<Overview> createState() => _OverviewState();
}

class _OverviewState extends State<Overview> {
  int _currentSelection = 0;
  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
              width: MediaQuery.of(context).size.width,
              child: Obx(() {
                final Color selectedColor =
                    Get.find<ColorController>().getSelectedColor();
                final List<Color> colorShades =
                    ColorUtils.generateShades(selectedColor, 200);
                final Color lightcolor = colorShades[0];
                return MaterialSegmentedControl(
                  children: _children,
                  selectionIndex: _currentSelection,
                  borderColor: _controller.currentTheme.value == ThemeMode.dark
                      ? Colors.white
                      : Colors.black,
                  selectedColor: lightcolor,
                  unselectedColor:
                      _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.black
                          : Colors.white,
                  selectedTextStyle: TextStyle(
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontController.selectedFontFamily.value),
                  unselectedTextStyle: TextStyle(
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: fontController.selectedFontFamily.value),
                  borderWidth: 0.7,
                  borderRadius: 32.0,
                  onSegmentTapped: (index) {
                    setState(() {
                      _currentSelection = index;
                    });
                  },
                );
              }),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentSelection,
                children: [
                  IncomeScreen(),
                  ExpenseScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => CalendarScreen());
        },
        tooltip: 'Calendar',
        child: Icon(Icons.calendar_today_outlined),
      ),
    );
  }

  Map<int, Widget> _children = {
    0: Text('Income'),
    1: Text('Expense'),
  };
}
