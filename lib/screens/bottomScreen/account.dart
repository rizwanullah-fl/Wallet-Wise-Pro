import 'package:expenses/controller/account_create.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_data_Screens.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/transaction_history.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    databaseHelper.loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<BankAccount>>(
        stream: databaseHelper.accountsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final accounts = snapshot.data ?? [];
            if (accounts.isEmpty) {
              return Center(
                child: Text('No accounts available'),
              );
            } else {
              return ListView.builder(
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  print(account.id);
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => TransactionHistory(account.id!.toInt()));
                    },
                    child: ContainerWidget(account),
                  );
                },
              );
            }
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddAccountScreen());
        },
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }
}
