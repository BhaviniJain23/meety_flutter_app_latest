import 'dart:io';

import 'package:action_broadcast/action_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/providers/chat_provider.dart';
import 'package:meety_dating_app/providers/single_chats_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/image_preview.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/no_internet_connection_container.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:readmore/readmore.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:tuple/tuple.dart';

import '../../../profile/widgets/image_view_pager.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatUser chatUser;
  final String loginUser;
  ChatScreen({Key? key, required this.chatUser, required this.loginUser})
      : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AutoCancelStreamMixin {
  late FocusNode inputNode;
  RefreshController chatRefreshController = RefreshController();
  TextEditingController chatController = TextEditingController();
  XFile? file;
  StreamSubscription? _subscription;
  InternetConnectionService connectionStatus =
      InternetConnectionService.getInstance();

  bool checkInternetBanner = false;
  // ignore: prefer_typing_uninitialized_variables
  var chatProvider;
  bool isInternet = true;

  @override
  void initState() {
    super.initState();
    inputNode = FocusNode();
    isInternet = connectionStatus.hasConnection;
    chatProvider = Provider.of<ChatProviders>(context, listen: false);
    _subscription = connectionStatus.connectionChange.listen((event) async {
      isInternet = event;
      if (isInternet) {
        chatProvider.getInitialMessage(widget.chatUser.channelName);
        Future.delayed(const Duration(seconds: 10), () {
          checkInternetBanner = false;
          setState(() {});
        });
      } else {
        checkInternetBanner = true;
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    chatProvider.dispose();
    super.dispose();
  }

  @override
  Iterable<StreamSubscription> get registerSubscriptions sync* {
    yield registerReceiver([Constants.readMsgNotificationBroadcaster])
        .listen((intent) {
      switch (intent.action) {
        case Constants.readMsgNotificationBroadcaster:
          if (chatProvider.isOnline.containsKey(Constants.isOnlineKey) &&
              chatProvider.isOnline[Constants.isOnlineKey].toString() ==
                  Constants.onlineState &&
              chatProvider.isOnline.containsKey(Constants.channelIdKey) &&
              chatProvider.isOnline[Constants.channelIdKey] ==
                  widget.chatUser.channelName) {
            chatProvider.readAllMessage();
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChatProviders>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBarX(
          title: '',
          elevation: 1,
          height: 80,
          mobileBar: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: OutLineBtnX2(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    radius: 15,
                    elevation: 1.5,
                    bgColor: white,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                        '${widget.chatUser.fname} ${widget.chatUser.lname ?? ''}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 0),
                      ),
                      Selector<ChatProviders, Map<String, dynamic>>(
                        selector: (context, provider) => provider.isOnline,
                        builder: (context, value, child) {
                          if (value.containsKey(Constants.isOnlineKey) &&
                              value[Constants.isOnlineKey].toString() ==
                                  Constants.onlineState) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  Assets.circleIcon,
                                  color: Colors.green,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Text(
                                  'online',
                                  style: TextStyle(fontSize: 14, color: grey),
                                )
                              ],
                            );
                          }
                          return Container();
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 50,
                  width: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        body: StreamBuilder(
            stream: connectionStatus.connectionChange,
            builder: (context, snapshot) {
              bool isInternetChange =
                  (snapshot.connectionState == ConnectionState.waiting &&
                      !connectionStatus.hasConnection);
              return Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Expanded(
                          child: SmartRefresher(
                        physics: const BouncingScrollPhysics(),
                        enablePullDown: false,
                        enablePullUp: true,
                        reverse: true,
                        footer: const ClassicFooter(
                          noDataText: '',
                        ),
                        controller: chatRefreshController,
                        onLoading: () async {
                          await provider
                              .getPreviousMessages(widget.chatUser.channelName);
                          if (provider.isLoadingMore) {
                            chatRefreshController.loadComplete();
                          } else {
                            chatRefreshController.loadNoData();
                          }
                        },
                        child: Selector<ChatProviders,
                            Tuple2<bool, List<Message>>>(
                          selector: (context, provider) =>
                              Tuple2(provider.showGetLoader, provider.messages),
                          builder: (context, value, child) {
                            if (!value.item1) {
                              if (value.item2.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 50),
                                  child: NoMessageWidget(
                                      image: Assets.noChatIcon,
                                      title: "Start a conversation",
                                      subTitle: "Messages will show up here."),
                                );
                              } else if (value.item2.isNotEmpty) {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: value.item2.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      Message msg = value.item2[index];
                                      return ChatItem(
                                        messageChat: msg,
                                        loginUserId: widget.loginUser,
                                        replyName: msg.replyMessage != null
                                            ? '''${widget.chatUser.fname} ${widget.chatUser.lname ?? ''}'''
                                            : null,
                                        channelId: widget.chatUser.channelName,
                                        onSwiped: () {
                                          Provider.of<ChatProviders>(context,
                                                  listen: false)
                                              .setReplyMessage(msg);
                                        },
                                      );
                                    });
                              }
                            }
                            return const Loading();
                          },
                        ),
                      )),
                      Selector<ChatProviders, Message?>(
                        selector: (context, provider) => provider.replyMessage,
                        builder: (context, value, child) {
                          return Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    color: white,
                                    width: double.maxFinite,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.fromBorderSide(
                                                      BorderSide(
                                                          color: grey
                                                              .withOpacity(0.5),
                                                          width: 0.8))),
                                              alignment: Alignment.centerLeft,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (value != null) ...[
                                                    Container(
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 5),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color:
                                                              grey.withOpacity(
                                                                  0.2)),
                                                      child: Stack(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 5,
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            3.0,
                                                                        vertical:
                                                                            3.0),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        Text(
                                                                          value.userId == widget.loginUser
                                                                              ? 'You'
                                                                              : '''${widget.chatUser.fname} ${widget.chatUser.lname ?? ''}''',
                                                                          style:
                                                                              const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                lightRed,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          value
                                                                              .msg,
                                                                          maxLines:
                                                                              2,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (value.file !=
                                                                        null &&
                                                                    value.file!
                                                                        .isNotEmpty) ...[
                                                                  if (Utils.getFileType(value
                                                                              .file!) ==
                                                                          FileTypes
                                                                              .IMAGE ||
                                                                      Utils.getFileType(value
                                                                              .file!) ==
                                                                          FileTypes
                                                                              .VIDEO) ...[
                                                                    Container(
                                                                      height:
                                                                          85,
                                                                      width: 75,
                                                                      decoration: const BoxDecoration(
                                                                          color: Colors
                                                                              .black,
                                                                          borderRadius: BorderRadius.only(
                                                                              topRight: Radius.circular(5),
                                                                              bottomRight: Radius.circular(5))),
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius: const BorderRadius
                                                                            .only(
                                                                            topRight:
                                                                                Radius.circular(5),
                                                                            bottomRight: Radius.circular(5)),
                                                                        child:
                                                                            CacheImage(
                                                                          imageUrl:
                                                                              value.file!,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ]
                                                                ]
                                                              ],
                                                            ),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .topRight,
                                                            child: InkWell(
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        2.0),
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        5.0),
                                                                decoration: BoxDecoration(
                                                                    color: value.file !=
                                                                                null &&
                                                                            value
                                                                                .file!.isNotEmpty
                                                                        ? white
                                                                        : Colors
                                                                            .transparent,
                                                                    shape: BoxShape
                                                                        .circle),
                                                                child:
                                                                    const Icon(
                                                                  Icons.close,
                                                                  color:
                                                                      lightRed,
                                                                  size: 16,
                                                                ),
                                                              ),
                                                              onTap: () async {
                                                                Provider.of<ChatProviders>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .setReplyMessage(
                                                                        null);
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                  TextField(
                                                    controller: chatController,
                                                    minLines: 1,
                                                    maxLines: 100,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    focusNode: inputNode,
                                                    textAlign: TextAlign.start,
                                                    decoration: InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 15,
                                                                vertical: 13),
                                                        hintText:
                                                            'Your message',
                                                        hintStyle:
                                                            const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                        ),
                                                        suffixIcon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(12),
                                                          child: InkWell(
                                                            onTap: () {
                                                              BottomSheetService()
                                                                  .showImagePicker(
                                                                      context,
                                                                      onCameraTap:
                                                                          () {
                                                                imagePicker(
                                                                    UiString
                                                                        .camera,
                                                                    provider,
                                                                    value
                                                                        ?.replyMessage);
                                                              }, onGalleryTap:
                                                                          () {
                                                                imagePicker(
                                                                    UiString
                                                                        .gallery,
                                                                    provider,
                                                                    value
                                                                        ?.replyMessage);
                                                              });
                                                            },
                                                            child: Image.asset(
                                                              Assets
                                                                  .attachmentIcon,
                                                              height: 2,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                        ),
                                                        border:
                                                            InputBorder.none),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: OutLineBtnX2(
                                              onPressed: () async {
                                                if (chatController.text
                                                        .trim()
                                                        .isNotEmpty &&
                                                    isInternet) {
                                                  if (widget.chatUser
                                                      .channelName.isEmpty) {
                                                    Map<String, dynamic>
                                                        apiResponse = await sl<
                                                                ChatRepository>()
                                                            .addChannelId(
                                                                widget.loginUser
                                                                    .toString(),
                                                                widget
                                                                    .chatUser.id
                                                                    .toString());

                                                    if (apiResponse[
                                                        UiString.successText]) {
                                                      if (apiResponse[UiString
                                                              .dataText] !=
                                                          null) {
                                                        widget.chatUser = widget
                                                            .chatUser
                                                            .copyWith(
                                                                channelName:
                                                                    apiResponse[
                                                                        UiString
                                                                            .dataText]);
                                                        Message msg = Message(
                                                            userId: widget
                                                                .loginUser,
                                                            msgId: Utils
                                                                .generateRandomString(),
                                                            msg: chatController
                                                                .text
                                                                .trim(),
                                                            file: null,
                                                            msgReadStatus:
                                                                Constants.sent,
                                                            createdAt:
                                                                DateTime.now()
                                                                    .toUtc(),
                                                            replyId: value !=
                                                                    null
                                                                ? value.msgId
                                                                : "",
                                                            replyMessage:
                                                                value);
                                                        chatController.clear();

                                                        await provider.sendMessage(
                                                            apiResponse[UiString
                                                                .dataText],
                                                            msg);
                                                      }
                                                    }
                                                  } else {
                                                    Message msg = Message(
                                                        userId:
                                                            widget.loginUser,
                                                        msgId: Utils
                                                            .generateRandomString(),
                                                        msg: chatController.text
                                                            .trim(),
                                                        file: null,
                                                        msgReadStatus:
                                                            Constants.sent,
                                                        createdAt:
                                                            DateTime.now()
                                                                .toUtc(),
                                                        replyId: value != null
                                                            ? value.msgId
                                                            : "",
                                                        replyMessage: value);
                                                    chatController.clear();

                                                    await provider.sendMessage(
                                                        widget.chatUser
                                                            .channelName,
                                                        msg);
                                                  }
                                                } else {
                                                  context.showSnackBar(
                                                      !isInternet
                                                          ? UiString.noInternet
                                                          : UiString
                                                              .msgCantBeEmpty);
                                                }
                                              },
                                              radius: 12,
                                              child: const Icon(Icons.send),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                  if (checkInternetBanner || isInternetChange)
                    AnimatedTextBar(
                      isOnline: isInternet,
                    ),
                ],
              );
            }),
      ),
    );
  }

  /// Show the soft keyboard.
  void openKeyboard() {
    FocusScope.of(context).requestFocus(inputNode);
  }

  /// Hide the soft keyboard.
  void hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  imagePicker(String type, ChatProviders providers, Message? replyMsg) async {
    ImagePicker picker = ImagePicker();

    if (type == UiString.camera) {
      bool cameraPermission = await Utils.checkCameraPermission(context);
      if (cameraPermission) {
        picker.pickImage(source: ImageSource.camera).then((value) async {
          if (value != null) {
            final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ImageCropPreview(
                          imagePath: value.path,
                          channelId: widget.chatUser.channelName,
                      singleChatProvider: SingleChatProvider(userChatListPro: context.read<UserChatListProvider>()),
                        )));

            if (result != null) {
              if (widget.chatUser.channelName.isEmpty) {
                Map<String, dynamic> apiResponse = await sl<ChatRepository>()
                    .addChannelId(widget.loginUser.toString(),
                        widget.chatUser.id.toString());

                if (apiResponse[UiString.successText]) {
                  if (apiResponse[UiString.dataText] != null) {
                    widget.chatUser = widget.chatUser
                        .copyWith(channelName: apiResponse[UiString.dataText]);

                    Message msg = Message(
                        userId: widget.loginUser,
                        msgId: Utils.generateRandomString(),
                        msg: "",
                        file: result,
                        msgReadStatus: Constants.sent,
                        createdAt: DateTime.now().toUtc(),
                        replyId: replyMsg != null ? replyMsg.msgId : "",
                        replyMessage: replyMsg);

                    await providers.sendMessage(
                        widget.chatUser.channelName, msg);
                  }
                }
              } else {
                Message msg = Message(
                    userId: widget.loginUser,
                    msgId: Utils.generateRandomString(),
                    msg: "",
                    file: result,
                    msgReadStatus: Constants.sent,
                    createdAt: DateTime.now().toUtc(),
                    replyId: replyMsg != null ? replyMsg.msgId : "",
                    replyMessage: replyMsg);

                await providers.sendMessage(widget.chatUser.channelName, msg);
              }
            }
          }
        });
      }
    } else if (type == UiString.gallery) {
      bool galleryPermission = await Utils.checkGalleryPermission(context);
      if (galleryPermission) {
        picker.pickImage(source: ImageSource.gallery).then((value) async {
          if (value != null) {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ImageCropPreview(
                          imagePath: value.path,
                          channelId: widget.chatUser.channelName,
                      singleChatProvider: SingleChatProvider(userChatListPro: context.read<UserChatListProvider>()),

                    )));
          }
        });
      }
    }
  }
}

