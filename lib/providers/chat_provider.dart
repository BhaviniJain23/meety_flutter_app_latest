import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/custom_notification.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/notification_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class ChatProviders with ChangeNotifier {
  final ChatRepository _chatRepository;

  StreamSubscription<Map<dynamic, dynamic>?>? _dataStream;
  StreamSubscription<Message?>? _lastMessageStream;

  UserChatListProvider? userChatListProvider;
  Timer? timer;

  ChatUser? _chatUser;

  bool _showGetLoader = true;

  List<Message> _messages = [];

  Map<String, dynamic> _isOnline = {};

  Message? _replyMessage;

  bool _isLoadingMore = true;

  List<Message> get messages => _messages;

  Message? get replyMessage => _replyMessage;

  Map<String, dynamic> get isOnline => _isOnline;

  bool get isLoadingMore => _isLoadingMore;

  bool get showGetLoader => _showGetLoader;

  ChatProviders({required UserChatListProvider userChatListPro})
      : _chatRepository = sl<ChatRepository>(),
        userChatListProvider = userChatListPro;

  final int _limit = 50;

  Future<void> init(String userId, String channelId) async {
    try {
      _chatUser = userChatListProvider?.chatUser
          .singleWhere((element) => element.id == userId);
    } on Exception {
      Future.delayed(const Duration(seconds: 2));
    }

    if(channelId.isNotEmpty){
      //silent notification
      _chatRepository.updateMsgReadStatus(channelId, Constants.msgRead,
          token: _chatUser?.fcmToken);
    }
    _dataStream = _chatRepository.isUserOnline(userId).listen((online) {
      if(online != null){
        final jsonData = jsonDecode(jsonEncode(online));
        // final lastOnlineAtStr = jsonData['lastOnlineAt'] as String?;
        _isOnline = jsonData;
        notifyListeners();
        if(timer != null){
          timer?.cancel();
        }
        timer = Timer(const Duration(seconds: 90), () async {
          _isOnline[Constants.isOnlineKey]  = Constants.offlineState;
          _isOnline = _isOnline;
          notifyListeners();
        });
      }

    });
      await getInitialMessage(channelId);

    _lastMessageStream = _chatRepository
        .chatLastMessageListener(channelId, _chatUser!.id)
        .listen((Message? chatMessage) async {
      chatListener(channelId, chatMessage);
    });
  }

  void readAllMessage() {
    final temp = List.from(
        _messages.map((e) => e.copyWith(msgReadStatus: Constants.msgRead)));
    _messages = List.from(temp);
    notifyListeners();
  }

  void setReplyMessage(Message? replyMsg) {
    _replyMessage = replyMsg;
    notifyListeners();
  }

  Future<void> sendMessage(String channelId, Message message) async {
    List<Message> temp = List.from(_messages);
    final replyMessage = _replyMessage;
    if (message.msg.isNotEmpty ||
        (message.file != null && message.file!.isNotEmpty)) {
      try {
        bool checkInternet =
            await sl<InternetConnectionService>().hasInternetConnection();

        if (checkInternet) {
          temp.add(message);
          _messages = List.from(temp);

          if (_replyMessage != null) {
            _replyMessage = null;
          }
          notifyListeners();
          String key = await _chatRepository.sendMessage(channelId, message);
          Message chatMessage = Message.fromDoc(key, message.toJson());
          final loginUser = sl<SharedPrefsManager>().getUserDataInfo();

          NotificationService.pushNotification(
              titleText:
                  '${_chatUser?.fname} ${_chatUser?.lname ?? ''} sent you a message',
              bodyText: chatMessage.msg,
              customNotification: CustomNotification(
                  notificationType: Constants.chatNotificationType,
                  receiverId: _chatUser?.id,
                  senderName: '${loginUser?.fname} ${loginUser?.lname ?? ''}',
                  receiverName: '${_chatUser?.fname} ${_chatUser?.lname ?? ''}',
                  senderId: loginUser?.id.toString() ?? '',
                  userProfileImage: loginUser?.images?[0] ?? '',
                  data: {
                    "chat_user": ChatUser(
                        id: loginUser?.id.toString() ?? '',
                        fname: loginUser?.fname ?? '',
                        lname: loginUser?.lname,
                        profilePic: loginUser?.images?[0].toString() ?? '',
                        unreadCount: '1',
                        lastMsg: chatMessage,
                        fcmToken: loginUser?.fcmToken,
                        channelName: _chatUser?.channelName ?? ''),
                    "msg": chatMessage.toJson()
                  }),
              token: _chatUser?.fcmToken ?? '');

          int index =
              temp.indexWhere((element) => element.msgId == message.msgId);
          temp[index] = chatMessage;
          _messages = List.from(temp);
          notifyListeners();
          //Update outer list
          userChatListProvider?.updateUserListFromMessage(
              channelId: channelId, message: chatMessage);
        }
      } on Exception catch (e) {
        temp.removeWhere((element) => element.msgId == message.msgId);
        _messages = List.from(temp);
        _replyMessage = replyMessage;
        notifyListeners();
      } finally {
        notifyListeners();
      }
    }
  }

  Future<void> getInitialMessage(String channelId) async {
    try {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (checkInternet && channelId.isNotEmpty) {
        _showGetLoader = true;
        notifyListeners();
        List<Message> temp =
            await _chatRepository.getMessages(channelId, _limit);
        _messages = List.from(temp);

      }
    } on Exception catch (e) {
    } finally {
      _showGetLoader = false;
      notifyListeners();
    }
  }

  Future<void> getPreviousMessages(String channelId) async {
    bool checkInternet =
        await sl<InternetConnectionService>().hasInternetConnection();
    if (checkInternet && _messages.isNotEmpty) {
      List<Message> temp = await _chatRepository.getPreviousMessages(
          channelId, _messages[0].createdAt.toUtc().toString(), _limit);
      if (temp.isEmpty) {
        _isLoadingMore = false;
      } else {
        final List<Message> allMessages = List.from(_messages)
          ..insertAll(0, temp);
        _messages = List.from(allMessages);
      }
      notifyListeners();
    }
  }

  Future<void> chatListener(String channelId, Message? chatMessage) async {
    if (chatMessage != null) {
      User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();
      final temp = List.from(_messages);
      int index =
          temp.indexWhere((element) => element.msgId == chatMessage.msgId);

      if (chatMessage.msgReadStatus != Constants.msgRead &&
          isOnline.containsKey(Constants.isOnlineKey) &&
          isOnline[Constants.isOnlineKey] == Constants.onlineState &&
          isOnline.containsKey(Constants.channelIdKey) &&
          isOnline[Constants.channelIdKey] == channelId) {

        //silent notification
        NotificationService.pushNotification(data: {
          Constants.notificationTypeKey: Constants.readAllMsgNotificationType,
          Constants.channelIdKey: channelId
        }, token: _chatUser?.fcmToken ?? '');
      }
      if (index == -1) {
        if (chatMessage.replyId.toString().isNotEmpty) {
          int index = _messages
              .indexWhere((element) => element.msgId == chatMessage.replyId);
          Message? replyMsgListRef;
          if (index != -1) {
            replyMsgListRef = _messages[index];
          }
          else {
            final msgRef = await sl<DatabaseReference>()
                .child('chats')
                .child(channelId)
                .child(chatMessage.replyId)
                .get();
            replyMsgListRef = Message.fromDoc(
                msgRef.key.toString(), msgRef.value as Map<dynamic, dynamic>);
          }
          temp.add(chatMessage.copyWith(replyMessage: replyMsgListRef));
        }
        else {
          temp.add(chatMessage);
        }
        if (chatMessage.msgReadStatus != Constants.msgRead &&
            loginUser?.id.toString() != chatMessage.userId) {
          await _chatRepository.updateMsgReadStatus(
              channelId, Constants.msgRead,
              msgId: chatMessage.msgId);
        }
      }
      _messages = List.from(temp);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _dataStream?.cancel();
    sl<BackgroundTimer>().stopBackgroundTimer(true);
    _lastMessageStream?.cancel();
    super.dispose();
  }
}
