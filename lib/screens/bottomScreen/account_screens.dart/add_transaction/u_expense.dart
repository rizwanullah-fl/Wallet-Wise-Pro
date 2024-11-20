import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/add_transactions_widgets.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:expenses/database/create_account.dart' as account;

class Uexpense extends StatefulWidget {
  final List<account.Transaction> transactionList;
  final account.Transaction transaction;

  const Uexpense({
    super.key,
    required this.transactionList,
    required this.transaction,
  });

  @override
  State<Uexpense> createState() => _UexpenseState();
}

class _UexpenseState extends State<Uexpense> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 30);
  int? selectedAccountId;
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with the transaction data
    expenseNameController.text = widget.transaction.description;
    amountController.text = widget.transaction.amount.toString();
    descriptionController.text = widget.transaction.description;
    selectedDate = DateTime.parse(widget.transaction.dateTime);
    selectedAccountId = widget.transaction.accountId;
    selectedCategoryId = widget.transaction.categoryId;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Expense Name',
          controller: expenseNameController,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Amount',
          controller: amountController,
          keyboardType: TextInputType.number,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        CustomTextFormField(
          hintText: 'Description',
          controller: descriptionController,
          borderRadius: 10.0,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black,
                    size: 30,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Row(
                children: [
                  Icon(
                    Icons.watch_later_outlined,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${selectedTime.format(context)}',
                    style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'select account'.tr,
          style: textStyler.mediumTextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black),
        ),
        SizedBox(height: 20),
        MyListView(
          onItemSelected: (accountId) {
            setState(() {
              selectedAccountId = accountId;
            });
          },
          // selectedId: selectedAccountId, // Pass the selected accountId
        ),
        SizedBox(height: 20),
        Text('select category'.tr),
        SizedBox(height: 20),
        TagList(
          filterByTransfer: false,
          onItemSelected: (index) {
            setState(() {
              selectedCategoryId = index;
            });
          },
          // selectedId: selectedCategoryId, // Pass the selected categoryId
        ),
        SizedBox(height: 20),
        Center(
          child: CustomElevatedButton(
            onPressed: () {
              updateExpense();
            },
            text: 'update'.tr,
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  void updateExpense() async {
    String expenseName = expenseNameController.text.trim();
    double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    String description = descriptionController.text.trim();

    // Check if any of the required fields are missing or invalid
    if (expenseName.isEmpty) {
      Get.snackbar('Error', 'Expense name cannot be empty',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
      return;
    }

    if (amount <= 0) {
      Get.snackbar('Error', 'Amount must be greater than zero',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
      return;
    }

    if (selectedAccountId == null) {
      Get.snackbar('Error', 'Please select an account',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
      return;
    }

    if (selectedCategoryId == null) {
      Get.snackbar('Error', 'Please select a category',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
      return;
    }

    try {
      print('account id $selectedAccountId');
      print('category id $selectedCategoryId');
      // Instantiate DatabaseHelper
      DatabaseHelper databaseHelper = DatabaseHelper();

      // Create updated transaction
      account.Transaction updatedTransaction = account.Transaction(
        id: widget.transaction.id,
        amount: amount,
        description: description,
        dateTime: selectedDate.toIso8601String(),
        accountId: selectedAccountId!,
        categoryId: selectedCategoryId!,
        type: 'expense',
      );

      // Update transaction
      await databaseHelper.updateTransaction(updatedTransaction);

      // Show success message
      Get.snackbar('Transaction Updated', 'Transaction successfully updated!',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));

      // Clear input fields
      expenseNameController.clear();
      amountController.clear();
      descriptionController.clear();

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      print(' $e');
      Get.snackbar('Error', 'Failed to update transaction. Please try again.',
          snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3));
    }
  }
}
