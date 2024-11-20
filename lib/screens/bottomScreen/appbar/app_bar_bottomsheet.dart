import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ProfileModalBottomSheet extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onUpdateProfile;

  ProfileModalBottomSheet({
    required this.controller,
    required this.onUpdateProfile,
  });
  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();
  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color secondarycolor = colorShades[3];
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'profile'.tr,
              style: textStyler.mediumTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: _controller.currentTheme.value == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      secondarycolor, // Change to your desired color
                  radius: 20,
                  child: Icon(
                    Icons.person_4_outlined,
                    color: Colors.grey.shade200,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CustomTextFormField(
                    hintText: 'Enter your name',
                    controller: controller,
                    borderRadius: 10.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  onUpdateProfile(controller.text);
                  Navigator.of(context).pop();
                },
                child: Text(
                  'update'.tr,
                  style: textStyler.mediumTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: secondarycolor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
