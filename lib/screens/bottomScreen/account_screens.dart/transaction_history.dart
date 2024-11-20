import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/add_transaction.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/update_transactions.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/update_account.dart';
import 'package:expenses/screens/bottomScreen/home_widgets.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:expenses/database/create_account.dart' as account;
import 'package:sqflite_common/sqlite_api.dart';

class TransactionHistory extends StatefulWidget {
  final int account;

  TransactionHistory(this.account);

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  final Color selectedColor = Get.find<ColorController>().getSelectedColor();

  DatabaseHelper databaseHelper = DatabaseHelper();

  TextStyler textStyler = TextStyler();

  List<account.Transaction> _transactionList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    try {
      List<account.Transaction> transactions =
          await databaseHelper.getTransactionsForAccount(widget.account);
      setState(() {
        _transactionList = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color secondarycolor = colorShades[3];
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'transactionhistory'.tr,
            style: textStyler.mediumTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: _controller.currentTheme.value == ThemeMode.dark
                    ? Colors.white
                    : Colors.black),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Get.to(() => UpdateAccount(
                      accountId: widget.account,
                    ));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  int deletedRows =
                      await databaseHelper.deleteAccount(widget.account);
                  await databaseHelper
                      .deleteAccountAndUpdateTransactions(widget.account);
                  await databaseHelper.loadAccounts();
                  print('Deleted $deletedRows row(s)');
                  Get.back();
                } catch (e) {
                  print('Error deleting account: $e');
                }
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: _transactionList.length,
          itemBuilder: (context, index) {
            account.Transaction transaction = _transactionList[index];
            if (categoryController.isLoading.value) {
              return CircularProgressIndicator();
            }

            final category =
                categoryController.getCategory(transaction.categoryId);
            if (category == null) {
              return Text('Category not found');
            }

            IconData iconData = IconData(int.parse(category.iconName),
                fontFamily: 'MaterialIcons');
            return GestureDetector(
              onTap: () {
                account.Transaction selectedTransaction =
                    _transactionList[index];
                if (_transactionList[index].type == 'expense') {
                  Get.to(() => Updatetransaction(
                            selectedIndex: 0,
                            transactionList: _transactionList,
                            transaction:
                                selectedTransaction, // Pass the transactionList
                          ))!
                      .then((value) {
                    _fetchTransactions();
                    setState(() {});
                  });
                } else if (_transactionList[index].type == 'income') {
                  Get.to(() => Updatetransaction(
                            selectedIndex: 1,
                            transactionList:
                                _transactionList, // Pass the transactionList
                            transaction: selectedTransaction,
                          ))!
                      .then((value) {
                    _fetchTransactions();
                    setState(() {});
                  });
                } else {
                  Get.to(() => Updatetransaction(
                            selectedIndex: 2,
                            transactionList:
                                _transactionList, // Pass the transactionList
                            transaction: selectedTransaction,
                          ))!
                      .then((value) {
                    _fetchTransactions();
                    setState(() {});
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.only(right: 16),
                        leading: CircleAvatar(
                          backgroundColor: ColorUtils.generateShades(
                            Color(int.parse(category.colorName)),
                            200,
                          )[0],
                          radius: 20,
                          child: Icon(
                            iconData,
                            color: Color(int.parse(category.colorName)),
                          ),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMMd().format(
                            DateTime.parse(transaction.dateTime),
                          ),
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        title: Obx(() {
                          return Text(
                            transaction.type == 'expense'
                                ? 'Transfer to ${transaction.description}'
                                : 'Received from ${transaction.description}',
                            style: textStyler.mediumTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _controller.currentTheme.value ==
                                      ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          );
                        }),
                        trailing: Obx(() {
                          return Text(
                            '${currencyController.selectedCurrency.value}${transaction.amount.toString()}',
                            style: textStyler.mediumTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: transaction.type == 'expense'
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                Get.to(() => AddTransaction(
                          selectedIndex: 1,
                        ))!
                    .then((value) async {
                  await _fetchTransactions();
                  setState(() {});
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: secondarycolor,
                ),
                height: 40,
                width: 110,
                child: Center(child: Text('income'.tr)),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
                onTap: () {
                  Get.to(() => AddTransaction(
                            selectedIndex: 0,
                          ))!
                      .then((value) async {
                    await _fetchTransactions();
                    setState(() {});
                  });
                },
                child: Container(
                    height: 40,
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: secondarycolor,
                    ),
                    child: Center(child: Text('expense'.tr))))
          ],
        ));
  }

  final HomeController _controller = Get.put(HomeController());
  final CategorysController categoryController =
      Get.put(CategorysController(databaseHelper: DatabaseHelper()));
  final CurrencyController currencyController = Get.find<CurrencyController>();
}
