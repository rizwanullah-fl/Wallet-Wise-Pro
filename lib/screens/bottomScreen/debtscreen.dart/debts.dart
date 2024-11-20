import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/controller/debit_controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/update_Debit_credit.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Debit extends StatefulWidget {
  @override
  State<Debit> createState() => _DebitState();
}

class _DebitState extends State<Debit> {
  final DebitController _debitController = Get.put(DebitController());

  TextStyler textStyler = TextStyler();

  final HomeController _controller = Get.put(HomeController());

  final DatabaseHelper2 dbHelper = DatabaseHelper2.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final CurrencyController currencyController =
          Get.find<CurrencyController>();
      final debits = _debitController
          .debitList; // Assuming you have a list of debits in your controller
      final selectedColor = Get.find<ColorController>().getSelectedColor();
      final colorShades = ColorUtils.generateShades(selectedColor, 200);
      final lightcolor = colorShades[0];
      final lightprocolor = colorShades[1];
      final secondarycolor = colorShades[3];
      final firstcolor = colorShades[2];

      return Center(
        // child: debits.isEmpty
        //     ? Column(
        //         crossAxisAlignment: CrossAxisAlignment.center,
        //         children: [
        //           Text(
        //             'There are no debits at this time',
        //             style: textStyler.smallTextStyle(
        //               fontWeight: FontWeight.bold,
        //               fontSize: 20,
        //               color: _controller.currentTheme.value == ThemeMode.dark
        //                   ? Colors.white
        //                   : Colors.black,
        //             ),
        //           ),
        //           Text(
        //             'Add your debts to see them displayed here',
        //             style: textStyler.smallTextStyle(
        //               fontWeight: FontWeight.bold,
        //               fontSize: 15,
        //               color: _controller.currentTheme.value == ThemeMode.dark
        //                   ? Colors.white
        //                   : Colors.black,
        //             ),
        //           ),
        //         ],
        //       )
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: dbHelper.getDebits(), // Call your method to get data
          builder: (BuildContext context,
              AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasData) {
              final debits =
                  snapshot.data!; // Extract the data from the snapshot

              // Now use this debits list to populate your UI
              return ListView.builder(
                itemCount: debits.length,
                itemBuilder: (BuildContext context, int index) {
                  final debit = debits[index];
                  final DateTime firstDate =
                      DateTime.parse(debit['first_date']);
                  final DateTime lastDate = DateTime.parse(debit['last_date']);
                  final daysDifference = lastDate.difference(firstDate).inDays;

                  return debit['selectedIndex'] == 1
                      ? SizedBox()
                      : GestureDetector(
                          onTap: () {
                            Get.to(() => UpdateDebitCredit(
                                      debit: debit,
                                    ))!
                                .then((value) {
                              dbHelper.reloadData();
                              setState(
                                  () {}); // Yeh zaroori hai, kyunki setState se UI update hoga
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 20.0, right: 20, top: 10, bottom: 10),
                            margin: EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.0),
                              color: lightcolor,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                      top: 10,
                                      bottom: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            debit[
                                                'name'], // Accessing name from the debit object
                                            style: textStyler.smallTextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: _controller.currentTheme ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 3.0),
                                          Text(
                                            debit[
                                                'account_name'], // Accessing description from the debit object
                                            style: textStyler.smallTextStyle(
                                              fontSize: 15,
                                              color: _controller
                                                          .currentTheme.value ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        "${currencyController.selectedCurrency.value}${debit['amount'].toString()}", // Accessing amount from the debit object
                                        style: textStyler.smallTextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color:
                                              _controller.currentTheme.value ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  color: secondarycolor,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${daysDifference.toString()} ${'day left'.tr}', // Accessing startDate from the debit object
                                        style: textStyler.smallTextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color:
                                              _controller.currentTheme.value ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.cabin),
                                          SizedBox(width: 6.0),
                                          Text(
                                            'paydebit'
                                                .tr, // Accessing endDate from the debit object
                                            style: textStyler.smallTextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color: _controller
                                                          .currentTheme.value ==
                                                      ThemeMode.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                },
              );
            } else {
              // If data is not available yet, display a loading indicator
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      );
    });
  }
}
