import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DebitController extends GetxController {
  var name = ''.obs;
  var description = ''.obs;
  var amount = ''.obs;
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _loadData(); // Load data when the controller is initialized
  }

  RxList<DebitModel> debitList = <DebitModel>[].obs;

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name.value = prefs.getString('name') ?? '';
    description.value = prefs.getString('description') ?? '';
    amount.value = prefs.getString('amount') ?? '';
    String? startDateString = prefs.getString('startDate');
    String? endDateString = prefs.getString('endDate');
    if (startDateString != null)
      startDate.value = DateTime.parse(startDateString);
    if (endDateString != null) endDate.value = DateTime.parse(endDateString);

    // Load debitList from SharedPreferences
    // Assuming debitList is stored as a JSON string
    String? debitListString = prefs.getString('debitList');
    if (debitListString != null) {
      Iterable decoded = jsonDecode(debitListString);
      List<DebitModel> tempList =
          decoded.map((model) => DebitModel.fromJson(model)).toList();
      debitList.assignAll(tempList);
    }
  }

  Future<void> saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name.value);
    await prefs.setString('description', description.value);
    await prefs.setString('amount', amount.value);
    await prefs.setString('startDate', startDate.value.toIso8601String());
    await prefs.setString('endDate', endDate.value.toIso8601String());

    // Save debitList to SharedPreferences
    // Assuming debitList is converted to a JSON string
    String debitListString = jsonEncode(debitList.toList());
    await prefs.setString('debitList', debitListString);
  }

  // Method to add a debit to the list
  void addDebit(DebitModel debit) {
    debitList.add(debit);
    saveData(); // Save the updated list
  }
}

class DebitModel {
  final String name;
  final String description;
  final String amount;
  final DateTime startDate;
  final DateTime endDate;

  DebitModel({
    required this.name,
    required this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
  });

  factory DebitModel.fromJson(Map<String, dynamic> json) {
    return DebitModel(
      name: json['name'],
      description: json['description'],
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}
