import "package:flutter/material.dart";

abstract class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;

  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  // Queries to see what the screen dimensions are
  // and constructs a safe scaling value to use for widths and heights.
  // Should use safeBlockHorizontal and safeBlockVertical to scale dimensions in the app
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100.0;
    blockSizeVertical = screenWidth / 100.0;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100.0;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100.0;
  }
}
