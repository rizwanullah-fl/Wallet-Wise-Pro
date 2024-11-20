import 'package:expenses/controller/account_create.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/Bank.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/Cash.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/Wallet.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UpdateAccount extends StatefulWidget {
  final int accountId; // Accept account ID as a parameter

  UpdateAccount({required this.accountId});

  @override
  State<UpdateAccount> createState() => _UpdateAccountState();
}

class _UpdateAccountState extends State<UpdateAccount> {
  List<String> items = ['cash', 'bank', 'wallet'];
  final TextEditingController cardholder = TextEditingController();
  final TextEditingController accountname = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final TextEditingController pincode = TextEditingController();

  TextStyler textStyler = TextStyler();
  int selectedIndex = 0;
  Color selectedColor2 = Colors.amber;

  @override
  void initState() {
    super.initState();
    _loadAccountData(); // Load account data when the widget initializes
  }

  Future<void> _loadAccountData() async {
    // Fetch the account data based on the given ID
    BankAccount? account = await databaseHelper.getAccount(widget.accountId);

    setState(() {
      cardholder.text = account!.cardHolder;
      accountname.text = account.accountName;
      amount.text = account.amount.toString();
      pincode.text = account.pinCode;
      selectedIndex = account.selectedIndex;
      selectedColor2 = Color(int.parse('0xFF' + account.color));
    });
  }

  @override
  Widget build(BuildContext context) {
    Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color secondarycolor = colorShades[3];
    final HomeController _controller = Get.put(HomeController());

    String selectedColorHex =
        selectedColor2.value.toRadixString(16).substring(2);
    return Scaffold(
      appBar: AppBar(
        title: Text('update'.tr),
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
                controller: accountname,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'enter your amount'.tr,
                controller: amount,
                borderRadius: 10.0,
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
                color: selectedColor2,
                title: 'pick color'.tr,
                subtitle: 'select color for your category'.tr,
                onPressed: () async {
                  Color? pickedColor = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      Color currentColor = selectedColor2;
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
                    setState(() {
                      selectedColor2 = pickedColor;
                      selectedColorHex =
                          selectedColor2.value.toRadixString(16).substring(2);
                    });
                  }
                },
                selectedColor: selectedColor2,
              ),
              SizedBox(
                  height: selectedIndex == 1
                      ? MediaQuery.of(context).size.height - 717
                      : MediaQuery.of(context).size.height - 653),
              CustomElevatedButton(
                onPressed: () async {
                  print(selectedColor2);
                  print(selectedColorHex);
                  if (cardholder.text == '') {
                    Get.snackbar(
                      'Error',
                      'Card Holder Name is required'.tr,
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                    );
                    return;
                  } else if (accountname.text == '') {
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
                    BankAccount updatedAccount = BankAccount(
                      id: widget.accountId,
                      selectedIndex: selectedIndex,
                      cardHolder: cardholder.text,
                      accountName: accountname.text,
                      amount: double.tryParse(amount.text) ?? 0.0,
                      pinCode: pincode.text,
                      color: selectedColorHex.toString(),
                    );
                    try {
                      await databaseHelper.updateAccount(updatedAccount);
                      await databaseHelper.loadAccounts();
                      accountController.accounts();
                      Get.back();
                    } catch (e) {
                      print('Error updating account: $e');
                    }
                  }
                },
                text: 'update'.tr,
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
