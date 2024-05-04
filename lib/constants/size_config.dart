import 'package:flutter/material.dart';

class ResponsiveDesign {
  // Constants based on Figma design
  static const double figmaDesignWidth = 430.0;
  static const double figmaDesignHeight = 932.0; // Adjust as needed

  // Get device screen width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Get device screen height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Calculate responsive width based on Figma design width
  static double width(double px, BuildContext context) {
    return (px / figmaDesignWidth) * screenWidth(context);
  }

  // Calculate responsive height based on Figma design height
  static double height(double px, BuildContext context) {
    return (px / figmaDesignHeight) * screenHeight(context);
  }

  // Calculate responsive font size
  static double fontSize(double px, BuildContext context) {
    return (px / figmaDesignWidth) * screenWidth(context);
  }

  // Calculate responsive padding/margin for all sides
  static EdgeInsetsGeometry all(double px, BuildContext context) {
    final double responsiveValue = width(px, context);
    return EdgeInsets.all(responsiveValue);
  }

  // Calculate responsive horizontal padding/margin
  static EdgeInsetsGeometry horizontal(double px, BuildContext context) {
    final double responsiveValue = width(px, context);
    return EdgeInsets.symmetric(horizontal: responsiveValue);
  }

  // Calculate responsive vertical padding/margin
  static EdgeInsetsGeometry vertical(double px, BuildContext context) {
    final double responsiveValue = height(px, context);
    return EdgeInsets.symmetric(vertical: responsiveValue);
  }

  // Calculate responsive padding/margin for specific sides
  static EdgeInsetsGeometry fromLTRB(
    double left,
    double top,
    double right,
    double bottom,
    BuildContext context,
  ) {
    return EdgeInsets.fromLTRB(
      width(left, context),
      height(top, context),
      width(right, context),
      height(bottom, context),
    );
  } // Calculate responsive padding/margin for specific sides

  static EdgeInsetsGeometry only(
    BuildContext context, {
    double left = 0.0,
    double top = 0.0,
    double right = 0.0,
    double bottom = 0.0,
  }) {
    return EdgeInsets.only(
      left: width(left, context),
      top: height(top, context),
      right: width(right, context),
      bottom: height(bottom, context),
    );
  }
}
