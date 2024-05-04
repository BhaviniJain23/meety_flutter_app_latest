// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';

import 'package:meety_dating_app/constants/utils.dart';


class Message {
  Message({
    required this.userId,
    required this.msgId,
    required this.msg,
    required this.file,
    required this.msgReadStatus,
    required this.createdAt,
    required this.replyId,
    this.replyMessage,
    this.isEncrypted = false,
    // required this.isForwarded,
  });

  final String userId;
  final String msgId;
  final String msg;
  String? file;
  final String msgReadStatus;
  final DateTime createdAt;
  Message? replyMessage;
  final String replyId;
  final bool isEncrypted;

  factory Message.fromJson(Map<String, dynamic> jsonObject) => Message(
    userId: jsonObject["userId"],
    msgId: jsonObject["msgId"],
    msg: jsonObject["msg"] ?? "",
    file: jsonObject["file"],
    msgReadStatus: jsonObject["msg_read_status"].toString(),
    createdAt: DateTime.parse(jsonObject["created_at"]).toLocal(),
    replyMessage: jsonObject['reply_message'] != null
        ? Message.fromReplyDoc(
        jsonObject["reply_id"], jsonObject['reply_message'])
        : null,
    replyId: jsonObject["reply_id"].toString(),
    isEncrypted: jsonObject["is_encrypted"] ?? false,
  );

  factory Message.fromDoc(String msgId, Map<dynamic, dynamic> jsonObject) {

    return Message(
      msgId: msgId,
      userId: jsonObject["userId"] ?? "",
      msg: jsonObject["msg"] ?? "",
      file: jsonObject["file"],
      createdAt: jsonObject["created_at"] != null
          ? DateTime.parse(jsonObject["created_at"]).toLocal()
          : DateTime.now().toLocal(),
      msgReadStatus: jsonObject["msg_read_status"] ?? '0',
      replyMessage: jsonObject['reply_message'] != null
          ? Message.fromReplyDoc(
          jsonObject["reply_id"], jsonObject['reply_message'])
          : null,
      replyId: jsonObject["reply_id"] ?? "",
      isEncrypted: jsonObject["is_encrypted"] ?? false,
    );
  }

  factory Message.fromReplyDoc(
      String msgId, Map<dynamic, dynamic> jsonObject) {

    return Message(
      msgId: msgId,
      userId: jsonObject["userId"] ?? "",
      msg: jsonObject["msg"] ?? "",
      file: jsonObject["file"] ,
      createdAt: jsonObject["created_at"] != null
          ? DateTime.parse(jsonObject["created_at"]).toLocal()
          : DateTime.now().toLocal(),
      replyId: jsonObject["reply_id"] ?? "",
      msgReadStatus: jsonObject["msg_read_status"],
      isEncrypted: jsonObject["is_encrypted"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "msgId": msgId,
    "msg": msg,
    "file": file,
    "created_at": createdAt.toUtc().toString(),
    "reply_message": replyMessage?.toJson(),
    "reply_id": replyId,
    "msg_read_status": msgReadStatus,
    "is_encrypted": isEncrypted,
  };

  Map<String, dynamic> toJsonForAdd(String channelId) => {
    "userId": userId,
    "msg": msg.trim().isNotEmpty ? Utils.encryptText(channelId, msg) : msg,
    "file": file,
    "created_at": createdAt.toUtc().toString(),
    "reply_id": replyId,
    "msg_read_status": msgReadStatus,
    "is_encrypted": true,
  };

  Message copyWith({
    String? userId,
    String? msgId,
    String? msg,
    String? file,
    String? readStatus,
    String? msgReadStatus,
    String? isAllDelete,
    Map<String, dynamic>? deleteBy,
    DateTime? createdAt,
    String? isEdited,
    Message? replyMessage,
    String? replyId,
    String? isForwarded,
    Map<String, dynamic>? reactions,
    bool? isEncrypted,
  }) {
    return Message(
      userId: userId ?? this.userId,
      msgId: msgId ?? this.msgId,
      msg: msg ?? this.msg,
      file: file ?? file,
      createdAt: createdAt ?? this.createdAt,
      replyId: replyId ?? this.replyId,
      msgReadStatus: msgReadStatus ?? this.msgReadStatus,
      replyMessage: replyMessage ?? this.replyMessage,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}
