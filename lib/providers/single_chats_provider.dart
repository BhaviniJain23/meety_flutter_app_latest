import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

import '../constants/constants.dart';
import '../data/repository/user_repo.dart';

class SingleChatProvider with ChangeNotifier {
  final int _limit = 50;
  final ChatRepository _chatRepository;

  SingleChatProvider({required UserChatListProvider userChatListPro})
      : _chatRepository = sl<ChatRepository>(),
        userChatListProvider = userChatListPro;

  UserChatListProvider? userChatListProvider;
  late final ChatUser1 chatUser;
  Timer? timer;
  final TextEditingController chatController = TextEditingController();

  StreamSubscription<Map<dynamic, dynamic>?>? _dataStream;
  StreamSubscription<Message?>? _lastMessageStream;

  bool _isOnline = false;

  bool get isOnline => _isOnline;
  String _message = '';

  String get message => _message;

  Message? _replyMessage;

  Message? get replyMessage => _replyMessage;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  bool _showGetLoader = false;

  bool get showGetLoader => _showGetLoader;

  bool _isLoadingMore = true;

  bool get isLoadingMore => _isLoadingMore;

  setReplyMessage(Message? replyMsg) {
    _replyMessage = replyMsg;
    notifyListeners();
  }

  Future<void> init(String loggedInId, ChatUser1 chatUser) async {
    this.chatUser = chatUser;

    if (chatUser.channelId != null) {
      //Update Unread count
      _chatRepository.updateMsgReadStatus(
          chatUser.channelId.toString(), Constants.msgRead,
          token: chatUser.userRecord?.fcmToken);

      //add listener to get Online...
      _dataStream = _chatRepository
          .isUserOnline(chatUser.userRecord!.id.toString())
          .listen((event) {
        final jsonData = jsonDecode(jsonEncode(event));

        _isOnline = isUserHaveOnlineStatus(jsonData);
        notifyListeners();

        if (timer != null) {
          timer?.cancel();
        }
        timer = Timer(const Duration(seconds: 90), () async {
          _isOnline = false;
          notifyListeners();
        });
      });

      await getInitialMessage(loggedInId, chatUser.channelId!);
    }

    _lastMessageStream = _chatRepository
        .chatLastMessageListener(
            chatUser.channelId ?? '', chatUser.userRecord?.id ?? '')
        .listen((Message? chatMessage) async {
      chatListener(loggedInId, chatMessage);
    });
  }

