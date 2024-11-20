import 'package:expenses/controller/account_create.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AddAccountScreen extends StatefulWidget {
  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  List<String> items = ['cash', 'bank', 'wellet'];
  final TextEditingController cardholder = TextEditingController();
  final TextEditingController acountname = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController pincode = TextEditingController();

  TextStyler textStyler = TextStyler();
  int selectedIndex = 0;
  Color selectedColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color secondarycolor = colorShades[3];
    final HomeController _controller = Get.put(HomeController());

    String selectedColorHex =
        selectedColor.value.toRadixString(16).substring(2);
    return Scaffold(
      appBar: AppBar(
        title: Text('add'.tr),
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
                        padding: EdgeInsets.only(left: 16.0, right: 16, top: 6),
                        child: Text(
                          items[index].tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: secondarycolor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter name'.tr,
                controller: cardholder,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter account name'.tr,
                controller: acountname,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter your amount'.tr,
                controller: amount,
                borderRadius: 10.0,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              selectedIndex == 1
                  ? CustomTextFormField(
                      hintText: 'enter your pin'.tr,
                      controller: pincode,
                      borderRadius: 10.0,
                    )
                  : SizedBox(),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'default account'.tr,
                    style: textStyler.largeTextStyle(
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
                title: 'pick color'.tr,
                subtitle: 'select color for your category'.tr,
                onPressed: () async {
                  Color? pickedColor = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      Color currentColor = selectedColor;
                      return AlertDialog(
                        title: Text('pick color'.tr),
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
                        .substring(
                            2); // Update the selected color hexadecimal string
                  }
                },
                selectedColor: selectedColor,
              ),
              SizedBox(
                  height: selectedIndex == 1
                      ? MediaQuery.of(context).size.height - 717
                      : MediaQuery.of(context).size.height - 653),
              CustomElevatedButton(
                onPressed: () async {
                  print(selectedColor);
                  print(selectedColorHex);
                  if (cardholder.text == '') {
                    Get.snackbar(
                      'Error',
                      'Card Holder Name is required'.tr,
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    );
                    return;
                  } else if (acountname.text == '') {
                    Get.snackbar(
                      'Error',
                      'Account Name is required'.tr,
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    );
                    return;
                  } else if (amount.text.isEmpty || !isNumeric(amount.text)) {
                    Get.snackbar(
                      'Error',
                      'Amount is required'.tr,
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    );
                    return;
                  } else {
                    BankAccount newAccount = BankAccount(
                      selectedIndex: selectedIndex,
                      cardHolder: cardholder.text,
                      accountName: acountname.text,
                      amount: double.tryParse(amount.text) ?? 0.0,
                      pinCode: pincode.text,
                      color: selectedColorHex.toString(),
                    );
                    try {
                      int id = await databaseHelper.insertAccount(newAccount);
                      await databaseHelper.loadAccounts();
                      print('Inserted row id: $id');
                      accountController.accounts();
                      Get.back();
                    } catch (e) {
                      print('Error inserting account: $e');
                    }
                  }
                },
                text: 'add'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isNumeric(String s) {
    if (s.isEmpty) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  final AccountController accountController = Get.put(AccountController());

  DatabaseHelper databaseHelper = DatabaseHelper();
}

//               selectedIndex == 0
//                   ? Cash()
//                   : (selectedIndex == 1 ? Bank() : Wallet())
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
