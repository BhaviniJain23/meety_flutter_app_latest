import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    final double xScaling = size.width / 375;
    const double yScaling = 1;
    path.lineTo(0 * xScaling,44 * yScaling);
    path.cubicTo(0 * xScaling,19.7 * yScaling,19.7 * xScaling,0 * yScaling,44 * xScaling,0 * yScaling,);
    path.cubicTo(44 * xScaling,0 * yScaling,156.1 * xScaling,0 * yScaling,156.1 * xScaling,0 * yScaling,);
    path.cubicTo(158.6 * xScaling,0 * yScaling,161.1 * xScaling,0.8 * yScaling,163.29999999999998 * xScaling,2.2 * yScaling,);
    path.cubicTo(177.7 * xScaling,11.7 * yScaling,196.39999999999998 * xScaling,11.8 * yScaling,211 * xScaling,2.6 * yScaling,);
    path.cubicTo(211 * xScaling,2.6 * yScaling,211.7 * xScaling,2.1 * yScaling,211.7 * xScaling,2.1 * yScaling,);
    path.cubicTo(213.79999999999998 * xScaling,0.7000000000000002 * yScaling,216.39999999999998 * xScaling,0 * yScaling,218.89999999999998 * xScaling,0 * yScaling,);
    path.cubicTo(218.89999999999998 * xScaling,0 * yScaling,331 * xScaling,0 * yScaling,331 * xScaling,0 * yScaling,);
    path.cubicTo(355.3 * xScaling,0 * yScaling,375 * xScaling,19.7 * yScaling,375 * xScaling,44 * yScaling,);
    path.cubicTo(375 * xScaling,44 * yScaling,375 * xScaling,514 * yScaling,375 * xScaling,514 * yScaling,);
    path.cubicTo(375 * xScaling,514 * yScaling,0 * xScaling,514 * yScaling,0 * xScaling,514 * yScaling,);
    path.cubicTo(0 * xScaling,514 * yScaling,0 * xScaling,44 * yScaling,0 * xScaling,44 * yScaling,);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = white;
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}