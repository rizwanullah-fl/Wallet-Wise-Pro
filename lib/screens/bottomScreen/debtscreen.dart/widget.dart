import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class MyDatePickerRow extends StatelessWidget {
  final Rx<DateTime> startDateController;
  final Rx<DateTime> endDateController;

  MyDatePickerRow(
      {required this.startDateController, required this.endDateController});
  TextStyler textStyler = TextStyler();
  final HomeController _controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            _selectDate(context, true);
          },
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined),
              Obx(() => Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      startDateController.value != null
                          ? '${startDateController.value.day}/${startDateController.value.month}/${startDateController.value.year}'
                          : 'Start Date',
                      style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                    ),
                  )),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            _selectDate(context, false);
          },
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined),
              Obx(() => Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      endDateController.value != null
                          ? '${endDateController.value.day}/${endDateController.value.month}/${endDateController.value.year}'
                          : 'End Date',
                      style: textStyler.mediumTextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  DateTime? _startDate;
  DateTime? _endDate;
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    var find = Get.find<ColorController>();
    final Color selectedColor = find.getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color lightcolor = colorShades[0];
    final Color lightprocolor = colorShades[1];
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    final DateTime? picked = await showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: secondarycolor, // header background color
              onPrimary: Colors.black, // header text color
              onSurface: firstcolor, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      if (isStartDate) {
        startDateController.value = picked;
      } else {
        endDateController.value = picked;
      }
    }
  }
}
