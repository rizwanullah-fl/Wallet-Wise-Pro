import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/update_Debit_credit.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Credit extends StatefulWidget {
  @override
  State<Credit> createState() => _CreditState();
}

class _CreditState extends State<Credit> {
  TextStyler textStyler = TextStyler();

  final HomeController _controller = Get.put(HomeController());

  final DatabaseHelper2 dbHelper = DatabaseHelper2.instance;

  @override
  Widget build(BuildContext context) {
    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    final selectedColor = Get.find<ColorController>().getSelectedColor();
    final colorShades = ColorUtils.generateShades(selectedColor, 200);
    final lightcolor = colorShades[0];
    final lightprocolor = colorShades[1];
    final secondarycolor = colorShades[3];
    final firstcolor = colorShades[2];
    return Center(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getDebits(), // Call your method to get data
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasData) {
            final debits = snapshot.data!; // Extract the data from the snapshot

            // Now use this debits list to populate your UI
            return ListView.builder(
              itemCount: debits.length,
              itemBuilder: (BuildContext context, int index) {
                final debit = debits[index];
                final DateTime firstDate = DateTime.parse(debit['first_date']);
                final DateTime lastDate = DateTime.parse(debit['last_date']);
                final daysDifference = lastDate.difference(firstDate).inDays;

                return debit['selectedIndex'] == 0
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
                                    left: 20.0, right: 20, top: 10, bottom: 20),
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
                                            fontSize: 15,
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
                                      "${currencyController.selectedCurrency.value} ${debit['amount'].toString()}", // Accessing amount from the debit object
                                      style: textStyler.smallTextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: _controller.currentTheme.value ==
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
                                      '${daysDifference.toString()}${'day left'.tr}', // Accessing startDate from the debit object
                                      style: textStyler.smallTextStyle(
                                        fontSize: 15,
                                        color: _controller.currentTheme.value ==
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
  }
}
