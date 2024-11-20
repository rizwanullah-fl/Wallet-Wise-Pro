import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/home_widgets.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final int categoryId;
  final String type;
  final double totalIncome;

  const TransactionsScreen(
      {Key? key,
      required this.categoryId,
      required this.type,
      required this.totalIncome})
      : super(key: key);

  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final dbHelper = DatabaseHelper(); // Instantiate your DatabaseHelper class
  final TextStyler textStyler = TextStyler();
  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('transactionhistory'.tr),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  _getTransactionsForCategory(), // Fetch transactions for the selected category
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final transactions = snapshot.data ?? [];
                  // totalAmount = transactions.fold(
                  //     0.0, (sum, item) => sum + (item['amount'] ?? 0.0));

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final categoryController = Get.put(CategorysController(
                          databaseHelper: DatabaseHelper()));

                      if (categoryController.isLoading.value) {
                        return CircularProgressIndicator();
                      }

                      final category =
                          categoryController.getCategory(widget.categoryId);
                      if (category == null) {
                        return Text('Category not found');
                      }

                      IconData iconData = IconData(int.parse(category.iconName),
                          fontFamily: 'MaterialIcons');
                      print(transaction);
                      return ListTile(
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
                        title: Text(
                          transaction['description'],
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        trailing: Text(
                          '\$${transaction['amount']}',
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: transaction['type'] == 'income'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        subtitle: Text(
                          DateFormat.yMMMMd().format(
                            DateTime.parse(transaction['date_time']),
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
                        // Add more details about the transaction if needed
                      );
                    },
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            height: 50,
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'totalbalance'.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                      // : Colors.black,
                      ),
                ),
                Text(
                  '\$${widget.totalIncome}',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                      // : Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _getTransactionsForCategory() async {
    return dbHelper.getTransactionsForCategory(widget.categoryId,
        widget.type); // Fetch transactions for the selected category
  }
}

// class TransactionsByCategoryScreen extends StatefulWidget {
//   @override
//   _TransactionsByCategoryScreenState createState() =>
//       _TransactionsByCategoryScreenState();
// }

// class _TransactionsByCategoryScreenState
//     extends State<TransactionsByCategoryScreen> {
//   DatabaseHelper databaseHelper = DatabaseHelper();
//   List<Map<String, dynamic>> transactionsByCategory = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTransactionsByCategory();
//   }

//   Future<void> _fetchTransactionsByCategory() async {
//     try {
//       List<Map<String, dynamic>> result =
//           await databaseHelper.getTransactionsGroupedByCategory();
//       setState(() {
//         transactionsByCategory = result;
//         isLoading = false;
//       });
//     } catch (e) {
//       print("Error fetching transactions by category: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Transactions by Category'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: transactionsByCategory.length,
//               itemBuilder: (context, index) {
//                 final category = transactionsByCategory[index];
//                 return ListTile(
//                   title: Text(category['category_name']),
//                   subtitle: Text('Total Amount: ${category['total']}'),
//                 );
//               },
//             ),
//     );
//   }
// }
