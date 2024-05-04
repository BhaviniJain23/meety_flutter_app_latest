import 'package:flutter/material.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

class HeadingStyles {
  HeadingStyles._();

  static boardingHeading(BuildContext context, String text,
      {double? fontSize}) {
    return Text(text,
        softWrap: true,
        style: context.textTheme.headlineMedium?.copyWith(
            fontSize: fontSize ?? 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: 0.2));
  }

  static boardingHeadingCaption(BuildContext context, String text,
      {bool isCenter = true, double? fontSize}) {
    return Align(
      alignment: isCenter ? Alignment.center : Alignment.centerLeft,
      child: Text(
        text,
        style: context.textTheme.bodyMedium!
            .copyWith(color: 0xff6a6b70.toColor, fontSize: fontSize ?? 14),
        softWrap: true,
      ),
    );
  }
}
