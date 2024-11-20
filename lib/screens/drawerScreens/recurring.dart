import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/drawerScreens/recurring_Screens/Add_recurring.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  List<Map<String, dynamic>> recurringItems = [];
  final DatabaseHelper2 databaseHelper = DatabaseHelper2.instance;
  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();

  @override
  void initState() {
    super.initState();
    _loadRecurringItems();
  }

  Future<void> _loadRecurringItems() async {
    try {
      final Database? db = await DatabaseHelper2.instance.db;
      final List<Map<String, dynamic>> items =
          await db!.query(DatabaseHelper2.instance.recurringTable);
      setState(() {
        recurringItems = items;
      });
    } catch (e) {
      print('Error loading recurring items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddRecurring())!.then((value) {
            _loadRecurringItems();
          });
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: recurringItems.length,
              itemBuilder: (BuildContext context, int index) {
                final item = recurringItems[index];
                final dateTimeString = item['select_date_time'];
                var myDate = DateFormat('dd-MM-yyyy').parse(dateTimeString);

                return ListTile(
                  title: Text(
                    item['recurring_name'],
                    style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat.yMMMMd().format(myDate),
                    style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await _deleteRecurring(item['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRecurring(int id) async {
    await databaseHelper.deleteRecurring(id);
    _loadRecurringItems(); // Refresh the list after deletion
  }
}
