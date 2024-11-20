import 'package:expenses/controller/category_controller.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_data_Screens.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/transfer.dart';
import 'package:expenses/screens/drawerScreens/categories_screens/add_category.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyListView extends StatefulWidget {
  final Function(int)? onItemSelected; // Define onItemSelected here

  MyListView({this.onItemSelected});
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  late List<BankAccount> accounts = []; // Update to store BankAccount objects
  int? selectedIndex; // Add selected index variable
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    // Fetch data from the database and populate the items list
    fetchDataFromDatabase();
    _loadAccounts();
  }

  Future<void> fetchDataFromDatabase() async {
    try {
      // Instantiate your DatabaseHelper class
      DatabaseHelper databaseHelper = DatabaseHelper();
      // Fetch the list of BankAccounts from the database
      List<BankAccount> fetchedAccounts = await databaseHelper.getAccounts();
      await databaseHelper.loadAccounts();
      setState(() {
        accounts = fetchedAccounts;
      });
    } catch (e) {
      print("Error fetching items from database: $e");
    }
  }

  Future<void> _loadAccounts() async {
    try {
      await databaseHelper.loadAccounts();
      fetchDataFromDatabase(); // Fetch data again to update the list
    } catch (e) {
      print('Error loading accounts: $e');
      // Handle any errors that occur during account loading
    }
  }

  void handleItemSelection(int index) {
    setState(() {
      selectedIndex = index;
    });
    print("Selected Account ID: ${accounts[index].id}");
    // Call the onItemSelected callback with the selected index
    if (widget.onItemSelected != null) {
      widget.onItemSelected!(accounts[index].id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    final HomeController _controller = Get.put(HomeController());
    TextStyler textStyler = TextStyler();

    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accounts.length + 1, // Add 1 for the "Add Account" button
        itemBuilder: (BuildContext context, int index) {
          print(accounts.length);
          if (index == 0) {
            // Render the "Add Account" button as the first item
            return GestureDetector(
              onTap: () {
                Get.to(() => AddAccountScreen())!
                    .then((value) => _loadAccounts());
                _loadAccounts();
              },
              child: Container(
                width: 150,
                margin: EdgeInsets.only(left: 10),
                padding:
                    EdgeInsets.only(bottom: 4, left: 10, top: 10, right: 10),
                decoration: BoxDecoration(
                  color: lightcolor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: secondarycolor,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'add account'.tr,
                      style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Render existing accounts
            int adjustedIndex = index -
                1; // Adjust index to account for the "Add Account" button
            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.onItemSelected!(accounts[adjustedIndex].id!);
                  print(accounts[adjustedIndex].id);
                });

                handleItemSelection(adjustedIndex);
              },
              child: Container(
                width: 150,
                margin: EdgeInsets.only(left: 10),
                padding:
                    EdgeInsets.only(bottom: 4, left: 10, top: 10, right: 10),
                decoration: BoxDecoration(
                  color: lightcolor,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    width: 3,
                    color: selectedIndex == adjustedIndex
                        ? secondarycolor
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 20),
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: secondarycolor,
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: Icon(
                        Icons.call_end_sharp,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      accounts[adjustedIndex].accountName,
                      style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class TagList extends StatefulWidget {
  final bool filterByTransfer;
  final Function(int)? onItemSelected;

  TagList({this.filterByTransfer = false, this.onItemSelected});

  @override
  State<TagList> createState() => _TagListState();
}

class _TagListState extends State<TagList> {
  final DatabaseHelper databaseHelper = DatabaseHelper();
  int? selectedItemId;
  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();
  @override
  void initState() {
    super.initState();
    databaseHelper.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Category>>(
      stream: databaseHelper.categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Category>? categories = snapshot.data;
          if (categories == null) {
            return Center(child: Text('No categories available'));
          }
          if (widget.filterByTransfer) {
            categories = categories
                .where((category) => category.transferCategory == 1)
                .toList();
          } else {
            categories = categories
                .where((category) => category.transferCategory != 1)
                .toList();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _buildTagRows(context, categories),
          );
        }
      },
    );
  }

  List<Widget> _buildTagRows(BuildContext context, List<Category> categories) {
    return [
      buildRows(categories),
    ];
  }

  Widget buildRows(List<Category> items) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        alignment: WrapAlignment.start,
        spacing: 8.0,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Get.to(() => AddCategoryScreen());
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  border: Border.all(
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black),
                    SizedBox(width: 8.0),
                    Text(
                      'add item'.tr,
                      style: textStyler.mediumTextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _controller.currentTheme.value == ThemeMode.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ...items.map((item) {
            IconData iconData =
                IconData(int.parse(item.iconName), fontFamily: 'MaterialIcons');
            bool isSelected = selectedItemId == item.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedItemId = isSelected ? null : item.id;
                });
                if (widget.onItemSelected != null) {
                  widget.onItemSelected!(item.id!);
                }
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    border: Border.all(
                      color: isSelected
                          ? Color(int.parse(item.colorName))
                          : _controller.currentTheme.value == ThemeMode.dark
                              ? Colors.white
                              : Colors.black,
                      width: isSelected ? 2 : 1,
                    ),
                    color: isSelected
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconData,
                        color: Color(int.parse(item.colorName)),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        item.holderName,
                        style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(int.parse(item.colorName)),
                        ),
                      ),
                      SizedBox(width: 8.0),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class GridItem extends StatelessWidget {
  final Data data;
  final bool isSelected;
  final Function()? onTap;

  GridItem({required this.data, required this.isSelected, this.onTap});
  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();
  @override
  Widget build(BuildContext context) {
    final Color color = Color(int.parse('0xFF${data.color.substring(1)}'));
    final Color darkerColor =
        color.withOpacity(0.8); // Adjust the opacity as needed
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? darkerColor : Colors.transparent,
          ),
          color: Color(int.parse('0xFF${data.color.substring(1)}')),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Icons.balance,
              color: darkerColor,
            ),
            SizedBox(width: 8),
            Text(
              data.name,
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
    );
  }
}

// class TagList extends StatefulWidget {
//   final bool filterByTransfer;
//   final Function(int)? onItemSelected;

//   TagList({this.filterByTransfer = false, this.onItemSelected});

//   @override
//   State<TagList> createState() => _TagListState();
// }

// class _TagListState extends State<TagList> {
//   final DatabaseHelper databaseHelper = DatabaseHelper();
//   int? selectedItemId;
//   final HomeController _controller = Get.put(HomeController());
//   TextStyler textStyler = TextStyler();
//   Category? selectedCategory;

//   @override
//   void initState() {
//     super.initState();
//     databaseHelper.loadCategories();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<List<Category>>(
//       stream: databaseHelper.categoriesStream,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           List<Category>? categories = snapshot.data;
//           if (categories == null) {
//             return Center(child: Text('No categories available'));
//           }
//           if (widget.filterByTransfer) {
//             categories = categories
//                 .where((category) => category.transferCategory == 1)
//                 .toList();
//           } else {
//             categories = categories
//                 .where((category) => category.transferCategory != 1)
//                 .toList();
//           }
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _buildDropdown(context, categories),
//               // ..._buildTagRows(context, categories),
//             ],
//           );
//         }
//       },
//     );
//   }

//   Widget _buildDropdown(BuildContext context, List<Category> categories) {
//     return DropdownButton<Category>(
//       value: selectedCategory,
//       hint: Text('Select a category'),
//       isExpanded: true,
//       icon: Icon(Icons.arrow_drop_down),
//       iconSize: 24,
//       elevation: 16,
//       items: categories.map((Category category) {
//         return DropdownMenuItem<Category>(
//           value: category,
//           child: Text(category.holderName),
//         );
//       }).toList(),
//       onChanged: (Category? newValue) {
//         setState(() {
//           selectedCategory = newValue;
//           if (widget.onItemSelected != null && newValue != null) {
//             widget.onItemSelected!(newValue.id!);
//           }
//         });
//       },
//     );
//   }

//   List<Widget> _buildTagRows(BuildContext context, List<Category> categories) {
//     return [
//       buildRows(categories),
//     ];
//   }

//   Widget buildRows(List<Category> items) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       padding: EdgeInsets.symmetric(vertical: 4.0),
//       child: Wrap(
//         alignment: WrapAlignment.start,
//         spacing: 8.0,
//         children: <Widget>[
//           GestureDetector(
//             onTap: () {
//               Get.to(() => AddCategoryScreen());
//             },
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.0),
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.all(Radius.circular(30)),
//                   border: Border.all(
//                       color: _controller.currentTheme.value == ThemeMode.dark
//                           ? Colors.white
//                           : Colors.black),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Icon(Icons.add,
//                         color: _controller.currentTheme.value == ThemeMode.dark
//                             ? Colors.white
//                             : Colors.black),
//                     SizedBox(width: 8.0),
//                     Text(
//                       'add item'.tr,
//                       style: textStyler.mediumTextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: _controller.currentTheme.value == ThemeMode.dark
//                             ? Colors.white
//                             : Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           ...items.map((item) {
//             IconData iconData =
//                 IconData(int.parse(item.iconName), fontFamily: 'MaterialIcons');
//             bool isSelected = selectedItemId == item.id;
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   selectedItemId = isSelected ? null : item.id;
//                 });
//                 if (widget.onItemSelected != null) {
//                   widget.onItemSelected!(item.id!);
//                 }
//               },
//               child: Container(
//                 margin: EdgeInsets.only(bottom: 10),
//                 padding: EdgeInsets.symmetric(horizontal: 4.0),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.all(Radius.circular(30)),
//                     border: Border.all(
//                       color: isSelected
//                           ? Color(int.parse(item.colorName))
//                           : _controller.currentTheme.value == ThemeMode.dark
//                               ? Colors.white
//                               : Colors.black,
//                       width: isSelected ? 2 : 1,
//                     ),
//                     color: isSelected
//                         ? Colors.blue.withOpacity(0.1)
//                         : Colors.transparent,
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         iconData,
//                         color: Color(int.parse(item.colorName)),
//                       ),
//                       SizedBox(width: 8.0),
//                       Text(
//                         item.holderName,
//                         style: textStyler.mediumTextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           color: Color(int.parse(item.colorName)),
//                         ),
//                       ),
//                       SizedBox(width: 8.0),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }
// }
