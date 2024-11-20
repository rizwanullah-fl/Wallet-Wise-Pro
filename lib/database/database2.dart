import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper2 {
  static final DatabaseHelper2 instance = DatabaseHelper2._instance();
  static Database? _db;

  DatabaseHelper2._instance();

  String debtTable = 'debt';
  String creditTable = 'credit';
  String recurringTable = 'recurring'; // New recurring table

  String colId = 'id';
  String colSelectedIndex = 'selectedIndex';
  String colName = 'name';
  String colAccountName = 'account_name';
  String colAmount = 'amount';
  String colFirstDate = 'first_date';
  String colLastDate = 'last_date';

  // Columns for the recurring table
  String colRecurringName = 'recurring_name';
  String colSelectDateTime = 'select_date_time';
  String colSelectDaily = 'select_daily';
  String colSelectAccountId = 'select_account_id';
  String colSelectCategoryId = 'select_category_id';

  List<Map<String, dynamic>> _debits = [];

  List<Map<String, dynamic>> get debits => _debits;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await _initDB('expenses.db');
    }
    return _db;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    await db.execute(
      'CREATE TABLE $debtTable($colId $idType, $colSelectedIndex INTEGER, $colName $textType, $colAccountName $textType, $colAmount $doubleType, $colFirstDate TEXT, $colLastDate TEXT)',
    );
    await db.execute(
      'CREATE TABLE $creditTable($colId $idType, $colSelectedIndex INTEGER, $colName $textType, $colAccountName $textType, $colAmount $doubleType, $colFirstDate TEXT, $colLastDate TEXT)',
    );
    await db.execute(
      'CREATE TABLE $recurringTable($colId $idType, $colSelectedIndex INTEGER, $colRecurringName $textType, $colAmount $doubleType, $colSelectDateTime TEXT, $colSelectDaily TEXT, $colSelectAccountId INTEGER NOT NULL, $colSelectCategoryId INTEGER NOT NULL)',
    );
  }

  Future<int> insertDebt(Map<String, dynamic> row) async {
    Database? db = await this.db;
    return await db!.insert(debtTable, row);
  }

  Future<int> insertCredit(Map<String, dynamic> row) async {
    Database? db = await this.db;
    return await db!.insert(creditTable, row);
  }

  Future<int> insertRecurring(Map<String, dynamic> data) async {
    final db = await instance.db;
    return await db!.insert('recurring', data);
  }

  Future<List<Map<String, dynamic>>> getDebt() async {
    Database? db = await this.db;
    return await db!.query(debtTable);
  }

  Future<List<Map<String, dynamic>>> getDebits() async {
    final Database? db = await instance.db;
    final List<Map<String, dynamic>> debits = await db!.query('debt');
    return debits;
  }

  Future<void> deleteDebit(int id) async {
    final db = await instance.db;
    await db!.delete(
      'debt',
      where: '$colId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getCredit() async {
    Database? db = await this.db;
    return await db!.query(creditTable);
  }

  Future<int> updateDebt(Map<String, dynamic> row) async {
    Database? db = await this.db;
    int id = row[colId];
    return await db!
        .update(debtTable, row, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> updateCredit(Map<String, dynamic> row) async {
    Database? db = await this.db;
    int id = row[colId];
    return await db!
        .update(creditTable, row, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> deleteDebt(int id) async {
    Database? db = await this.db;
    return await db!.delete(debtTable, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> deleteCredit(int id) async {
    Database? db = await this.db;
    return await db!.delete(creditTable, where: '$colId = ?', whereArgs: [id]);
  }

  Future<int> deleteRecurring(int id) async {
    Database? db = await this.db;
    return await db!
        .delete(recurringTable, where: '$colId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRecurring() async {
    Database? db = await this.db;
    return await db!.query(recurringTable);
  }

  Future<int> updateRecurring(Map<String, dynamic> row) async {
    Database? db = await this.db;
    int id = row[colId];
    return await db!
        .update(recurringTable, row, where: '$colId = ?', whereArgs: [id]);
  }

  Future<void> reloadData() async {
    try {
      final Database? db = await instance.db;
      final List<Map<String, dynamic>> debits = await db!.query('debt');
      _debits = debits;
    } catch (e) {
      print('Error reloading data: $e');
    }
  }
}
