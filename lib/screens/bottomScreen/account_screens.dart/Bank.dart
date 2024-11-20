import 'package:expenses/controller/account_create.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_data_Screens.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Bank extends StatelessWidget {
  final TextEditingController cardholder = TextEditingController();
  final TextEditingController accountname = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController pincode = TextEditingController();

  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    Color selectedColor = Colors.amber;
    String selectedColorHex = selectedColor.value.toRadixString(16).substring(
        2); // Convert color to hexadecimal string and remove the alpha value

    return Column(
      children: [
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Enter Card Holder Name',
          controller: cardholder,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Enter your Account Name',
          controller: accountname,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Enter your Amount',
          controller: amount,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Enter your Pin',
          controller: pincode,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Default Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _controller.currentTheme.value == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            SwitchExample(),
          ],
        ),
        SizedBox(height: 20),
        PickColorListTile(
          icon: Icons.palette,
          color: selectedColor,
          title: 'Pick Color',
          subtitle: 'Select color for your category',
          onPressed: () async {
            Color? pickedColor = await showDialog(
              context: context,
              builder: (BuildContext context) {
                Color currentColor = selectedColor;
                return AlertDialog(
                  title: Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: currentColor,
                      onColorChanged: (Color color) {
                        currentColor = color;
                      },
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(currentColor);
                      },
                      child: Text('Done'),
                    ),
                  ],
                );
              },
            );
            if (pickedColor != null) {
              selectedColor = pickedColor;
              selectedColorHex = selectedColor.value
                  .toRadixString(16)
                  .substring(2); // Update the selected color hexadecimal string
            }
          },
          selectedColor: selectedColor,
        ),
        SizedBox(height: 20),
//         CustomElevatedButton(
//           onPressed: () async {
//             print(selectedColor);
//             print(selectedColorHex);
//             BankAccount newAccount = BankAccount(
//               cardHolder: cardholder.text,
//               accountName: accountname.text,
//               amount: double.tryParse(amount.text) ?? 0.0,
//               pinCode: pincode.text,
//               color: selectedColorHex.toString(),
//             );
//             try {
//               int id = await databaseHelper.insertAccount(newAccount);

// // Reload the accounts and update the stream
//               await databaseHelper.loadAccounts();
//               print('Inserted row id: $id');
//               accountController.accounts();
//               Get.back();
//             } catch (e) {
//               print('Error inserting account: $e');
//             }
//           },
//           text: 'ADD',
//         ),
      ],
    );
  }

  final AccountController accountController = Get.put(AccountController());

  DatabaseHelper databaseHelper = DatabaseHelper();
}
