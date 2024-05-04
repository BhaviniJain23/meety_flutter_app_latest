import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/single_chats_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/widgets/chat_app_bar.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/no_internet_connection_container.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tuple/tuple.dart';

import 'chats.dart';

class OneToOneChatScreen extends StatefulWidget {
  final ChatUser1 chatUser1;
  final UserBasicInfo loggedInUser;

  const OneToOneChatScreen(
      {super.key, required this.chatUser1, required this.loggedInUser});

  static Widget create(
      BuildContext context, ChatUser1 user1, UserBasicInfo loggedInUser) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => SingleChatProvider(
          userChatListPro: context.read<UserChatListProvider>())
        ..init(loggedInUser.id, user1),
      child: OneToOneChatScreen(chatUser1: user1, loggedInUser: loggedInUser),
    );
  }

  @override
  State<OneToOneChatScreen> createState() => _OneToOneChatScreenState();
}

class _OneToOneChatScreenState extends State<OneToOneChatScreen> {
  final InternetConnectionService internetConnectionService =
      InternetConnectionService.getInstance();
  late StreamSubscription connectionSub;
  final ValueNotifier<bool> isInternet = ValueNotifier(true);
  final ValueNotifier<bool> checkInternetBanner = ValueNotifier(false);
  final RefreshController chatRefreshController = RefreshController();

  @override
  void initState() {
    internetConnectionService.initialize();
    super.initState();
    _internetConnectionChecker();
  }

  @override
  void dispose() {
    if (connectionSub.late.isInitialized) {
      connectionSub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChatAppBar(
        userRecord: widget.chatUser1.userRecord!,
      ),
      body: Stack(
        children: [
          Column(
            children: [
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
                  onLoading(context);
                },
                child:
                    Selector<SingleChatProvider, Tuple2<bool, List<Message>>>(
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
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Message msg = value.item2[index];
                              return ChatItem(
                                messageChat: msg,
                                loginUserId: widget.loggedInUser.id,
                                replyName: msg.replyMessage != null
                                    ? widget.chatUser1.userRecord?.name ?? ''
                                    : null,
                                channelId: widget.chatUser1.channelId ?? '',
                                onSwiped: () {
                                  context
                                      .read<SingleChatProvider>()
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
              Align(
                alignment: Alignment.bottomCenter,
                child: SendMessageWidget(
                  loggedInUser: widget.loggedInUser,
                ),
              )
            ],
          ),
          MultiValueListenableBuilder(
              valueListenables: [isInternet, checkInternetBanner],
              builder: (context, values, _) {
                if (values[1]) {
                  return AnimatedTextBar(
                    isOnline: values[0],
                  );
                }
                return const SizedBox.shrink();
              })
        ],
      ),
    );
  }

  void _internetConnectionChecker() {
    connectionSub =
        internetConnectionService.connectionChange.listen((hasConnection) {
      isInternet.value = hasConnection;

      if (isInternet.value) {
        // Handle the case when there is an internet connection
        Future.delayed(const Duration(seconds: 10), () {
          checkInternetBanner.value = false;
        });
        //Get All messages
      } else {
        // Handle the case when there is no internet connection
        checkInternetBanner.value = true;
      }
    });
  }

  Future<void> onLoading(BuildContext ctx) async {
    chatRefreshController.loadComplete();
    final provider = context.read<SingleChatProvider>();
    await provider.getPreviousMessages();
    if (provider.isLoadingMore) {
      chatRefreshController.loadComplete();
    } else {
      chatRefreshController.loadNoData();
    }
  }
}

class SendMessageWidget extends StatelessWidget {
  final UserBasicInfo loggedInUser;

  const SendMessageWidget({
    super.key,
    required this.loggedInUser,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SingleChatProvider>(
      builder: (context, singleChatProvider, child) {
        return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: Container(
              color: white,
              width: double.maxFinite,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.fromBorderSide(BorderSide(
                                color: grey.withOpacity(0.5), width: 0.8))),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: singleChatProvider.chatController,
                              minLines: 1,
                              maxLines: 100,
                              textInputAction: TextInputAction.done,
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 13),
                                  hintText: 'Your message',
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: InkWell(
                                      onTap: () {
                                        BottomSheetService().showImagePicker(
                                            context, onCameraTap: () {
                                          singleChatProvider.imagePicker(
                                              context,
                                              singleChatProvider,
                                              UiString.camera);
                                        }, onGalleryTap: () {
                                          singleChatProvider.imagePicker(
                                              context,
                                              singleChatProvider,
                                              UiString.gallery);
                                        });
                                      },
                                      child: Image.asset(
                                        Assets.attachmentIcon,
                                        height: 2,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  border: InputBorder.none),
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
                          if (singleChatProvider
                                  .chatUser.userRecord?.canMsgSend !=
                              0) {
                            // sendMessage
                            await singleChatProvider.sendMessage(
                              context,
                              loggedInUser,
                            );
                          } else {
                            AlertService.showToast(
                                "You can not send another messages until he/she replied",
                                context);
                          }
                        },
                        radius: 12,
                        child: Icon(Icons.send,
                            color: singleChatProvider
                                        .chatUser.userRecord?.canMsgSend ==
                                    0
                                ? grey
                                : null),
                      ),
                    ),
                  ]),
            ));
      },
    );
  }
}
