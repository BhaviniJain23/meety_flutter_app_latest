// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:action_broadcast/action_broadcast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/chat_message.dart' as chatMessage;
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/custom_notification.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/persistent_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/one_to_one_chat_screen.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/profile/edit_profile.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:provider/provider.dart';

late FlutterLocalNotificationsPlugin _normalLocalNotifications;
late AndroidNotificationChannel _normalChannel;

bool isFlutterLocalNotificationsInitialized = false;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're goingto use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // if (kDebugMode) {
  if (message.data.containsKey(Constants.notificationTypeKey)) {
    sendBroadcast(Constants.homeScreenNotificationReceiver, data: message);
  }
}

Future<void> notificationPermissions(BuildContext context) async {
  await _requestPermission();
  await _loadFCM(context);
  await _listenFCM(context);
}

Future<void> _requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );
}

Future<void> _listenFCM(BuildContext context) async {
  FirebaseMessaging.instance.getInitialMessage().then((value) async {
    if (value != null) {
      await handleMessage(context, value);
    }
  });

  FirebaseMessaging.onMessage.listen((m) {

    showLocalNotification(context, m);
  });

  /// When app is onBackground
  FirebaseMessaging.onMessageOpenedApp.listen((m) async {
    await handleMessage(context, m);
  });
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }

  _normalChannel = AndroidNotificationChannel(
    DateTime.now().microsecondsSinceEpoch.toString(),
    'high_importance_channel',
    importance: Importance.max,
    enableVibration: true,
    playSound: true,
    showBadge: true,
    sound: const RawResourceAndroidNotificationSound('notification'),
  );

  _normalLocalNotifications = FlutterLocalNotificationsPlugin();

  await _normalLocalNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_normalChannel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

// ignore: duplicate_ignore
Future<void> _loadFCM(BuildContext context) async {
  await setupFlutterNotifications();
  const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/launcher_icon"),
      iOS: DarwinInitializationSettings());

  /// when app opened and select the message
  _normalLocalNotifications.initialize(initializationSettings,
      onDidReceiveNotificationResponse: (p) {
    _onSelectNotification(
      context,
      true,
      p.payload,
    );
  });

  // /// When app is close
  await _detailsWhenAppClose(context);
}

Future<void> _detailsWhenAppClose(BuildContext context) async {
  final normalDetails =
      await _normalLocalNotifications.getNotificationAppLaunchDetails();

  if (normalDetails != null && normalDetails.didNotificationLaunchApp) {
    String? payload = normalDetails.notificationResponse?.payload;
    if (payload != null) {
      Future.delayed(Duration.zero, () async {
        await _onSelectNotification(context, false, payload);
      });
    }
  }
}

Future<void> handleMessage(BuildContext context, RemoteMessage message) async {
  await _pushToPage(context,
      customNotification: CustomNotification.fromJson(message.data),
      message: message.notification?.body?.toString() ?? '',
      isAppOpen: false);
}

Future<void> showNotificationBanner(
    RemoteMessage message, bool showNotification) async {
  RemoteNotification? notification = message.notification;

  if (notification != null && !kIsWeb) {
    BigPictureStyleInformation? bigPictureStyleInformation;

    FilePathAndroidBitmap? iconFilePathAndroidBitmap;
    DarwinNotificationAttachment? iosNotificationAttachment;

    try {
      if (message.data["sender_image"] != null &&
          message.data["sender_image"].toString().isNotEmpty) {
        final String largeIconPath = (await DefaultCacheManager()
                .getSingleFile(message.data["sender_image"]!))
            .path;

        // filePathAndroidBitmap = FilePathAndroidBitmap(largeIconPath);
        iconFilePathAndroidBitmap = FilePathAndroidBitmap(largeIconPath);
        bigPictureStyleInformation = BigPictureStyleInformation(
            FilePathAndroidBitmap(largeIconPath),
            largeIcon: FilePathAndroidBitmap(largeIconPath));
        iosNotificationAttachment = DarwinNotificationAttachment(largeIconPath);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        notification.hashCode.toString(), notification.title ?? '',
        channelDescription: notification.body,
        importance: Importance.max,
        priority: Priority.high,
        //playSound: true,
        enableVibration: true,
        largeIcon: iconFilePathAndroidBitmap,
        styleInformation: bigPictureStyleInformation);

    var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        //presentSound: true,
        attachments: iosNotificationAttachment != null
            ? [iosNotificationAttachment]
            : null);

    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    if (showNotification) {
      _normalLocalNotifications.show(notification.hashCode, notification.title,
          notification.body, platformChannelSpecifics,
          payload: jsonEncode(message.data));
    }
  }
}

