

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) =>
    List<NotificationModel>.from(
        json.decode(str).map((x) => NotificationModel.fromJson(x)));

String notificationModelToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  int notificationId;
  int userFrom;
  int userTo;
  int notificationType;
  String message;
  int isRead;
  DateTime createdAt;
  DateTime updateAt;
  int isDeleted;

  NotificationModel({
    required this.notificationId,
    required this.userFrom,
    required this.userTo,
    required this.notificationType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    required this.updateAt,
    required this.isDeleted,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationId: json["notification_id"],
        userFrom: json["user_from"],
        userTo: json["user_to"],
        notificationType: json["notification_type"],
        message: json["message"],
        isRead: json["is_read"],
        createdAt: DateTime.parse(json["created_at"]),
        updateAt: DateTime.parse(json["update_at"]),
        isDeleted: json["is_deleted"],
      );

  Map<String, dynamic> toJson() => {
        "notification_id": notificationId,
        "user_from": userFrom,
        "user_to": userTo,
        "notification_type": notificationType,
        "message": message,
        "is_read": isRead,
        "created_at": createdAt.toIso8601String(),
        "update_at": updateAt.toIso8601String(),
        "is_deleted": isDeleted,
      };
}
