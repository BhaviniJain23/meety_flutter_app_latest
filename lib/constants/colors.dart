import 'package:flutter/material.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

const white = Color(0xffffffff);
const black = Color(0xFF231f20);
const grey1 = Color(0xFF808080);
const whitesmoke = Color(0xFFF2F2F2);
const loginUserChatColor = Color(0xFFF3F3F3);

const red = Color(0xffff5a78);
const lightRed =  Color(0xffFFA5B5);
const purple =  Color(0xffba03ff);
const lightPurple =  Color(0xfffdf2ff);
const yellow =  Color(0xfffbb309);
const lightYellow =  Color(0xffe3ce9f);
const grey = Color(0xff909090);
const grey2 = Color.fromRGBO(224, 221, 221, 100);
const lightBlue = Color(0xff6fb0e7);
const disabledBorderColor = Color.fromRGBO(199, 194, 194, 0.30196078431372547);
final dividerColor = const Color(0xff000000).toMaterialColor.shade400;


const buttonGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
  colors: [
    Color.fromRGBO(255, 90, 120, 1),
    // Color.fromRGBO(255, 103, 131, 1),
    // Color.fromRGBO(255, 128, 151, 1),
    Color.fromRGBO(255, 187, 202, 1.0),
  ],
  stops: [0.0,/* 0.05, 0.75,*/ 1.0],
  transform: GradientRotation(180),
);
const disabledGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomRight,
  colors: [
    Color.fromRGBO(157, 157, 157, 1.0),
    Color.fromRGBO(236, 232, 233, 1.0),
  ],
  stops: [0.0,1.0],
  transform: GradientRotation(180),
);