import 'package:expenses/controller/account_create.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/controller/transaction_controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:u_credit_card/u_credit_card.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final double borderRadius;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged; // Define onChanged callback

  const CustomTextFormField(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.borderRadius = 10.0,
      this.keyboardType = TextInputType.text,
      this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    TextStyler textStyler = TextStyler();
    final HomeController _controller = Get.put(HomeController());

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textStyler.mediumTextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: _controller.currentTheme.value == ThemeMode.dark
              ? Colors.white
              : Colors.black,
        ),
        filled: true,
        fillColor: lightcolor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: secondarycolor),
        ),
      ),
    );
  }
}

class SwitchExample extends StatefulWidget {
  final bool? value;
  final Function(bool)? onChanged; // Define the onChanged callback as optional

  const SwitchExample({Key? key, this.value, this.onChanged}) : super(key: key);

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = false;
  final Color selectedColor = Get.find<ColorController>().getSelectedColor();

  @override
  Widget build(BuildContext context) {
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    return Switch(
      // This bool value toggles the switch.
      value: light,
      activeColor: secondarycolor,
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
          if (widget.onChanged != null) {
            widget.onChanged!(value); // Call the callback if it's not null
          }
        });
      },
    );
  }
}

class PickColorListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? color;
  final VoidCallback onPressed;
  final Color? selectedColor;

  const PickColorListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onPressed,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    TextStyler textStyler = TextStyler();
    final HomeController _controller = Get.put(HomeController());

    return ListTile(
      contentPadding: EdgeInsets.all(0),
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(title,
          style: textStyler.largeTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _controller.currentTheme.value == ThemeMode.dark
                ? Colors.white
                : Colors.black,
          )),
      subtitle: Text(subtitle,
          style: textStyler.largeTextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: _controller.currentTheme.value == ThemeMode.dark
                ? Colors.white
                : Colors.black,
          )),
      trailing: selectedColor != null
          ? Icon(Icons.palette, color: selectedColor)
          : null,
      onTap: onPressed,
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color secondarycolor = colorShades[3];
    return ElevatedButton(
      onPressed: onPressed,
      child: Obx(() {
        TextStyler textStyler = TextStyler();
        return Text(text,
            style: textStyler.largeTextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white));
      }),
      style: ElevatedButton.styleFrom(
        backgroundColor: secondarycolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(70.0),
        ),
        minimumSize: Size(327, 56),
      ),
    );
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class ContainerWidget extends StatefulWidget {
  final BankAccount account;

  ContainerWidget(this.account);

  @override
  State<ContainerWidget> createState() => _ContainerWidgetState();
}

class _ContainerWidgetState extends State<ContainerWidget> {
  TextStyler textStyler = TextStyler();
  double totalExpense = 0.0;
  double totalIncome = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    displayTotalExpenseAndIncomeForAccount(widget.account.id!.toInt());
  }

  void displayTotalExpenseAndIncomeForAccount(int accountId) async {
    try {
      // Fetch total expense and total income for the account
      double expense =
          await DatabaseHelper().getTotalExpenseForAccount(accountId);
      double income =
          await DatabaseHelper().getTotalIncomeForAccount(accountId);

      // Update the state with the fetched values
      setState(() {
        totalExpense = expense;
        totalIncome = income;
        isLoading = false;
        print('Total Expense: $totalExpense');
        print('Total Income: $totalIncome');
      });
      // Force the rebuild of the widget after updating state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {});
      });
    } catch (e) {
      print("Error fetching total expense and income for account: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child:
                CircularProgressIndicator()) // Show loading indicator while fetching values
        : Obx(() {
            final HomeController _controller = Get.put(HomeController());
            final SummaryController transactionController =
                Get.find<SummaryController>();

            final CurrencyController currencyController =
                Get.find<CurrencyController>();
            String savedColor = "0xFF${widget.account.color}";
            print(transactionController.totalExpense);

            return Container(
              margin: EdgeInsets.all(10),
              child: CreditCardUi(
                cardHolderFullName: widget.account.cardHolder.toString(),
                cardNumber: '1234567812345678',
                validFrom: '01/23',
                validThru: '01/28',
                topLeftColor: ColorUtils.generateShades(
                  Color(int.parse(savedColor)),
                  200,
                )[3],
                doesSupportNfc: false,
                placeNfcIconAtTheEnd: true,
                cardType: CardType.debit,
                showBalance: true,
                balance: 128.32434343,
                autoHideBalance: true,
                enableFlipping: true, // 👈 Enables the flipping
                cvvNumber: '123',
              ),
            );
          });
  }
}



