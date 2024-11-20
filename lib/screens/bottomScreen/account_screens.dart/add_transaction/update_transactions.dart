import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/u_expense.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/u_income.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/u_transfer.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:expenses/database/create_account.dart' as account;

class Updatetransaction extends StatefulWidget {
  final int selectedIndex;
  final List<Transaction> transactionList; // Add this parameter
  final account.Transaction transaction; // Use the alias here

  Updatetransaction({
    required this.selectedIndex,
    required this.transactionList,
    required this.transaction, // Use the alias here
  });
  @override
  State<Updatetransaction> createState() => _UpdatetransactionState();
}

class _UpdatetransactionState extends State<Updatetransaction> {
  List<String> items = ['expense', 'income', 'transfer'];
  int? selectedIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final HomeController _controller = Get.put(HomeController());
    TextStyler textStyler = TextStyler();

    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color secondarycolor = colorShades[3];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'update'.tr,
          style: textStyler.mediumTextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black),
        ),
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
              selectedIndex == 0
                  ? Uexpense(
                      transactionList: widget.transactionList,
                      transaction: widget.transaction,
                    )
                  : (selectedIndex == 1
                      ? uIncome(
                          transactionList: widget.transactionList,
                          transaction: widget.transaction,
                        )
                      : Updatetransfer(
                          transactionList: widget.transactionList,
                          transaction: widget.transaction,
                        )),
            ],
          ),
        ),
      ),
    );
  }
}
