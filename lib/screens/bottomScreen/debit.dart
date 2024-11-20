import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/add_debit_credit.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/credits.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/debts.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Debits extends StatefulWidget {
  const Debits({Key? key}) : super(key: key);

  @override
  State<Debits> createState() => _DebitsState();
}

class _DebitsState extends State<Debits> {
  @override
  Widget build(BuildContext context) {
    final DatabaseHelper2 dbHelper = DatabaseHelper2.instance;

    final HomeController _controller = Get.put(HomeController());
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: fontController.selectedFontFamily.value);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(() {
                  final selectedColor =
                      Get.find<ColorController>().getSelectedColor();
                  final colorShades =
                      ColorUtils.generateShades(selectedColor, 200);
                  final lightcolor = colorShades[0];
                  final lightprocolor = colorShades[1];
                  final secondarycolor = colorShades[3];
                  final firstcolor = colorShades[2];

                  return SegmentedTabControl(
                    // Customization of widget
                    tabTextColor:
                        _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                    barDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    indicatorDecoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    selectedTabTextColor: Colors.white,
                    indicatorPadding: const EdgeInsets.all(4),
                    squeezeIntensity: 2,
                    tabPadding: const EdgeInsets.symmetric(horizontal: 8),
                    textStyle: selectedTextStyle,
                    selectedTextStyle: selectedTextStyle,
                    tabs: [
                      SegmentTab(
                        label: 'debit'.tr,
                        color: secondarycolor,
                        backgroundColor:
                            _controller.currentTheme.value == ThemeMode.dark
                                ? Colors.grey.shade900
                                : Colors.grey.shade300,
                      ),
                      SegmentTab(
                        label: 'credit'.tr,
                        backgroundColor:
                            _controller.currentTheme.value == ThemeMode.dark
                                ? Colors.grey.shade900
                                : Colors.grey.shade300,
                        color: secondarycolor,
                      ),
                    ],
                  );
                }),
              ),
              // Sample pages
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Debit(),
                    Credit(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => AddDebitCredit())!.then((value) {
              dbHelper.reloadData();
              setState(
                  () {}); // Yeh zaroori hai, kyunki setState se UI update hoga
            });
          },
          tooltip: 'Add',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
