import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/custom_notification.dart';
import 'package:meety_dating_app/models/push_notification.dart';

class NotificationService {

  static Future<void> pushNotification(
      {String? titleText,
      String? bodyText,
      Map<String, dynamic>? data,
      CustomNotification? customNotification,
      required String token}) async {

    return await sendPopupNotification(pushNotification: PushNotification(
      title: titleText ?? '',
      body: bodyText ?? '',
      deviceToken: token,
      data: data ?? customNotification!.toJson(),
      senderPhoto: customNotification?.senderProfileImage ?? '',
      receiverId: customNotification?.receiverId ?? '',
      notificationType:
      customNotification?.notificationType ?? Constants.noneOfNotification,
    ));
  }

  static Future<void> silentNotification({
    required Map<String, dynamic> data,
    required String token,
    required String notificationType,
    required String receiverId,
  }) async {

    return await sendPopupNotification(pushNotification: PushNotification(
      title: '',
      body: '',
      deviceToken: token,
      data: data,
      receiverId: receiverId,
      notificationType: notificationType,
    ));
  }

  static Future<void> sendPopupNotification(
      {required PushNotification pushNotification}) async {
    try {
      try {

        if (kDebugMode) {
          print("sending push notification");
          print(jsonEncode(pushNotification.toMap()));
        }
        final dio = Dio();
        final result = await dio.post(
          'https://fcm.googleapis.com/fcm/send',
          options: Options(
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=${Constants.serverKey}',
            },
          ),
          data: jsonEncode(pushNotification.toMap()),
        );
        if (result.data is Map &&
            result.data.containsKey('failure') &&
            result.data['failure'] >= 1) {
          Map<String, dynamic> apiResponse = await UserRepository()
              .getFcmTokenFromUserId(userId: pushNotification.receiverId);
          if (apiResponse[UiString.successText]) {
            if (apiResponse[UiString.dataText] != null) {
              sendPopupNotification(
                  pushNotification: pushNotification
                      .copyWith(apiResponse[UiString.dataText]['fcm_token']));
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("catch e<<<<<<<<<<<<<<$e");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("catch e>>>>>>>>>>>>>>>>$e");
      }

      return Future.error("Error with push notification");
    }
  }
}
