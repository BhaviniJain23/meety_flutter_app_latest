import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class EmptyWidget extends StatelessWidget {
  final String? image;
  final String? titleText;
  final String? subTitleText;
  const EmptyWidget({Key? key, this.image,
    this.titleText, this.subTitleText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: white,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          if(image?.isNotEmpty ?? true)...[

            Image.asset(
              image ?? Assets.notDataFoundImg,
              height:  200,
            )
          ],
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: <Widget>[
                Text(
                  titleText ?? 'Oops !! No Data Found',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                if(subTitleText != null)
                  Text(
                    subTitleText!,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: const Color(0xff002055),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  final double? height;
  const Loading({
    Key? key,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? (context.height * 0.8),
      color: white,
      child: Lottie.asset(Assets.loader),
    );
  }
}
