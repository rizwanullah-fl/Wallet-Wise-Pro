import 'package:expenses/database/create_account.dart';
import 'package:get/get.dart';

class SummaryController extends GetxController {
  var totalIncome = 0.0.obs;
  var totalExpense = 0.0.obs;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    fetchSummary(); // Call fetchSummary method when the controller is initialized
  }

  Future<void> fetchSummary() async {
    try {
      double income = await _databaseHelper.getTotalIncomeForAllAccounts();
      double expense = await _databaseHelper.getTotalExpenseForAllAccounts();
      totalIncome.value = income;
      totalExpense.value = expense;
      print(totalExpense.value);
    } catch (e) {
      print("Error fetching summary: $e");
    }
  }
}