// class ContainerWidget extends StatefulWidget {
//   final BankAccount account;

//   ContainerWidget(this.account);

//   @override
//   State<ContainerWidget> createState() => _ContainerWidgetState();
// }

// class _ContainerWidgetState extends State<ContainerWidget> {
//   TextStyler textStyler = TextStyler();
//   double totalExpense = 0.0;
//   double totalIncome = 0.0;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     displayTotalExpenseAndIncomeForAccount(widget.account.id!.toInt());
//   }

//   void displayTotalExpenseAndIncomeForAccount(int accountId) async {
//     try {
//       // Fetch total expense and total income for the account
//       double expense =
//           await DatabaseHelper().getTotalExpenseForAccount(accountId);
//       double income =
//           await DatabaseHelper().getTotalIncomeForAccount(accountId);

//       // Update the state with the fetched values
//       setState(() {
//         totalExpense = expense;
//         totalIncome = income;
//         isLoading = false;
//         print('Total Expense: $totalExpense');
//         print('Total Income: $totalIncome');
//       });
//       // Force the rebuild of the widget after updating state
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         setState(() {});
//       });
//     } catch (e) {
//       print("Error fetching total expense and income for account: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Center(
//             child:
//                 CircularProgressIndicator()) // Show loading indicator while fetching values
//         : Obx(() {
//             final HomeController _controller = Get.put(HomeController());
//             final SummaryController transactionController =
//                 Get.find<SummaryController>();

//             final CurrencyController currencyController =
//                 Get.find<CurrencyController>();
//             String savedColor = "0xFF${widget.account.color}";
//             print(transactionController.totalExpense);

//             return Container(
//               padding: EdgeInsets.all(20.0),
//               margin: EdgeInsets.only(left: 20.0, right: 20, top: 20),
//               decoration: BoxDecoration(
//                 color: ColorUtils.generateShades(
//                   Color(int.parse(savedColor)),
//                   200,
//                 )[3],
//                 borderRadius: const BorderRadius.all(Radius.circular(30)),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.account.accountName.toString(),
//                             style: textStyler.mediumTextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: _controller.currentTheme.value ==
//                                         ThemeMode.dark
//                                     ? Colors.white
//                                     : Colors.black),
//                           ),
//                           Text(
//                             widget.account.cardHolder.toString(),
//                             style: textStyler.smallTextStyle(
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 13,
//                                 color: _controller.currentTheme.value ==
//                                         ThemeMode.dark
//                                     ? Colors.white
//                                     : Colors.black),
//                           ),
//                         ],
//                       ),
//                       Icon(Icons.cast_sharp),
//                     ],
//                   ),
//                   SizedBox(height: 10.0),
//                   Text(
//                     '${currencyController.selectedCurrency.value} ${widget.account.amount}',
//                     style: textStyler.largeTextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 30,
//                         color: _controller.currentTheme.value == ThemeMode.dark
//                             ? Colors.white
//                             : Colors.black),
//                   ),
//                   SizedBox(height: 10.0),
//                   Text(
//                     'this month'.tr,
//                     style: textStyler.largeTextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18,
//                         color: _controller.currentTheme.value == ThemeMode.dark
//                             ? Colors.white
//                             : Colors.black),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'income'.tr,
//                               style: textStyler.largeTextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                   color: _controller.currentTheme.value ==
//                                           ThemeMode.dark
//                                       ? Colors.white
//                                       : Colors.black),
//                             ),
//                             Text(
//                               '${currencyController.selectedCurrency.value} ${totalIncome}',
//                               style: textStyler.largeTextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                   color: _controller.currentTheme.value ==
//                                           ThemeMode.dark
//                                       ? Colors.white
//                                       : Colors.black),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'expense'.tr,
//                               style: textStyler.largeTextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 14,
//                                   color: _controller.currentTheme.value ==
//                                           ThemeMode.dark
//                                       ? Colors.white
//                                       : Colors.black),
//                             ),
//                             Text(
//                               '${currencyController.selectedCurrency.value} ${totalExpense}',
//                               style: textStyler.largeTextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 20,
//                                   color: _controller.currentTheme.value ==
//                                           ThemeMode.dark
//                                       ? Colors.white
//                                       : Colors.black),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             );
//           });
//   }
// }
