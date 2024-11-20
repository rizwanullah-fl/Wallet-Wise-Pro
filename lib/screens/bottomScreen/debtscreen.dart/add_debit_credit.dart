import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/controller/debit_controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

// ignore: must_be_immutable
class AddDebitCredit extends StatefulWidget {
  AddDebitCredit({super.key});

  @override
  State<AddDebitCredit> createState() => _AddDebitCreditState();
}

class _AddDebitCreditState extends State<AddDebitCredit> {
  final DatabaseHelper2 dbHelper = DatabaseHelper2.instance;

  List<String> items = [
    'debit',
    'credit',
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);

    final DebitController debitController = Get.put(DebitController());

    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    TextStyler textStyler = TextStyler();
    final HomeController _controller = Get.put(HomeController());
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    return Scaffold(
      appBar: AppBar(
        title: Text('add'.tr,
            style: textStyler.smallTextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          top: 20,
          right: 22,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 35,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedIndex == index
                                  ? secondarycolor
                                  : Colors.transparent),
                          color: lightcolor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                        ),
                        padding: EdgeInsets.only(left: 16.0, right: 16, top: 8),
                        child: Text(
                          items[index].tr,
                          style: textStyler.mediumTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _controller.currentTheme.value ==
                                      ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter name'.tr,
                controller:
                    TextEditingController(text: debitController.name.value),
                onChanged: (value) => debitController.name.value = value,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter account name'.tr,
                controller: TextEditingController(
                    text: debitController.description.value),
                onChanged: (value) => debitController.description.value = value,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter your amount'.tr,
                keyboardType: TextInputType.number,
                controller:
                    TextEditingController(text: debitController.amount.value),
                onChanged: (value) => debitController.amount.value = value,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              MyDatePickerRow(
                startDateController: debitController.startDate,
                endDateController: debitController.endDate,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'transactionhistory'.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height - 603),
              CustomElevatedButton(
                onPressed: () async {
                  // Check if any required field is null or empty
                  if (debitController.name.value.isEmpty ||
                      debitController.description.value.isEmpty ||
                      debitController.amount.value.isEmpty) {
                    // Show toast message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please fill in all the fields'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    // All fields are filled, proceed with insertion
                    Map<String, dynamic> newDebt = {
                      'selectedIndex': selectedIndex,
                      'name': debitController.name.value,
                      'account_name': debitController.description.value,
                      'amount': double.parse(debitController.amount.value),
                      'first_date':
                          debitController.startDate.value.toIso8601String(),
                      'last_date':
                          debitController.endDate.value.toIso8601String(),
                    };
                    await dbHelper.insertDebt(newDebt);

                    // Clear fields and navigate back
                    Navigator.pop(context);
                    debitController.name.value = '';
                    debitController.amount.value = '';
                    debitController.description.value = '';
                    debitController.startDate.value = DateTime.now();
                    debitController.endDate.value = DateTime.now();
                  }
                },
                text: 'add'.tr,
              ),
              // selectedIndex == 0 ? DebitScreen() : CreditScreen()
            ],
          ),
        ),
      ),
    );
  }
}
