// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/data/repository/home_repo.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/textfields.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

class HomeProvider extends ChangeNotifier {
  final recordSize = 5;
  List<UserBasicInfo> _users = [];
  bool _rewind = false;
  int _currentIndex = 0; // Track the currently displayed user index
  DataState _dataState = DataState.Uninitialized;

  bool get rewind => _rewind;

  int get currentIndex => _currentIndex;

  List<UserBasicInfo> get users => [..._users];

  DataState get dataState => _dataState;

  set rewind(bool value) {
    _rewind = value;
    notifyListeners();
  }

  void setCurrentIndex(int value) {
    _currentIndex = value;
    notifyListeners();
  }

  void updateDataState(DataState value) {
    _dataState = value;
    notifyListeners();
  }

  void updateImageIndexById(int index, int imageIndex) {
    _users[index] = _users[index].copyWith(imageIndex: imageIndex);
  }

  void updateAllList({
    required bool isUpdateStatus,
    UserBasicInfo? userBasicInfo,
    bool isBlock = false,
    required LikeListProvider likeListProvider1,
    required OnlineUserProvider onlineUserProvider1,
    required UserChatListProvider userChatListProvider1,
  }) {
    try {
      final likeListProvider = likeListProvider1;

      final userChatListProvider = userChatListProvider1;

      final onlineUserListProvider = onlineUserProvider1;

      if (userBasicInfo != null) {
        int homeIndex =
            users.indexWhere((element) => element.id == userBasicInfo.id);

        int likedSentIndex = likeListProvider.likeSentList
            .indexWhere((element) => element.id == userBasicInfo.id);

        int matchIndex = likeListProvider.matchesList
            .indexWhere((element) => element.id == userBasicInfo.id);

        int userChatListIndex = userChatListProvider.chatUser1.indexWhere(
            (element) => element.userRecord?.id == userBasicInfo.id);

        int onlineUserIndex = onlineUserListProvider.onlineUsers.indexWhere(
            (element) => element.userBasicInfo?.id == userBasicInfo.id);

        if ((homeIndex != -1 && homeIndex > currentIndex) &&
            (homeIndex != -1 && isBlock)) {
          if ((isUpdateStatus &&
                  userBasicInfo.visitStatus != Constants.noStatus) ||
              isBlock) {
            _users = users..removeAt(homeIndex);
          }
          notifyListeners();
        }

        if (isBlock) {
          int likedIndex = likeListProvider.likeList
              .indexWhere((element) => element.id == userBasicInfo.id);
          int visitedIndex = likeListProvider.visitorList
              .indexWhere((element) => element.id == userBasicInfo.id);
          if (likedIndex != -1 || visitedIndex != -1) {
            if (likedIndex != -1) {
              likeListProvider.likeList = likeListProvider.likeList
                ..removeAt(likedIndex);
            }
            if (visitedIndex != -1) {
              likeListProvider.visitorList = likeListProvider.visitorList
                ..removeAt(visitedIndex);
            }
          }
        }

        if (likedSentIndex != -1 || matchIndex != -1) {
          if (likedSentIndex != -1) {
            if ((userBasicInfo.visitStatus == Constants.liked ||
                    userBasicInfo.visitStatus == Constants.visitedAndLike) &&
                isUpdateStatus) {
              likeListProvider.likeSentList = List.from(likeListProvider
                  .likeSentList
                  .updateAtIndex(likedSentIndex, userBasicInfo));
            } else {
              likeListProvider.likeSentList = likeListProvider.likeSentList
                ..removeAt(likedSentIndex);
            }
          }
          if (matchIndex != -1) {
            if (userBasicInfo.visitStatus == Constants.matchStatus &&
                isUpdateStatus) {
              likeListProvider.matchesList = List.from(likeListProvider
                  .matchesList
                  .updateAtIndex(matchIndex, userBasicInfo));
            } else {
              likeListProvider.matchesList = likeListProvider.matchesList
                ..removeAt(matchIndex);
            }
          }
          likeListProvider.notifyListeners();
        }

        if (userChatListIndex != -1) {
          if (isUpdateStatus) {
            userChatListProvider.chatUsers1 = List.from(
                userChatListProvider.chatUser1.updateAtIndex(
                    userChatListIndex,
                    userChatListProvider.chatUser1[userChatListIndex]
                        .copyWith(userRecord: userBasicInfo)));
          }
          if (isBlock) {
            userChatListProvider.chatUsers1 = userChatListProvider.chatUser1
              ..removeAt(userChatListIndex);
          }
          userChatListProvider.notifyListeners();
        }

        if (onlineUserIndex != -1) {
          if (isUpdateStatus) {
            onlineUserListProvider.onlineUsers = List.from(
                onlineUserListProvider.onlineUsers.updateAtIndex(
                    onlineUserIndex,
                    onlineUserListProvider.onlineUsers[onlineUserIndex]
                        .copyWith(userBasicInfo: userBasicInfo)));
          }
          if (isBlock) {
            onlineUserListProvider.onlineUsers =
                onlineUserListProvider.onlineUsers..removeAt(onlineUserIndex);
          }
          onlineUserListProvider.notifyListeners();
        }
      } else {
        fetchUsers(page: 1);
        likeListProvider.fetchingInitialData();
        userChatListProvider.fetchChats();
        onlineUserListProvider.getOnlineUsers(refresh: true);
      }
    } on Exception catch (_) {}
  }

