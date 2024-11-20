import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/home_widgets.dart';
import 'package:flutter/material.dart';
import 'package:expenses/database/create_account.dart' as account;
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AllTransactions extends StatefulWidget {
  const AllTransactions({super.key});

  @override
  State<AllTransactions> createState() => _AllTransactionsState();
}

class _AllTransactionsState extends State<AllTransactions> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

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

  late List<Map<String, dynamic>> transactions = [];
  List<account.Transaction> _transactionList = [];
  final CategorysController categoryController =
      Get.put(CategorysController(databaseHelper: DatabaseHelper()));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction History'),
      ),
      body: categoryController.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> transactionData = transactions[index];
                    account.Transaction transaction =
                        account.Transaction.fromMap(transactionData);

                    return Column(
                      children: [
                        Container(
                          height: 60, // Set a fixed height for each item
                          child: MyListRow(
                            transaction: transaction,
                            transactionList: _transactionList,
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }
}
