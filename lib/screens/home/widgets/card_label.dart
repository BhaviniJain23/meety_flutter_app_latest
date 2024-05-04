import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';

const _labelAngle = math.pi / 2 * 0.2;

class CardLabel extends StatelessWidget {
  const CardLabel._({
    required this.color,
    required this.label,
    required this.angle,
    required this.alignment,
     this.padding =12,
  });

  factory CardLabel.right() {
    return const CardLabel._(
      color: red,
      label: Assets.heartIcon,
      angle: -_labelAngle,
      alignment: Alignment.centerLeft,
    );
  }

  factory CardLabel.left() {
    return  const CardLabel._(
      color: purple,
      label: Assets.dislikeIcon,
      padding: 16,
      angle: _labelAngle,
      alignment: Alignment.centerRight,
    );
  }


  final Color color;
  final String label;
  final double angle;
  final Alignment alignment;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(
        vertical: 36,
        horizontal: 36,
      ),
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 60,
          height: 60,
          padding: EdgeInsets.all(padding),
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  offset: Offset(0, 20),
                  blurRadius: 30)
            ],
            color: Color.fromRGBO(255, 255, 255, 1),
            borderRadius: BorderRadius.all(Radius.elliptical(78, 78)),
          ),
          child: SizedBox(
            height: 20,
            width: 20,
            child: Image.asset(
             label,
              height: 20,
              width: 20,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
