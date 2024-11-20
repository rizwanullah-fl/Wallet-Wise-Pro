import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/screens/bottomScreen/Home.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/expense.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/income_screen.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/transfer.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AddTransaction extends StatefulWidget {
  final int selectedIndex;
  const AddTransaction({super.key, required this.selectedIndex});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color secondarycolor = colorShades[3];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('add'.tr),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              MySegmentedTransactions(),
              Container(
                  height: MediaQuery.of(context).size.height - 60,
                  child: TabBarView(
                      children: [AddExpense(), AddIncome(), Transfer()])),
            ],
          ),
        ),
      ),
    );
  }
}

class MySegmentedTransactions extends StatelessWidget {
  final MyController _controller =
      Get.find<MyController>(); // Assuming you have a GetX controller

  MySegmentedTransactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedColor = Get.find<ColorController>().getSelectedColor();
      final colorShades = ColorUtils.generateShades(selectedColor, 200);
      final secondarycolor = colorShades[3];

      return Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: SegmentedTabControl(
          tabTextColor: _controller.currentTheme.value == ThemeMode.dark
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
          squeezeIntensity: 3,
          tabPadding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          selectedTextStyle:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          tabs: [
            SegmentTab(
              label: 'expense'.tr,
              color: secondarycolor,
              backgroundColor: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
            ),
            SegmentTab(
              label: 'income'.tr,
              backgroundColor: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
              color: secondarycolor,
            ),
            SegmentTab(
              label: 'transfer'.tr,
              backgroundColor: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
              color: secondarycolor,
            ),
          ],
        ),
      );
    });
  }
}




// SizedBox(
                //   height: 35,
                //   child: ListView.builder(
                //     scrollDirection: Axis.horizontal,
                //     itemCount: items.length,
                //     itemBuilder: (BuildContext context, int index) {
                //       return GestureDetector(
                //         onTap: () {
                //           setState(() {
                //             selectedIndex = index;
                //           });
                //         },
                //         child: Container(
                //           margin: EdgeInsets.only(left: 10),
                //           height: 20,
                //           decoration: BoxDecoration(
                //             border: Border.all(
                //                 color: selectedIndex == index
                //                     ? secondarycolor
                //                     : Colors.transparent),
                //             color: lightcolor,
                //             borderRadius:
                //                 const BorderRadius.all(Radius.circular(30)),
                //           ),
                //           padding: EdgeInsets.only(left: 16.0, right: 16, top: 8),
                //           child: Text(
                //             items[index].tr,
                //             style: textStyler.mediumTextStyle(
                //                 fontWeight: FontWeight.bold,
                //                 fontSize: 12,
                //                 color: _controller.currentTheme.value ==
                //                         ThemeMode.dark
                //                     ? Colors.white
                //                     : Colors.black),
                //           ),
                //         ),
                //       );
                //     },
                //   ),
                // ),

                
                // selectedIndex == 0
                //     ? AddExpense()
                //     : (selectedIndex == 1 ? AddIncome() : Transfer())



  //                 List<String> items = ['expense', 'income', 'transfer'];
  // int? selectedIndex;
  //   selectedIndex = widget.selectedIndex;