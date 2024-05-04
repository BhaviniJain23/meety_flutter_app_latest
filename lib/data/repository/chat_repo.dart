// ignore_for_file: unused_import

import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/custom_notification.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/notification_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:share_plus/share_plus.dart';

class ChatRepository {
  final DatabaseReference _chatsRef = sl<DatabaseReference>().child('chats');
  final DatabaseReference _usersRef = sl<DatabaseReference>().child('users');

  Future<void> setUserOnlineStatus(
      {String? userId,
      required String isOnline,
      String? isChannelOn,
      bool isOnlineTimeUpdate = false}) async {
    try {
      userId ??=
          sl<SharedPrefsManager>().getUserDataInfo()?.id.toString() ?? '0';

      if (userId != '0') {
        final currentTime = DateTime.now().toUtc().toIso8601String();

        var data = {
          Constants.isOnlineKey: isOnline,
          Constants.lastOnlineAtKey: currentTime,
        };
        if (isChannelOn != null) {
          data.addAll({Constants.channelIdKey: isChannelOn});
        }
        if (isOnlineTimeUpdate) {
          data.addAll({Constants.onlineTime: currentTime});
        }
        await _usersRef.child(userId).update(data);
      }
    } on Exception catch (_) {
      // TODO
    }
  }

  Future<List<dynamic>> getOnlineUsersPaginated(
      int pageNumber, int pageSize) async {
    try {
      final currentTime = DateTime.now().toUtc();
      final oneHourAgo = currentTime.subtract(const Duration(hours: 1));

      final Query query = _usersRef
          .orderByChild(Constants.onlineTime)
          .startAt(oneHourAgo.toIso8601String())
          .endAt(currentTime.toIso8601String())
          .limitToLast(pageSize * pageNumber);

      final DataSnapshot dataSnapshot = await query.get();

      final result = List<Map<String, dynamic>>.empty(growable: true);
      String? id = sl<SharedPrefsManager>().getUserDataInfo()?.id;
      for (var element in dataSnapshot.children) {
        if (id != null && id != element.key) {
          result.add({"user_id": element.key, ...element.value as Map});
        }
      }

      return result;
    } on Exception {
      if (kDebugMode) {
        // Handle exceptions as needed
      }
    }
    return [];
  }

  Stream<Map<dynamic, dynamic>?> isUserOnline(String userId) {
    return _usersRef.child(userId).onValue.map((event) {
      return (event.snapshot.value as Map<dynamic, dynamic>?);
    });
  }

  Future<List<UserBasicInfo>> getOnlineUsers(List<String> userIds) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(api: EndPoints.GET_ONLINE_USERS_API, data: {
        "anotherUser_user_ids": [...userIds].join(",")
      });

      return response.fold((l) {
        return [];
      }, (r) {
        final result = r?.data as Map<String, dynamic>;

        if (result[UiString.successText]) {
          return List.from((result[UiString.dataText] as List<dynamic>)
              .map((e) => UserBasicInfo.fromJson(e)));
        }
        return [];
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return [];
    }
  }

  Stream<Message?> chatLastMessageListener(String channelId, String userId) {
    return _chatsRef
        .child(channelId)
        .orderByChild("userId")
        .equalTo(userId)
        .limitToLast(1)
        .onChildAdded
        .map((event) {
      if (event.snapshot.value != null) {
        final onValueData = event.snapshot.value as Map<dynamic, dynamic>;

        String msgId = event.snapshot.key.toString();
        return Message.fromDoc(msgId, onValueData);
      }
      return null;
    });
  }