  Future<void> sendMessage(BuildContext context, UserBasicInfo loggedInUser,
      {String? file}) async {
    final replyMessage = _replyMessage;
    final msgId = Utils.generateRandomString();
    try {
      if (chatController.text.isNotEmpty || file != null) {
        try {
          List<Message> temp = List.from(_messages);

          Message? msg = Message(
              userId: loggedInUser.id,
              msgId: msgId,
              msg: chatController.text,
              file: file ?? '',
              msgReadStatus: Constants.unsent,
              createdAt: DateTime.now().toUtc(),
              replyId: replyMessage != null ? replyMessage.msgId : "",
              replyMessage: replyMessage);

          _messages = List.from(temp..add(msg));

          notifyListeners();

          if (_replyMessage != null) {
            _replyMessage = null;
          }
          chatController.clear();

          if (chatUser.isBothRead == 0) {
            Map<String, dynamic> apiResponse = await sl<ChatRepository>()
                .checkUserCanSendMsgOrNotAPICall(
                    chatUser.userRecord?.id.toString() ?? '');

            if (apiResponse[UiString.successText] &&
                apiResponse[UiString.dataText] != null) {
              msg = await sl<ChatRepository>().sendMessageWithPushNotification(
                  chatUser, msg.msg, 1,
                  loginUser: loggedInUser, reply: replyMessage);
            }
          } else {
            msg = await sl<ChatRepository>().sendMessageWithPushNotification(
                chatUser, msg.msg, 1,
                loginUser: loggedInUser, reply: replyMessage,filePath: file);
          }

          if (msg != null) {
            int index =
                _messages.indexWhere((element) => element.msgId == msgId);
            if (index != -1) {
              _messages.removeWhere((element) => element.msgId == msgId);
              _messages.add(msg);
              notifyListeners();
            }

            final tempChatUser = chatUser.copyWith(lastMessage: msg);

            userChatListProvider?.updateChatUserLastMessage(
                chatUser1: tempChatUser.copyWith(isBothRead: 1),
                unreadCount: 0);
          }
        } finally {
          // notifyListeners();
        }
      } else {
        context.showSnackBar("The message can't be empty.",
            backgroundColor: Colors.red);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
      // ignore: use_build_context_synchronously
      context.showSnackBar("Your messages not sent",
          backgroundColor: Colors.red);
      _messages.removeWhere((element) => element.msgId == msgId);

      // _replyMessage = replyMessage;
      notifyListeners();
    }
  }

  Future<void> getInitialMessage(String loggedId, String channelId) async {
    try {
      _showGetLoader = true;
      notifyListeners();
      List<Message>? temp =
          await _chatRepository.getInitialMessages(loggedId, channelId, _limit);
      if (temp != null) {
        _messages = List.from(temp);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {
      _showGetLoader = false;
      notifyListeners();
    }
  }

  Future<void> getPreviousMessages() async {
    List<Message>? temp = await _chatRepository.getPreviousMessage(
        chatUser.channelId ?? '',
        _messages[0].createdAt.toUtc().toString(),
        _limit);
    if (temp != null) {
      if (temp.isEmpty) {
        _isLoadingMore = false;
      } else {
        final List<Message> allMessages = List.from(_messages)
          ..insertAll(0, temp);
        _messages = List.from(allMessages);
      }
    }
    notifyListeners();
  }

  Future<void> chatListener(String loggedInId, Message? chatMessage) async {
    if (chatMessage != null) {
      final temp = List.from(_messages);
      int index =
          temp.indexWhere((element) => element.msgId == chatMessage.msgId);

      if (index == -1) {
        if (chatMessage.replyId.toString().isNotEmpty) {
          int index = _messages
              .indexWhere((element) => element.msgId == chatMessage.replyId);

          Message? replyMsgListRef;
          if (index != -1) {
            replyMsgListRef = _messages[index];
          } else {
            final msgRef = await sl<DatabaseReference>()
                .child('chats')
                .child(chatUser.channelId ?? '')
                .child(chatMessage.replyId)
                .get();
            replyMsgListRef = Message.fromDoc(
                msgRef.key.toString(), msgRef.value as Map<dynamic, dynamic>);
          }

          temp.add(chatMessage.copyWith(replyMessage: replyMsgListRef));
        } else {
          temp.add(chatMessage);
        }

        if (chatMessage.msgReadStatus != Constants.msgRead &&
            loggedInId != chatMessage.userId) {
          final tempChatUser = chatUser.copyWith(lastMessage: chatMessage);

          userChatListProvider?.updateChatUserLastMessage(
              chatUser1: tempChatUser, unreadCount: 0);

          await _chatRepository.updateSingleMsgReadStatus(
              chatUser: tempChatUser,
              readStatus: Constants.msgRead,
              msgId: chatMessage.msgId,
              sendNotification:
                  chatMessage.msgReadStatus != Constants.msgRead && isOnline);
        }
      }
      _messages = List.from(temp);
      notifyListeners();
    }
  }

  bool isUserHaveOnlineStatus(Map<String, dynamic> value) {
    return (value.containsKey(Constants.isOnlineKey) &&
            value[Constants.isOnlineKey].toString() == Constants.onlineState) &&
        (value.containsKey(Constants.lastOnlineAtKey) &&
            DateTime.now()
                    .difference(DateTime.parse(
                        value[Constants.lastOnlineAtKey].toString()))
                    .inMinutes <
                2);
  }

  void imagePicker(
      BuildContext context, SingleChatProvider provider, String type) async {
    final ImagePicker picker = ImagePicker();
    XFile? file;
    if (type == UiString.camera) {
      bool cameraPermission = await Utils.checkCameraPermission(context);
      if (cameraPermission) {
        file = await picker.pickImage(source: ImageSource.camera);
      }
    } else if (type == UiString.gallery) {
      bool galleryPermission = await Utils.checkGalleryPermission(context);
      if (galleryPermission) {
        file = await picker.pickImage(source: ImageSource.gallery);
      }

      // var result;
      if (file != null) {
        await sl<NavigationService>().navigateTo(
          RoutePaths.imageCropPreviewScreen,
          arguments: {
            "imagePath": file.path,
            "channelId": chatUser.channelId,
            "singleChatProvider": provider
          },
        );
        // Message msg = Message(
        //     userId: widget.loginUser,
        //     msgId: Utils.generateRandomString(),
        //     msg: "",
        //     file: result,
        //     msgReadStatus: Constants.sent,
        //     createdAt: DateTime.now().toUtc(),
        //     replyId: replyMsg != null ? replyMsg.msgId : "",
        //     replyMessage: replyMsg);
        //
        // await providers.sendMessage(
        //     widget.chatUser.channelName, msg);
      }

      // final messageVal =
      //     await sl<ChatRepository>().sendMessageWithPushNotification(
      //   chatUser1,
      //   message,
      //   loginUser: UserBasicInfo.fromUser(loginUser),
      // );
    }
  }

  Future<void> reportUser(
      {required String loginUserId,
      required String userId,
      required String reason}) async {
    try {
      Map<String, dynamic> apiResponse = await UserRepository()
          .reportUser(loginUserId: loginUserId, userId: userId, reason: reason);
      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.messageText] != null) {
          _message = apiResponse[UiString.messageText];
          notifyListeners();
        }
      } else {
        _message = UiString.error;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Either<String, bool>> blockUser(
      {required String loginUserId, required String userId}) async {
    try {
      Map<String, dynamic> apiResponse = await UserRepository().blockUser(
        userId: userId,
      );
      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.messageText] != null) {
        return const Right(true);
      } else {
        return Left(apiResponse[UiString.messageText]);
      }
    } catch (_) {}
    return const Left(UiString.error);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (kDebugMode) {
      print("dispose.......");
    }
    timer?.cancel();
    _dataStream?.cancel();
    _lastMessageStream?.cancel();
    super.dispose();
  }
}
