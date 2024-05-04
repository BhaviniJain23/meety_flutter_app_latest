import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:swipable_stack/swipable_stack.dart';

class SwipeCardView extends StatelessWidget {
  const SwipeCardView(
      {Key? key,
      required this.onPreviousPageTap,
      required this.onNextPageTap,
      required this.user})
      : super(key: key);
  final GestureTapCallback onPreviousPageTap;
  final GestureTapCallback onNextPageTap;
  final UserBasicInfo user;

  @override
  Widget build(BuildContext context) {
    final titleStyle = context.textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2);
    final bodyStyle = context.textTheme.bodyMedium
        ?.copyWith(color: Colors.white, fontSize: 14);
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: white,
          boxShadow: [
            BoxShadow(color: grey.toMaterialColor.shade100, blurRadius: 15)
          ]),
      margin: EdgeInsets.only(bottom: ResponsiveDesign.height(32, context)),
      child: Stack(
        children: [
          Positioned.fill(
            child: InkWell(
              onTapDown: (details) {
                double screenWidth = MediaQuery.of(context).size.width;
                double tapPosition = details.globalPosition.dx;
                if (tapPosition < screenWidth / 2) {
                  onPreviousPageTap.call();
                }
                if (details.localPosition.direction < 1.0) {
                  onNextPageTap();
                }
              },
              child: Stack(
                children: [
                  if (user.images?.isNotEmpty ?? false) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                          ).createShader(Rect.fromLTRB(
                              0, -140, rect.width, rect.height + 32));
                        },
                        blendMode: BlendMode.darken,
                        child: SizedBox(
                          height: ResponsiveDesign.screenHeight(context) * 0.80,
                          width: ResponsiveDesign.screenWidth(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CacheImage(
                              height:
                                  ResponsiveDesign.screenHeight(context) * 0.80,
                              width: ResponsiveDesign.screenWidth(context),
                              imageUrl: user.images![user.imageIndex],
                            ),
                          ),
                        ),
                      ),
                    )
                  ] else ...[
                    Container(
                      color: Colors.black,
                    )
                  ],
                  if ((user.images?.length ?? 0) > 1)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color:
                                Colors.black.toMaterialColor.withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(20),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: DotsIndicator(
                            axis: Axis.vertical,
                            dotsCount: user.images?.length ?? 0,
                            position: user.imageIndex.toDouble(),
                            decorator: const DotsDecorator(
                              color: Colors.white38, // Inactive color
                              activeColor: white,
                            ),
                          )),
                    ),
                  Positioned(
                    left: 15,
                    top: 15,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.toMaterialColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Text.rich(TextSpan(children: [
                        const WidgetSpan(
                            alignment: PlaceholderAlignment.bottom,
                            child: Icon(
                              Icons.location_on_outlined,
                              color: white,
                              size: 18,
                            )),
                        TextSpan(
                            text: user.calDistance,
                            style: context.textTheme.labelLarge
                                ?.copyWith(color: white, fontSize: 12))
                      ])),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: context.height * 0.88,
                minHeight: context.height * 0.18,
              ),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                      child: Text.rich(TextSpan(children: [
                    TextSpan(
                      text: "${user.name}, ${user.age}",
                      style: titleStyle,
                    ),
                    WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: InkWell(
                            onTap: () {
                              sl<NavigationService>().navigateTo(
                                RoutePaths.viewProfile,
                                nextScreen: ProfileScreen(
                                  userId: user.id.toString(),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Icon(
                                Icons.info_outlined,
                                color: Colors.white,
                              ),
                            )))
                  ]))),
                  if (user.imageIndex == 0) ...[
                    if (user.about != null) ...[
                      Flexible(
                        child: Text(
                          "${user.about}",
                          style: bodyStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (user.sexOrientation != null) ...[
                      Flexible(
                        child: Text(
                          user.sexOrientation,
                          style: bodyStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                  if (user.imageIndex == 1) ...[
                    if (user.hometown != null) ...[
                      iconWithTitle(
                          icon: Icons.home,
                          title: "Lives in ${user.hometown}",
                          bodyStyle: bodyStyle),
                    ],
                    if (user.basicDetail != null) ...[
                      iconWithTitle(
                          icon: Icons.book_sharp,
                          title: "${user.basicDetail}",
                          bodyStyle: bodyStyle),
                    ],
                    if (user.hometown == null && user.basicDetail == null) ...[
                      Flexible(
                        child: interestList(
                            interests: user.interest?.split(",") ?? []),
                      )
                    ]
                  ],
                  if (user.imageIndex == 2) ...[
                    Flexible(
                        child: interestList(
                            interests: user.interest?.split(",") ?? []))
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconWithTitle(
      {required IconData icon, required String title, TextStyle? bodyStyle}) {
    return Text.rich(TextSpan(children: [
      WidgetSpan(
          alignment: PlaceholderAlignment.bottom,
          child: Icon(
            icon,
            color: Colors.black,
            size: 22,
          )),
      const WidgetSpan(
          child: SizedBox(
        width: 10,
      )),
      TextSpan(
        text: title,
        style: bodyStyle?.copyWith(fontSize: 15),
      )
    ]));
  }

  Widget interestList({required List<String> interests}) {
    return Wrap(
      runSpacing: 5,
      children: interests
          .map((e) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color(0x89dad3d3),
                  ),
                  child: Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class BottomButtonRow extends StatelessWidget {
  const BottomButtonRow(
      {Key? key,
      this.canRewind,
      this.onRewindTap,
      this.onSwipe,
      this.onMessageTap,
      this.disabled = false})
      : super(key: key);

  final bool? canRewind;
  final bool disabled;
  final VoidCallback? onRewindTap;
  final VoidCallback? onMessageTap;
  final ValueChanged<SwipeDirection>? onSwipe;

  static const double height = 80;
  static double circleHeight = 55;
  static double circleWidth = 55;
  static double imageHeight = 35;
  static double imageWidth = 35;

  dynamic decoration(disabled) => BoxDecoration(
        boxShadow: [
          if (disabled) ...[
            const BoxShadow(
                color: disabledBorderColor, offset: Offset(0, 5), blurRadius: 5)
          ] else ...[
            const BoxShadow(
                color: Color.fromRGBO(232, 106, 106, 0.12),
                offset: Offset(0, 20),
                blurRadius: 20)
          ]
        ],
        border: Border.all(color: disabled ? disabledBorderColor : white),
        color: disabled ? white : red,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      );

  @override
  Widget build(BuildContext context) {
    circleHeight = ResponsiveDesign.height(55, context);
    circleWidth = ResponsiveDesign.width(55, context);
    imageHeight = ResponsiveDesign.height(38, context);
    imageWidth = ResponsiveDesign.width(38, context);

    return Container(
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // _rewindWidget(),
          // const SizedBox(
          //   width: 20,
          // ),
          _dislikeWidget(),
          const SizedBox(
            width: 20,
          ),
          _messageWidget(),
          const SizedBox(
            width: 20,
          ),
          _likeWidget(),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _rewindWidget() {
    return InkWell(
      onTap: canRewind ?? false ? onRewindTap : null,
      child: Container(
        width: circleWidth,
        height: circleHeight,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.1),
                offset: Offset(0, 20),
                blurRadius: 30)
          ],
          border: Border.all(
              color: canRewind ?? false
                  ? red.toMaterialColor.shade300
                  : grey.toMaterialColor.shade300),
          color: canRewind ?? false
              ? red.toMaterialColor.shade100
              : grey.toMaterialColor.shade100,
          borderRadius: const BorderRadius.all(Radius.elliptical(78, 78)),
        ),
        child: SizedBox(
          height: imageHeight,
          width: imageWidth,
          child: Image.asset(
            Assets.rewindIcon,
            color: canRewind ?? false ? red : grey,
          ),
        ),
      ),
    );
  }

  Widget _dislikeWidget() {
    return InkWell(
      onTap: !disabled
          ? () {
              onSwipe!(SwipeDirection.left);
            }
          : null,
      child: Container(
        width: circleWidth,
        height: circleHeight,
        padding: const EdgeInsets.all(12),
        decoration: decoration(disabled),
        child: SizedBox(
          height: imageHeight,
          width: imageWidth,
          child: Image.asset(
            Assets.dislikeIcon,
            color: disabled ? grey.toMaterialColor.shade200 : white,
          ),
        ),
      ),
    );
  }

  Widget _likeWidget() {
    return InkWell(
      onTap: !disabled
          ? () {
              onSwipe!(SwipeDirection.right);
            }
          : null,
      child: Container(
        width: circleHeight,
        height: circleWidth,
        padding: const EdgeInsets.all(10),
        decoration: decoration(disabled),
        child: SizedBox(
          height: imageHeight,
          width: imageWidth,
          child: Image.asset(
            Assets.heartIcon,
            color: disabled ? grey.toMaterialColor.shade200 : white,
          ),
        ),
      ),
    );
  }

  Widget _messageWidget() {
    return InkWell(
      onTap: !disabled ? onMessageTap : null,
      child: Container(
        width: circleWidth + 10,
        height: circleHeight + 10,
        padding: const EdgeInsets.all(10),
        decoration: decoration(disabled),
        child: SizedBox(
          height: imageHeight,
          width: imageWidth,
          child: Image.asset(
            Assets.messageCommentIcon,
            color: disabled ? grey.toMaterialColor.shade200 : white,
          ),
        ),
      ),
    );
  }
}
