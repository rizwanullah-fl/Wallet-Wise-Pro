import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/currency_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/controller/transaction_controller.dart';
import 'package:expenses/database/create_account.dart' as account;
import 'package:expenses/controller/total_Amount_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/Home.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/update_transactions.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BalanceContainer extends StatefulWidget {
  @override
  State<BalanceContainer> createState() => _BalanceContainerState();
}

class _BalanceContainerState extends State<BalanceContainer> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double totalExpenses = 0.0;

  double totalIncome = 0.0;
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalExpenses();
  }

  Future<void> fetchTotalExpenses() async {
    try {
      final total = await _databaseHelper.getTotalExpenses();
      final totalincome = await _databaseHelper.getTotalIncome();
      final totalbalance = await _databaseHelper.getTotalAmountStream();

      setState(() {
        totalExpenses = total;
        totalIncome = totalincome;
        balance = totalbalance as double;
        print(totalbalance);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching total expenses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final TotalController _totalAmountController = Get.put(TotalController());
      final CurrencyController currencyController =
          Get.find<CurrencyController>();
      final Color selectedColor =
          Get.find<ColorController>().getSelectedColor();

      TextStyler textStyler = TextStyler();
      final List<Color> colorShades =
          ColorUtils.generateShades(selectedColor, 200);
      final Color secondarycolor = colorShades[3];
      return Container(
        padding: EdgeInsets.all(
          20.0,
        ),
        decoration: BoxDecoration(
          color: secondarycolor,
          borderRadius: const BorderRadius.all(Radius.circular(30)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'totalbalance'.tr,
              style: textStyler.mediumTextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
            ),
            SizedBox(height: 10.0),
            Obx(
              () => Text(
                '${currencyController.selectedCurrency.value}${_totalAmountController.totalAmount.value}',
                style: textStyler.mediumTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.white),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'income'.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
                Text(
                  'expense'.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${totalIncome.toString()}',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white), // Replace with actual income value
                ),
                Text(
                  '\$${totalExpenses.toString()}', // Replace with actual expense value
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class CustomTransactionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final double amount;
  final Color iconColor;
  final String transactionType;
  final List<Transaction> transactionList;

  CustomTransactionContainer(
      {required this.title,
      required this.icon,
      required this.amount,
      required this.iconColor,
      required this.transactionType,
      required this.transactionList});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final HomeController _controller = Get.put(HomeController());
      final Color selectedColor =
          Get.find<ColorController>().getSelectedColor();

      TextStyler textStyler = TextStyler();
      final List<Color> colorShades =
          ColorUtils.generateShades(selectedColor, 200);
      final Color lightcolor = colorShades[0];
      final CurrencyController currencyController =
          Get.find<CurrencyController>();

      return Container(
        // Wrap your Container with Obx to listen to changes
        height: 120,
        width: 170,
        padding: EdgeInsets.only(left: 10.0, right: 10, top: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color:
              lightcolor, // This color will now update when the selected color changes
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title.tr,
              style: textStyler.mediumTextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _controller.currentTheme.value == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            ),
            SizedBox(height: 8.0),
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  color: iconColor,
                ),
                SizedBox(width: 8.0),
                Container(
                  width: MediaQuery.of(context).size.width - 294,
                  child: Text(
                    "${currencyController.selectedCurrency.value}$amount", // Change this to your desired price
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: iconColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            CustomCurveLine(
              color: iconColor, // Specify color
              name: title, // Specify name
              transactions:
                  transactionList, // Pass the list of income transactions from the database
              transactionType: transactionType, // Specify transaction type
            )
          ],
        ),
      );
    });
  }
}

class CustomCurveLine extends StatelessWidget {
  final Color color;
  final String name;
  final List<Transaction> transactions;
  final String transactionType;

  CustomCurveLine({
    required this.color,
    required this.name,
    required this.transactions,
    required this.transactionType,
  });

  @override
  Widget build(BuildContext context) {
    // Extracting the amounts from transactions based on the transaction type
    List<double> data = [];
    if (transactionType == 'income') {
      data = transactions
          .where((transaction) => transaction.type == 'income')
          .map((transaction) => transaction.amount)
          .toList();
    } else if (transactionType == 'expense') {
      data = transactions
          .where((transaction) => transaction.type == 'expense')
          .map((transaction) => transaction.amount)
          .toList();
    }

    // Placeholder data if no transactions found
    if (data.isEmpty) {
      data = [0.0, 0.0, 0.1];
    }

    return CustomPaint(
      painter: LinePainter(color: color, data: data),
      child: Container(
        height: 30, // You can customize the height of your line here
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<double> data;
  final Color color;

  LinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    final double maxData =
        data.reduce((curr, next) => curr > next ? curr : next);
    final double unitHeight = size.height / maxData;

    for (int i = 0; i < data.length - 1; i++) {
      final startPoint = Offset(
        (size.width / (data.length - 1)) * i,
        size.height - (data[i] * unitHeight),
      );
      final endPoint = Offset(
        (size.width / (data.length - 1)) * (i + 1),
        size.height - (data[i + 1] * unitHeight),
      );
      canvas.drawLine(startPoint, endPoint, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyListRow extends StatefulWidget {
  final Transaction transaction;
  final List<Transaction> transactionList;

  MyListRow({required this.transaction, required this.transactionList});

  @override
  State<MyListRow> createState() => _MyListRowState();
}

class _MyListRowState extends State<MyListRow> {
  final CurrencyController currencyController = Get.find<CurrencyController>();
  final TextStyler textStyler = TextStyler();
  final HomeController _controller = Get.put(HomeController());

  final CategorysController categoryController =
      Get.put(CategorysController(databaseHelper: DatabaseHelper()));

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (categoryController.isLoading.value) {
        return Center(child: CircularProgressIndicator());
      }

      final category =
          categoryController.getCategory(widget.transaction.categoryId);
      if (category == null) {
        // IconData iconData =
        //     IconData(int.parse(category!.iconName), fontFamily: 'MaterialIcons');

        return GestureDetector(
            onTap: () {
              account.Transaction selectedTransaction =
                  widget.transaction; // Use the alias here

              Get.to(() => Updatetransaction(
                        selectedIndex: widget.transaction.type == 'expense'
                            ? 0
                            : widget.transaction.type == 'income'
                                ? 1
                                : 2,
                        transactionList: widget.transactionList,
                        transaction: selectedTransaction,
                      ))!
                  .then((value) {
                setState(() {});
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.only(right: 16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 20,
                      child: Icon(Icons.ac_unit_outlined, color: Colors.indigo),
                    ),
                    subtitle: Text(
                      DateFormat.yMMMMd().format(
                        DateTime.parse(widget.transaction.dateTime),
                      ),
                      style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 12,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    title: Obx(() {
                      return Text(
                        widget.transaction.type == 'expense'
                            ? '${'transfer to'.tr} ${widget.transaction.description}'
                            : '${'received from'.tr} ${widget.transaction.description}',
                        style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      );
                    }),
                    trailing: Obx(() {
                      return Text(
                        '${currencyController.selectedCurrency.value}${widget.transaction.amount.toString()}',
                        style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: widget.transaction.type == 'expense'
                              ? Colors.red
                              : Colors.green,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ));
      }

      IconData iconData =
          IconData(int.parse(category.iconName), fontFamily: 'MaterialIcons');

      return GestureDetector(
        onTap: () {
          account.Transaction selectedTransaction =
              widget.transaction; // Use the alias here

          Get.to(() => Updatetransaction(
                    selectedIndex: widget.transaction.type == 'expense'
                        ? 0
                        : widget.transaction.type == 'income'
                            ? 1
                            : 2,
                    transactionList: widget.transactionList,
                    transaction: selectedTransaction,
                  ))!
              .then((value) {
            setState(() {});
          });
        },
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
                    DateTime.parse(widget.transaction.dateTime),
                  ),
                  style: textStyler.mediumTextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                title: Obx(() {
                  return Text(
                    widget.transaction.type == 'expense'
                        ? '${'transfer to'.tr} ${widget.transaction.description}'
                        : '${'received from'.tr} ${widget.transaction.description}',
                    style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }),
                trailing: Obx(() {
                  return Text(
                    '${currencyController.selectedCurrency.value}${widget.transaction.amount.toString()}',
                    style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: widget.transaction.type == 'expense'
                          ? Colors.red
                          : Colors.green,
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class CategorysController extends GetxController {
  final DatabaseHelper databaseHelper;

  CategorysController({required this.databaseHelper});

  var categories = <int, Category>{}.obs;
  var isLoading = true.obs;

  @override
  void onInit() async {
    super.onInit();
    fetchCategories();
    List<Category> categoryList = await databaseHelper.getCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true; // Set loading to true before fetching
      await databaseHelper.loadCategories();

      List<Category> categoryList = await databaseHelper.getCategories();
      categories.clear(); // Clear existing categories
      for (var category in categoryList) {
        categories[category.id!.toInt()] = category;
      }
    } catch (e) {
      print("Error fetching categories: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Category? getCategory(int categoryId) {
    return categories[categoryId];
  }

  Future<void> updateCategory(Category category) async {
    try {
      isLoading.value = true;
      await databaseHelper.updateCategory(category);
      await fetchCategories(); // Refresh the categories after update
    } catch (e) {
      print("Error updating category: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class CreditCardWidget extends StatefulWidget {
  final BankAccount account;

  CreditCardWidget(this.account);

  @override
  State<CreditCardWidget> createState() => _CreditCardWidgetState();
}

class _CreditCardWidgetState extends State<CreditCardWidget> {
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

  // final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final SummaryController transactionController =
        Get.find<SummaryController>();

    final CurrencyController currencyController =
        Get.find<CurrencyController>();
    String savedColor = "0xFF${widget.account.color}";
    print(transactionController.totalExpense);
    return Container(
      width: 450,
      height: 200,
      padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
      margin: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: ColorUtils.generateShades(
          Color(int.parse(savedColor)),
          200,
        )[4],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available balance',
            style: textStyler.mediumTextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            '\$ ${totalIncome}',
            style: textStyler.mediumTextStyle(
                fontWeight: FontWeight.bold, fontSize: 40, color: Colors.white),
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.account.accountName.toString(),
                style: textStyler.mediumTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'VISA',
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                  Container(width: 80, child: OverlappingCircles()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OverlappingCircles extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          right: 10,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class SavingsContainer extends StatefulWidget {
  @override
  State<SavingsContainer> createState() => _SavingsContainerState();
}

class _SavingsContainerState extends State<SavingsContainer> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double totalExpenses = 0.0;

  double totalIncome = 0.0;
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalExpenses();
  }

  Future<void> fetchTotalExpenses() async {
    try {
      final total = await _databaseHelper.getTotalExpenses();
      final totalincome = await _databaseHelper.getTotalIncome();
      final totalbalance = await _databaseHelper.getTotalAmountStream();

      setState(() {
        totalExpenses = total;
        totalIncome = totalincome;
        balance = totalbalance as double;
        print(totalbalance);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching total expenses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final TotalController _totalAmountController = Get.put(TotalController());
      final CurrencyController currencyController =
          Get.find<CurrencyController>();
      final Color selectedColor =
          Get.find<ColorController>().getSelectedColor();

      TextStyler textStyler = TextStyler();
      final List<Color> colorShades =
          ColorUtils.generateShades(selectedColor, 200);
      final Color secondarycolor = colorShades[3];
      return Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: secondarycolor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL SAVINGS',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white),
                ),
                Obx(
                  () => Container(
                    width: 270,
                    child: Text(
                      '${currencyController.selectedCurrency.value}${_totalAmountController.totalAmount.value}',
                      style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.savings_sharp,
              color: Colors.white,
              size: 36.0,
            ),
          ],
        ),
      );
    });
  }
}

class EarningsSpentContainer extends StatefulWidget {
  @override
  State<EarningsSpentContainer> createState() => _EarningsSpentContainerState();
}

class _EarningsSpentContainerState extends State<EarningsSpentContainer> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  double totalExpenses = 0.0;

  double totalIncome = 0.0;
  double balance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTotalExpenses();
  }

  Future<void> fetchTotalExpenses() async {
    try {
      final total = await _databaseHelper.getTotalExpenses();
      final totalincome = await _databaseHelper.getTotalIncome();
      final totalbalance = await _databaseHelper.getTotalAmountStream();

      setState(() {
        totalExpenses = total;
        totalIncome = totalincome;
        balance = totalbalance as double;
        print(totalbalance);
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching total expenses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final TotalController _totalAmountController = Get.put(TotalController());
      final CurrencyController currencyController =
          Get.find<CurrencyController>();
      final Color selectedColor =
          Get.find<ColorController>().getSelectedColor();

      TextStyler textStyler = TextStyler();
      final List<Color> colorShades =
          ColorUtils.generateShades(selectedColor, 200);
      final Color secondarycolor = colorShades[2];
      return Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: secondarycolor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL Income',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                Text(
                  '\$${totalIncome.toString()}', // Replace with actual expense value
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL Expense',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                Text(
                  '\$${totalExpenses.toString()}', // Replace with actual expense value
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// class IncomeExpenseChart extends StatelessWidget {
//   final Map<String, double> incomeData;
//   final Map<String, double> expenseData;
//   final String title;
//   final String period;

//   IncomeExpenseChart({
//     required this.incomeData,
//     required this.expenseData,
//     required this.title,
//     required this.period,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final incomeSpots = incomeData.entries.map((e) {
//       final date = _parseDate(e.key, period);
//       return ChartData(date, e.value);
//     }).toList();

//     final expenseSpots = expenseData.entries.map((e) {
//       final date = _parseDate(e.key, period);
//       return ChartData(date, e.value);
//     }).toList();

//     return SfCartesianChart(
//       backgroundColor: Colors.white, // Adding background color for visibility
//       title: ChartTitle(text: title),
//       legend: Legend(isVisible: true),
//       tooltipBehavior: TooltipBehavior(enable: true),
//       primaryXAxis: DateTimeAxis(
//         dateFormat: DateFormat('MM/dd'),
//         intervalType: _getIntervalType(period),
//       ),
//       primaryYAxis: NumericAxis(),
//       series: <ChartSeries>[
//         LineSeries<ChartData, DateTime>(
//           name: 'Income',
//           dataSource: incomeSpots,
//           xValueMapper: (ChartData data, _) => data.date,
//           yValueMapper: (ChartData data, _) => data.amount,
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           width: 2, // Explicitly setting line width
//           color:
//               Colors.green.withOpacity(0.7), // Setting line color with opacity
//         ),
//         LineSeries<ChartData, DateTime>(
//           name: 'Expense',
//           dataSource: expenseSpots,
//           xValueMapper: (ChartData data, _) => data.date,
//           yValueMapper: (ChartData data, _) => data.amount,
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           width: 2, // Explicitly setting line width
//           color: Colors.red.withOpacity(0.7), // Setting line color with opacity
//         ),
//       ],
//     );
//   }

//   DateTime _parseDate(String date, String period) {
//     switch (period) {
//       case 'weekly':
//         return DateFormat('yyyy-MM-dd').parse(date);
//       case 'monthly':
//         return _parseWeekDate(date);
//       case 'yearly':
//         return DateFormat('yyyy-MM').parse(date);
//       default:
//         throw Exception("Invalid period: $period");
//     }
//   }

//   DateTime _parseWeekDate(String week) {
//     var parts = week.split('-');
//     var year = int.parse(parts[0]);
//     var weekOfYear = int.parse(parts[1]);
//     var firstDayOfYear = DateTime(year, 1, 1);
//     var daysOffset = (weekOfYear - 1) * 7;
//     return firstDayOfYear.add(Duration(days: daysOffset));
//   }

//   DateTimeIntervalType _getIntervalType(String period) {
//     switch (period) {
//       case 'weekly':
//         return DateTimeIntervalType.days;
//       case 'monthly':
//         return DateTimeIntervalType.days;
//       case 'yearly':
//         return DateTimeIntervalType.months;
//       default:
//         throw Exception("Invalid period: $period");
//     }
//   }
// }

class MySegmentedTabControl extends StatelessWidget {
  final MyController _controller =
      Get.find<MyController>(); // Assuming you have a GetX controller

  MySegmentedTabControl({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedColor = Get.find<ColorController>().getSelectedColor();
      final colorShades = ColorUtils.generateShades(selectedColor, 200);
      final secondarycolor = colorShades[3];

      return Container(
        margin: EdgeInsets.only(left: 15, right: 15),
        child: SegmentedTabControl(
          tabTextColor: _controller.currentTheme.value == ThemeMode.dark
              ? Colors.white
              : Colors.black,
          barDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          indicatorDecoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(30)),
          ),
          selectedTabTextColor: Colors.white,
          indicatorPadding: const EdgeInsets.all(4),
          squeezeIntensity: 3,
          tabPadding: const EdgeInsets.symmetric(horizontal: 8),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          selectedTextStyle:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          tabs: [
            SegmentTab(
              label: 'weekly'.tr,
              color: secondarycolor,
              backgroundColor: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
            ),
            SegmentTab(
              label: 'monthly'.tr,
              backgroundColor: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
              color: secondarycolor,
            ),
            SegmentTab(
              label: 'yearly'.tr,
              backgroundColor: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.grey.shade900
                  : Colors.grey.shade300,
              color: secondarycolor,
            ),
          ],
        ),
      );
    });
  }
}
