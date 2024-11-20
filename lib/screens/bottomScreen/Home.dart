import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/add_transaction.dart';
import 'package:expenses/screens/bottomScreen/get_all_transactions.dart';
import 'package:expenses/screens/bottomScreen/home_widgets.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/controller/profile_Controller.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:expenses/database/create_account.dart' as account;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  double totalExpenses = 0.0;
  double totalIncome = 0.0;
  bool isLoading = true;
  final PageController _pageController = PageController();

  late List<Map<String, dynamic>> transactions = [];
  List<account.Transaction> _transactionList = [];
  final CategorysController categoryController =
      Get.put(CategorysController(databaseHelper: DatabaseHelper()));

  late Future<Map<String, double>> weeklyIncomeFuture;
  late Future<Map<String, double>> weeklyExpenseFuture;
  late Future<Map<String, double>> monthlyIncomeFuture;
  late Future<Map<String, double>> monthlyExpenseFuture;
  late Future<Map<String, double>> yearlyIncomeFuture;
  late Future<Map<String, double>> yearlyExpenseFuture;

  @override
  void initState() {
    super.initState();
    fetchTotalExpenses();
    fetchTransactions();
    _databaseHelper.loadAccounts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register the RouteAware observer.
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    // Unregister the RouteAware observer.
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the current route has been popped and the previous route is visible again.
    fetchTotalExpenses();
    fetchTransactions();
  }

  Future<void> fetchTotalExpenses() async {
    try {
      final total = await _databaseHelper.getTotalExpenses();
      final totalincome = await _databaseHelper.getTotalIncome();

      setState(() {
        totalExpenses = total;
        totalIncome = totalincome;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching total expenses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchTransactions() async {
    try {
      List<Map<String, dynamic>> data =
          await _databaseHelper.getAllTransactionsFromAppExcludingDeleted();
      setState(() {
        transactions = data;
        _transactionList =
            data.map((item) => account.Transaction.fromMap(item)).toList();
      });
    } catch (e) {
      print("Error fetching transactions: $e");
      // Handle error accordingly
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    TextStyler textStyler = TextStyler();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[1];
    double transactionRowHeight = 77.0;
    // Total height for all transactions
    double transactionsHeight = transactionRowHeight * transactions.length + 50;
    // Screen height
    double screenHeight = MediaQuery.of(context).size.height;
    // Calculating the container height ensuring it does not exceed screen height
    double containerHeight =
        transactionsHeight < screenHeight ? transactionsHeight : screenHeight;
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final selectedTextStyle = textStyle?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: fontController.selectedFontFamily.value);
    final HomeController _controller = Get.put(HomeController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Obx(
                  () => Text(
                    'Hi  ${profileController.profileName.value}',
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Obx(
                  () => Text(
                    'wellcome back'.tr,
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 13,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                width: 500,
                color: Colors.transparent,
                child: StreamBuilder<List<BankAccount>>(
                  stream: _databaseHelper.accountsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final accounts = snapshot.data ?? [];
                      if (accounts.isEmpty) {
                        return Center(child: Text('No accounts available'));
                      } else {
                        return Swiper(
                          itemCount: accounts.length,
                          itemWidth: 398,
                          axisDirection: AxisDirection.right,
                          layout: SwiperLayout.STACK,
                          itemBuilder: (context, index) {
                            final account = accounts[index];
                            print(account.id);
                            return CreditCardWidget(account);
                          },
                        );
                      }
                    }
                  },
                ),
              ),
              // StreamBuilder<List<BankAccount>>(
              //   stream: _databaseHelper.accountsStream,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return SizedBox.shrink();
              //     } else if (snapshot.hasError) {
              //       return SizedBox.shrink();
              //     } else {
              //       final accounts = snapshot.data ?? [];
              //       return Center(
              //         child: Padding(
              //           padding: const EdgeInsets.symmetric(vertical: 20.0),
              //           child: SmoothPageIndicator(
              //             controller: _pageController,
              //             count: accounts.length,
              //             effect: WormEffect(
              //               dotHeight: 12,
              //               dotWidth: 12,
              //               activeDotColor: lightcolor,
              //               dotColor: Colors.grey.shade200,
              //             ),
              //           ),
              //         ),
              //       );
              //     }
              //   },
              // ),
              SizedBox(height: 20),

              SavingsContainer(),
              SizedBox(height: 20),
              MySegmentedTabControl(),
              SizedBox(height: 20),
              Container(
                  height: 400,
                  margin: const EdgeInsets.only(left: 22.0, right: 20),
                  child: TabBarView(children: [
                    Center(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future:
                            _databaseHelper.getTransactionsByPeriod('weekly'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('No data available');
                          } else {
                            return IncomeExpenseChart(
                              transactions: snapshot.data!,
                              title: "Income vs Expense (Weekly)",
                              period: 'weekly',
                            );
                          }
                        },
                      ),
                    ),
                    Center(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future:
                            _databaseHelper.getTransactionsByPeriod('monthly'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('No data available');
                          } else {
                            return IncomeExpenseChart(
                              transactions: snapshot.data!,
                              title: "Income vs Expense (Monthly)",
                              period: 'monthly',
                            );
                          }
                        },
                      ),
                    ),
                    Center(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future:
                            _databaseHelper.getTransactionsByPeriod('yearly'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return Text('No data available');
                          } else {
                            return IncomeExpenseChart(
                              transactions: snapshot.data!,
                              title: "Income vs Expense (Yearly)",
                              period: 'yearly',
                            );
                          }
                        },
                      ),
                    ),
                  ])),
              SizedBox(height: 20),
              EarningsSpentContainer(),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Obx(
                      () => Text(
                        'transactionhistory'.tr,
                        style: textStyler.largeTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Obx(
                      () => TextButton(
                        onPressed: () {
                          Get.to(() => AllTransactions());
                        },
                        child: Text(
                          'See All-->',
                          style: textStyler.largeTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _controller.currentTheme.value ==
                                      ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              categoryController.isLoading.value
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      height: containerHeight,
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> transactionData =
                              transactions[index];
                          account.Transaction transaction =
                              account.Transaction.fromMap(transactionData);

                          return Container(
                            height: transactionRowHeight,
                            child: Column(
                              children: [
                                Container(
                                  height:
                                      60, // Set a fixed height for each item
                                  child: MyListRow(
                                    transaction: transaction,
                                    transactionList: _transactionList,
                                  ),
                                ),
                                Divider(),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Get.to(() => AddTransaction(
                      selectedIndex: 0,
                    ))!
                .then((value) {
              fetchTransactions();
              fetchTotalExpenses();
              categoryController.categories();
            });
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.date, this.amount);
  final DateTime date;
  final double amount;

  @override
  String toString() => 'ChartData(date: $date, amount: $amount)';
}

// Define a global RouteObserver to be used for observing route changes.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyController extends GetxController {
  var currentTheme = ThemeMode.light.obs;
  var selectedTabIndex = 0.obs;

  void updateSelectedTabIndex(int index) {
    selectedTabIndex.value = index;
  }
}

class IncomeExpenseChart extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final String title;
  final String period;

  IncomeExpenseChart({
    required this.transactions,
    required this.title,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final MyController myController = Get.find();

    final incomeData = transactions
        .where((transaction) => transaction['type'] == 'income')
        .map((transaction) {
      final date = DateTime.parse(transaction['date_time']);
      return ChartData(date, transaction['amount']);
    }).toList();

    final expenseData = transactions
        .where((transaction) => transaction['type'] == 'expense')
        .map((transaction) {
      final date = DateTime.parse(transaction['date_time']);
      return ChartData(date, transaction['amount']);
    }).toList();

    return Obx(() {
      return SfCartesianChart(
        backgroundColor: myController.currentTheme.value == ThemeMode.light
            ? Colors.white
            : Colors.black,
        title: ChartTitle(
          text: title,
          textStyle: TextStyle(
            color: myController.currentTheme.value == ThemeMode.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        legend: Legend(
          isVisible: true,
          textStyle: TextStyle(
            color: myController.currentTheme.value == ThemeMode.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          textStyle: TextStyle(
            color: myController.currentTheme.value == ThemeMode.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        primaryXAxis: DateTimeAxis(
          dateFormat: DateFormat('MM/dd'),
          intervalType: _getIntervalType(period),
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: myController.currentTheme.value == ThemeMode.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        primaryYAxis: NumericAxis(
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: myController.currentTheme.value == ThemeMode.light
                ? Colors.black
                : Colors.white,
          ),
        ),
        series: <ChartSeries>[
          LineSeries<ChartData, DateTime>(
            name: 'Income',
            dataSource: incomeData,
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.amount,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            width: 2,
            color: Colors.green.withOpacity(0.7),
          ),
          LineSeries<ChartData, DateTime>(
            name: 'Expense',
            dataSource: expenseData,
            xValueMapper: (ChartData data, _) => data.date,
            yValueMapper: (ChartData data, _) => data.amount,
            dataLabelSettings: DataLabelSettings(isVisible: true),
            width: 2,
            color: Colors.red.withOpacity(0.7),
          ),
        ],
      );
    });
  }

  DateTimeIntervalType _getIntervalType(String period) {
    switch (period) {
      case 'weekly':
        return DateTimeIntervalType.days;
      case 'monthly':
        return DateTimeIntervalType.days;
      case 'yearly':
        return DateTimeIntervalType.months;
      default:
        throw Exception("Invalid period: $period");
    }
  }
}


  // Widget buildLineChart(Map<String, double> incomeData,
  //     Map<String, double> expenseData, String title, String period) {
  //   print('Income Data: $incomeData');
  //   print('Expense Data: $expenseData');

  //   if (incomeData.isEmpty && expenseData.isEmpty) {
  //     return Center(child: Text('No data available'));
  //   }

  //   // Ensure data continuity by filling in missing dates with zero values
  //   final List<MapEntry<String, double>> incomeEntries =
  //       _ensureDataContinuity(incomeData, period);
  //   final List<MapEntry<String, double>> expenseEntries =
  //       _ensureDataContinuity(expenseData, period);

  //   // Generate DateTime objects for domainFn
  //   final List<charts.Series<MapEntry<String, double>, DateTime>> series = [
  //     charts.Series<MapEntry<String, double>, DateTime>(
  //       id: 'Income',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (MapEntry<String, double> entry, _) {
  //         DateTime parsedDate = _parseDate(entry.key, period);
  //         print('Parsed Income Date: $parsedDate');
  //         return parsedDate;
  //       },
  //       measureFn: (MapEntry<String, double> entry, _) => entry.value,
  //       data: incomeEntries,
  //     ),
  //     charts.Series<MapEntry<String, double>, DateTime>(
  //       id: 'Expense',
  //       colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
  //       domainFn: (MapEntry<String, double> entry, _) {
  //         DateTime parsedDate = _parseDate(entry.key, period);
  //         print('Parsed Expense Date: $parsedDate');
  //         return parsedDate;
  //       },
  //       measureFn: (MapEntry<String, double> entry, _) => entry.value,
  //       data: expenseEntries,
  //     ),
  //   ];

  //   print('Series Data: $series');

  //   return charts.TimeSeriesChart(
  //     series,
  //     animate: true,
  //     dateTimeFactory: const charts.LocalDateTimeFactory(),
  //     defaultRenderer:
  //         charts.LineRendererConfig(includeArea: true, stacked: true),
  //     behaviors: [
  //       charts.SeriesLegend(),
  //       charts.ChartTitle(title, behaviorPosition: charts.BehaviorPosition.top),
  //       charts.ChartTitle('Amount',
  //           behaviorPosition: charts.BehaviorPosition.start),
  //       charts.ChartTitle(
  //           period == 'weekly'
  //               ? 'Days'
  //               : period == 'monthly'
  //                   ? 'Weeks'
  //                   : 'Months',
  //           behaviorPosition: charts.BehaviorPosition.bottom),
  //     ],
  //   );
  // }

  // DateTime _parseDate(String date, String period) {
  //   switch (period) {
  //     case 'weekly':
  //       return DateFormat('yyyy-MM-dd').parse(date);
  //     case 'monthly':
  //       return _parseWeekDate(date);
  //     case 'yearly':
  //       return DateFormat('yyyy-MM').parse(date);
  //     default:
  //       throw Exception("Invalid period: $period");
  //   }
  // }

  // List<MapEntry<String, double>> _ensureDataContinuity(
  //     Map<String, double> data, String period) {
  //   List<MapEntry<String, double>> entries = data.entries.toList();
  //   entries.sort((a, b) => a.key.compareTo(b.key));

  //   if (entries.isEmpty) return entries;

  //   DateTime startDate = _parseDate(entries.first.key, period);
  //   DateTime endDate = _parseDate(entries.last.key, period);
  //   Map<String, double> continuousData = {};

  //   for (var date = startDate;
  //       date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
  //       date = _incrementDate(date, period)) {
  //     String formattedDate = _formatDate(date, period);
  //     continuousData[formattedDate] =
  //         data.containsKey(formattedDate) ? data[formattedDate]! : 0.0;
  //   }

  //   return continuousData.entries.toList();
  // }

  // DateTime _incrementDate(DateTime date, String period) {
  //   switch (period) {
  //     case 'weekly':
  //       return date.add(Duration(days: 1));
  //     case 'monthly':
  //       return date.add(Duration(days: 7));
  //     case 'yearly':
  //       return DateTime(date.year, date.month + 1, 1);
  //     default:
  //       throw Exception("Invalid period: $period");
  //   }
  // }

  // String _formatDate(DateTime date, String period) {
  //   switch (period) {
  //     case 'weekly':
  //       return DateFormat('yyyy-MM-dd').format(date);
  //     case 'monthly':
  //       return '${date.year}-${(date.day / 7).ceil()}';
  //     case 'yearly':
  //       return DateFormat('yyyy-MM').format(date);
  //     default:
  //       throw Exception("Invalid period: $period");
  //   }
  // }

  // DateTime _parseWeekDate(String week) {
  //   var parts = week.split('-');
  //   var year = int.parse(parts[0]);
  //   var weekOfYear = int.parse(parts[1]);
  //   var firstDayOfYear = DateTime(year, 1, 1);
  //   var daysOffset = (weekOfYear - 1) * 7;
  //   return firstDayOfYear.add(Duration(days: daysOffset));
  // }