import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/screens/profile/view_profile.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';

import '../../../services/singleton_locator.dart';

class UserCard extends StatelessWidget {
  final UserBasicInfo userBasicInfo;
  final bool isImageBlur;
  final bool showLikeButton;
  final bool showDisLikeButton;
  final VoidCallback? onBlurTap;

  const UserCard(this.userBasicInfo, {
    Key? key,
    required this.isImageBlur,
    required this.showLikeButton,
    required this.showDisLikeButton,
    this.onBlurTap
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveDesign.height(300, context),
      width: ResponsiveDesign.width(180, context),
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
          color: whitesmoke, borderRadius: BorderRadius.circular(10)),
      child: Stack(
        children: [
          BlurFilter(
            isBlur: isImageBlur,
            child: InkWell(
              onTap: () {
                if (!isImageBlur) {
                  sl<NavigationService>().navigateTo(RoutePaths.viewProfile,
                      nextScreen: ProfileScreen(
                          userId: userBasicInfo.id.toString()));
                } else if (onBlurTap != null) {
                  onBlurTap!();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ).createShader(
                        Rect.fromLTRB(0, -140, rect.width, rect.height));
                  },
                  blendMode: BlendMode.darken,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CacheImage(
                      imageUrl: userBasicInfo.images!.isNotEmpty
                          ? userBasicInfo.images![userBasicInfo.imageIndex]
                          : '',
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (!isImageBlur) ...[
            Container(
              height: ResponsiveDesign.height(35, context),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10),
                  ),
                  color: Colors.black.toMaterialColor.withOpacity(0.4)),
              alignment: Alignment.center,
              child: Text(
                '${userBasicInfo.name}, ${userBasicInfo.age}',
                style: context.textTheme.titleSmall?.copyWith(
                    color: white, fontWeight: FontWeight.w400, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
          Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                //height: getVerticalSize(42),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: Container(
                      height: 40,
                      color: white.withOpacity(0.1),
                      child: Row(
                        children: [
                          if (showDisLikeButton) ...[
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!isImageBlur) {
                                    context
                                        .read<HomeProvider>()
                                        .updateVisitAction(
                                        context,
                                        userBasicInfo.visitStatus !=
                                            Constants.visitor
                                            ? Constants.disliked
                                            : Constants.visitedAndDisliked,
                                        userBasicInfo: userBasicInfo,
                                        isDirectionUpdate: false);
                                  } else if (onBlurTap != null) {
                                    onBlurTap!();
                                  }
                                },
                                child: SvgPicture.asset(
                                  Assets.dislikeSvgIcon,
                                  color: white,
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                            ),
                            Container(
                              width: 0.4,
                              color: white,
                            ),
                          ],
                          Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!isImageBlur) {
                                    context
                                        .read<HomeProvider>()
                                        .updateVisitAction(
                                        context, Constants.message,
                                        userBasicInfo: userBasicInfo,
                                        isDirectionUpdate: false);
                                  } else if (onBlurTap != null) {
                                    onBlurTap!();
                                  }
                                },
                                child: SvgPicture.asset(
                                  Assets.messageSvgIcon,
                                  color: white,
                                  height: 22,
                                  width: 22,
                                ),
                              )),
                          if (showLikeButton) ...[
                            Container(
                              width: 0.4,
                              color: white,
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (!isImageBlur) {
                                    context
                                        .read<HomeProvider>()
                                        .updateVisitAction(
                                        context, Constants.liked,
                                        userBasicInfo: userBasicInfo,
                                        isDirectionUpdate: false);
                                  } else if (onBlurTap != null) {
                                    onBlurTap!();
                                  }
                                },
                                child: SvgPicture.asset(
                                  Assets.likeSvgIcon,
                                  color: white,
                                  height: 18,
                                  width: 18,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class BlurFilter extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final bool isBlur;

  const BlurFilter({super.key,
    required this.child,
    this.sigmaX = 5.0,
    this.sigmaY = 5.0,
    required this.isBlur});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: sigmaX,
              sigmaY: sigmaY,
            ),
            child: Opacity(
              opacity: isBlur ? 0.005 : 1,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
