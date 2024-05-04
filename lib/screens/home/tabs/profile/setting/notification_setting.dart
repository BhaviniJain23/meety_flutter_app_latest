// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

import '../../../../../services/singleton_locator.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({Key? key, required this.loginUser})
      : super(key: key);
  final User loginUser;

  @override
  State<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  ValueNotifier notiVisitor = ValueNotifier("0");
  ValueNotifier notiLike = ValueNotifier("0");
  ValueNotifier notiMsgRequests = ValueNotifier("0");
  ValueNotifier notiMsgMatch = ValueNotifier("0");
  ValueNotifier notiMatch = ValueNotifier("0");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notiVisitor.value = widget.loginUser.notiVisitor ?? '0';
    notiLike.value = widget.loginUser.notiLike ?? '0';
    notiMsgRequests.value = widget.loginUser.notiMsgRequests ?? '0';
    notiMsgMatch.value = widget.loginUser.notiMsgMatch ?? '0';
    notiMatch.value = widget.loginUser.notiMatch ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(
        title: "Notification Setting",
        elevation: 2,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: notificationInfo(),
        ),
      ),
    );
  }

  Widget notificationInfo() {
    return Selector<EditUserProvider, String>(
      selector: (context, provider) => provider.loginUser.toString(),
      builder: (context, value, child) {
        return MultiValueListenableBuilder(
          valueListenables: [
            notiVisitor,
            notiLike,
            notiMsgRequests,
            notiMsgMatch,
            notiMatch
          ],
          builder: (context, values, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(UiString.visitorText,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontSize: 15, color: Colors.grey)),
                  tileColor: white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  value: notiVisitor.value == "1" ? true : false,
                  onChanged: (newValue) {
                    notiVisitor.value = newValue ? "1" : "0";
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(UiString.likesText,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontSize: 15, color: Colors.grey)),
                  tileColor: white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  value: notiLike.value == "1" ? true : false,
                  onChanged: (newValue) {
                    notiLike.value = newValue ? "1" : "0";
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(UiString.msgRequests,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontSize: 15, color: Colors.grey)),
                  tileColor: white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  value: notiMsgRequests.value == "1" ? true : false,
                  onChanged: (newValue) {
                    notiMsgRequests.value = newValue ? "1" : "0";
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(UiString.msgMatch,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontSize: 15, color: Colors.grey)),
                  tileColor: white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  value: notiMsgMatch.value == "1" ? true : false,
                  onChanged: (newValue) {
                    notiMsgMatch.value = newValue ? "1" : "0";
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(UiString.matchText,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontSize: 15, color: Colors.grey)),
                  tileColor: white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  value: notiMatch.value == "1" ? true : false,
                  onChanged: (newValue) {
                    notiMatch.value = newValue ? "1" : "0";
                  },
                ),
                const SizedBox(height: 40),
                Builder(builder: (context) {
                  var isUpdate =
                      widget.loginUser.notiVisitor != notiVisitor.value ||
                          widget.loginUser.notiMsgRequests !=
                              notiMsgRequests.value ||
                          widget.loginUser.notiMsgMatch != notiMsgMatch.value ||
                          widget.loginUser.notiLike != notiLike.value ||
                          widget.loginUser.notiMatch != notiMatch.value;
                  return FillBtnX(
                      onPressed: () async {
                        if (isUpdate) {
                          await context
                              .read<EditUserProvider>()
                              .updateNotificationApi(context,
                                  notiVisitor: notiVisitor.value,
                                  notiMsgRequests: notiMsgRequests.value,
                                  notiMsgMatch: notiMsgMatch.value,
                                  notiLike: notiLike.value,
                                  notiMatch: notiMatch.value);
                        }
                        sl<NavigationService>().pop();
                      },
                      isDisabled: !isUpdate,
                      text: UiString.update);
                })
              ],
            );
          },
        );
      },
    );
  }
}