  Future<Map<String, dynamic>> getUserChatList(
      int pageNumber, int pageSize) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(
              api: EndPoints.USER_CHAT_LIST_API,
              data: {"records_per_page": pageSize, "page_number": pageNumber});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> getUserMessageRequestList(
      int pageNumber, int pageSize) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(
              api: EndPoints.GET_MY_REQUESTS_LIST_API,
              data: {"records_per_page": pageSize, "page_number": pageNumber});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> getSentMessagesList(
      int pageNumber, int pageSize) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .getCallWithoutHeader(
              api: EndPoints.GET_MY_SENT_LIST_API,
              data: {"records_per_page": pageSize, "page_number": pageNumber});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> checkUserCanSendMsgOrNotAPICall(
      String userId) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.checkUserCanSendMsgOrNotAPI,
              data: {"another_id": userId});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Message?> sendMessageWithPushNotification(
      ChatUser1 chatUser1, String message, int otherReadStatus,
      {UserBasicInfo? loginUser, String? filePath, Message? reply}) async {
    final loggedInUser = loginUser ??
        UserBasicInfo.fromUser(sl<SharedPrefsManager>().getUserDataInfo()!);

    Message msg = Message(
        userId: loggedInUser.id,
        msgId: Utils.generateRandomString(),
        msg: message,
        file: filePath,
        msgReadStatus: Constants.sent,
        createdAt: DateTime.now().toUtc(),
        replyId: reply != null ? reply.msgId : "",
        replyMessage: reply);
    try {
      final messageId =
          _chatsRef.child(chatUser1.channelId ?? '').push().key as String;
      await _chatsRef
          .child(chatUser1.channelId ?? '')
          .child(messageId)
          .set(msg.toJsonForAdd(chatUser1.channelId ?? ''));

      Message chatMessage = Message.fromDoc(messageId, msg.toJson());

      // Send Notification......
      NotificationService.pushNotification(
          titleText: '${loggedInUser.name ?? ''} sent you a message',
          bodyText: chatMessage.msg,
          customNotification: CustomNotification.forChatNotification(
              loggedInUser, chatUser1, otherReadStatus, chatMessage),
          token: chatUser1.userRecord?.fcmToken ?? '');

      return chatMessage;
    } on Exception {
      // // log(e.toString());
    }
    return null;
  }

  Future<List<Message>?> getInitialMessages(
      String loggedId, String channelId, int numberOfRecord) async {
    try {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();

      if (checkInternet) {
        // User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();
        List<Message> messages = [];

        await _chatsRef.child(channelId).keepSynced(true);
        final msgListRef = await _chatsRef
            .child(channelId)
            .orderByChild("created_at")
            .limitToLast(numberOfRecord)
            .get();
        for (var element in msgListRef.children) {
          if (element.key != null && element.value != null) {
            var message = Message.fromDoc(
                element.key.toString(), element.value as Map<dynamic, dynamic>);
            if (message.replyId.isNotEmpty) {
              final replyMsgListRef =
                  await _chatsRef.child(channelId).child(message.replyId).get();
              message = message.copyWith(
                  replyMessage: Message.fromDoc(replyMsgListRef.key.toString(),
                      replyMsgListRef.value as Map<dynamic, dynamic>));
            }
            if (message.msgReadStatus != Constants.msgRead &&
                loggedId != message.userId) {
              await updateMsgReadStatus(channelId, Constants.msgRead,
                  msgId: message.msgId);
            }
            messages.add(message);
          }
        }
        return messages;
      }
    } on Exception {
      if (kDebugMode) {
        // print(e);
      }
    }

    return null;
  }

  Future<List<Message>?> getPreviousMessage(
      String channelId, String msgTime, int numberOfRecord) async {
    try {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();

      if (checkInternet) {
        List<Message> messages = [];
        await _chatsRef.child(channelId).keepSynced(true);
        final msgListRef = await _chatsRef
            .child(channelId)
            .orderByChild("created_at")
            .limitToLast(numberOfRecord)
            .endBefore(msgTime.toString())
            .get();

        for (var element in msgListRef.children) {
          if (element.key != null && element.value != null) {
            var message = Message.fromDoc(
                element.key.toString(), element.value as Map<dynamic, dynamic>);
            if (message.replyId.isNotEmpty) {
              final replyMsgListRef =
                  await _chatsRef.child(channelId).child(message.replyId).get();
              message = message.copyWith(
                  replyMessage: Message.fromDoc(replyMsgListRef.key.toString(),
                      replyMsgListRef.value as Map<dynamic, dynamic>));
            }
            messages.add(message);
          }
        }

        return messages;
      }
    } on Exception {
      if (kDebugMode) {
        // print(e);
      }
    }

    return null;
  }

  Future<void> updateAllMsgReadStatus(
      {required ChatUser1 chatUser,
      required String readStatus,
      required String loggedInId}) async {
    final channelRef = await _chatsRef
        .child(chatUser.channelId ?? '')
        .orderByChild("msg_read_status")
        .startAt("0")
        .endAt("1")
        .get();
    if (channelRef.exists) {
      final updates = <String, dynamic>{};
      for (var element in channelRef.children) {
        Message chat = Message.fromDoc(
            element.key.toString(), element.value as Map<dynamic, dynamic>);
        if (chat.msgReadStatus == Constants.unRead &&
            chat.userId != loggedInId) {
          updates[chat.msgId] = {'msg_read_status': readStatus};
        }
      }

      if (updates.isNotEmpty) {
        await _chatsRef
            .child(chatUser.channelId ?? '')
            .runTransaction((transaction) {
          updates.forEach((key, value) {
            _chatsRef.child(chatUser.channelId ?? '').child(key).update(value);
          });
          return transaction as Transaction;
        }).then((value) {
          if (kDebugMode) {
            // print('Transaction completed.');
          }
        }).catchError((error) {
          if (kDebugMode) {
            // print('Transaction failed: $error');
          }
        });

        //silent Notification
        NotificationService.silentNotification(
          data: {
            "chat_user": chatUser,
          },
          token: chatUser.userRecord?.fcmToken ?? '',
          notificationType: Constants.readAllMsgNotificationType,
          receiverId: chatUser.userRecord?.id ?? '',
        );

        return;
      }
    }
  }

  Future<void> updateSingleMsgReadStatus(
      {required ChatUser1 chatUser,
      required String readStatus,
      required String msgId,
      bool sendNotification = true}) async {
    await _chatsRef
        .child(chatUser.channelId ?? '')
        .child(msgId)
        .update({"msg_read_status": readStatus});

    //silent Notification
    if (sendNotification) {
      NotificationService.silentNotification(
        data: {
          "chat_user": chatUser,
        },
        token: chatUser.userRecord?.fcmToken ?? '',
        notificationType: Constants.readLastMessageNotificationType,
        receiverId: chatUser.userRecord?.id ?? '',
      );
    }
  }

  Future<Map<String, dynamic>> uploadChatImage(
      {required Map<String, dynamic> data, required String images}) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithDioHeaderMultipart(
              EndPoints.UPLOAD_CHAT_IMAGES_API, data, [images]);
      return response.fold((l) {
        if (kDebugMode) {
          // print("on verifyYourProfile response: $l");
        }
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on verifyYourProfile catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<List<Message>> getMessages(
      String channelId, int numberOfRecord) async {
    try {
      User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();
      List<Message> messages = [];

      await _chatsRef.child(channelId).keepSynced(true);
      final msgListRef = await _chatsRef
          .child(channelId)
          .orderByChild("created_at")
          .limitToLast(numberOfRecord)
          .get();
      for (var element in msgListRef.children) {
        if (element.key != null && element.value != null) {
          var message = Message.fromDoc(
              element.key.toString(), element.value as Map<dynamic, dynamic>);
          if (message.replyId.isNotEmpty) {
            final replyMsgListRef =
                await _chatsRef.child(channelId).child(message.replyId).get();
            message = message.copyWith(
                replyMessage: Message.fromDoc(replyMsgListRef.key.toString(),
                    replyMsgListRef.value as Map<dynamic, dynamic>));
          }
          log(msgListRef.toString());
          log(message.toString());

          if (message.msgReadStatus != Constants.msgRead &&
              loginUser?.id.toString() != message.userId) {
            await updateMsgReadStatus(channelId, Constants.msgRead,
                msgId: message.msgId);
          }
          messages.add(message);
        }
      }
      return messages;
    } on Exception {
      if (kDebugMode) {
        // print(e);
      }
    }

    return [];
  }

  Future<List<Message>> getPreviousMessages(
      String channelId, String msgTime, int numberOfRecord) async {
    try {
      List<Message> messages = [];
      await _chatsRef.child(channelId).keepSynced(true);
      final msgListRef = await _chatsRef
          .child(channelId)
          .orderByChild("created_at")
          .limitToLast(numberOfRecord)
          .endBefore(msgTime.toString())
          .get();

      for (var element in msgListRef.children) {
        if (element.key != null && element.value != null) {
          var message = Message.fromDoc(
              element.key.toString(), element.value as Map<dynamic, dynamic>);
          if (message.replyId.isNotEmpty) {
            final replyMsgListRef =
                await _chatsRef.child(channelId).child(message.replyId).get();
            message = message.copyWith(
                replyMessage: Message.fromDoc(replyMsgListRef.key.toString(),
                    replyMsgListRef.value as Map<dynamic, dynamic>));
          }
          messages.add(message);
        }
      }

      return messages;
    } on Exception {
      // // log(e.toString());
    }

    return [];
  }

  Future<String> sendMessage(String channelId, Message msg) async {
    try {
      final messageId = _chatsRef.child(channelId).push().key as String;
      await _chatsRef.child(channelId).child(messageId).set(msg.toJsonForAdd(channelId));

      return messageId;
    } on Exception {
      // // log(e.toString());
    }
    return "";
  }

  Future<void> updateMsgReadStatus(String channelId, String readStatus,
      {String? msgId, String? token}) async {
    final loginUserId =
        sl<SharedPrefsManager>().getUserDataInfo()?.id.toString() ?? '0';

    if (msgId != null) {
      await _chatsRef
          .child(channelId)
          .child(msgId)
          .update({"msg_read_status": readStatus});
    } else {
      final channelRef = await _chatsRef
          .child(channelId)
          .orderByChild("msg_read_status")
          .startAt("0")
          .endAt("1")
          .get();
      if (channelRef.exists) {
        final updates = <String, dynamic>{};
        for (var element in channelRef.children) {
          Message chat = Message.fromDoc(
              element.key.toString(), element.value as Map<dynamic, dynamic>);
          if (chat.msgReadStatus == Constants.unRead &&
              chat.userId != loginUserId) {
            updates[chat.msgId] = {'msg_read_status': readStatus};
          }
        }

        if (updates.isNotEmpty) {
          await _chatsRef.child(channelId).runTransaction((transaction) {
            updates.forEach((key, value) {
              _chatsRef.child(channelId).child(key).update(value);
            });
            return transaction as Transaction;
          }).then((value) {
            if (kDebugMode) {
              // print('Transaction completed.');
            }
          }).catchError((error) {
            if (kDebugMode) {
              // print('Transaction failed: $error');
            }
          });

          //silent Notification
          NotificationService.pushNotification(data: {
            'notificationType': Constants.readAllMsgNotificationType,
            'channelId': channelId
          }, token: token ?? '');

          return;
        }
      }
    }
  }

  Future<Map<String, dynamic>> getChatUserFromId(
      String loginUserId, String userId) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.CHECK_USER_NAME_CHANNEL_API,
              data: {"user1": userId, "user2": loginUserId});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> addChannelId(
      String loginUserId, String userId) async {
    try {
      Either<String, Response?> response = await sl<ApiHelper>()
          .postCallWithoutHeader(
              api: EndPoints.USER_NAME_CHANNEL_API,
              data: {"user1": userId, "user2": loginUserId});
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      if (kDebugMode) {
        // print("on AuthRepository userSignedUp catch: $e");
      }
      return UiString.fixFailResponse();
    }
  }
}
