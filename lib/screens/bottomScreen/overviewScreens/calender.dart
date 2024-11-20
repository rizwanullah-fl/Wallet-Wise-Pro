import 'dart:math';
import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:paged_vertical_calendar/paged_vertical_calendar.dart';

class CalendarScreen extends StatefulWidget {
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime? start;
  DateTime? end;

  /// method to check wether a day is in the selected range
  /// used for highlighting those day
  bool isInRange(DateTime date) {
    if (start == null) return false;
    if (end == null) return date == start;
    return ((date == start || date.isAfter(start!)) &&
        (date == end || date.isBefore(end!)));
  }

  TextStyler textStyler = TextStyler();
  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: textStyler.largeTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
              ))
        ],
      ),
      body: Obx(() {
        final Color selectedColor =
            Get.find<ColorController>().getSelectedColor();
        final List<Color> colorShades =
            ColorUtils.generateShades(selectedColor, 200);
        final Color lightcolor = colorShades[0];
        final Color lightprocolor = colorShades[1];
        final Color secondarycolor = colorShades[3];
        final Color firstcolor = colorShades[2];
        return PagedVerticalCalendar(
          addAutomaticKeepAlives: true,
          dayBuilder: (context, date) {
            // update the days color based on if it's selected or not
            final color = isInRange(date) ? secondarycolor : Colors.transparent;

            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              child: Center(
                child: Text(DateFormat('d').format(date)),
              ),
            );
          },
          onDayPressed: (date) {
            setState(() {
              // if start is null, assign this date to start
              if (start == null)
                start = date;
              // if only end is null assign it to the end
              else if (end == null)
                end = date;
              // if both start and end arent null, show results and reset
              else {
                print('selected range from $start to $end');
                start = null;
                end = null;
              }
            });
          },
        );
      }),
    );
  }
}
