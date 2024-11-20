import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTheme {
  static const lightThemeFont = "ComicNeue", darkThemeFont = "Poppins";

  // light theme
  static ThemeData lightTheme() {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();

    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color appBarBackgroundColor = colorShades[0];
    final Color lightcolor = colorShades[1];
    final Color iconColor = colorShades[3];
    return ThemeData(
      primaryColor: appBarBackgroundColor,
      brightness: Brightness.light,
      useMaterial3: true,
      fontFamily: lightThemeFont,

      switchTheme: SwitchThemeData(
        thumbColor:
            MaterialStateProperty.resolveWith<Color>((states) => Colors.white),
        // trackColor:
        //     MaterialStateProperty.resolveWith<Color>((states) => Colors.white),
      ),
      // datePickerTheme: DatePickerThemeData(
      //   backgroundColor: Colors.white,
      //   todayForegroundColor:
      //       MaterialStateProperty.resolveWith<Color>((states) => Colors.white),
      //   todayBackgroundColor:
      //       MaterialStateProperty.resolveWith<Color>((states) => selectedColor),
      // ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: appBarBackgroundColor,
        indicatorColor: lightcolor,
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black,
          fontSize: 23, //20
        ),
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
        actionsIconTheme: IconThemeData(color: iconColor),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // backgroundColor: appBarBackgroundColor,
      scaffoldBackgroundColor: Colors.white,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: iconColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // dark theme
  static ThemeData darkTheme() {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();

    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color appBarBackgroundColor = colorShades[0];
    final Color iconColor = colorShades[3];
    final Color secondaycolor = colorShades[2];
    final Color lightcolor = colorShades[1];

    return ThemeData(
        datePickerTheme: DatePickerThemeData(
          backgroundColor: Colors.black,
          todayForegroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) => Colors.black),
          todayBackgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) => selectedColor),
        ),
        primaryColor: secondaycolor,
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: darkThemeFont,
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
              (states) => Colors.white),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: appBarBackgroundColor,
          indicatorColor: lightcolor,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: appBarBackgroundColor,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 23, //20
          ),
          iconTheme: IconThemeData(color: selectedColor),
          elevation: 0,
          actionsIconTheme: IconThemeData(color: selectedColor),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.black,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        scaffoldBackgroundColor: appBarBackgroundColor,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: iconColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.black, elevation: 0, shadowColor: iconColor,
          // primaryColor: darkThemeColor,
        ));
  }

  // colors
  // static Color lightThemeColor = Colors.white, darkThemeColor = Colors.yellow;
}
