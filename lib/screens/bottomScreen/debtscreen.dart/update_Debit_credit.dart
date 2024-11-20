import 'package:expenses/controller/debit_controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/screens/bottomScreen/debtscreen.dart/widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class UpdateDebitCredit extends StatefulWidget {
  final Map<String, dynamic> debit; // Receive the selected debit data

  UpdateDebitCredit({required this.debit});

  @override
  State<UpdateDebitCredit> createState() => _UpdateDebitCreditState();
}

class _UpdateDebitCreditState extends State<UpdateDebitCredit> {
  final DatabaseHelper2 dbHelper = DatabaseHelper2.instance;

  final TextEditingController name = TextEditingController();

  final TextEditingController description = TextEditingController();

  final TextEditingController amount = TextEditingController();

  final DebitController debitController = Get.put(DebitController());

  @override
  void initState() {
    super.initState();

    // Populate the TextFormField controllers with the selected debit's data
    name.text = widget.debit['name'];
    description.text = widget.debit['account_name'];
    amount.text = widget.debit['amount'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('update'.tr),
        actions: [
          IconButton(
            onPressed: () {
              // Show confirmation dialog before deleting
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm Delete"),
                    content:
                        Text("Are you sure you want to delete this debit?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Perform delete action
                          deleteDebit(widget
                              .debit['id']); // Implement deleteDebit method
                          Navigator.pop(context);
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter Card Holder Name',
                controller: amount,
                keyboardType: TextInputType.number,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter your Acount Name',
                controller: name,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'Enter your Amount',
                controller: description,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              MyDatePickerRow(
                startDateController: debitController.startDate,
                endDateController: debitController.endDate,
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'transactionhistory'.tr,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 270),
              CustomElevatedButton(
                onPressed: () {
                  updateDebit();
                },
                text: 'update'.tr,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void deleteDebit(int id) async {
    try {
      // Call the delete method from your dbHelper class
      await dbHelper.deleteDebit(id);
      // Show a snackbar or toast message indicating successful deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debit deleted successfully'),
        ),
      );
      // Navigate back to the previous screen after deletion
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that occur during deletion
      print('Error deleting debit: $e');
      // Show a snackbar or toast message indicating failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete debit'),
        ),
      );
    }
  }

  void updateDebit() async {
    try {
      // Prepare updated data
      Map<String, dynamic> updatedDebit = {
        'id': widget.debit['id'],
        'name': name.text,
        'account_name': description.text,
        'amount': double.parse(amount.text),
        'first_date': debitController.startDate.value.toIso8601String(),
        'last_date': debitController.endDate.value.toIso8601String(),
      };
      // Update the debit record in the database
      await dbHelper.updateDebt(updatedDebit);
      // Show a snackbar or toast message indicating successful update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debit updated successfully'),
        ),
      );
      // Navigate back to the previous screen after updat
      Navigator.pop(context);
    } catch (e) {
      // Handle any errors that occur during update
      print('Error updating debit: $e');
      // Show a snackbar or toast message indicating failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update debit'),
        ),
      );
    }
  }
}
