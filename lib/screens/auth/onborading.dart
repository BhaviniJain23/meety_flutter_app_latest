// ignore_for_file: non_constant_identifier_names

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

import '../../services/shared_pref_manager.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final pageController = PageController();
  final totalDots = 3;
  ValueNotifier<int> currentPosition = ValueNotifier(0);

  @override
  void dispose() {
    pageController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Assets.boarding), fit: BoxFit.fill)),
          child: ValueListenableBuilder(
            builder: (context, currentPositionVal, _) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: PageView(
                      onPageChanged: (value) {
                        currentPosition.value = value;
                      },
                      controller: pageController,
                      children: [
                        BoardingScreen1(),
                        BoardingScreen2(),
                        BoardingScreen3(),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding:
                          ResponsiveDesign.only(context, top: 46, right: 35),
                      child: InkWell(
                        onTap: () async {
                          await sl<SharedPrefsManager>()
                              .saveBoardingScreen("true");

                          sl<NavigationService>().navigateTo(RoutePaths.login,
                              withPushAndRemoveUntil: true);
                        },
                        child: Container(
                          height: ResponsiveDesign.width(35, context),
                          width: ResponsiveDesign.width(91, context),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                  width: 1, color: Color(0xFFFF5A78)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Skip",
                                  style: TextStyle(
                                    color: red,
                                    fontSize: 16.23,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: red,
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: ResponsiveDesign.only(context,
                        bottom: 46, left: 35, right: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DotsIndicator(
                          dotsCount: totalDots,
                          position: currentPositionVal.toDouble(),
                          decorator:
                              const DotsDecorator(activeColor: Colors.black),
                        ),
                        InkWell(
                          onTap: () async {
                            if (currentPositionVal != totalDots - 1) {
                              pageController.nextPage(
                                  duration: const Duration(seconds: 1),
                                  curve: Curves.fastEaseInToSlowEaseOut);
                            } else {
                              await sl<SharedPrefsManager>()
                                  .saveBoardingScreen("true");

                              sl<NavigationService>().navigateTo(
                                  RoutePaths.login,
                                  withPushAndRemoveUntil: true);
                            }
                          },
                          child: Container(
                            height: ResponsiveDesign.width(35, context),
                            width: ResponsiveDesign.width(91, context),
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(
                                    width: 1, color: Color(0xFFFF5A78)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "Next",
                                  style: TextStyle(color: red),
                                ),
                                Icon(
                                  Icons.arrow_forward,
                                  color: red,
                                  size: 15,
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
            valueListenable: currentPosition,
          ),
        ),
      ),
    );
  }

  Widget BoardingScreen1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: ResponsiveDesign.width(354.59, context),
            height: ResponsiveDesign.height(344, context),
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(Assets.boarding1)))),
        Padding(
          padding: ResponsiveDesign.only(context, left: 20, right: 20, top: 70),
          child: const Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(24, 24, 24, 1)),
                  children: [
                    TextSpan(text: "Advanced "),
                    TextSpan(text: "Matching ", style: TextStyle(color: red)),
                    TextSpan(text: "Algorithm\nFor better compatibility")
                  ])),
        ),
        SizedBox(
          height: ResponsiveDesign.height(40, context),
        ),
        Padding(
          padding: ResponsiveDesign.horizontal(15.0, context),
          child: const Column(
            children: [
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(text: "Precision "),
                        TextSpan(
                            text: "Matchmaking ", style: TextStyle(color: red)),
                        TextSpan(text: "for Genuine Connections.")
                      ])),
              Text.rich(
                  textAlign: TextAlign.center,
                  TextSpan(
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(text: "Meet Your Ideal Partner with "),
                        TextSpan(text: "Meety. ", style: TextStyle(color: red)),
                      ])),
            ],
          ),
        ),
      ],
    );
  }

  Widget BoardingScreen2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: ResponsiveDesign.width(337.73, context),
            height: ResponsiveDesign.height(328.84, context),
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(Assets.boarding2)))),
        Padding(
          padding:
              ResponsiveDesign.only(context, left: 20, right: 20, top: 120),
          child: const Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "Unlimited"),
                    TextSpan(
                        text: " Connections\n", style: TextStyle(color: red)),
                    TextSpan(text: "Anywhere in the World "),
                  ])),
        ),
        SizedBox(
          height: ResponsiveDesign.height(40, context),
        ),
        const Text.rich(
            textAlign: TextAlign.center,
            TextSpan(
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(
                      text: "Unlock Worldwide Romance\n"
                          "Love Knows No Borders"),
                ])),
      ],
    );
  }

  Widget BoardingScreen3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: ResponsiveDesign.width(323.73, context),
            height: ResponsiveDesign.height(323.84, context),
            decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage(Assets.boarding3)))),
        Padding(
          padding:
              ResponsiveDesign.only(context, left: 20, right: 20, top: 120),
          child: const Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "Not Just Matches,\nGet Real "),
                    TextSpan(text: "Connections", style: TextStyle(color: red)),
                  ])),
        ),
        SizedBox(
          height: ResponsiveDesign.height(40, context),
        ),
        const Text.rich(
            maxLines: 2,
            textAlign: TextAlign.center,
            TextSpan(
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                children: [
                  TextSpan(text: "Match ", style: TextStyle(color: red)),
                  TextSpan(
                    text:
                        "for Meaningful Connections,\nNot Just Random Encounters.",
                  ),
                ])),
      ],
    );
  }
}
