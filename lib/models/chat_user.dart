import 'dart:convert';

import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';

class ChatUser1 {
  final String? channelId;
  final int? isBothRead;
  final Message? lastMessage;
  final int? totalUnreadMessage;
  final UserBasicInfo? userRecord;

  ChatUser1({
    this.channelId,
    this.isBothRead,
    this.lastMessage,
    this.totalUnreadMessage,
    this.userRecord,
  });

  ChatUser1 copyWith(
      {String? channelId,
      int? isBothRead,
      Message? lastMessage,
      int? totalUnreadMessage,
      UserBasicInfo? userRecord}) {
    return ChatUser1(
      channelId: channelId ?? this.channelId,
      isBothRead: isBothRead ?? this.isBothRead,
      lastMessage: lastMessage ?? this.lastMessage,
      totalUnreadMessage: totalUnreadMessage ?? this.totalUnreadMessage,
      userRecord: userRecord ?? this.userRecord,
    );
  }

  factory ChatUser1.fromJson(String str) => ChatUser1.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ChatUser1.fromMap(Map<String, dynamic> json) => ChatUser1(
        channelId: json["channel_id"],
        isBothRead: json["is_both_read"],
        lastMessage: json["last_message"] == null
            ? null
            : Message.fromJson(json["last_message"]),
        totalUnreadMessage: json["total_unread_message"] ?? 0,
        userRecord: json["user_record"] == null
            ? null
            : UserBasicInfo.fromJson(json["user_record"]),
      );

  factory ChatUser1.fromChatUserAndLastMsg(
          ChatUser1 user, Message msg, String unreadCount) =>
      ChatUser1(
        channelId: user.channelId,
        isBothRead: user.isBothRead,
        lastMessage: msg,
        totalUnreadMessage: 0,
        userRecord: user.userRecord,
      );

  factory ChatUser1.fromUserBasicRecord(
    UserBasicInfo user,
  ) =>
      ChatUser1(
        channelId: user.channelId,
        isBothRead: user.canMsgSend == 2  ? 1 : 0,
        lastMessage: null,
        totalUnreadMessage: 0,
        userRecord: user,
      );

  Map<String, dynamic> toMap() => {
        "channel_id": channelId,
        "is_both_read": isBothRead,
        "last_message": lastMessage,
        "total_unread_message": totalUnreadMessage,
        "user_record": userRecord?.toJson(),
      };
}

class ChatUser {
  ChatUser({
    required this.id,
    required this.fname,
    required this.lname,
    required this.profilePic,
    required this.unreadCount,
    required this.channelName,
    this.lastMsg,
    this.fcmToken,
  });

  final String id;
  final String fname;
  final String? lname;
  final String profilePic;
  final String unreadCount;
  final String channelName;
  final Message? lastMsg;
  final String? fcmToken;

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
        id: json["id"].toString(),
        fname: json["fname"] ?? "",
        lname: json["lname"] ?? "",
        profilePic: json["profile_pic"] ?? "",
        unreadCount: json["unread_count"] != null
            ? json["unread_count"].toString()
            : "0",
        channelName: json["channel_id"] ?? "",
        fcmToken: json["fcm_token"] ?? "",
        lastMsg: json['last_message'] != null
            ? Message.fromJson(json['last_message'])
            : null,
      );

  factory ChatUser.fromChatUserAndLastMsg(
          ChatUser user, Message msg, String unreadCount) =>
      ChatUser(
          id: user.id,
          fname: user.fname,
          lname: user.lname,
          profilePic: user.profilePic,
          unreadCount: unreadCount,
          channelName: user.channelName,
          lastMsg: msg,
          fcmToken: user.fcmToken);

  ChatUser copyWith({
    String? id,
    String? fname,
    String? lname,
    String? profilePic,
    String? unreadCount,
    String? channelName,
    Message? lastMsg,
    String? fcmToken,
  }) {
    return ChatUser(
      id: id ?? this.id,
      fname: fname ?? this.fname,
      lname: lname ?? this.lname,
      profilePic: profilePic ?? this.profilePic,
      unreadCount: unreadCount ?? this.unreadCount,
      channelName: channelName ?? this.channelName,
      lastMsg: lastMsg ?? this.lastMsg,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "fname": fname,
        "lname": lname,
        "profile_pic": profilePic,
        "unread_count": unreadCount,
        "channel_id": channelName,
        "last_message": lastMsg?.toJson(),
        "fcm_token": fcmToken,
      };

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}
