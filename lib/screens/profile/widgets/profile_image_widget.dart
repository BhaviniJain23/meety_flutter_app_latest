import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

class ProfileImage extends StatelessWidget {
  final List<String> images;
  final double height;
  ProfileImage({Key? key, required this.images, required this.height})
      : super(key: key);

  final imageIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.only(
        bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15));
    return Container(
      height: height,
      width: double.maxFinite,
      decoration: const BoxDecoration(borderRadius: borderRadius),
      child: ValueListenableBuilder(
        valueListenable: imageIndex,
        builder: (context, imageIndexValue, child) {
          return Material(
            type: MaterialType.transparency,
            borderRadius: borderRadius,
            child: InkWell(
              onTapDown: (details) {
                double screenWidth = MediaQuery.of(context).size.width;
                double tapPosition = details.globalPosition.dx;
                if (tapPosition < screenWidth / 2) {
                  if (imageIndex.value > 0) {
                    imageIndex.value = imageIndex.value - 1;
                  }
                }
                if (details.localPosition.direction < 1.0) {
                  if (imageIndex.value < (images.length - 1)) {
                    imageIndex.value = imageIndex.value + 1;
                  }
                }
              },
              child: Stack(
                children: [
                  SizedBox(
                    height: double.maxFinite,
                    width: double.maxFinite,
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: Image.network(
                        images[imageIndexValue],
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.black.toMaterialColor.withOpacity(0.5),
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(15)),
                        ),
                        child: DotsIndicator(
                          axis: Axis.horizontal,
                          dotsCount: images.length,
                          position: imageIndexValue.toDouble(),
                          decorator: const DotsDecorator(
                            color: Colors.white38, // Inactive color
                            activeColor: white,
                          ),
                        )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
