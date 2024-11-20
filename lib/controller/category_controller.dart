// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:flutter_iconpicker/Models/icon_picker_icon.dart';
// import 'package:flutter_iconpicker/flutter_iconpicker.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseCategory {
//   static final DatabaseCategory _instance = DatabaseCategory._internal();

//   factory DatabaseCategory() {
//     return _instance;
//   }

//   DatabaseCategory._internal();

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasesPath = await getDatabasesPath();
//     final path = join(databasesPath, 'categories.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE categories (
//             id INTEGER PRIMARY KEY AUTOINCREMENT,
//             title TEXT,
//             subtitle TEXT,
//             transfer INTEGER,
//             icon TEXT,
//             color TEXT,
//             showTextFormField INTEGER,
//             amount TEXT
//           )
//         ''');
//       },
//     );
//   }

//   Future<void> insertCategory(Map<String, dynamic> category) async {
//     final db = await database;
//     await db.insert('categories', category);
//   }

//   Future<List<Map<String, dynamic>>> getCategories() async {
//     final db = await database;
//     return await db.query('categories');
//   }

//   Future<void> deleteCategory(int id) async {
//     final db = await database;
//     await db.delete('categories', where: 'id = ?', whereArgs: [id]);
//   }
// }

// class CategoryController extends GetxController {
//   RxList<Map<String, dynamic>> items = <Map<String, dynamic>>[].obs;

//   final TextEditingController categoryController = TextEditingController();
//   final TextEditingController descriptionController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   IconData? selectedIcon;
//   Color? selectedColor;
//   bool showTextFormField = false;
//   bool transferCategory = false;

//   final DatabaseCategory _dbHelper = DatabaseCategory();

//   @override
//   void onInit() {
//     super.onInit();
//     _loadData(); // Load data when the controller initializes
//     showTextFormField = false;
//     transferCategory = false;
//   }

//   // Load data from SQLite
//   Future<void> _loadData() async {
//     final data = await _dbHelper.getCategories();
//     final List<Map<String, dynamic>> loadedItems = data.map((item) {
//       return {
//         'id': item['id'],
//         'title': item['title'],
//         'subtitle': item['subtitle'],
//         'transfer': item['transfer'] == 1,
//         'icon': _deserializeIconData(
//             json.decode(item['icon'])), // Deserialize IconData
//         'color': item['color'] != null
//             ? _deserializeColor(json.decode(item['color']))
//             : null,
//         'showTextFormField': item['showTextFormField'] == 1,
//         'amount': item['amount']
//       };
//     }).toList();
//     items.value = loadedItems;
//   }

//   void _saveData(Map<String, dynamic> category) async {
//     await _dbHelper.insertCategory(category);
//   }

//   Map<String, dynamic> _serializeColor(Color? color) {
//     if (color != null) {
//       return {
//         'red': color.red,
//         'green': color.green,
//         'blue': color.blue,
//         'alpha': color.alpha,
//       };
//     }
//     return {}; // Return an empty map if color is null
//   }

//   Color _deserializeColor(Map<String, dynamic> colorData) {
//     return Color.fromARGB(colorData['alpha'], colorData['red'],
//         colorData['green'], colorData['blue']);
//   }

//   Map<String, dynamic> _serializeIconData(IconData? icon) {
//     if (icon == null) return {};
//     return {
//       'codePoint': icon.codePoint,
//       'fontFamily': icon.fontFamily,
//     };
//   }

//   IconData _deserializeIconData(Map<String, dynamic> data) {
//     return IconData(data['codePoint'], fontFamily: data['fontFamily']);
//   }

//   void addItem(Map<String, dynamic> item) {
//     items.add(item);
//     _saveData(item); // Save data after adding an item
//     update();
//   }

//   void deleteCategory(int index) {
//     final item = items[index];
//     _dbHelper.deleteCategory(item['id']);
//     items.removeAt(index);
//     update();
//   }

//   void selectIcon(IconData icon) {
//     selectedIcon = icon;
//     update();
//   }

//   void selectColor(Color color) {
//     selectedColor = color;
//     update();
//   }

//   void toggleTextFormField(bool value) {
//     showTextFormField = value;
//     update();
//   }

//   void toggleTransferCategory(bool value) {
//     transferCategory = value;
//     update();
//   }

//   Future<void> pickIcon(BuildContext context) async {
//     IconData? icon = await showIconPicker(
//       context,
//       adaptiveDialog: true,
//       showTooltips: false,
//       showSearchBar: true,
//       iconPickerShape:
//           RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       searchComparator: (String search, IconPickerIcon icon) =>
//           search
//               .toLowerCase()
//               .contains(icon.name.replaceAll('_', ' ').toLowerCase()) ||
//           icon.name.toLowerCase().contains(search.toLowerCase()),
//     );

//     if (icon != null) {
//       selectIcon(icon);
//       debugPrint('Picked Icon:  $icon');
//     }
//   }

//   Future<void> showColorPickerDialog(BuildContext context) async {
//     Color currentColor = selectedColor ?? Colors.orange;
//     Color? newColor = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         Color? pickedColor = currentColor;
//         return AlertDialog(
//           title: Text('Pick a color'),
//           content: SingleChildScrollView(
//             child: BlockPicker(
//               pickerColor: currentColor,
//               onColorChanged: (Color color) {
//                 pickedColor = color;
//               },
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(pickedColor);
//               },
//               child: Text('Done'),
//             ),
//           ],
//         );
//       },
//     );

//     if (newColor != null) {
//       selectColor(newColor);
//     }
//   }

//   void addCategory() {
//     String category = categoryController.text;
//     String description = descriptionController.text;
//     String amount = amountController.text;

//     final item = {
//       'title': category,
//       'subtitle': description,
//       'transfer': transferCategory ? 1 : 0,
//       'icon': json.encode(_serializeIconData(selectedIcon)),
//       'color': json.encode(_serializeColor(selectedColor)),
//       'showTextFormField': showTextFormField ? 1 : 0,
//       'amount': amount
//     };

//     addItem(item);
//   }

//   @override
//   void onClose() {
//     categoryController.dispose();
//     descriptionController.dispose();
//     amountController.dispose();
//     super.onClose();
//   }
// }
