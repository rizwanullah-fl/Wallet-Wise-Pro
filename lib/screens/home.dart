import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/screens/bottomNavigator.dart';
import 'package:expenses/screens/bottomScreen/Home.dart';
import 'package:expenses/screens/bottomScreen/account.dart';
import 'package:expenses/screens/bottomScreen/appbar/app_bar_bottomsheet.dart';
import 'package:expenses/screens/bottomScreen/debit.dart';
import 'package:expenses/screens/bottomScreen/overview.dart';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/profile_Controller.dart';
import 'package:expenses/screens/drawer.dart';
import 'package:expenses/screens/drawerScreens/budget.dart';
import 'package:expenses/screens/drawerScreens/categories.dart';
import 'package:expenses/screens/drawerScreens/recurring.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final ProfileController _profileController = Get.put(ProfileController());
  TextEditingController controller = TextEditingController();
  final HomeController _controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.text = _profileController.profileName.value;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.pop(context);
    });
  }

  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Account(),
    Debits(),
    Overview(),
  ];
  static List<Widget> _drawerOptions = <Widget>[
    Home(),
    Account(),
    Debits(),
    Overview(),
    CategoriesScreen(),
    BudgetScreen(),
    RecurringScreen(),
  ];

  void _showProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ProfileModalBottomSheet(
          controller: controller,
          onUpdateProfile: (String profileName) {
            _profileController.updateProfile(controller.text);
            print('Updating profile: $profileName');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightprocolor = colorShades[1];
    TextStyler textStyler = TextStyler();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Obx(
          () {
            final themeMode = _controller.currentTheme.value;
            return Text(
              _getPageTitle(_selectedIndex),
              style: textStyler.mediumTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color:
                    themeMode == ThemeMode.dark ? Colors.white : Colors.black,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                _controller.currentTheme.value == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
            ),
            onPressed: () {
              _controller.switchTheme();
              Get.changeThemeMode(_controller.currentTheme.value);
            },
          ),
          IconButton(
            onPressed: () {
              _showProfileModal(context);
            },
            icon: CircleAvatar(
              backgroundColor: lightprocolor,
              radius: 20,
              child: Icon(
                Icons.person_4_outlined,
                color: Colors.grey.shade200,
              ),
            ),
          )
        ],
      ),
      drawer: CustomDrawer(
        selectedIndex: _selectedIndex,
        onDrawerItemTapped: _onDrawerItemTapped,
      ),
      body: _selectedIndex > 3
          ? _drawerOptions.elementAt(_selectedIndex)
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: _selectedIndex > 3
          ? CustomBottomNavigationBar2(
              currentIndex: _selectedIndex,
              onTap: _onDrawerItemTapped,
            )
          : CustomBottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'home'.tr;
      case 1:
        return 'accounts'.tr;
      case 2:
        return 'debts'.tr;
      case 3:
        return 'overview'.tr;
      case 4:
        return 'category'.tr;
      case 5:
        return 'budget'.tr;
      case 6:
        return 'recurring'.tr;
      default:
        return 'Unknown';
    }
  }
}
