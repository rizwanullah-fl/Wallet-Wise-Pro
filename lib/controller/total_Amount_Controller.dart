import 'dart:async';

import 'package:expenses/database/create_account.dart';
import 'package:get/get.dart';

class TotalController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final totalAmount = 0.0.obs;
  late StreamSubscription<double> _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    _streamSubscription =
        _databaseHelper.getTotalAmountStream().listen((double amount) {
      totalAmount.value = amount;
    });
    _databaseHelper.loadAccounts();
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    _databaseHelper.loadAccounts();

    super.onClose();
  }
}
