import 'package:flutter/cupertino.dart';
import 'package:madina_diallo_l3gl_examen/utils/utils.dart';

class SizeConfig {
  // Reference suivant les dimensions de l'iphone X/XS
  static const double DESIGN_WIDTH = 375.0;
  static const double DESIGN_HEIGHT = 812.0;

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double pixelRatio;
  static late Orientation orientation;
  static bool isTablet = false;
  static bool isDarkMode = false;

  /*
   Cache pour stocker les calculs de pourcentages
   Ces maps evitent de recalculer les meme pourcentages
   plusieurs.

   */
  static final Map<int, double> _widthPercenrages = {};
  static final Map<int, double> _heightPercenrages = {};

  static void init(BuildContext context) async {
    // permet de recupérer les infos de l'appareils
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    pixelRatio = _mediaQueryData.devicePixelRatio;
    isDarkMode = _mediaQueryData.platformBrightness ==  Brightness.dark;

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