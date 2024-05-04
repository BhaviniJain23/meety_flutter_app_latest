import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/screens/profile/widgets/bottom_buttons.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';

import '../../../constants/assets.dart';

class CardWidget extends StatefulWidget {
  final UserBasicInfo userBasicInfo;
  final int index;
  final ValueChanged<bool>? onRewind;
  final ValueChanged<bool>? onLike;
  final ValueChanged<bool>? onDisLike;
  final ValueChanged<bool>? onMessage;

  const CardWidget(
      {super.key,
      required this.userBasicInfo,
      required this.index,
      this.onLike,
      this.onDisLike,
      this.onMessage,
      this.onRewind});

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 72.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          color: Colors.white,
          height: (ResponsiveDesign.screenHeight(context) * 0.85 - 72),
          padding: ResponsiveDesign.only(
            context,
            top: 0,
            left: 10,
            right: 10,
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      child: imageSection(widget.userBasicInfo, widget.index)),
                  Expanded(
                      child: DefaultTabController(
                    length: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TabBar(
                                    unselectedLabelColor: grey,
                                    labelColor: red,
                                    labelStyle: context.textTheme.bodyMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ResponsiveDesign.fontSize(
                                                14, context),
                                            color: grey),
                                    isScrollable: true,
                                    labelPadding: const EdgeInsets.only(
                                        right: 10, left: 5),
                                    padding: EdgeInsets.zero,
                                    physics: const BouncingScrollPhysics(),
                                    // indicator: const BoxDecoration(),
                                    indicatorSize: TabBarIndicatorSize.label,
                                    tabs: [
                                      Tab(
                                        height: ResponsiveDesign.height(
                                            25, context),
                                        child: Text(
                                          'Bio',
                                          style: TextStyle(
                                              fontSize:
                                                  ResponsiveDesign.fontSize(
                                                      18, context)),
                                        ),
                                      ),
                                      Tab(
                                        height: ResponsiveDesign.height(
                                            25, context),
                                        child: Text(
                                          'Preferences',
                                          style: TextStyle(
                                              fontSize:
                                                  ResponsiveDesign.fontSize(
                                                      18, context)),
                                        ),
                                      ),
                                    ]),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: InkWell(
                                    onTap: () async {
                                      final result =
                                          await sl<NavigationService>()
                                              .navigateTo(
                                        RoutePaths.viewProfile,
                                        nextScreen: ProfileScreen(
                                          userId: widget.userBasicInfo.id
                                              .toString(),
                                        ),
                                      );

                                      if (result == Constants.liked &&
                                          widget.onLike != null) {
                                        widget.onLike!(true);
                                      }

                                      if (result == Constants.disliked &&
                                          widget.onDisLike != null) {
                                        widget.onDisLike!(true);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.more_horiz,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ResponsiveDesign.height(5, context),
                          ),
                          Expanded(
                            child: TabBarView(
                                physics: const BouncingScrollPhysics(),
                                children: [
                                  SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child:
                                          aboutSection(widget.userBasicInfo)),
                                  SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: preferencesSection(
                                          widget.userBasicInfo))
                                ]),
                          )
                        ],
                      ),
                    ),
                  ))
                ],
              ),
              Positioned(
                  top: ResponsiveDesign.screenWidth(context) -
                      ResponsiveDesign.height(30, context),
                  right: ResponsiveDesign.width(10, context),
                  child: Padding(
                    padding:
                        ResponsiveDesign.only(context, right: 10, left: 10),
                    child: ButtonsRow(
                      userBasicInfo: widget.userBasicInfo,
                      onLike: widget.onLike,
                      onDisLike: widget.onDisLike,
                      onMessage: widget.onMessage,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageSection(UserBasicInfo user, int index) {
    // final user = provider.users[index];
    return SizedBox(
      width: ResponsiveDesign.screenWidth(context),
      height: ResponsiveDesign.screenWidth(context) +
          ResponsiveDesign.height(40, context),
      child: Stack(
        children: [
          SizedBox(
            width: ResponsiveDesign.screenWidth(context),
            height: (ResponsiveDesign.screenWidth(context) +
                    ResponsiveDesign.height(50, context)) -
                35,
            child: Stack(
              children: [
                PageView.builder(
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (indexVal) {
                      context
                          .read<HomeProvider>()
                          .updateImageIndexById(index, indexVal);
                    },
                    itemCount: user.images?.length ?? 0,
                    itemBuilder: (context, index) {
                      return ImageWidget(
                          imageUrl: user.images?[index] ?? '',
                          showShader: true,
                          borderRadius: BorderRadius.circular(20));
                    }),
                Positioned(
                  bottom: 5,
                  left: 10,
                  child: SizedBox(
                    width: ResponsiveDesign.screenWidth(context) * 0.8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 0, right: 10, top: 5, left: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              TextSpan(
                                  text:
                                      "${widget.userBasicInfo.name}${widget.userBasicInfo.age != null ? ", ${widget.userBasicInfo.age}" : ''} ",
                                  children: [
                                    if (widget.userBasicInfo.isProfileVerified
                                            .toString() ==
                                        '1') ...[
                                      const WidgetSpan(
                                          child: Icon(
                                        Icons.verified,
                                        color: Colors.blue,
                                      ))
                                    ]
                                  ]),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      ResponsiveDesign.fontSize(22, context),
                                  color: Colors.white),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text.rich(
                            TextSpan(children: [
                              WidgetSpan(
                                  child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, right: 10, bottom: 10),
                                child: Image.asset(
                                  Assets.distanceAway2,
                                  width: ResponsiveDesign.width(23, context),
                                  height: ResponsiveDesign.height(23, context),
                                ),
                              )),
                              TextSpan(
                                text: "${user.calDistance}".split(" ").first,
                              ),
                              const TextSpan(
                                text: " ",
                              ),
                              TextSpan(
                                text: "${user.calDistance}"
                                    .split(" ")
                                    .last
                                    .replaceAll(".", ""),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize:
                                        ResponsiveDesign.fontSize(12, context)),
                              ),
                            ]),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize:
                                    ResponsiveDesign.fontSize(24, context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if ((user.images?.length ?? 0) > 1) ...[
            // Positioned(
            //   top: 0,
            //   right: 0,
            //   child: Container(
            //       padding: const EdgeInsets.symmetric(vertical: 3,horizontal: 2),
            //       decoration: BoxDecoration(
            //         color: Colors.black.toMaterialColor.withOpacity(0.2),
            //         borderRadius: const BorderRadius.only(
            //           topLeft: Radius.circular(10),
            //           topRight: Radius.circular(30),
            //           bottomLeft: Radius.circular(10),
            //         ),
            //       ),
            //       child: DotsIndicator(
            //         axis: Axis.vertical,
            //         dotsCount: user.images?.length ?? 0,
            //         position: user.imageIndex.toDouble(),
            //         decorator: const DotsDecorator(
            //           color: Colors.white38, // Inactive color
            //           activeColor: white,
            //           size:  Size.square(6.0),
            //           spacing:  EdgeInsets.all(5.0)
            //         ),
            //       )),
            // )
          ],
          if (context.read<HomeProvider>().rewind) ...[
            Positioned(
              top: 0,
              left: 0,
              child: InkWell(
                onTap: () async {
                 final result = await  context.read<HomeProvider>().updateVisitAction(
                      context, Constants.rewindStatus,
                      userBasicInfo: user);

                  if (result &&
                      widget.onRewind != null) {
                    widget.onRewind!(true);
                  }

                },
                child: Container(
                  width: ResponsiveDesign.width(45, context),
                  height: ResponsiveDesign.height(45, context),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.black.toMaterialColor.withOpacity(0.5),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      )),
                  child: const Icon(
                    Icons.fast_rewind,
                    color: white,
                    size: 24,
                  ),
                ),
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget aboutSection(UserBasicInfo userBasicInfo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if ((userBasicInfo.sexOrientation?.toString().isNotEmpty ?? false) ||
              (userBasicInfo.gender?.toString().isNotEmpty ?? false)) ...[
            Container(
              color: Colors.white.withOpacity(0.2),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                child: Text(
                  "${userBasicInfo.gender?.toString().isNotEmpty ?? false ? userBasicInfo.gender : ''} ${userBasicInfo.sexOrientation?.toString().isNotEmpty ?? false ? '[${userBasicInfo.sexOrientation?.toString().isNotEmpty ?? false ? (userBasicInfo.sexOrientation?.replaceAll(",", " - ") ?? '') : ''}]' : ''}",
                  style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(15, context),
                      color: black),
                ),
              ),
            ),
          ],
          const SizedBox(
            height: 5,
          ),
          if ((userBasicInfo.hometown ?? '').isNotEmpty) ...[
            // titleDescription("Home Town", userBasicInfo.hometown ?? ''),
            Row(
              children: [
                const SizedBox(
                  width: 5,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Text(
                        "🏘 ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: grey1,
                            fontSize: ResponsiveDesign.fontSize(20, context)),
                      ),
                    ),
                    Text(
                      userBasicInfo.hometown ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: grey1,
                          fontSize: ResponsiveDesign.fontSize(15, context)),
                    ),
                  ],
                )
              ],
            )
          ],
          if ((userBasicInfo.occupation ?? '').isNotEmpty) ...[
            titleDescription("Occupation", userBasicInfo.occupation ?? ''),
          ],
          if ((userBasicInfo.education ?? '').isNotEmpty) ...[
            titleDescription("Education", userBasicInfo.education ?? ''),
          ],
          if ((userBasicInfo.about ?? '').isNotEmpty) ...[
            titleDescription("About", userBasicInfo.about ?? ''),
          ],
        ],
      ),
    );
  }

  Widget preferencesSection(UserBasicInfo userBasicInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            userBasicInfo.lookingFor ?? '',
            style: TextStyle(
                //fontWeight: FontWeight.bold,
                fontSize: ResponsiveDesign.fontSize(13, context)),
          ),
        ),
        if ((userBasicInfo.futurePlan ?? '').isNotEmpty) ...[
          SizedBox(
            height: ResponsiveDesign.height(6, context),
          ),
          titleListDescription(
              "Future Plan", (userBasicInfo.futurePlan ?? '').split(",")),
        ],
        if ((userBasicInfo.interest ?? '').isNotEmpty) ...[
          SizedBox(
            height: ResponsiveDesign.height(6, context),
          ),
          titleListDescription2(
              "Hobbies & Interest", (userBasicInfo.interest ?? '').split(",")),
        ],
        if ((userBasicInfo.habit ?? '').isNotEmpty) ...[
          SizedBox(
            height: ResponsiveDesign.height(6, context),
          ),
          titleListDescription("Habit", (userBasicInfo.habit ?? '').split(",")),
        ],
      ],
    );
  }

  Widget titleDescription(String title, String desc) {
    return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5, top: 7),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveDesign.fontSize(13, context))),
            const SizedBox(
              height: 1,
            ),
            ReadMoreText(
              desc,
              trimLines: 3,
              preDataTextStyle:
                  const TextStyle(fontWeight: FontWeight.w800, color: grey1),
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: grey1,
                  fontSize: ResponsiveDesign.fontSize(15, context)),
              moreStyle:
                  const TextStyle(fontWeight: FontWeight.normal, color: red),
              colorClickableText: red,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Read more',
              trimExpandedText: ' Show less',
            ),
          ],
        ));
  }

  Widget titleListDescription(String title, List listVal) {
    return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveDesign.fontSize(13, context))),
            const SizedBox(
              height: 4,
            ),
            Wrap(
                spacing: 10,
                runSpacing: 10,
                children: listVal.map((e) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: ResponsiveDesign.only(context,
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: Text(
                        e,
                        style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: ResponsiveDesign.fontSize(13, context)),
                      ),
                    ),
                  );
                }).toList()),
          ],
        ));
  }

  Widget titleListDescription2(String title, List listVal) {
    return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5, top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveDesign.fontSize(13, context))),
            const SizedBox(
              height: 4,
            ),
            Wrap(
                spacing: 10,
                runSpacing: 10,
                children: listVal.map((e) {
                  return Card(
                    shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1.5),
                        borderRadius: BorderRadius.circular(5)),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: ResponsiveDesign.only(context,
                          left: 5, right: 5, top: 5, bottom: 5),
                      child: Text(
                        e,
                        style: TextStyle(
                            //fontWeight: FontWeight.bold,
                            fontSize: ResponsiveDesign.fontSize(13, context)),
                      ),
                    ),
                  );
                }).toList()),
          ],
        ));
  }
}
