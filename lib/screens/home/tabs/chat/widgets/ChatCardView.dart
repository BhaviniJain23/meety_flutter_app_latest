// ignore_for_file: file_names

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ChatCardView extends StatelessWidget {
  const ChatCardView({Key? key, required this.user}) : super(key: key);
  final ChatUser1 user;

  @override
  Widget build(BuildContext context) {


    var ipsumText = " What is Lorem Ipsum?Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.Why do we use it?It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).Where does it come from?Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of 'de Finibus Bonorum et Malorum' (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, 'Lorem ipsum dolor sit amet..', comes from a line in section 1.10.32.The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from 'de Finibus Bonorum et Malorum' by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.Where can I get some?There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to gen";

    return InkWell(
      onTap: () async {
        // String encrypted = Utils.encryptText(digest.toString(),ipsumText);
        // String decryptedText = Utils.decrypt(digest.toString(), encrypted);
        await context
            .read<UserChatListProvider>()
            .navigateToSingleChats(context, user);
      },
      child: Material(
        color: white,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 15),
                      alignment: Alignment.topCenter,
                      decoration: const BoxDecoration(
                          color: white, shape: BoxShape.circle),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: CacheImage(
                            imageUrl: user.userRecord?.images?.isNotEmpty ?? false
                                ? user.userRecord!.images!.first
                                : '',
                            height: 80,
                            width: 80,
                          )),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  (user.userRecord?.name ?? '').trim(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                user.lastMessage?.createdAt.toTime().toString() ??
                                    '',
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          if (user.lastMessage != null)
                            Row(
                              children: [
                                Expanded(
                                  child: user.lastMessage?.msg != null &&
                                          user.lastMessage!.msg.isNotEmpty
                                      ? Text(
                                         user.lastMessage!.isEncrypted &&
                                             user.lastMessage!.msg.isNotEmpty ?
                                       Utils.decrypt(user.channelId ?? '', user.lastMessage!.msg)
                                          : user.lastMessage!.msg,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : const Row(
                                          children: [
                                            Icon(Icons.photo),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text('Photo')
                                          ],
                                        ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                if (user.totalUnreadMessage != 0 &&
                                    user.lastMessage != null &&
                                    user.userRecord != null &&
                                    user.lastMessage!.userId ==
                                        user.userRecord!.id) ...[
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle, color: lightRed),
                                    child: Text(
                                      user.totalUnreadMessage.toString(),
                                      style: const TextStyle(color: white),
                                    ),
                                  )
                                ]
                              ],
                            ),
                        ],
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 10,
              ),
              Divider(
                color: 0xffE8E6EA.toColor,
                height: 1,
                thickness: 1,
                indent: 60,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerChatCard extends StatelessWidget {
  const ShimmerChatCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: white,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      width: 55,
                      height: 55,
                      margin: const EdgeInsets.only(right: 15),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200, shape: BoxShape.circle),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 18,
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 14,
                            width: context.width * 0.6,
                            decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ],
        ),
      ),
    );
  }
}
