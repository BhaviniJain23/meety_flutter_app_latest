import 'dart:convert';

import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';

class CustomNotification {
  CustomNotification(
      {required this.notificationType,
      this.time,
      this.receiverName,
      required this.receiverId,
      this.userProfileImage,
      required this.senderName,
      required this.senderId,
      this.senderProfileImage,
      required this.data});

  String? receiverName;
  String? receiverId;
  String? userProfileImage;
  String? senderName;
  String senderId;
  String? senderProfileImage;
  DateTime? time;
  String notificationType;
  Map<String, dynamic> data;

  factory CustomNotification.fromJson(Map<String, dynamic> jsonObj) =>
      CustomNotification(
        receiverName: jsonObj["receiver_name"]?.toString() ?? '',
        receiverId: jsonObj["receiver_id"]?.toString() ?? '',
        userProfileImage: jsonObj["receiver_image"]?.toString() ?? '',
        senderName: jsonObj["sender_name"]?.toString() ?? '',
        senderId: jsonObj["sender_id"]?.toString() ?? '',
        senderProfileImage: jsonObj["sender_image"]?.toString() ?? '',
        time: jsonObj["time"] is String
            ? DateTime.tryParse(jsonObj['time']) ?? DateTime.now()
            : jsonObj['time'] ?? DateTime.now(),
        notificationType: jsonObj["notification_type"]?.toString() ?? '',
        data: jsonObj['data'] != null ? json.decode(jsonObj["data"]) : {},
      );

  factory CustomNotification.forChatNotification(
    UserBasicInfo loginUser,
    ChatUser1 chatUser1,
    int otherReadStatus,
      Message chatMessage,
  ) {
    final loggedChatInfo = ChatUser1.fromChatUserAndLastMsg(
        ChatUser1.fromUserBasicRecord(loginUser)
            .copyWith(isBothRead: otherReadStatus),
        chatMessage,
        '1').copyWith(
      channelId: chatUser1.channelId
    );
    return CustomNotification(
        notificationType: Constants.chatNotificationType,
        receiverId: chatUser1.userRecord?.id,
        receiverName: chatUser1.userRecord?.name,
        senderName: loginUser.name,
        senderId: loginUser.id,
        userProfileImage:
            loginUser.images != null && loginUser.images!.isNotEmpty
                ? loginUser.images!.first
                : '',
        data: {
          "chat_user": loggedChatInfo,
          "msg": chatMessage.toJson()
        });
  }

  Map<String, dynamic> toJson() => {
        "receiver_name": receiverName,
        "receiver_id": receiverId,
        "receiver_image": userProfileImage,
        "sender_name": senderName,
        "sender_id": senderId,
        "sender_image": senderProfileImage,
        "time": time,
        "notification_type": notificationType,
        "data": jsonEncode(data)
      };

  CustomNotification copyWith({
    String? receiverName,
    String? receiverId,
    String? userProfileImage,
    String? senderName,
    String? senderId,
    String? senderProfileImage,
    DateTime? time,
    String? isNotificationRead,
    String? notificationType,
    Map<String, dynamic>? data,
  }) {
    return CustomNotification(
      receiverName: receiverName ?? this.receiverName,
      receiverId: receiverId ?? this.receiverId,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      senderName: senderName ?? this.senderName,
      senderId: senderId ?? this.senderId,
      senderProfileImage: senderProfileImage ?? this.senderProfileImage,
      time: time ?? this.time,
      notificationType: notificationType ?? this.notificationType,
      data: data ?? this.data,
    );
  }

  static CustomNotification empty = CustomNotification(
      notificationType: "0",
      receiverId: '',
      senderName: '',
      senderId: '',
      data: {});

  bool get isEmpty => this == CustomNotification.empty;
}
