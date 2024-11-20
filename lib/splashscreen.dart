import 'package:expenses/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Simulate a delay for the splash screen, then navigate to MyHomePage
    Future.delayed(Duration(seconds: 3), () {
      Get.offAll(() => MyHomePage());
    });
  }

  Future<double> whenNotZero(Stream<double> source) async {
    await for (double value in source) {
      debugPrint("Width: $value");
      if (value > 0) {
        debugPrint("Width > 0:  $value");
        return value;
      } else {
        return 0;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
          future: whenNotZero(
            Stream<double>.periodic(const Duration(milliseconds: 50),
                (x) => MediaQuery.of(context).size.width),
          ),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              if (snapshot.data! > 0) {
                return Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomImageView(
                        imagePath: 'assets/images/logo.png',
                        width: 700,
                        height: 400,
                      ),
                    ],
                  ),
                );
              } else {
                return Container();
              }
            } else {
              return Container();
            }
          }),
    );
  }
}

class CustomImageView extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  CustomImageView({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      width: getHorizontalSize(context, width),
      height: getVerticalSize(context, height),
      fit: BoxFit.contain,
    );
  }

  double getHorizontalSize(BuildContext context, double size) {
    return (size / 375.0) * MediaQuery.of(context).size.width;
  }

  double getVerticalSize(BuildContext context, double size) {
    return (size / 812.0) * MediaQuery.of(context).size.height;
  }
}
