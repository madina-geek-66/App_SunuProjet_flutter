import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:madina_diallo_l3gl_examen/utils/utils.dart';

class SizeConfig {
  static const double DESIGN_WIDTH = 375.0;
  static const double DESIGN_HEIGHT = 812.0;

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double pixelRatio;
  static late Orientation orientation;
  static bool isTablet = false;
  static bool isDarkMode = false;

  static final Map<int, double> _widthPercentages = {};
  static final Map<int, double> _heightPercentages = {};

  static void init(BuildContext context) async {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    pixelRatio = _mediaQueryData.devicePixelRatio;
    isDarkMode = Get.isDarkMode; // Utilisation de GetX pour le mode sombre

    print("screenWidth: $screenWidth");
    print("screenHeight: $screenHeight");
    print("orientation: $orientation");
    print("pixelRatio: $pixelRatio");
    print("isDarkMode: $isDarkMode");

    isTablet = await Utils.isTablet(context);
    print("isTablet: $isTablet");
  }

  static double getPropotionateScreenHeight(double inputHeight) {
    return (inputHeight / DESIGN_HEIGHT) * screenHeight;
  }

  static double getPropotionateScreenWidth(double inputWidth) {
    return (inputWidth / DESIGN_WIDTH) * screenWidth;
  }
}
