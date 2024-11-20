import 'package:expenses/database/create_account.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AccountController extends GetxController {
  final databaseHelper = DatabaseHelper();
  final accounts = <BankAccount>[].obs;

  @override
  void onInit() {
    loadAccounts();
    super.onInit();
  }

  Future<void> loadAccounts() async {
    try {
      final loadedAccounts = await databaseHelper.getAccounts();
      accounts.assignAll(loadedAccounts);
    } catch (e) {
      print("Error loading accounts: $e");
    }
  }

  Future<void> addAccount(BankAccount account) async {
    try {
      final id = await databaseHelper.insertAccount(account);
      account.id = id;
      accounts.add(account);
    } catch (e) {
      print("Error adding account: $e");
    }
  }

  Future<void> deleteAccount(int id) async {
    try {
      await databaseHelper.deleteAccount(id);
      accounts.removeWhere((account) => account.id == id);
    } catch (e) {
      print("Error deleting account: $e");
    }
  }
}
