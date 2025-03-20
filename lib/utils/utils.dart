import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:madina_diallo_l3gl_examen/config/size_config.dart';
import 'dart:math' as math;

class Utils {
  static const double TABLE_BREAKPOINT  = 600.0;

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static bool isPortait(BuildContext context) {
    return SizeConfig.orientation == Orientation.portrait;
  }

  static Future<bool> isTablet(BuildContext context) async {
    try {

      if(Platform.isIOS){
        return _isIosTablet();
      }

      if(Platform.isAndroid){
        return _isAndroidTablet(context);
      }

      return _isTabletByScreenSize(context);

    } catch(e) {
      debugPrint("Erreur lors de la détection de la tablette: $e");
      return _isTabletByScreenSize(context);
    }
  }

  /*
  Pour ios c'est simple on verifie juste si le modèle
  contient "ipad". C'est fiable car Apple a une
  nomenclature claire
   */
  static Future<bool> _isIosTablet() async {
    final iosInfos = await _deviceInfo.iosInfo;
    return iosInfos.model.toLowerCase().contains("ipad");
  }

  /*
  Pour Android, on utilse 3 critères:
    - Verifier si l'ecran depasse 600dp
    - Verifier si l'appareil supporte le 64 bits(commun sur la plupart des tablettes modernes)
    - Verifier si l'ecran fait plus de 7 pouces en diagonal
   */
  static Future<bool> _isAndroidTablet(BuildContext context) async {
    final androidInfos = await _deviceInfo.androidInfo;

    bool isTableByScreen = _isTabletByScreenSize(context);

    bool hasTabletCharacteristics = androidInfos.supported64BitAbis?.isNotEmpty ?? false;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double diagonalInches = _calculateScreenDiagonal(screenWidth, screenHeight, context);
    bool isLargeScreen = diagonalInches > 7.0;

    return isTableByScreen && hasTabletCharacteristics && isLargeScreen;
  }

  static double _calculateScreenDiagonal(double width, double height,
      BuildContext context) {
    var pixelRatio = MediaQuery.of(context).devicePixelRatio;
    var physicalWidth = width * pixelRatio;
    var physicalHeight = height * pixelRatio;
    var diagonalPixels = _pythagoras(physicalWidth, physicalHeight);

    return diagonalPixels / (160 * pixelRatio);
  }

  static double _pythagoras(double width, double height) {
    return math.sqrt(width * width + height * height);
  }

  static bool _isTabletByScreenSize(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide > TABLE_BREAKPOINT;
  }
}