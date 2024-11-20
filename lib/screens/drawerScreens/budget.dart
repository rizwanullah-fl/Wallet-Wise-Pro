import 'dart:math';

import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    databaseHelper.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<List<Category>>(
            stream: DatabaseHelper()
                .categoriesStream, // Use the stream from your DatabaseHelper
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<Category>? categories = snapshot.data;
                return ListView.builder(
                  itemCount: categories!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Category category = categories[index];
                    print(category.iconName);
                    IconData iconData = IconData(int.parse(category.iconName),
                        fontFamily: 'MaterialIcons');
                    return category.budget.isEmpty ||
                            category.transferCategory == 1
                        ? Container()
                        : BudgetListItem(
                            categoryid: category.id!.toInt(),
                            icon: iconData,
                            color: Color(int.parse(category.colorName)),
                            name: category.holderName,
                            limit: category.budget,
                            spent: category.budget,
                            remaining: category.budget,
                            progressValue: category.budget);
                  },
                );
              }
            },
          )),
        ],
      ),
    );
  }
}

class BudgetListItem extends StatefulWidget {
  final int categoryid;
  final IconData icon;
  final String name;
  final String limit;
  final String spent;
  final String remaining;
  final String progressValue;
  final Color color;

  BudgetListItem({
    required this.categoryid,
    required this.icon,
    required this.name,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.progressValue,
    required this.color,
  });

  @override
  State<BudgetListItem> createState() => _BudgetListItemState();
}

class _BudgetListItemState extends State<BudgetListItem> {
  double totalSpent = 0.0;
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    getTotalSpent();
  }

  void getTotalSpent() async {
    try {
      double spent = await databaseHelper
          .getTotalTransactionsAmountForCategory(widget.categoryid);
      setState(() {
        totalSpent = spent;
      });
    } catch (e) {
      print("Error getting total spent: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double limitAmount = double.tryParse(widget.limit) ?? 0.0;

    // Calculate remaining amount and ensure it doesn't go below 0
    double remaining = max(0, limitAmount - totalSpent);
    Locale currentLocale = Get.locale ??
        Locale('en', 'US'); // Fallback to English if no locale is set
    String currentLanguageCode = currentLocale.languageCode;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 10),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: CircleAvatar(
            backgroundColor: widget.color,
            radius: 20,
            child: Icon(
              widget.icon,
              color: Colors.grey.shade200,
            ),
          ),
        ),
        SizedBox(width: 10), // Adjust the width as needed
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                widget.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Limit: ${widget.limit}',
              ),
              Text(
                'Spent: $totalSpent',
              ),
              Text(
                'Remaining: $remaining',
              ),
              SizedBox(height: 3),
              Container(
                margin: isLtr(currentLocale)
                    ? EdgeInsets.only(right: 20)
                    : EdgeInsets.only(left: 20),
                child: LinearProgressIndicator(
                  value: totalSpent / limitAmount,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool isLtr(Locale locale) {
    // You can add more LTR languages here if needed
    return locale.languageCode == 'en';
  }
}
