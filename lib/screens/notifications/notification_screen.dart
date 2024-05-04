// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/notification_model.dart';
import 'package:meety_dating_app/providers/notification_provider.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../constants/assets.dart';
import '../../constants/constants.dart';
import '../../constants/size_config.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(
        title: UiString.notifications,
      ),
      body: ChangeNotifierProvider(
        create: (context) => NotificationProvider()..fetchNotification(),
        child: Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            bool dataFetched = (provider.notificationLoader ==
                        DataState.Fetched ||
                    provider.notificationLoader == DataState.No_More_Data) &&
                provider.notificationList.isNotEmpty;
            bool dataLoading =
                (provider.notificationLoader == DataState.Uninitialized ||
                    provider.notificationLoader == DataState.Initial_Fetching ||
                    provider.notificationLoader == DataState.More_Fetching);
            if (dataLoading) {
              return const Center(child: Loading());
            } else {
              if (dataFetched) {
                return SmartRefresher(
                  controller: provider.refreshController,
                  enablePullUp: true,
                  onRefresh: provider.onRefresh,
                  onLoading: provider.onLoadMore,
                  child: ListView.separated(
                    itemCount: provider.notificationList.length,
                    itemBuilder: (context, i) {
                      return NotificationCard(
                        notificationModel: provider.notificationList[i],
                        title: provider.notificationList[i].message.toString(),
                        date: provider.notificationList[i].createdAt,
                        isReads:
                            // ignore: dead_null_aware_expression
                            provider.notificationList[i].isRead ?? 0,
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Padding(
                        padding: EdgeInsets.only(right: 20, left: 70),
                        child: Divider(
                          color: grey,
                          height: 0,
                          thickness: 1,
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.only(top: 125),
                  child: Center(
                    child: EmptyWidget(
                      subTitleText: "No Notification Found",
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final int isReads;
  final NotificationModel notificationModel;

  const NotificationCard(
      {Key? key,
      required this.title,
      required this.date,
      required this.isReads,
      required this.notificationModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ResponsiveDesign.height(180, context),
      width: ResponsiveDesign.width(double.infinity, context),
      foregroundDecoration: isReads != '1'
          ? BoxDecoration(color: const Color(0xff8DA6F4).withOpacity(0.1))
          : null,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          left: 10,
          right: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (notificationModel.notificationType.toString() !=
                    Constants.visitNotificationType &&
                notificationModel.notificationType.toString() !=
                    Constants.profileCompletingNotificationType) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 35),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade300,
                  child: Image.asset(
                    Assets.notificationOutline,
                    height: ResponsiveDesign.width(30, context),
                    width: ResponsiveDesign.width(30, context),
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 35, top: 30),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade300,
                  child: Image.asset(
                    Assets.heartOutline,
                    height: ResponsiveDesign.height(30, context),
                    width: ResponsiveDesign.width(30, context),
                  ),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(20, context),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (date.toString().isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                          textAlign: TextAlign.center,
                          date.toEdMMMyAgoString(),
                          style: context.textTheme.titleSmall?.copyWith(
                              fontSize: ResponsiveDesign.fontSize(15, context),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                  const SizedBox(
                    height: 10,
                  ),
                  if (notificationModel.notificationType.toString() !=
                          Constants.visitNotificationType &&
                      notificationModel.notificationType.toString() !=
                          Constants.profileCompletingNotificationType) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () async {},
                        child: Container(
                          height: ResponsiveDesign.width(35, context),
                          width: ResponsiveDesign.width(110, context),
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(width: 1, color: black),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            UiString.viewProfile,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontSize: ResponsiveDesign.fontSize(17, context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ] else
                    ...[],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
