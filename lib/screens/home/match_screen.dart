import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/chat_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/chats.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

class MatchScreen extends StatefulWidget {
  final UserBasicInfo loginUser;
  final UserBasicInfo otherUser;
  final String message;
  const MatchScreen(
      {Key? key, required this.loginUser, required this.otherUser, required this.message})
      : super(key: key);

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  @override
  Widget build(BuildContext context) {
    var height = context.height * 0.8;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Container(
            height: height * 0.02,
          ),
          SizedBox(
            height: height * 0.12,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                'Congratulations\nIt\'s a match!',
                style: context.textTheme.headlineSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            height: height * 0.035,
          ),
          SizedBox(
            height: height * 0.25,
            child: DropShadow(
              offset: const Offset(0, 5),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left:context.width*0.45,

                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white54,width:3)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: CacheImage(
                          imageUrl:
                          widget.loginUser.images?.first.toString() ?? '',
                          width: height * 0.135,
                          height: height * 0.135,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    left:context.width*0.25,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70,width:3)
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: CacheImage(
                          imageUrl:
                          widget.otherUser.images?.isNotEmpty ?? false ? widget.otherUser.images?.first.toString() ?? '' : '',
                          width: height * 0.135,
                          height: height * 0.135,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: height * 0.03,
          ),
          SizedBox(
            height: height * 0.04,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Text(
                '${widget.otherUser.name}, ${widget.otherUser.age}',
                style: context.textTheme.labelLarge
                    ?.copyWith( fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            height: height * 0.06,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0),
            child: Text(
              widget.message,
              maxLines: 3,
              softWrap: true,
              style: context.textTheme.bodyLarge?.copyWith(
                  color: grey,
                  fontSize:16,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Padding(
            padding:const EdgeInsets.symmetric(horizontal: 30.0),
            child: FillBtnX(onPressed: () async {
              openChats();
            }, text: 'Say "Hi"'),
          ),
          Container(
            height: height * 0.01,
          ),
        ],
      ),
    );
  }

  Future<void> openChats() async {
    bool checkInternet =
    await sl<InternetConnectionService>().hasInternetConnection();
    if (checkInternet) {
      Map<String, dynamic> apiResponse = await sl<ChatRepository>()
          .getChatUserFromId(widget.loginUser.id.toString(), widget.otherUser.id.toString());
      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null) {
          ChatUser chatUser = ChatUser(
              id:  widget.otherUser.id.toString(),
              fname:  widget.otherUser.name.toString(),
              lname: '',
              profilePic:  widget.otherUser.images?.first.toString() ?? '',
              unreadCount: '0',
              channelName: apiResponse[UiString.dataText],
              fcmToken: widget.otherUser.fcmToken
          );

          Future.delayed(Duration.zero, () {
            final provider = sl<UserChatListProvider>();

            provider.updateUserListFromMessage(user: chatUser);


            sl<NavigationService>()
                .customMaterialPageRoute(ChangeNotifierProvider(
              create: (BuildContext context) =>
              ChatProviders(userChatListPro: provider)
                ..init(chatUser.id, chatUser.channelName),
              child: ChatScreen(
                  chatUser: chatUser, loginUser: widget.loginUser.id.toString()),
            ));
          });
        }
      } else {}
    }
  }

}
