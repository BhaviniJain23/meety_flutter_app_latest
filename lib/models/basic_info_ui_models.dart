import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BasicInfoQuery {
  final IconData iconData;
  final String que;
  final List<String> answer;
  String? selectingVal;
  final bool showHelp;

  BasicInfoQuery({
    required this.iconData,
    required this.que,
    required this.answer,
    this.showHelp = false,
    this.selectingVal,
  });

  BasicInfoQuery copyWith({final String? selectingVal}) {
    return BasicInfoQuery(
        iconData: iconData,
        que: que,
        answer: answer,
        selectingVal: selectingVal ?? this.selectingVal);
  }
}