Future<void> showLocalNotification(
    BuildContext context, RemoteMessage message) async {
  if (kDebugMode) {
    print("handling showLocalNotification ${message.data}");
  }
  final RemoteNotification? notification = message.notification;

  if (message.data.containsKey("notification_type")) {
    final dataResponse = message.data;

    switch (dataResponse['notification_type'].toString()) {
      case Constants.likeNotificationType:
        showNotificationBanner(message, true);
        try {
          final likeListProvider = context.read<LikeListProvider>();
          if (dataResponse.containsKey("data")) {
            dynamic userInfo;
            if (dataResponse['data'] is String) {
              userInfo =
                  UserBasicInfo.fromJson(jsonDecode(dataResponse['data']));
            } else {
              userInfo =
                  UserBasicInfo.fromJson(jsonDecode(dataResponse['data']));
            }
            if (userInfo != null) {
              int index = likeListProvider.likeList
                  .indexWhere((element) => element.id == userInfo.id);

              if (index != -1) {
                likeListProvider.likeList = likeListProvider.likeList
                  ..removeAt(index)
                  ..insert(0, userInfo);
              } else {
                likeListProvider.likeList = likeListProvider.likeList
                  ..insert(0, userInfo);
                likeListProvider.totalLikeCounts += 1;
              }
              return;
            }
          }
          likeListProvider.fetchTotalCount();
          likeListProvider.fetchLikes();
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.visitNotificationType:
        showNotificationBanner(message, true);
        try {
          final likeListProvider = context.read<LikeListProvider>();
          if (dataResponse.containsKey("data")) {
            dynamic userInfo;
            if (dataResponse['data'] is String) {
              userInfo =
                  UserBasicInfo.fromJson(jsonDecode(dataResponse['data']));
            } else {
              userInfo =
                  UserBasicInfo.fromJson(jsonDecode(dataResponse['data']));
            }
            if (userInfo != null) {

              int index = likeListProvider.visitorList
                  .indexWhere((element) => element.id == userInfo.id);

              if (index != -1) {
                likeListProvider.visitorList = likeListProvider.visitorList
                  ..removeAt(index);
              }
              likeListProvider.visitorList = likeListProvider.visitorList
                ..insert(0, userInfo);
              return;
            }
          }
          likeListProvider.fetchVisitors();
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.matchNotificationType:
        // showNotificationBanner(message, true);
        try {
          final likeListProvider = context.read<LikeListProvider>();
          likeListProvider.fetchMatches();

          if (dataResponse.containsKey("data")) {
            UserBasicInfo userInfo;
            if (dataResponse['data'] is String) {
              userInfo =
                  UserBasicInfo.fromJson(jsonDecode(dataResponse['data']));
            } else {
              userInfo =
                  UserBasicInfo.fromJson(jsonDecode(dataResponse['data']));
            }

            Utils.showMatchPopUp(context, likeListProvider, userInfo,
                message.notification?.body ?? '');
            return;
                    }
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.chatNotificationType:
        try {
          final userChatListProvider = context.read<UserChatListProvider>();

          if (dataResponse.containsKey("data")) {
            dynamic chatResponse;
            if (dataResponse["data"] is String) {

              try {
                chatResponse = jsonDecode(dataResponse['data']);
              } catch (e) {
                // Handle the error, if the data is not in proper JSON format
              }
            } else {
              chatResponse = dataResponse['data'];
            }

            if (chatResponse is Map &&
                (chatResponse).containsKey("chat_user") &&
                chatResponse.containsKey("msg")) {
              var chatUserResponse = chatResponse['chat_user'];
              var msgResponse = chatResponse['msg'];
              ChatUser1? chatUser;

              if (chatUserResponse is String) {
                chatUser = ChatUser1.fromJson(chatUserResponse);
              } else {
                chatUser = ChatUser1.fromMap(chatUserResponse);
              }

              if (chatUser.channelId != userChatListProvider.visitChannelId) {
                showNotificationBanner(message, true);
              }


              chatUser = chatUser.copyWith(
                  lastMessage: chatMessage.Message.fromJson(
                      msgResponse is String
                          ? jsonDecode(msgResponse)
                          : msgResponse),
                  totalUnreadMessage: (chatUser.totalUnreadMessage ?? 0) + 1);

              userChatListProvider.updateChatUserLastMessage(
                  chatUser1: chatUser);
            } else {

              userChatListProvider.fetchChats();
            }
          } else {

            userChatListProvider.fetchChats();
          }
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;

      default:
        showNotificationBanner(message, true);
    }
  }
  return;
}

Future<void> _onSelectNotification(
    BuildContext context, bool isAppOpen, String? payload) async {
  if (payload != null) {
    log("IsAppOpen:$isAppOpen");
    log("payload:$payload");
    await _pushToPage(context,
        customNotification: CustomNotification.fromJson(jsonDecode(payload)),
        message: '',
        isAppOpen: isAppOpen);
  }
}

Future<void> _pushToPage(
  BuildContext context, {
  required CustomNotification customNotification,
  required String message,
  bool isAppOpen = false,
}) async {
  Widget page;

  if (sl<NavigationService>().canPop()) {
    sl<NavigationService>().popUntil((route) => route.isFirst);
  }
  if (kDebugMode) {
    print("handling _pushToPage ${customNotification.toJson()}");
  }
  if (customNotification.notificationType.isNotEmpty) {
    switch (customNotification.notificationType) {
      case Constants.likeNotificationType:
        try {
          if (!isAppOpen) {
            final likeListProvider = context.read<LikeListProvider>();
            likeListProvider.fetchTotalCount();
            likeListProvider.fetchLikes();
          }

          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.likeTab);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.visitNotificationType:
        try {
          if (!isAppOpen) {
            final likeListProvider = context.read<LikeListProvider>();
            likeListProvider.fetchVisitors();
          }
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.likeTab);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.matchNotificationType:
        try {
          final likeListProvider = context.read<LikeListProvider>();
          if (customNotification.data.containsKey("data")) {
            dynamic userInfo;
            if (customNotification.data['data'] is String) {
              userInfo = UserBasicInfo.fromJson(
                  jsonDecode(customNotification.data['data']));
            } else {
              userInfo = UserBasicInfo.fromJson(
                  jsonDecode(customNotification.data['data']));
            }

            if (userInfo != null) {
              Utils.showMatchPopUp(
                  context, likeListProvider, userInfo, message);
              return;
            }
          }
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.chatTab);
          likeListProvider.fetchMatches();
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.chatNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.chatTab);
          final userChatListProvider = context.read<UserChatListProvider>();
          final loggedInUser =
          UserBasicInfo.fromUser(sl<SharedPrefsManager>().getUserDataInfo()!);
          if (customNotification.data.containsKey("chat_user") &&
              customNotification.data.containsKey("msg")) {
            var chatUserResponse = customNotification.data['chat_user'];
            var msgResponse = customNotification.data['msg'];
            ChatUser1? chatUser;
            if (chatUserResponse is String) {
              chatUser = ChatUser1.fromJson(chatUserResponse);
            } else {
              chatUser = ChatUser1.fromMap(chatUserResponse);
            }

            chatUser = chatUser.copyWith(
                lastMessage: chatMessage.Message.fromJson(msgResponse is String
                    ? jsonDecode(msgResponse)
                    : msgResponse),
                totalUnreadMessage: (chatUser.totalUnreadMessage ?? 0) + 1);

            userChatListProvider.updateChatUserLastMessage(chatUser1: chatUser);

            await sl<NavigationService>().navigateTo(
              RoutePaths.oneToOneScreen,
              nextScreen: OneToOneChatScreen.create(context, chatUser, loggedInUser),
            );
          } else {
            userChatListProvider.fetchChats();
          }
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }

        break;
      case Constants.profileNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.profileTab);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.premiumPlansNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.profileTab);
          sl<NavigationService>().navigateTo(
            RoutePaths.subscriptionScreen,
          );
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.editProfileNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.profileTab);
          sl<NavigationService>().navigateTo(
            RoutePaths.editProfile,
            nextScreen: const EditProfileScreen(),
          );
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.signInPageNotificationType:
        try {
          sl<NavigationService>()
              .navigateTo(RoutePaths.login, withPushAndRemoveUntil: true);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.profileVerificationNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.profileTab);
          Utils.showVerifiedNowDialog(context);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.sevenDaysAddonPlansNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.profileTab);
          AlertService.moreVisitorPopUpService(context);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
      case Constants.messageAddonPlansNotificationType:
        try {
          sl<PersistentTabControllerService>()
              .controller
              .jumpToTab(Constants.profileTab);
          AlertService.moreMessagePopUpService(context);
        } catch (e) {
          if (kDebugMode) {
            log(e.toString());
          }
        }
        break;
    }
  }
  return;
}

void scheduleProfileCompletionNotification() async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'profile_completion', // channelId
    'Profile Completion Reminders', // channelName
    channelDescription: 'Reminders to complete your profile',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await _normalLocalNotifications.periodicallyShow(
    0,
    'Complete Your Profile',
    ConstantList.messages[math.Random().nextInt(ConstantList.messages.length)],
    RepeatInterval.daily,
    platformChannelSpecifics,
  );

  // Schedule the notification in 24 hours from now
  // await _normalLocalNotifications.zonedSchedule(
  //   0, // Notification ID
  //   'Complete Your Profile',
  //   'Please complete your profile to enjoy all the features of ${UiString.appTitle}.',
  //   tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)),
  //   platformChannelSpecifics,
  //   // ignore: deprecated_member_use
  //   androidAllowWhileIdle: true,
  //   uiLocalNotificationDateInterpretation:
  //   UILocalNotificationDateInterpretation.absoluteTime,
  // );
}

void cancelProfileCompletionNotification() async {
  await _normalLocalNotifications.cancel(0); // Cancel notification with ID 0
}
