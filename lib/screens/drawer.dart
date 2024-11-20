import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/screens/drawerScreens/setting.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/custome_list_tile.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CustomDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDrawerItemTapped;

  const CustomDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onDrawerItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController _controller = Get.put(HomeController());
    TextStyler textStyler = TextStyler();
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 50,
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Icon(
                  Icons.wallet,
                  size: 35,
                  color: firstcolor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Knot',
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CustomListTile(
            leadingIcon: Icons.home_outlined,
            title: 'home'.tr,
            onTap: () => onDrawerItemTapped(0),
            selected: selectedIndex == 0,
          ),
          CustomListTile(
            leadingIcon: Icons.credit_card_outlined,
            title: 'accounts'.tr,
            onTap: () => onDrawerItemTapped(1),
            selected: selectedIndex == 1,
          ),
          CustomListTile(
            leadingIcon: Icons.person_outlined,
            title: 'debts'.tr,
            onTap: () => onDrawerItemTapped(2),
            selected: selectedIndex == 2,
          ),
          CustomListTile(
            leadingIcon: Icons.view_carousel_outlined,
            title: 'overview'.tr,
            onTap: () => onDrawerItemTapped(3),
            selected: selectedIndex == 3,
          ),
          CustomListTile(
            leadingIcon: Icons.category_outlined,
            title: 'category'.tr,
            onTap: () => onDrawerItemTapped(4),
            selected: selectedIndex == 4,
          ),
          CustomListTile(
            leadingIcon: Icons.attach_money_outlined,
            title: 'budget'.tr,
            onTap: () => onDrawerItemTapped(5),
            selected: selectedIndex == 5,
          ),
          CustomListTile(
            leadingIcon: Icons.no_accounts_outlined,
            title: 'recurring'.tr,
            onTap: () => onDrawerItemTapped(6),
            selected: selectedIndex == 6,
          ),
          Divider(),
          ListTile(
            contentPadding: EdgeInsets.only(left: 30, right: 30),
            leading: Icon(Icons.settings),
            title: Obx(() => Text(
                  'setting'.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: _controller.currentTheme.value == ThemeMode.dark
                          ? Colors.white
                          : Colors.black),
                )),
            onTap: () {
              Get.to(() => Setting());
            },
          ),
        ],
      ),
    );
  }
}
