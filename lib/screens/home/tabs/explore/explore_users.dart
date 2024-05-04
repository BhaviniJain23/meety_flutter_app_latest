import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/models/interest_model.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/screens/home/widgets/card_label.dart';
import 'package:meety_dating_app/screens/home/widgets/swipe_card.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:swipable_stack/swipable_stack.dart';

class ExploreUsersScreen extends StatefulWidget {
  final InterestModel interestModel;
  const ExploreUsersScreen({Key? key, required this.interestModel}) : super(key: key);

  @override
  State<ExploreUsersScreen> createState() => _ExploreUsersScreenState();
}

class _ExploreUsersScreenState extends State<ExploreUsersScreen> {

  late final SwipableStackController _controller;
  final UserBasicInfo user = UserBasicInfo.fromJson(json.decode(
      '{"id": 2,"name": "Jessica Parker","gender": null,"sex_orientation": null,"showme": null, "looking_for": null,"about": "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.", "interest": "Cooking,Reading,Writing,Dancing","basic_detail": "B.Tech at SVMIT","hometown": "Gujarat","images": [ "https://meety-bucket1.s3.ap-south-1.amazonaws.com/user/2/image_16777487095990.png","https://meety-bucket1.s3.ap-south-1.amazonaws.com/user/2/image_16777487095991.png"], "age": 23,"cal_distance": "0 km" }'));
  void _listenController() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    _controller = SwipableStackController()..addListener(_listenController);
  }
  @override
  void dispose() {
    super.dispose();
    _controller
      ..removeListener(_listenController)
      ..dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(widget.interestModel.image, fit: BoxFit.cover),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Material(
              // color: Colors.white10,
              color: whitesmoke,
              child: Column(
                children: [
                  AppBarX(
                    // bgColor: Colors.transparent,
                    centerTitle: true,
                    title: widget.interestModel.interest,
                    elevation: 0,
                  ),

                  Expanded(
                    child: Center(
                      child: Container(
                        height: height * 0.86,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SwipableStack(
                          detectableSwipeDirections: const {
                            SwipeDirection.right,
                            SwipeDirection.left,
                          },
                          swipeAssistDuration: const Duration(seconds: 1),

                          overlayBuilder: (context, properties) {
                            var takingVal = properties.swipeProgress;
                            if (takingVal < 1.5) {
                              takingVal = 0;
                            } else {
                              takingVal = takingVal * 0.2;
                            }
                            final opacity = min(takingVal, 1.0);
                            final isRight = properties.direction == SwipeDirection.right;
                            final isLeft = properties.direction == SwipeDirection.left;
                            return Stack(
                              children: [
                                Opacity(
                                  opacity: isRight ? opacity : 0,
                                  child: CardLabel.right(),
                                ),
                                Opacity(
                                  opacity: isLeft ? opacity : 0,
                                  child: CardLabel.left(),
                                ),
                              ],
                            );
                          },
                          viewFraction: 0,
                          controller: _controller,
                          onSwipeCompleted: (index, direction) {
                            if (kDebugMode) {
                              // print('$index, $direction');
                            }
                          },
                          stackClipBehaviour: Clip.none,
                          // allowVerticalSwipe: false,
                          horizontalSwipeThreshold: 0.2,
                          verticalSwipeThreshold: 0.8,
                          // itemCount: 5,
                          swipeAnchor: SwipeAnchor.bottom,
                          builder: (context, properties) {
                            // final itemIndex = properties.index % 2;

                            return SwipeCardView(
                              onPreviousPageTap: () {
                                if (user.imageIndex > 0) {
                                  setState(() {
                                    user.imageIndex -= 1;
                                  });
                                }
                              },
                              onNextPageTap: () {
                                if (user.imageIndex < user.images!.length - 1) {
                                  setState(() {
                                    user.imageIndex += 1;
                                  });
                                }
                              },
                              user: user,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