  Future<List<UserBasicInfo>> fetchUsersFromAPI(int page,
      {String userIds = ''}) async {
    User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    bool isCurrent = loginUser?.showCurrent ?? true;

    Map<String, dynamic> apiResponse = await HomeRepository().fetchUsers(data: {
      "lat": isCurrent ? loginUser?.currentLat : loginUser?.findingLat,
      "long": isCurrent ? loginUser?.currentLong : loginUser?.findingLong,
      "is_current": isCurrent ? "1" : '0',
      "page_number": page,
      "records_per_page": recordSize,
      "user_ids": userIds
    });

    if (apiResponse[UiString.successText] &&
        apiResponse[UiString.dataText] != null) {
      List<UserBasicInfo> tempUsers =
          List.from((apiResponse[UiString.dataText] as List).map((e) {
        return UserBasicInfo.fromJson(e);
      }));

      return tempUsers;
    } else {
      return [];
    }
  }

  Future<void> fetchUsers({int page = 1}) async {
    try {
      if (page == 1) {
        _dataState = DataState.Initial_Fetching;
        notifyListeners();
      }
      final usersList = await fetchUsersFromAPI(page,
          userIds: users.isNotEmpty
              ? users.map((e) => e.id).toList().join(",")
              : '');

      if (usersList.isNotEmpty) {
        if (page == 1) {
          _users = [...usersList];
        } else {
          _users.addAll(usersList);
        }
        _dataState = DataState.Fetched;
      } else {
        _dataState = DataState.Error;
      }
    } catch (e) {
      if (kDebugMode) {
        // print('Error fetching more data: $e');
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadMoreData(int page) async {
    if (dataState != DataState.No_More_Data) {
      try {
        final usersList = await fetchUsersFromAPI(page,
            userIds: users.map((e) => e.id).toList().join(","));
        if (usersList.isNotEmpty) {
          _users.addAll(usersList);
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error fetching more data: $error');
        }
      } finally {
        notifyListeners();
      }
    }
  }

  Future<bool> updateVisitAction(BuildContext context, String action,
      {required UserBasicInfo userBasicInfo,
      bool isDirectionUpdate = false}) async {
    final User? user = sl<SharedPrefsManager>().getUserDataInfo();
    final getRemainingValue = user?.getRemainingValue ?? GetRemainingValue();
    final tempVal = userBasicInfo;

    final likeListProvider = context.read<LikeListProvider>();
    final userChatListProvider = context.read<UserChatListProvider>();
    final onlineUserListProvider = context.read<OnlineUserProvider>();
    final homeProvider = context.read<HomeProvider>();

    switch (action) {
      case Constants.liked:
      case Constants.visitedAndLike:
        final remainingLikeVal = (getRemainingValue.remainingLikes ?? 0);

        if (remainingLikeVal > 0) {
          likeListProvider.updateVisitStatus(
              context, tempVal, action, user?.id ?? '',
              likeListProvider: likeListProvider,
              userChatListProvider: userChatListProvider,
              onlineUserProvider: onlineUserListProvider,
              homeController: homeProvider);

          await sl<SharedPrefsManager>().saveUserInfo(user!.copyWith(
              getRemainingValue: getRemainingValue.copyWith(
                  remainingLikes: remainingLikeVal - 1)));
          _rewind = true;
          return true;
        } else {
          Utils.printingAllPremiumInfo(context, isForLike: true);
          return false;
        }
      case Constants.disliked:
      case Constants.visitedAndDisliked:
        final remainingDisLikeVal = (getRemainingValue.remainingDisLikes ?? 0);

        if (remainingDisLikeVal > 0) {
          await sl<SharedPrefsManager>().saveUserInfo(user!.copyWith(
              getRemainingValue: getRemainingValue.copyWith(
                  remainingDisLikes: remainingDisLikeVal - 1)));
          _rewind = true;

          likeListProvider.updateVisitStatus(
              context, tempVal, action, user.id ?? '',
              likeListProvider: likeListProvider,
              userChatListProvider: userChatListProvider,
              onlineUserProvider: onlineUserListProvider,
              homeController: homeProvider);
          return true;
        } else {
          Utils.printingAllPremiumInfo(context, isForDislike: true);

          return false;
        }

      case Constants.unmatchStatus:
        likeListProvider.updateVisitStatus(
            context, tempVal, action, user?.id ?? '',
            likeListProvider: likeListProvider,
            userChatListProvider: userChatListProvider,
            onlineUserProvider: onlineUserListProvider,
            homeController: homeProvider);
        return true;
      case Constants.visitor:
        likeListProvider.updateVisitStatus(
            context, tempVal, action, user?.id ?? '',
            likeListProvider: likeListProvider,
            userChatListProvider: userChatListProvider,
            onlineUserProvider: onlineUserListProvider,
            homeController: homeProvider);
        return true;

      case Constants.rewindStatus:
        final remainingRewind = (getRemainingValue.remainingRewind ?? 0);

        if (remainingRewind > 0) {
          await sl<SharedPrefsManager>().saveUserInfo(user!.copyWith(
              getRemainingValue: getRemainingValue.copyWith(
                  remainingRewind: remainingRewind - 1)));

          _rewind = false;
          notifyListeners();

          HomeRepository().addRewind(data: {});
          return true;
        } else {
          Utils.printingAllPremiumInfo(context, isForRewind: true);
          return false;
        }

      case Constants.message:
        if (userBasicInfo.canMsgSend == null || userBasicInfo.canMsgSend != 0) {
          if (userBasicInfo.canMsgSend == null) {
            final remainingMessage =
                (getRemainingValue.remainingMessageLimit ?? 0);

            if (remainingMessage > 0) {
              showMessage(context, user!, userBasicInfo);
              return true;
            } else {
              Utils.printingAllPremiumInfo(context, isForMsg: true);
              return false;
            }
          } else {
            await userChatListProvider.navigateToSingleChats(
                context, ChatUser1.fromUserBasicRecord(userBasicInfo));

            return true;
          }
        } else {
          context.showSnackBar("You cannot send the message.");
          return false;
        }
      default:
        return false;
    }
  }

  void clearProvider() {
    _users = [];
    _dataState = DataState.Uninitialized;
  }

  void showMessage(
      BuildContext context, User loginUser, UserBasicInfo chatUser) {
    final messageController = TextEditingController();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  10.0,
                ),
              ),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 30),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 60,
                                width: 60,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: CacheImage(
                                    imageUrl:
                                        chatUser.images![chatUser.imageIndex],
                                    boxFit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8.0, left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "${chatUser.name} ${chatUser.age == null || chatUser.age == 0 ? '' : ", ${chatUser.age}"}",
                                        maxLines: 2,
                                      ),
                                      Text.rich(
                                        TextSpan(children: [
                                          TextSpan(
                                              text:
                                                  "${chatUser.hometown ?? ''} ${chatUser.calDistance?.split(" ").first != "0" ? chatUser.calDistance : ''}",
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ]),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFieldX(
                          controller: messageController,
                          hint: "Enter message",
                          maxlines: 5,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 60,
                        padding: const EdgeInsets.all(8.0),
                        child: FillBtnX(
                          onPressed: () async {
                            if (messageController.text.isNotEmpty) {
                              Navigator.pop(ctx);
                              await openChats(loginUser, chatUser,
                                  messageController.text, context);
                            } else {
                              context.showSnackBar("Please enter the message ");
                            }
                          },
                          text: "Send",
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -10,
                  top: -10,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.black87,
                      radius: 15,
                      child: Icon(
                        Icons.close,
                        size: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> openChats(User loginUser, UserBasicInfo otherUser,
      String message, BuildContext context) async {
    try {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (checkInternet) {
        Map<String, dynamic> apiResponse = await sl<ChatRepository>()
            .checkUserCanSendMsgOrNotAPICall(otherUser.id.toString());


        if (apiResponse[UiString.successText] &&
            apiResponse[UiString.dataText] != null) {
          final ChatUser1 chatUser1 =
              ChatUser1.fromMap(apiResponse[UiString.dataText]);

          if (chatUser1.isBothRead.toString() != '1') {
           Message? lastMsg = await sl<ChatRepository>().sendMessageWithPushNotification(
              chatUser1,
              message,
              0,
              loginUser: UserBasicInfo.fromUser(loginUser),
            );

            final getRemainingVal =
                sl<SharedPrefsManager>().getUserDataInfo()?.getRemainingValue ??
                    GetRemainingValue();

            await sl<SharedPrefsManager>().saveUserInfo(loginUser.copyWith(
                getRemainingValue: getRemainingVal.copyWith(
                    remainingMessageLimit:
                        (getRemainingVal.remainingMessageLimit ?? 0) - 1)));

            await context.read<UserChatListProvider>().updateSentRequestList(chatUser1: chatUser1.copyWith(lastMessage: lastMsg));
          } else {
            await context
                .read<UserChatListProvider>()
                .navigateToSingleChats(context, chatUser1);
          }
        } else {
          context.showSnackBar(apiResponse[UiString.messageText]);
        }
      }
    } on Exception catch (e) {
      context.showSnackBar(e.toString());
    }
  }

  Future<void> fetchResetUserSettingAfterSubscription() async {
    try {
      await HomeRepository().fetchResetUserSetting();
    } catch (e) {
      _dataState = DataState.Error;
    }
    notifyListeners();
  }
}

// // Unused
// class HomeProvider extends ChangeNotifier {
//   int _page = 1;
//   final bool _rewind = false;
//
//   List<UserBasicInfo> _users = [];
//
//   DataState _dataState = DataState.Uninitialized;
//
//   SwipableStackController _controller;
//
//   int get page => _page;
//
//   bool get rewind => _rewind;
//
//   List<UserBasicInfo> get users {
//     return [..._users];
//   }
//
//   DataState get dataState => _dataState;
//
//   SwipableStackController get controller => _controller;
//
//   HomeProvider(this._controller);
//
//   void _listenController() {
//     notifyListeners();
//   }
//
//   void setController(SwipableStackController value) {
//     _controller = value;
//     _controller.addListener(_listenController);
//     notifyListeners();
//   }
//
//   void disposeController() {
//     _controller.removeListener(_listenController);
//     _controller.dispose();
//   }
//
//   set page(int value) {
//     _page = value;
//     notifyListeners();
//   }
//
//   set dataState(DataState value) {
//     _dataState = value;
//     notifyListeners();
//   }
//
//   Future<void> fetchResetUserSettingAfterSubscription() async {
//     try {
//       if (_dataState != DataState.No_More_Data) {
//         final apiResponse = await HomeRepository().fetchResetUserSetting();
//         if (apiResponse[UiString.successText] &&
//             apiResponse[UiString.dataText] != null) {
//           // List<> tempList =
//           // List.from((apiResponse[UiString.dataText] as List).map((e) {
//           //   return BlockUser.fromJson(e);
//           // }
//           // ));
//           notifyListeners();
//         } else {
//           _dataState = DataState.Error;
//           notifyListeners();
//         }
//         // log(apiResponse.toString());
//       }
//     } catch (e) {
//       _dataState = DataState.Error;
//     }
//     notifyListeners();
//   }
//
//   Future<void> fetchUsers({int? page, String? userIds}) async {
//     User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();
//     try {
//       if (_dataState != DataState.No_More_Data) {
//         _dataState = (_dataState == DataState.Uninitialized || page == 1)
//             ? DataState.Initial_Fetching
//             : DataState.More_Fetching;
//
//         if (page != null) {
//           _page = page;
//         }
//         if (_page == 1) {
//           notifyListeners();
//         }
//
//         bool isCurrent = loginUser?.showCurrent ?? true;
//
//         Map<String, dynamic> apiResponse =
//             await HomeRepository().fetchUsers(data: {
//           "user_id": loginUser?.id,
//           "lat": isCurrent ? loginUser?.currentLat : loginUser?.findingLat,
//           "long": isCurrent ? loginUser?.currentLong : loginUser?.findingLong,
//           "is_current": isCurrent ? "1" : '0',
//           "page_number": _page,
//           "records_per_page": 10,
//           "user_ids": userIds
//         });
//
//         if (apiResponse[UiString.successText]) {
//           if (apiResponse[UiString.dataText] != null) {
//             List<UserBasicInfo> tempUsers =
//                 List.from((apiResponse[UiString.dataText] as List).map((e) {
//               return UserBasicInfo.fromJson(e);
//             }));
//
//             if (_page == 1) {
//               _users = [...tempUsers];
//             } else {
//               // if (tempUsers.isNotEmpty) {
//               _users.addAll(tempUsers);
//               // } else {
//               //   _dataState = DataState.No_More_Data;
//               // }
//             }
//             _dataState = DataState.Fetched;
//             _page += 1;
//
//             notifyListeners();
//           } else {
//             _dataState = DataState.Error;
//             notifyListeners();
//           }
//         } else {
//           _dataState = DataState.Error;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<void> updateVisitAction(BuildContext context, String action,
//       {UserBasicInfo? userBasicInfo, bool isDirectionUpdate = false}) async {
//     final User? user = sl<SharedPrefsManager>().getUserDataInfo();
//     final getRemainingValue = user?.getRemainingValue ?? GetRemainingValue();
//     final tempVal = userBasicInfo ?? users[controller.currentIndex];
//
//     switch (action) {
//       case Constants.liked:
//       case Constants.visitedAndLike:
//         final remainingLikeVal = (getRemainingValue.remainingLikes ?? 0);
//
//         if (remainingLikeVal > 0) {
//           await sl<SharedPrefsManager>().saveUserInfo(user!.copyWith(
//               getRemainingValue: getRemainingValue.copyWith(
//                   remainingLikes: remainingLikeVal - 1)));
//           context
//               .read<LikeListProvider>()
//               .updateVisitStatus(context, tempVal, action, user.id ?? '');
//
//           if (isDirectionUpdate) {
//             controller.next(swipeDirection: SwipeDirection.right);
//           }
//         } else {
//           // AlertService.showAlertMessage(context,
//           //     msg: "Please Take Subscription to like Users");
//           // AlertService.premiumPopUpService(context);
//
//           Utils.printingAllPremiumInfo(context, isForLike: true);
//         }
//         break;
//
//       case Constants.disliked:
//       case Constants.visitedAndDisliked:
//         final remainingDisLikeVal = (getRemainingValue.remainingDisLikes ?? 0);
//
//         if (remainingDisLikeVal > 0) {
//           await sl<SharedPrefsManager>().saveUserInfo(user!.copyWith(
//               getRemainingValue: getRemainingValue.copyWith(
//                   remainingDisLikes: remainingDisLikeVal - 1)));
//           context
//               .read<LikeListProvider>()
//               .updateVisitStatus(context, tempVal, action, user.id ?? '');
//
//           if (isDirectionUpdate) {
//             controller.next(swipeDirection: SwipeDirection.left);
//           }
//         } else {
//           // AlertService.showAlertMessage(context,
//           //     msg: "Please Take Subscription to like Users");
//           // AlertService.premiumPopUpService(context);
//           Utils.printingAllPremiumInfo(context, isForDislike: true);
//         }
//         break;
//
//       case Constants.visitor:
//         context
//             .read<LikeListProvider>()
//             .updateVisitStatus(context, tempVal, action, user?.id ?? '');
//         break;
//
//       case Constants.rewindStatus:
//         final remainingRewind = (getRemainingValue.remainingRewind ?? 0);
//
//         if (remainingRewind > 0) {
//           await sl<SharedPrefsManager>().saveUserInfo(user!.copyWith(
//               getRemainingValue: getRemainingValue.copyWith(
//                   remainingRewind: remainingRewind - 1)));
//           HomeRepository().addRewind(data: {});
//           controller.rewind();
//         } else {
//           // AlertService.showAlertMessage(context,
//           //     msg: "Please Take Subscription to like Users");
//           // AlertService.premiumPopUpService(context);
//
//           Utils.printingAllPremiumInfo(context, isForRewind: true);
//         }
//         break;
//     }
//   }
//
//   void updateImageIndexById(int index, int imageIndex) {
//     _users[index] = _users[index].copyWith(imageIndex: imageIndex);
//     notifyListeners();
//   }
//
//   void clearProvider() {
//     _page = 1;
//     _users = [];
//     _dataState = DataState.Uninitialized;
//   }
// }