class ChatItem extends StatelessWidget {
  final Message messageChat;
  final String? loginUserId;
  final String? replyName;
  final String channelId;
  final Function()? onSwiped;
  const ChatItem(
      {Key? key,
      required this.messageChat,
      this.loginUserId,
      this.replyName,
      this.onSwiped, required this.channelId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loginUserId != null && (messageChat.msg.trim().isNotEmpty ||
        messageChat.file != null)) {
      final bool isLoginUser =
          (messageChat.userId == loginUserId) ? true : false;
      final FileTypes messageType = messageChat.file == null
          ? FileTypes.TEXT
          : Utils.getFileType(messageChat.file!);

      double fileHeightRatio = 3.4;
      double fileWidthRation = 1.54;

      return Container(
        margin: const EdgeInsets.only(bottom: 2, top: 2),
        color: white,
        child: SwipeableTile.swipeToTrigger(
          key: UniqueKey(),
          backgroundBuilder: swipeAnimationBuilder,
          behavior: HitTestBehavior.translucent,
          isElevated: false,
          color: white,
          swipeThreshold: 0.2,
          direction: SwipeDirection.startToEnd,
          onSwiped: (_) {
            if (onSwiped != null) {
              onSwiped!.call();
            }
          },
          child: Row(
            mainAxisAlignment:
                isLoginUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    right: 10, bottom: 3, top: 3, left: 10),
                child: Column(
                  crossAxisAlignment: isLoginUser
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: context.width * 0.65,
                          minWidth: context.width * 0.1),
                      decoration: BoxDecoration(
                          color: !isLoginUser
                              ? lightRed.withOpacity(0.5)
                              : loginUserChatColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: isLoginUser
                                ? const Radius.circular(12)
                                : Radius.zero,
                            bottomRight: isLoginUser
                                ? Radius.zero
                                : const Radius.circular(12),
                          )),
                      padding: (messageType == FileTypes.TEXT)
                          ? const EdgeInsets.fromLTRB(5, 3, 5, 3)
                          : null,
                      child: Column(
                        crossAxisAlignment: isLoginUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (messageChat.replyMessage != null) ...[
                            Container(
                              height: 70,
                              width: MediaQuery.of(context).size.width * 0.65,
                              decoration: BoxDecoration(
                                  color: white.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10.0,
                                        // top: 5.0
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            replyName ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          if(messageChat.replyMessage!.msg.isNotEmpty)...[
                                            Text(
                                              messageChat.replyMessage!.isEncrypted ?
                                              Utils.decrypt(channelId, messageChat.replyMessage!.msg) :
                                              messageChat.replyMessage!.msg,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ] ,
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (messageChat.replyMessage!.file !=
                                      null) ...[
                                    if (Utils.getFileType(messageChat
                                                .replyMessage!.file!) ==
                                            FileTypes.IMAGE ||
                                        Utils.getFileType(messageChat
                                                .replyMessage!.file!) ==
                                            FileTypes.VIDEO) ...[
                                      Container(
                                        height: 70,
                                        width: 70,
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(5),
                                                bottomRight:
                                                    Radius.circular(5))),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(5),
                                              bottomRight: Radius.circular(5)),
                                          child: CacheImage(
                                            imageUrl: messageChat
                                                    .replyMessage!.file ??
                                                '',
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                      ),
                                    ]
                                  ]
                                ],
                              ),
                            )
                          ],
                          if (messageType == FileTypes.IMAGE ||
                              messageType == FileTypes.VIDEO) ...[
                            Container(
                              height: (MediaQuery.of(context).size.height /
                                      fileHeightRatio -
                                  20),
                              width: MediaQuery.of(context).size.width /
                                  fileWidthRation,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft:
                                    isLoginUser && messageChat.msg.isNotEmpty
                                        ? const Radius.circular(12)
                                        : Radius.zero,
                                bottomRight:
                                    isLoginUser || messageChat.msg.isNotEmpty
                                        ? Radius.zero
                                        : const Radius.circular(12),
                              )),
                              child: InkWell(
                                onTap: () {
                                  if (messageType == FileTypes.IMAGE) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ImageViewPager(
                                                  imageList: [
                                                    messageChat.file
                                                  ],
                                                  currentPosition: 0,
                                                )));
                                    print(messageChat.file!.trim());
                                  }
                                  else {
                                    // Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             DefaultPlayer(
                                    //                 url:
                                    //                 messageChat.file,
                                    //                 isMute: true)));
                                  }
                                },
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (messageChat.file!.trim().isUrl()) ...[
                                      CacheImage(
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        imageUrl:
                                            messageChat.file?.trim() ?? '',
                                        radius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft: isLoginUser &&
                                                  messageChat.msg.isNotEmpty
                                              ? const Radius.circular(12)
                                              : Radius.zero,
                                          bottomRight: isLoginUser ||
                                                  messageChat.msg.isNotEmpty
                                              ? Radius.zero
                                              : const Radius.circular(12),
                                        ),
                                      ),
                                    ] else ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft: isLoginUser &&
                                                  messageChat.msg.isNotEmpty
                                              ? const Radius.circular(12)
                                              : Radius.zero,
                                          bottomRight: isLoginUser ||
                                                  messageChat.msg.isNotEmpty
                                              ? Radius.zero
                                              : const Radius.circular(12),
                                        ),
                                        child: Image.file(
                                            File(messageChat.file!.trim())),
                                      )
                                    ],
                                    if (messageType == FileTypes.IMAGE)
                                      ...[]
                                    else ...[
                                      const Align(
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: white,
                                          size: 60,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (messageChat.msg.isNotEmpty) ...[
                            Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.65),
                              child: Wrap(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        top: 10,
                                        right: 10,
                                        bottom: 10.0),
                                    child: ReadMoreText(
                                      messageChat.isEncrypted ?
                                      Utils.decrypt(channelId, messageChat.msg) :
                                      messageChat.msg,
                                      style: const TextStyle(fontSize: 15),
                                      trimLines: 21,
                                      colorClickableText: Colors.grey.shade900,
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'read more',
                                      delimiter: ' ',
                                      trimExpandedText: 'less',
                                      delimiterStyle: const TextStyle(
                                          fontSize: 14,
                                          color: black,
                                          fontWeight: FontWeight.bold),
                                      moreStyle: const TextStyle(
                                          fontSize: 15,
                                          color: black,
                                          fontWeight: FontWeight.w500),
                                      lessStyle: const TextStyle(
                                          fontSize: 15,
                                          color: black,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Row(
                      mainAxisAlignment: isLoginUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Text(
                          messageChat.createdAt.toTime(),
                          style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromRGBO(0, 0, 0, 0.4)),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        // if (isLoginUser) ...[
                        //   if (readStatus == Constants.unsent) ...[
                        //     Image.asset(
                        //       Assets.clockIcon,
                        //       height: 15,
                        //       width: 15,
                        //       color: grey,
                        //     )
                        //   ],
                        //   if (readStatus == Constants.sent) ...[
                        //     const Icon(
                        //       Icons.done,
                        //       color: grey,
                        //     )
                        //   ],
                        //   if (readStatus == Constants.delivered) ...[
                        //     const Icon(
                        //       Icons.done_all,
                        //       color: grey,
                        //     )
                        //   ],
                        //   if (readStatus == Constants.msgRead) ...[
                        //     const Icon(
                        //       Icons.done_all,
                        //       color: red,
                        //     )
                        //   ],
                        // ],
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget swipeAnimationBuilder(BuildContext context, SwipeDirection direction,
      AnimationController progress) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        return Container(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Transform.scale(
              scale: Tween<double>(
                begin: 0.0,
                end: 1.2,
              )
                  .animate(
                    CurvedAnimation(
                      parent: progress,
                      curve: const Interval(0.5, 1.0, curve: Curves.linear),
                    ),
                  )
                  .value,
              child: Icon(
                Icons.reply,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        );
      },
    );
  }
}

class NoMessageWidget extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;
  final double? imageHeight;
  final double? imageWidth;
  final double? fontSize;
  final Color? imageColor;
  const NoMessageWidget(
      {Key? key,
      required this.image,
      required this.title,
      required this.subTitle,
      this.imageHeight,
      this.imageWidth,
      this.fontSize,
      this.imageColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Image.asset(
            image,
            height: imageHeight ?? 150,
            width: imageWidth ?? 150,
            color: imageColor ?? grey,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
            child: Text(
              title,
              style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize ?? 18),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              subTitle,
              style: TextStyle(
                  color: grey,
                  letterSpacing: 0.2,
                  fontSize: fontSize != null ? (fontSize! - 1) : 15),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
