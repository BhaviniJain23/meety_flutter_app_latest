import 'package:flutter/material.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

class SubHeading extends StatelessWidget {
  final String text;
  const SubHeading({
    super.key, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.bodyMedium!.copyWith(
        color: 0xff868D95.toColor,
      ),
    );
  }
}

class Heading extends StatelessWidget {
  final String text;
  const Heading({
    super.key, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: context.textTheme.headlineSmall,
    );
  }
}
