import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:provider/provider.dart';

class ButtonsRow extends StatefulWidget {
  final bool isLikeShow;
  final bool isDisLikeShow;
  final bool isMessageShow;
  final UserBasicInfo userBasicInfo;

  final ValueChanged<bool>? onLike;
  final ValueChanged<bool>? onDisLike;
  final ValueChanged<bool>? onMessage;
  const ButtonsRow(
      {super.key,
      this.isLikeShow = true,
      this.isDisLikeShow = true,
      this.isMessageShow = true,
      required this.userBasicInfo,
      this.onLike,
      this.onDisLike,
      this.onMessage});

  @override
  State<ButtonsRow> createState() => _ButtonsRowState();
}

class _ButtonsRowState extends State<ButtonsRow> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 10,
        ),
        if (widget.isDisLikeShow) ...[
          InkWell(
            onTap: () async {
              final value = await context
                  .read<HomeProvider>()
                  .updateVisitAction(context, Constants.disliked,
                      userBasicInfo: widget.userBasicInfo);
              if (widget.onDisLike != null) {
                widget.onDisLike!(value);
              }
            },
            borderRadius:
                BorderRadius.circular(ResponsiveDesign.width(60, context)),
            child: Container(
              width: ResponsiveDesign.width(60, context),
              height: ResponsiveDesign.height(60, context),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: Colors.white)),
              child: Center(
                child: SvgPicture.asset(
                  Assets.profileDislike,
                  color: black,
                  height: 18,
                  width: 18,
                ),
              ),
            ),
          )
        ],
        const SizedBox(
          width: 8,
        ),
        InkWell(
          onTap: () async {
            final value = await context
                .read<HomeProvider>()
                .updateVisitAction(context, Constants.message,
                    userBasicInfo: widget.userBasicInfo);
            if (widget.onMessage != null) {
              widget.onMessage!(value);
            }
          },
          borderRadius:
              BorderRadius.circular(ResponsiveDesign.width(80, context)),
          child: Container(
            width: ResponsiveDesign.width(80, context),
            height: ResponsiveDesign.height(80, context),
            decoration: BoxDecoration(
                color: red,
                shape: BoxShape.circle,
                border: Border.all(width: 3, color: Colors.white)),
            child: Center(
              child: SvgPicture.asset(
                Assets.profileMessage,
                color: Colors.white,
                height: 35,
                width: 35,
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        if (widget.isLikeShow) ...[
          InkWell(
            onTap: () async {
              final value = await context
                  .read<HomeProvider>()
                  .updateVisitAction(context, Constants.liked,
                      userBasicInfo: widget.userBasicInfo);
              if (widget.onLike != null) {
                widget.onLike!(value);
              }
            },
            borderRadius:
                BorderRadius.circular(ResponsiveDesign.width(60, context)),
            child: Container(
              width: ResponsiveDesign.width(60, context),
              height: ResponsiveDesign.height(60, context),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                  border: Border.all(width: 3, color: Colors.white)),
              child: Center(
                child: SvgPicture.asset(
                  Assets.profileLike,
                  color: Colors.black,
                  height: 20,
                  width: 20,
                ),
              ),
            ),
          )
        ]
      ],
    );
  }
}
