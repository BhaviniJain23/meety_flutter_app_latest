import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  const Responsive({
    super.key,
    required this.smallScreen,
    this.mediumScreen,
    this.onChange,
    required this.bigScreen,
  });
  final Widget smallScreen;
  final Widget? mediumScreen;
  final Widget bigScreen;
  final VoidCallback? onChange;

  /* static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 850;*/

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        onChange?.call();

        if (constraints.maxWidth >= 1100) {
          return bigScreen;
        } else if ( //
        constraints.maxWidth >= 650.00 && constraints.maxWidth < 1100.00 //
        ) {
          return mediumScreen ?? bigScreen;
        } else {
          return smallScreen;
        }
      },
    );
  }
}

enum ScreenSize {
  bigScreen,
  mediumScreen,
  smallScreen,
}

extension SizeConfig on BuildContext {
  bool get isSmallScreen => MediaQuery.of(this).size.width < 650;
  bool get isMediumScreen =>
      MediaQuery.of(this).size.width >= 650 &&
          MediaQuery.of(this).size.width < 1100;
  bool get isBigScreen => MediaQuery.of(this).size.width >= 1100;
}