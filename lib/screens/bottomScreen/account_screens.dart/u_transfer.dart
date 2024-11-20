import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/add_transactions_widgets.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/transfer.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:expenses/database/create_account.dart' as account;
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class Updatetransfer extends StatefulWidget {
  final List<account.Transaction> transactionList; // Use the alias here
  final account.Transaction transaction; // Use the alias here

  const Updatetransfer(
      {super.key, required this.transactionList, required this.transaction});

  @override
  State<Updatetransfer> createState() => _UpdatetransferState();
}

class _UpdatetransferState extends State<Updatetransfer> {
  final TextEditingController amount = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay time = TimeOfDay(hour: 10, minute: 30);
  TextStyler textStyler = TextStyler();
  final HomeController _controller = Get.put(HomeController());
  Future<void> _selectDate(BuildContext context) async {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];

    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: secondarycolor, // header background color
                onPrimary: Colors.black, // header text color
                onSurface: firstcolor, // body text color
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red, // button text color
                ),
              ),
            ),
            child: child!,
          );
        },
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Amount',
          controller: amount,
          borderRadius: 10.0,
        ),
        SizedBox(
          height: 20,
        ),
        Text('select category'.tr),
        SizedBox(
          height: 20,
        ),
        Container(
            child: TagList(
          filterByTransfer: true,
          onItemSelected: (index) {
            setState(() {
              selectedCategoryId = index;
            });
          },
        )),
        Text('date & time'.tr),
        SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    size: 25,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Row(
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${time.format(context)}',
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Text('transferaccountfrom'.tr),
        SizedBox(height: 20),
        Container(
          height: 50.0 * dataList.length,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: dataList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 8),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GridItem(
                data: dataList[index],
                isSelected: fromSelectedIndex == index,
                onTap: () => _onItemTap(true, index),
              );
            },
          ),
        ),
        Text('transferaccountto'.tr),
        SizedBox(height: 10),
        Container(
          height: 50.0 * dataList.length,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemCount: dataList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: MediaQuery.of(context).size.width /
                  (MediaQuery.of(context).size.height / 8),
              mainAxisSpacing: 10.0,
              crossAxisSpacing: 10.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GridItem(
                data: dataList[index],
                isSelected: toSelectedIndex == index,
                onTap: () => _onItemTap(false, index),
              );
            },
          ),
        ),
        SizedBox(height: 70),
        Center(
          child: CustomElevatedButton(
            onPressed: () {
              _performTransfer();
            },
            text: 'update'.tr,
          ),
        ),
      ],
    );
  }

  late List<Data> dataList = [];
  int fromSelectedIndex = -1;
  int toSelectedIndex = -1;
  @override
  void initState() {
    super.initState();
    loadBankAccounts();
    amount.text = widget.transaction.amount.toString();
  }

  int? selectedCategoryId;

  void loadBankAccounts() async {
    try {
      List<BankAccount> accounts = await DatabaseHelper().getAccounts();
      setState(() {
        dataList = accounts
            .map((account) => Data(
                name: account.accountName.toString(), color: account.color))
            .toList();
      });
    } catch (e) {
      print("Error loading bank accounts: $e");
    }
  }

  void _onItemTap(bool isFromGrid, int index) {
    setState(() {
      if (isFromGrid) {
        fromSelectedIndex = index;
      } else {
        toSelectedIndex = index;
      }
    });
  }

  Future<void> _performTransfer() async {
    double transferAmount = double.tryParse(amount.text) ?? 0.0;
    if (fromSelectedIndex == toSelectedIndex) {
      // Display toast message for same account transfer
      print("Cannot transfer funds within the same account");
      return;
    }
    try {
      double amounts = double.tryParse(amount.text.trim()) ?? 0.0;
      // Perform transfer
      await DatabaseHelper().updateTransfer(widget.transaction.accountId,
          transferAmount, selectedCategoryId!.toInt(), toSelectedIndex);
      // Show success message or navigate to a different screen
      print("Transfer successful");
      Navigator.pop(context);
    } catch (e) {
      Get.snackbar(
        'Error',
        'transaction amount is 0',
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      );
      print("Error performing transfer: $e");
      // Handle error - Show error message or log the error
      print("Error performing transfer");
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: time,
    );
    if (picked != null && picked != time) {
      setState(() {
        time = picked;
      });
    }
  }
}

String _formatTimeOfDay(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  final dt =
      DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  final format = DateFormat.jm(); // '6:00 AM'
  return format.format(dt);
}
