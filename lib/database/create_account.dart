import 'dart:async';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expenses/database/create_account.dart' as account;

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper = DatabaseHelper._();
  static Database? _database;
  List<int> deletedAccountIds = []; // Track deleted account IDs

  StreamController<List<BankAccount>> _accountsController =
      StreamController<List<BankAccount>>.broadcast();
  StreamController<List<Category>> _categoriesController =
      StreamController<List<Category>>.broadcast();
  StreamController<List<Map<String, dynamic>>> _transactionsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  DatabaseHelper._();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'bank.db');
    var bankDatabase = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
      readOnly: false, // Ensure readOnly is set to false
    );
    return bankDatabase;
  }

  Future<void> _createDb(Database db, int newVersion) async {
    await db.execute('''
    CREATE TABLE bank_account(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      card_holder TEXT,
      account_name TEXT,
      amount REAL,
      pin_code TEXT,
      color TEXT,
      selected_index INTEGER
    )
  ''');
    await db.execute('''
      CREATE TABLE ${Category.tableName}(
        ${Category.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Category.colHolderName} TEXT,
        ${Category.colDescription} TEXT,
        ${Category.colIconName} TEXT,
        ${Category.colColorName} TEXT,
        ${Category.colBudget} TEXT,
        ${Category.colTransferCategory} INTEGER
      )
    ''');

    await db.execute('''
    CREATE TABLE ${Transaction.tableName}(
      ${Transaction.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${Transaction.colType} TEXT,
      ${Transaction.colAmount} REAL,
      ${Transaction.colDescription} TEXT,
      ${Transaction.colDateTime} TEXT,
      ${Transaction.colAccountId} INTEGER,
      ${Transaction.colCategoryId} INTEGER,
      FOREIGN KEY(${Transaction.colAccountId}) REFERENCES ${BankAccount.tableName}(${BankAccount.colId}),
      FOREIGN KEY(${Transaction.colCategoryId}) REFERENCES ${Category.tableName}(${Category.colId})
    )
  ''');
    await db.execute('''
      CREATE TABLE transactions_(
        ${Transaction.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Transaction.colType} TEXT,
        ${Transaction.colAmount} REAL,
        ${Transaction.colDescription} TEXT,
        ${Transaction.colDateTime} TEXT,
        ${Transaction.colAccountId} INTEGER,
        ${Transaction.colCategoryId} INTEGER,
        FOREIGN KEY(${Transaction.colAccountId}) REFERENCES ${BankAccount.tableName}(${BankAccount.colId}),
        FOREIGN KEY(${Transaction.colCategoryId}) REFERENCES ${Category.tableName}(${Category.colId})
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS ${Category.tableName}(
          ${Category.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
          ${Category.colHolderName} TEXT,
          ${Category.colDescription} TEXT,
          ${Category.colIconName} TEXT,
          ${Category.colColorName} TEXT,
          ${Category.colBudget} TEXT,
          ${Category.colTransferCategory} INTEGER
        )
      ''');
    }
  }

  Future<void> reloadDatabase() async {
    try {
      _accountsController.close();
      _categoriesController.close();

      // Create new instances of StreamControllers
      _accountsController = StreamController<List<BankAccount>>.broadcast();
      _categoriesController = StreamController<List<Category>>.broadcast();

      // Reload accounts and categories
      await loadAccounts();
      await loadCategories();
      await reloadTransactions();

      // Notify listeners about the updated data
      _accountsController.add(await getAccounts());
      _categoriesController.add(await getCategories());
    } catch (e) {
      print("Error reloading database: $e");
      throw e;
    }
  }

  Future<double> getTotalTransactionsAmountForCategory(int categoryId) async {
    try {
      final db = await database;

      // Fetch total transaction amount for the specified category
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions_ 
      WHERE category_id = ?
    ''', [categoryId]);

      print(result);

      // Extract total amount from the result
      if (result.isNotEmpty && result[0]['total'] != null) {
        return result[0]['total'] as double;
      } else {
        return 0.0; // Return 0.0 if no transactions found
      }
    } catch (e) {
      print("Error calculating total transactions amount for category: $e");
      throw e;
    }
  }

  Future<void> reloadTransactions() async {
    try {
      _transactionsController.close();
      _transactionsController =
          StreamController<List<Map<String, dynamic>>>.broadcast();
      _transactionsController
          .add(await getAllTransactionsFromAppExcludingDeleted());
    } catch (e) {
      print("Error reloading transactions: $e");
      throw e;
    }
  }

  Future<void> createAccountTransactionsTable(
      Database db, int accountId) async {
    try {
      final List<Map<String, dynamic>> tableCheck = await db.rawQuery('''
    SELECT count(*) as count FROM sqlite_master 
    WHERE type = 'table' AND name = 'transactions_$accountId'
    ''');

      if (tableCheck[0]['count'] == 0) {
        await db.execute('''
      CREATE TABLE transactions_$accountId (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        amount REAL,
        description TEXT,
        date_time TEXT,
        account_id INTEGER,
        category_id INTEGER
      )
      ''');

        print('Created table transactions_$accountId');
      }
    } catch (e) {
      print("Error creating transactions table for account $accountId: $e");
      throw e;
    }
  }

  Stream<double> getTotalAmountStream() {
    return _accountsController.stream.map<double>((accounts) {
      double total = 0.0;
      for (var account in accounts) {
        total += account.amount;
      }
      return total;
    });
  }

  Future<List<Map<String, dynamic>>> getTransactionsGroupedByCategory() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        c.${Category.colId} as category_id,
        c.${Category.colHolderName} as category_name,
        c.${Category.colIconName} as category_icon,
        c.${Category.colColorName} as category_color,
        c.${Category.colBudget} as category_budget,
        SUM(t.${Transaction.colAmount}) as total_amount 
      FROM 
        ${Category.tableName} c
      LEFT JOIN 
        ${Transaction.tableName} t
      ON 
        c.${Category.colId} = t.${Transaction.colCategoryId}
      GROUP BY 
        c.${Category.colId}, c.${Category.colHolderName}, c.${Category.colIconName}, c.${Category.colColorName}, c.${Category.colBudget}
    ''');

      print("Transactions grouped by category: $result");

      return result;
    } catch (e) {
      print("Error fetching transactions grouped by category: $e");
      throw e;
    }
  }

  Future<int> insertAccount(BankAccount account) async {
    final db = await database;
    var result = await db.insert(BankAccount.tableName, account.toMap());
    _accountsController.sink.add(await getAccounts());
    return result;
  }

  Future<double> getTotalExpenses() async {
    try {
      final db = await database;

      // Fetch all tables that are transaction tables
      final List<Map<String, dynamic>> tables = await db.rawQuery('''
    SELECT name FROM sqlite_master 
    WHERE type = 'table' AND name LIKE 'transactions_%'
    ''');

      double totalExpenses = 0.0;

      for (var table in tables) {
        final String tableName = table['name'];
        final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $tableName WHERE type = 'expense'
      ''');

        // Check if the result is not null and has data
        if (result.isNotEmpty && result[0]['total'] != null) {
          totalExpenses += result[0]['total'];
        }
      }

      return totalExpenses;
    } catch (e) {
      print("Error calculating total expenses: $e");
      throw e;
    }
  }

  Future<double> getTotalIncome() async {
    try {
      final db = await database;

      // Fetch all tables that are transaction tables
      final List<Map<String, dynamic>> tables = await db.rawQuery('''
    SELECT name FROM sqlite_master 
    WHERE type = 'table' AND name LIKE 'transactions_%'
    ''');

      double totalIncome = 0.0;

      for (var table in tables) {
        final String tableName = table['name'];
        final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $tableName WHERE type = 'income'
      ''');

        // Check if the result is not null and has data
        if (result.isNotEmpty && result[0]['total'] != null) {
          totalIncome += result[0]['total'];
        }
      }

      return totalIncome;
    } catch (e) {
      print("Error calculating total income: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionsByPeriod(
      String period) async {
    final db = await database;
    String dateFormat;

    switch (period) {
      case 'weekly':
        dateFormat = '%Y-%m-%d';
        break;
      case 'monthly':
        dateFormat = '%Y-%m';
        break;
      case 'yearly':
        dateFormat = '%Y';
        break;
      default:
        throw Exception("Invalid period: $period");
    }

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * 
      FROM transactions_
      ORDER BY date_time
    ''');

    return result;
  }

  Future<List<BankAccount>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(BankAccount.tableName);
    return List<BankAccount>.generate(maps.length, (i) {
      return BankAccount.fromMap(maps[i]);
    });
  }

  Future<void> updateTransfer(int transactionId, double newAmount,
      int newAccountId, int newCategoryId) async {
    try {
      final db = await database;

      // Retrieve the original transaction
      final List<Map<String, dynamic>> originalTransaction = await db.query(
        'transactions_',
        where: '${Transaction.colId} = ?',
        whereArgs: [transactionId],
      );

      // Ensure the transaction exists
      if (originalTransaction.isEmpty) {
        throw Exception("Transaction not found with ID: $transactionId");
      }

      // Retrieve the original amount, account ID, and category ID
      final double originalAmount =
          originalTransaction[0][Transaction.colAmount] as double;
      final int originalAccountId =
          originalTransaction[0][Transaction.colAccountId] as int;
      final int originalCategoryId =
          originalTransaction[0][Transaction.colCategoryId] as int;

      // Update the original transaction with the new amount, description, account ID, and category ID
      await db.update(
        'transactions_',
        {
          Transaction.colAmount: newAmount,
          Transaction.colAccountId: newAccountId,
          Transaction.colCategoryId: newCategoryId,
        },
        where: '${Transaction.colId} = ?',
        whereArgs: [transactionId],
      );

      // Calculate the difference in amount
      final double amountDifference = newAmount - originalAmount;

      // Update the original account's balance accordingly
      await updateAccountBalance(db, originalAccountId, -amountDifference);

      // Update the new account's balance accordingly
      await updateAccountBalance(db, newAccountId, amountDifference);
    } catch (e) {
      print("Error updating transfer: $e");
      throw e;
    }
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    int result = await db.delete(
      BankAccount.tableName,
      where: '${BankAccount.colId} = ?',
      whereArgs: [id],
    );
    if (result > 0) {
      deletedAccountIds.add(id); // Add the deleted account ID to the list
      _accountsController.sink.add(await getAccounts());
    }
    return result;
  }

  Future<void> deleteAccountAndUpdateTransactions(int id) async {
    try {
      final db = await database;

      // Step 1: Delete the account
      await db.delete(
        BankAccount.tableName,
        where: '${BankAccount.colId} = ?',
        whereArgs: [id],
      );

      // Step 2: Retrieve all transactions associated with the deleted account
      final List<Map<String, dynamic>> transactions = await db.query(
        'transactions_',
        where: 'account_id = ?',
        whereArgs: [id],
      );

      // Step 3: Update each transaction to deduct the account's amount
      for (var transaction in transactions) {
        double amount = transaction['amount'];
        int transactionId = transaction['id'];

        // Update the transaction amount
        await db.rawUpdate('''
        UPDATE transactions_
        SET amount = amount - ?
        WHERE id = ?
      ''', [amount, transactionId]);
      }

      // Step 4: Update the account's balance in the database
      // Calculate the total amount for the deleted account's transactions
      final totalAmount = transactions.fold(0.0, (sum, transaction) {
        return sum + (transaction['amount'] as double);
      });

      // Retrieve the current balance of the deleted account
      final currentBalance = (await getAccount(id))?.amount ?? 0.0;

      // Update the account's balance in the database
      await db.rawUpdate('''
      UPDATE ${BankAccount.tableName}
      SET ${BankAccount.colAmount} = ?
      WHERE ${BankAccount.colId} = ?
    ''', [currentBalance - totalAmount, id]);
    } catch (e) {
      print("Error deleting account and updating transactions: $e");
      throw e;
    }
  }

  Stream<List<BankAccount>> get accountsStream => _accountsController.stream;

  Future<void> loadAccounts() async {
    try {
      final List<BankAccount> accounts = await getAccounts();
      _accountsController.add(accounts);
    } catch (e) {
      print("Error loading accounts: $e");
      _accountsController.addError(e);
    }
  }

  Future<int> updateAccount(BankAccount account) async {
    final db = await database;
    return await db.update(
      'bank_account',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> insertCategory(Category category) async {
    Database? db = await this.database;
    if (db != null) {
      var result = await db.insert(Category.tableName, category.toMap());
      _categoriesController.sink.add(await getCategories());
      return result;
    } else {
      throw Exception("Database is null");
    }
  }

  Future<List<Category>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(Category.tableName);
    return List<Category>.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;

    try {
      // Step 1: Delete the category itself
      await db.delete(
        Category.tableName,
        where: '${Category.colId} = ?',
        whereArgs: [id],
      );

      // Step 2: Retrieve all transactions associated with the deleted category
      final List<Map<String, dynamic>> transactions = await db.query(
        'transactions_',
        where: '${Transaction.colCategoryId} = ?',
        whereArgs: [id],
      );

      // Step 3: Delete each of these transactions
      for (var transaction in transactions) {
        int transactionId = transaction[Transaction.colId] as int;
        await db.delete(
          'transactions_',
          where: '${Transaction.colId} = ?',
          whereArgs: [transactionId],
        );
      }

      // Notify listeners about the updated categories
      _categoriesController.sink.add(await getCategories());
    } catch (e) {
      print("Error deleting category and associated transactions: $e");
      throw e;
    }
  }

  Stream<List<Category>> get categoriesStream => _categoriesController.stream;

  Future<void> loadCategories() async {
    try {
      final List<Category> categories = await getCategories();
      _categoriesController.add(categories);
    } catch (e) {
      print("Error loading categories: $e");
      _categoriesController.addError(e);
    }
  }

  Future<Category?> getcategoryByid(int id) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> result = await db.query(
        Category.tableName,
        where: '${Category.colId} = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return Category.fromMap(result.first);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching category: $e");
      return null;
    }
  }

  Future<BankAccount?> getAccount(int id) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> result = await db.query(
        BankAccount.tableName,
        where: '${BankAccount.colId} = ?',
        whereArgs: [id],
      );

      if (result.isEmpty) {
        print("No account found with ID: $id");
        return null;
      }

      return BankAccount.fromMap(result.first);
    } catch (e) {
      print("Error fetching account: $e");
      throw e;
    }
  }

  Future<void> loadTransactions() async {
    try {
      final List<Map<String, dynamic>> transactions =
          await getAllTransactionsFromAppExcludingDeleted();
      _transactionsController.add(transactions);
    } catch (e) {
      print("Error loading transactions: $e");
      _transactionsController.addError(e);
    }
  }

  Future<List<Map<String, dynamic>>>
      getAllTransactionsFromAppExcludingDeleted() async {
    try {
      final db = await database;

      // Fetch all transactions from all accounts
      final List<Map<String, dynamic>> transactions =
          await db.query('transactions_');

      // Filter out transactions associated with deleted accounts
      final filteredTransactions = transactions.where((transaction) {
        final accountId = transaction['account_id'];
        return !deletedAccountIds.contains(accountId);
      }).toList();

      // Sort the transactions by date/time, handling null values
      filteredTransactions.sort((a, b) {
        final aDateTime = a['dateTime'];
        final bDateTime = b['dateTime'];

        // Handle cases where dateTime is null
        if (aDateTime == null && bDateTime == null) {
          return 0;
        } else if (aDateTime == null) {
          // Treat null aDateTime as earlier than any non-null bDateTime
          return -1;
        } else if (bDateTime == null) {
          // Treat null bDateTime as earlier than any non-null aDateTime
          return 1;
        } else {
          return aDateTime.compareTo(bDateTime);
        }
      });

      return filteredTransactions;
    } catch (e) {
      print("Error fetching all transactions from the app: $e");
      throw e;
    }
  }

  Future<int> addExpense(String expenseName, double amount, String description,
      int categoryId, int accountId) async {
    try {
      final db = await database;
      await createAccountTransactionsTable(
          db, accountId); // Ensure the table exists

      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      var transactionId = await db.insert(
        'transactions_',
        {
          'type': 'expense', // Use 'type' to denote expense type
          'amount': amount,
          'description': description,
          'date_time': formattedDate,
          'account_id': accountId,
          'category_id': categoryId,
        },
      );

      await updateAccountBalance(db, accountId, -amount);

      print(
          'Inserted transaction ID: $transactionId into transactions_$accountId');

      return transactionId;
    } catch (e) {
      print("Error adding expense: $e");
      throw e;
    }
  }

  Future<int> addIncome(String incomeName, double amount, String description,
      int categoryId, int accountId) async {
    try {
      final db = await database;
      await createAccountTransactionsTable(
          db, accountId); // Ensure the table exists

      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      var transactionId = await db.insert(
        'transactions_',
        {
          'type': 'income', // Use 'type' to denote income type
          'amount': amount,
          'description': description,
          'date_time': formattedDate,
          'account_id': accountId,
          'category_id': categoryId,
        },
      );

      await updateAccountBalance(db, accountId, amount);

      print(
          'Inserted transaction ID: $transactionId into transactions_$accountId');

      return transactionId;
    } catch (e) {
      print("Error adding income: $e");
      throw e;
    }
  }

  Future<void> updateAccountBalance(
      Database db, int accountId, double amount) async {
    try {
      var account = await getAccount(accountId);
      if (account == null) {
        print("Account with ID $accountId not found.");
        return;
      }

      double newBalance = account.amount + amount;
      await db.update(
        BankAccount.tableName,
        {BankAccount.colAmount: newBalance},
        where: '${BankAccount.colId} = ?',
        whereArgs: [accountId],
      );

      print("Account balance updated successfully. New balance: $newBalance");
    } catch (e) {
      print("Error updating account balance: $e");
      throw e;
    }
  }

  Future<int> addTransfer(double amount, String description, int categoryId,
      int fromAccountId, int toAccountId) async {
    try {
      final db = await database;
      await createAccountTransactionsTable(
          db, fromAccountId); // Ensure the table exists
      await createAccountTransactionsTable(
          db, toAccountId); // Ensure the table exists

      var now = DateTime.now();
      var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

      // Insert transaction for the source account (debit)
      var transactionIdFrom = await db.insert(
        'transactions_',
        {
          'type': 'Transfer',
          'amount': -amount,
          'description': description,
          'date_time': formattedDate,
          'account_id': fromAccountId,
          'category_id': categoryId,
        },
      );

      // Insert transaction for the destination account (credit)
      var transactionIdTo = await db.insert(
        'transactions_',
        {
          'type': 'Transfer',
          'amount': amount,
          'description': description,
          'date_time': formattedDate,
          'account_id': toAccountId,
          'category_id': categoryId,
        },
      );

      // Update balances for both accounts
      await updateAccountBalance(
          db, fromAccountId, -amount); // Deduct from source account
      await updateAccountBalance(
          db, toAccountId, amount); // Add to destination account

      return transactionIdTo;
    } catch (e) {
      print("Error adding transfer: $e");
      throw e;
    }
  }

  Future<List<Transaction>> getTransactionsForAccount(int accountId) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'transactions_',
        where: 'account_id = ?',
        whereArgs: [accountId],
      );

      // Convert the List<Map<String, dynamic>> to a List<Transaction>
      List<Transaction> transactions =
          maps.map((map) => Transaction.fromMap(map)).toList();

      // Sort the transactions by date/time if necessary
      transactions.sort((a, b) {
        final aDateTime = a.dateTime;
        final bDateTime = b.dateTime;

        // Check if both dates are null
        if (aDateTime == null && bDateTime == null) {
          return 0;
        }

        // If aDateTime is null, consider a greater than b
        if (aDateTime == null) {
          return 1;
        }

        // If bDateTime is null, consider b greater than a
        if (bDateTime == null) {
          return -1;
        }

        // If both dates are not null, compare them
        return aDateTime.compareTo(bDateTime);
      });

      return transactions;
    } catch (e) {
      print("Error fetching transactions for account: $e");
      throw e;
    }
  }

  Future<double> getTotalExpenseForAccount(int accountId) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'transactions_',
        where: 'account_id = ? AND type = ?',
        whereArgs: [accountId, 'expense'],
      );

      double totalExpense =
          maps.fold(0, (total, map) => total + (map['amount'] ?? 0.0));
      return totalExpense;
    } catch (e) {
      print("Error fetching total expense for account: $e");
      throw e;
    }
  }

  // Method to get total income for a specific account
  Future<double> getTotalIncomeForAccount(int accountId) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        'transactions_',
        where: 'account_id = ? AND type = ?',
        whereArgs: [accountId, 'income'],
      );

      double totalIncome =
          maps.fold(0, (total, map) => total + (map['amount'] ?? 0.0));
      return totalIncome;
    } catch (e) {
      print("Error fetching total income for account: $e");
      throw e;
    }
  }

  Future<double> getTotalIncomeForAllAccounts() async {
    try {
      final List<BankAccount> accounts = await getAccounts();
      double totalIncome = 0.0;

      for (var account in accounts) {
        double accountIncome =
            await getTotalIncomeForAccount(account.id!.toInt());
        totalIncome += accountIncome;
      }

      return totalIncome;
    } catch (e) {
      print("Error fetching total income for all accounts: $e");
      throw e;
    }
  }

  // Method to get total expense for all accounts
  Future<double> getTotalExpenseForAllAccounts() async {
    try {
      final List<BankAccount> accounts = await getAccounts();
      double totalExpense = 0.0;

      for (var account in accounts) {
        double accountExpense =
            await getTotalExpenseForAccount(account.id!.toInt());
        totalExpense += accountExpense;
        print(accountExpense);
      }

      return totalExpense;
    } catch (e) {
      print("Error fetching total expense for all accounts: $e");
      throw e;
    }
  }

  Future<double> getTotalIncomeForCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions_ 
      WHERE category_id = ? AND type = 'income'
    ''', [categoryId]);

    if (result.isNotEmpty && result[0]['total'] != null) {
      return result[0]['total'] as double;
    } else {
      return 0.0;
    }
  }

  Future<double> getTotalExpenseForCategory(int categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT SUM(amount) as total 
      FROM transactions_ 
      WHERE category_id = ? AND type = 'expense'
    ''', [categoryId]);

    if (result.isNotEmpty && result[0]['total'] != null) {
      return result[0]['total'] as double;
    } else {
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionsForCategory(
      int categoryId, String transactionType) async {
    try {
      final db = await database;

      // Fetch transactions for the specified category and type
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * 
      FROM transactions_ 
      WHERE category_id = ? AND type = ?
    ''', [categoryId, transactionType]);

      return result;
    } catch (e) {
      print("Error fetching transactions for category: $e");
      throw e;
    }
  }

  Future<int> updateTransaction(account.Transaction transaction) async {
    try {
      final db = await database;
      return await db.update(
        'transactions_',
        transaction.toMap(),
        where: '${account.Transaction.colId} = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      print("Error updating transaction: $e");
      throw e;
    }
  }

  Future<int> updateCategory(Category category) async {
    try {
      final db = await database;
      int result = await db.update(
        Category.tableName,
        category.toMap(),
        where: '${Category.colId} = ?',
        whereArgs: [category.id],
      );
      _categoriesController.sink.add(await getCategories());
      return result;
    } catch (e) {
      print("Error updating category: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDay(
      String period, String type) async {
    final db = await database;
    String dateFormat;

    switch (period) {
      case 'weekly':
        dateFormat = '%Y-%m-%d';
        break;
      case 'monthly':
        dateFormat = '%Y-%W';
        break;
      case 'yearly':
        dateFormat = '%Y-%m';
        break;
      default:
        throw Exception("Invalid period: $period");
    }

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT strftime('$dateFormat', date_time) as period, SUM(amount) as total
      FROM transactions_
      WHERE type = ?
      GROUP BY period
      ORDER BY period
    ''', [type]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * 
      FROM transactions_
      ORDER BY date_time
    ''');

    return result;
  }

  void dispose() {
    _accountsController.close();
    _categoriesController.close();
  }
}

class Category {
  static const String tableName = 'categories';
  static const String colId = 'id';
  static const String colHolderName = 'holderName';
  static const String colDescription = 'description';
  static const String colIconName = 'iconName';
  static const String colColorName = 'colorName';
  static const String colBudget = 'budget';
  static const String colTransferCategory = 'transferCategory';

  int? id;
  String holderName;
  String description;
  String iconName;
  String colorName;
  String budget;
  int transferCategory;

  Category({
    this.id,
    required this.holderName,
    required this.description,
    required this.iconName,
    required this.colorName,
    required this.budget,
    required this.transferCategory,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colHolderName: holderName,
      colDescription: description,
      colIconName: iconName,
      colColorName: colorName,
      colBudget: budget,
      colTransferCategory: transferCategory,
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map[colId],
      holderName: map[colHolderName],
      description: map[colDescription],
      iconName: map[colIconName],
      colorName: map[colColorName],
      budget: map[colBudget],
      transferCategory: map[colTransferCategory],
    );
  }
}

class BankAccount {
  static const String tableName = 'bank_account';
  static const String colId = 'id';
  static const String colCardHolder = 'card_holder';
  static const String colAccountName = 'account_name';
  static const String colAmount = 'amount';
  static const String colPinCode = 'pin_code';
  static const String colColor = 'color';
  static const String colSelectedIndex = 'selected_index'; // Add this line

  int? id;
  String cardHolder;
  String accountName;
  double amount;
  String pinCode;
  String color;
  int selectedIndex; // Add this line

  BankAccount({
    this.id,
    required this.cardHolder,
    required this.accountName,
    required this.amount,
    required this.pinCode,
    required this.color,
    required this.selectedIndex, // Add this line
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colCardHolder: cardHolder,
      colAccountName: accountName,
      colAmount: amount,
      colPinCode: pinCode,
      colColor: color,
      colSelectedIndex: selectedIndex, // Add this line
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  static BankAccount fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map[colId],
      cardHolder: map[colCardHolder],
      accountName: map[colAccountName],
      amount: map[colAmount],
      pinCode: map[colPinCode],
      color: map[colColor],
      selectedIndex: map[colSelectedIndex], // Add this line
    );
  }
}

enum TransactionType {
  income,
  expense,
  transfer,
}

class Transaction {
  static const String tableName = 'transactions';
  static const String colId = 'id';
  static const String colType = 'type';
  static const String colAmount = 'amount';
  static const String colDescription = 'description';
  static const String colDateTime = 'date_time';
  static const String colAccountId = 'account_id';
  static const String colCategoryId = 'category_id';

  final int id;
  final String type;
  final double amount;
  final String description;
  final String dateTime;
  final int accountId;
  late final int categoryId;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.dateTime,
    required this.accountId,
    required this.categoryId,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map[colId],
      type: map[colType],
      amount: map[colAmount],
      description: map[colDescription],
      dateTime: map[colDateTime],
      accountId: map[colAccountId],
      categoryId: map[colCategoryId],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      colId: id,
      colType: type,
      colAmount: amount,
      colDescription: description,
      colDateTime: dateTime,
      colAccountId: accountId,
      colCategoryId: categoryId,
    };
  }
}
