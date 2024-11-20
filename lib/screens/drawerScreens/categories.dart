import 'package:expenses/database/create_account.dart';
import 'package:expenses/screens/drawerScreens/categories_screens/add_category.dart';
import 'package:expenses/screens/drawerScreens/categories_screens/update_category.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/custome_list_tile.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    databaseHelper.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: StreamBuilder<List<Category>>(
            stream: DatabaseHelper()
                .categoriesStream, // Use the stream from your DatabaseHelper
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else {
                List<Category>? categories = snapshot.data;
                return ListView.builder(
                  itemCount: categories!.length,
                  itemBuilder: (BuildContext context, int index) {
                    Category category = categories[index];
                    print(category.iconName);
                    IconData iconData = IconData(int.parse(category.iconName),
                        fontFamily: 'MaterialIcons');
                    return CustomListTile2(
                      leadingIcon: iconData,
                      color: Color(int.parse(category.colorName)),
                      title: category.holderName,
                      onTap: () {
                        Get.to(() => UpdateCategory(
                              index: category.id!.toInt(),
                            ));
                      },
                      subtitle: category.description,
                      trailingIcon: category.transferCategory == 1,
                      trailingIconData: Icons.keyboard_double_arrow_left_sharp,
                    );
                  },
                );
              }
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddCategoryScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
