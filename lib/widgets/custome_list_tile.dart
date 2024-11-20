import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CustomListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  CustomListTile({
    required this.leadingIcon,
    required this.title,
    this.selected = false,
    required this.onTap, // Default selected tile color
  });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final HomeController _controller = Get.put(HomeController());
    TextStyler textStyler = TextStyler();

    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color iconColor = colorShades[3];
    final Color secondaycolor = colorShades[2];
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 5,
      ),
      decoration: BoxDecoration(
        color: selected ? lightcolor : null,
        borderRadius: BorderRadius.circular(30.0), // Adjust as needed
      ),
      child: ListTile(
        selectedColor: _controller.currentTheme.value == ThemeMode.dark
            ? Colors.white
            : Colors.black,
        leading: Icon(
          leadingIcon,
        ),
        title: Obx(() => Text(
              title,
              style: textStyler.mediumTextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: _controller.currentTheme.value == ThemeMode.dark
                      ? Colors.white
                      : Colors.black),
            )),
        selected: selected,
        onTap: onTap,
      ),
    );
  }
}

class CustomListTile2 extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final VoidCallback onTap;
  final String subtitle;
  final bool trailingIcon;
  final IconData trailingIconData;
  final Color color;

  CustomListTile2(
      {required this.leadingIcon,
      required this.title,
      required this.onTap,
      required this.subtitle,
      required this.trailingIcon,
      required this.trailingIconData,
      required this.color // Default selected tile color
      });

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final TextStyler textStyler = TextStyler();
    final HomeController _controller = Get.put(HomeController());
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[1];
    final Color iconColor = colorShades[3];
    final Color secondaycolor = colorShades[2];
    return ListTile(
      selectedColor: _controller.currentTheme.value == ThemeMode.dark
          ? Colors.white
          : Colors.black,
      leading: CircleAvatar(
        backgroundColor: color,
        radius: 20,
        child: Icon(
          leadingIcon,
          color: Colors.grey.shade200,
        ),
      ),
      title: Obx(
        () => Text(title,
            style: textStyler.largeTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _controller.currentTheme.value == ThemeMode.dark
                  ? Colors.white
                  : Colors.black,
            )),
      ),
      subtitle: Obx(
        () => Text(subtitle,
            style: textStyler.largeTextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _controller.currentTheme.value == ThemeMode.dark
                    ? Colors.white
                    : Colors.black)),
      ),
      trailing: trailingIcon == true ? Icon(trailingIconData) : SizedBox(),
      onTap: onTap,
    );
  }
}
