class PushNotification {
  String body;
  String title;
  String deviceToken;
  String receiverId;
  String senderPhoto;
  Map<String, dynamic> data;
  String notificationType;

  PushNotification({
    required this.body,
    required this.title,
    required this.deviceToken,
    this.receiverId = '',
    this.senderPhoto = '',
    required this.notificationType,
    required this.data,
  });

  Map<String, dynamic> toMap() {

    if(title.isNotEmpty && body.isNotEmpty) {
      return {
        'notification': <String, dynamic>{
          'body': body,
          'title': title,
          'image': senderPhoto
        },
        'priority': 'high',
        'data': data
          ..addAll(<String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'receiver_id': receiverId,
            'notificationType': notificationType.toString(),
            'image': senderPhoto
          }),
        "to": deviceToken,
      };
    }
    return {
      'priority': 'high',
      'data': data
        ..addAll(<String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'receiverId': receiverId,
          'image': senderPhoto
        }),
      "to": deviceToken,
    };
  }

  PushNotification copyWith(String? fcmToken) {
    return PushNotification(
        body: body,
        title: title,
        deviceToken: fcmToken ?? deviceToken,
        notificationType: notificationType,
        data: data);
  }
}
