import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';

class ChipWidget extends StatelessWidget {
  final Widget label;
  final Function(String)? onTap;
  final bool selected;
  const ChipWidget({Key? key, required this.label, this.onTap, this.selected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: label,
      labelStyle:  TextStyle(fontSize: 12,color: selected ? red : Colors.black),
      labelPadding:
      const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
      shape: RoundedRectangleBorder(
          side:  BorderSide(color: selected ? red : const Color(0xffe8e6ea)),
          borderRadius: BorderRadius.circular(8)),
      backgroundColor:  white,
        materialTapTargetSize:MaterialTapTargetSize.shrinkWrap
    );
  }
}

