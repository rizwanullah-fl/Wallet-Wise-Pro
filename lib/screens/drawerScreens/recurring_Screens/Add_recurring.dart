import 'package:expenses/controller/color_controller.dart';
import 'package:expenses/controller/darkMode_Controller.dart';
import 'package:expenses/database/database2.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/add_transaction/add_transactions_widgets.dart';
import 'package:expenses/screens/bottomScreen/account_screens.dart/widget.dart';
import 'package:expenses/widgets/colorutilis.dart';
import 'package:expenses/widgets/font.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class AddRecurring extends StatefulWidget {
  const AddRecurring({super.key});

  @override
  State<AddRecurring> createState() => _AddRecurringState();
}

class _AddRecurringState extends State<AddRecurring> {
  List<String> items = [
    'expense',
    'income',
  ];
  int selectedIndex = 0;
  List<String> daily = ['daily', 'weekly', 'monthly', 'yearly'];

  int selectedIndex2 = 0;
  final TextEditingController recuring = TextEditingController();
  final TextEditingController amount = TextEditingController();
  final HomeController _controller = Get.put(HomeController());
  TextStyler textStyler = TextStyler();
  DateTime selectedDate = DateTime.now();
  TimeOfDay time = TimeOfDay(hour: 10, minute: 30);
  Future<void> _selectDate(BuildContext context) async {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
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
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Get.find<ColorController>().getSelectedColor();
    final List<Color> colorShades =
        ColorUtils.generateShades(selectedColor, 200);
    final Color secondarycolor = colorShades[3];
    final Color firstcolor = colorShades[2];
    final Color lightcolor = colorShades[0];
    return Scaffold(
      appBar: AppBar(
        title: Text('recurring'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 12.0,
          top: 20,
          right: 22,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 35,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedIndex == index
                                  ? secondarycolor
                                  : Colors.transparent),
                          color: lightcolor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                        ),
                        padding: EdgeInsets.only(left: 16.0, right: 16, top: 6),
                        child: Text(
                          items[index].tr,
                          style: textStyler.mediumTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _controller.currentTheme.value ==
                                      ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // selectedIndex == 0 ? RecurringExpense() : RecurringIncome(),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'recurring'.tr,
                controller: recuring,
                borderRadius: 10.0,
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                hintText: 'amount'.tr,
                controller: amount,
                borderRadius: 10.0,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                          size: 30,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "${selectedDate.toLocal()}".split(' ')[0],
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      TimeOfDay? newTime = await showTimePicker(
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary:
                                      secondarycolor, // header background color
                                  onPrimary: Colors.black, // header text color
                                  onSurface: firstcolor, // body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        Colors.red, // button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                          context: context,
                          initialTime: time);
                      if (newTime == null) return;
                      setState(() => time = newTime);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          size: 20,
                          color:
                              _controller.currentTheme.value == ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          '${_formatTimeOfDay(time)}',
                          style: textStyler.mediumTextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                _controller.currentTheme.value == ThemeMode.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'periodic'.tr,
                style: textStyler.mediumTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 35,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: daily.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex2 = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: selectedIndex2 == index
                                  ? secondarycolor
                                  : Colors.transparent),
                          color: lightcolor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(30)),
                        ),
                        padding: EdgeInsets.only(left: 16.0, right: 16, top: 6),
                        child: Text(
                          daily[index].tr,
                          style: textStyler.mediumTextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: _controller.currentTheme.value ==
                                      ThemeMode.dark
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'select account'.tr,
                style: textStyler.mediumTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
              ),
              SizedBox(
                height: 20,
              ),
              MyListView(
                onItemSelected: (accountId) {
                  setState(() {
                    selectedAccountId = accountId;
                  });
                },
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'select category'.tr,
                style: textStyler.mediumTextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _controller.currentTheme.value == ThemeMode.dark
                        ? Colors.white
                        : Colors.black),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                child: TagList(
                  filterByTransfer: false,
                  onItemSelected: (index) {
                    setState(() {
                      selectedCategoryId = index;
                    });
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20),
                child: CustomElevatedButton(
                  onPressed: _addRecurring,
                  text: 'add'.tr,
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addRecurring() async {
    String recurringName = recuring.text;
    double recurringAmount = double.tryParse(amount.text) ?? 0.0;
    String selectedDateTime =
        "${selectedDate.toLocal()} ${_formatTimeOfDay(time)}";
    String selectedDaily = daily[selectedIndex2];
    int? accountId = selectedAccountId;
    int? categoryId = selectedCategoryId;

    if (recurringName.isNotEmpty && accountId != null && categoryId != null) {
      Map<String, dynamic> recurringData = {
        'selectedIndex': selectedIndex,
        'recurring_name': recurringName,
        'amount': recurringAmount,
        'select_date_time': selectedDateTime,
        'select_daily': selectedDaily,
        'select_account_id': accountId,
        'select_category_id': categoryId,
      };

      await DatabaseHelper2.instance.insertRecurring(recurringData);

      // Clear the fields after insertion
      recuring.clear();
      amount.clear();

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recurring transaction added successfully')));

      Navigator.pop(context);
    } else {
      // Show an error message
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all the fields')));
    }
  }

  int? selectedAccountId;
  int? selectedCategoryId;
}

String _formatTimeOfDay(TimeOfDay timeOfDay) {
  final now = DateTime.now();
  final dt =
      DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
  final format = DateFormat.jm(); // '6:00 AM'
  return format.format(dt);
}
