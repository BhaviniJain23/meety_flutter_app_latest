import 'package:flutter/material.dart';

enum BannerPosition {
  topLeft,
  topRight,
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
//                                                                      //
//    Developed by Syed Mahfuzur Rahman                                 //
//    more update and customization will be added to the next update    //
//                                                                      //
//    If you have any suggestion about this package,                    //
//    feel free to contact with me: eaglex129@gmail.com                 //
//                                                                      //
//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////

class CustomBannerWidget extends StatelessWidget {
  ///Banner position will be set [Left or Right] by value [false or true]
  final BannerPosition? bannerPosition;

  ///Show Banner on top corner or not.
  final bool? showBanner;

  ///Set banner size.
  ///Height & Width will be 1:1 aspect ratio.
  final double? bannerSize;

  ///Text that shown on the banner.
  final String? bannerText;

  ///Banner text color. [bannerTextColor = Colors.red]
  final Color? bannerTextColor;

  ///Banner foreground color.
  final Color? bannerColor;

  ///Tile foreground color.
  final Color? backgroundColor;

  final Widget child;
  final BorderRadius? borderRadius;

  ///Fuctions
  final Function()? onTap;
  final Function()? onTapCancel;
  final Function(bool)? onHighlightChanged;
  final Function(bool)? onFocusChange;
  final Function(TapDownDetails)? onTapDown;
  final Function()? onLongPress;
  final Function(bool)? onHover;
  final Function()? onDoubleTap;

  ///Suitable for use in column or listview or anykind of vertical list.
  ///then it will automatically take a height by given child.
  ///
  ///Otherwise height & width must be given or it will take all the available space it get.
  ///
  const CustomBannerWidget({
    Key? key,
    this.bannerText,
    this.bannerSize = 40.0,
    this.showBanner = true,
    this.bannerPosition = BannerPosition.topRight,
    this.bannerTextColor,
    this.bannerColor,
    this.backgroundColor = const Color(0xff003354),
    this.onTap,
    this.onTapCancel,
    this.onHighlightChanged,
    this.onFocusChange,
    this.onTapDown,
    this.onLongPress,
    this.onHover,
    this.borderRadius,
    this.onDoubleTap, required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: borderRadius ?? BorderRadius.circular(0),
      child: Stack(
        children: [
          child,
          if (showBanner == true)
            Positioned(
              top: 0,
              left: bannerPosition == BannerPosition.topLeft ? 0 : null,
              right: bannerPosition == BannerPosition.topRight ||
                  bannerPosition == null
                  ? 0
                  : null,
              child: ClipPath(
                clipper: BannerClipper(bannerPosition),
                child: Container(
                  decoration: BoxDecoration(
                    color: bannerColor ?? const Color(0xffcf0517),
                  ),
                  height: bannerSize == null
                      ? 40
                      : bannerSize! >= 80
                      ? 80
                      : bannerSize! <= 40
                      ? 40.0
                      : bannerSize!, //40
                  width: bannerSize == null
                      ? 40
                      : bannerSize! >= 80
                      ? 80
                      : bannerSize! <= 40
                      ? 40.0
                      : bannerSize!,
                  child: Align(
                    alignment: bannerPosition == BannerPosition.topLeft
                        ? Alignment.topLeft
                        : Alignment.topRight,

                    child:  SizedBox(
                      height: bannerSize == null
                          ? 30
                          : bannerSize! >= 80
                          ? (30.0 * 80.0) / 40.0
                          : bannerSize! <= 40
                          ? (30.0 * 40.0) / 40.0
                          : (30.0 * bannerSize!) /
                          40.0, //30
                      width: bannerSize == null
                          ? 30
                          : bannerSize! >= 80
                          ? (30.0 * 80.0) / 40.0
                          : bannerSize! <= 40
                          ? (30.0 * 40.0) / 40.0
                          : (30.0 * bannerSize!) / 40.0,
                      child: FittedBox(
                        alignment: Alignment.center,
                        fit: BoxFit.contain,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 2,
                              top: 2,
                              left: 2,
                              bottom: 4),
                          child: Text(
                            bannerText ?? "New",
                            style: TextStyle(
                                color: bannerTextColor ??
                                    Colors.yellow,
                                fontSize: 20
                            ),
                            softWrap: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

//Custom image container shape
class ImageBoxClipper extends CustomClipper<Path> {
  final int? shapeindex;

  ImageBoxClipper(this.shapeindex);
  @override
  Path getClip(Size size) {
    var path = Path();

    if (shapeindex == null) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width * 0.85, size.height);
      path.lineTo(0, size.height);
    } else if (shapeindex! % 2 == 0) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width * 0.85, size.height);
      path.lineTo(0, size.height);
    } else {
      path.lineTo(size.width * 0.85, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

//Custom banner container shape
class BannerClipper extends CustomClipper<Path> {
  final BannerPosition? side;

  BannerClipper(this.side);

  @override
  Path getClip(Size size) {
    var path = Path();

    if (side == null || side == BannerPosition.topRight) {
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else {
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    }

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}