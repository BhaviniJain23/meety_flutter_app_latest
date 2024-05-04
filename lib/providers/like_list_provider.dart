// ignore_for_file: unnecessary_getters_setters, use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/home_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/providers/online_users_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

import '../constants/enums.dart';
import '../constants/ui_strings.dart';

class LikeListProvider with ChangeNotifier {
  late TabController _controller;

  final recordSize = 10;

  int _totalLikeCounts = 1;

  int _likePageNo = 1;
  int _likeSentPageNo = 1;
  int _visitorPageNo = 1;
  int _matchPageNo = 1;

  bool _isMyLikesListShow = false;
  bool _isMySentLikesListShow = false;
  bool _isMyVisitorListShow = false;

  bool get isMyLikesListShow => _isMyLikesListShow;
  bool get isMySentLikesListShow => _isMySentLikesListShow;
  bool get isMyVisitorListShow => _isMyVisitorListShow;

  List<UserBasicInfo> _likeList = [];
  List<UserBasicInfo> _likeSentList = [];
  List<UserBasicInfo> _visitorList = [];
  List<UserBasicInfo> _matchesList = [];

  DataState _likeState = DataState.Uninitialized;
  DataState _likeSentState = DataState.Uninitialized;
  DataState _visitorState = DataState.Uninitialized;
  DataState _matchLoadingState = DataState.Uninitialized;

  String _likeMessage = '';
  String _likeSentMessage = '';
  String _visitorMessage = '';

  List<UserBasicInfo> get matchesList {
    return [..._matchesList.unique((x) => x.id)];
  }

  List<UserBasicInfo> get likeList {
    return [..._likeList.unique((x) => x.id)];
  }

  List<UserBasicInfo> get likeSentList {
    return [..._likeSentList.unique((x) => x.id)];
  }

  List<UserBasicInfo> get visitorList {
    return [..._visitorList.unique((x) => x.id)];
  }

  int get totalLikeCounts => _totalLikeCounts;

  DataState get likeState => _likeState;
  DataState get likeSentState => _likeSentState;
  DataState get visitorState => _visitorState;
  DataState get matchLoadingState => _matchLoadingState;

  String get likeMessage => _likeMessage;
  String get likeSentMessage => _likeSentMessage;
  String get visitorMessage => _visitorMessage;

  set totalLikeCounts(int value) {
    _totalLikeCounts = value;
    notifyListeners();
  }

  set visitorMessage(String value) {
    _visitorMessage = value;
    notifyListeners();
  }

  set likeSentMessage(String value) {
    _likeSentMessage = value;
    notifyListeners();
  }

  set likeMessage(String value) {
    _likeMessage = value;
    notifyListeners();
  }

  set visitorState(DataState value) {
    _visitorState = value;
    notifyListeners();
  }

  set likeSentState(DataState value) {
    _likeSentState = value;
    notifyListeners();
  }

  set likeState(DataState value) {
    _likeState = value;
    notifyListeners();
  }

  set matchLoadingState(DataState value) {
    _matchLoadingState = value;
    notifyListeners();
  }

  set matchesList(List<UserBasicInfo> value) {
    _matchesList = value;
    _matchesList.unique((x) => x.id);

    notifyListeners();
  }

  set visitorList(List<UserBasicInfo> value) {
    _visitorList = value;
    _visitorList.unique((x) => x.id);
    notifyListeners();
  }

  set likeSentList(List<UserBasicInfo> value) {
    _likeSentList = value;
    _likeSentList.unique((x) => x.id);
    notifyListeners();
  }

  set likeList(List<UserBasicInfo> value) {
    _likeList = value;
    _likeList.unique((x) => x.id);
    notifyListeners();
  }

  set visitorPageNo(int value) {
    _visitorPageNo = value;
    notifyListeners();
  }

  set likeSentPageNo(int value) {
    _likeSentPageNo = value;
    notifyListeners();
  }

  set likePageNo(int value) {
    _likePageNo = value;
    notifyListeners();
  }

  TabController get controller => _controller;

  void setController(TabController controller) {
    _controller = controller;
    notifyListeners();
  }

  Future<void> updateVisitStatus(
    BuildContext context,
    UserBasicInfo userBasicInfo,
    String status,
    String loginId,
  {
    required LikeListProvider likeListProvider,
    required OnlineUserProvider onlineUserProvider,
    required UserChatListProvider userChatListProvider,
    required HomeProvider homeController ,
  }
  ) async {
    try {
      final apiResponse = await HomeRepository().updateVisitorStatus(data: {
        "user_id": loginId,
        "visited_id": userBasicInfo.id,
        "status":
            status == Constants.unmatchStatus ? Constants.disliked : status
      });

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        var newVisitStatus =
            apiResponse[UiString.dataText]['visit_status'].toString();
        final newUserBasicInfo =
            userBasicInfo.copyWith(visitStatus: newVisitStatus);

        int visitedIndex = _visitorList
            .indexWhere((element) => element.id == userBasicInfo.id);

        int likedIndex =
            _likeList.indexWhere((element) => element.id == userBasicInfo.id);

        if (visitedIndex != -1) {
          _visitorList[visitedIndex] = newUserBasicInfo;
        }

        if (likedIndex != -1) {
          if (newUserBasicInfo.visitStatus.toString() !=
              Constants.matchStatus) {
            _likeList[likedIndex] = newUserBasicInfo;
          } else {
            _likeList.removeAt(likedIndex);
            _totalLikeCounts -= 1;
          }
        }


        switch (newVisitStatus.toString()) {
          case Constants.liked:
          case Constants.visitedAndLike:
            if (isMySentLikesListShow) {
              int likedIndex = _likeSentList
                  .indexWhere((element) => element.id == userBasicInfo.id);
              if (likedIndex == -1) {
                _likeSentList.insert(0, newUserBasicInfo);
              } else {
                _likeSentList.removeAt(likedIndex);
                _likeSentList.insert(0, newUserBasicInfo);
              }
            } else {
              _likeSentList.clear();
              _likeSentList.add(newUserBasicInfo);
            }
            break;

          case Constants.disliked:
            // if (isMySentLikesListShow) {
            try {
              int likedIndex = _likeSentList
                  .indexWhere((element) => element.id == userBasicInfo.id);
              if (likedIndex != -1) {
                _likeSentList.removeAt(likedIndex);
              }
            } catch (_) {
            }

            if (status == Constants.unmatchStatus) {
              int matchIndex = _matchesList
                  .indexWhere((element) => element.id == userBasicInfo.id);

              if (matchIndex != -1) {
                _matchesList.removeAt(matchIndex);
              }
            }
            // }
            break;

          case Constants.matchStatus:
            // if (isMySentLikesListShow) {

            try {
              int sentLikedIndex = _likeSentList
                  .indexWhere((element) => element.id == userBasicInfo.id);
              if (sentLikedIndex != -1) {
                _likeSentList.removeAt(sentLikedIndex);
              }
            } catch (_) {}
            // }

            Utils.showMatchPopUp(
                context, likeListProvider, userBasicInfo, '');
            break;
        }

        homeController.updateAllList(
              isUpdateStatus: true,
              userBasicInfo: newUserBasicInfo,
          likeListProvider1: likeListProvider,
          userChatListProvider1: userChatListProvider,
          onlineUserProvider1: onlineUserProvider,
            );


      }
    } catch (e) {
      if (kDebugMode) {
        print("KDebugMode:$e");
      }
    } finally {
      notifyListeners();
    }
  }

  void fetchingInitialData() {
    _likeState = DataState.Uninitialized;
    _likeSentState = DataState.Uninitialized;
    _visitorState = DataState.Uninitialized;
    _matchLoadingState = DataState.Uninitialized;
    User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();

    print(loginUser != null );
    print(loginUser?.pastSubscription != null);
    if (loginUser != null && loginUser.subscription != null) {
      /// subscription change
      for (var mySubVal in loginUser.subscription!) {
        if (!isMyLikesListShow && mySubVal.likelist == '1') {
          _isMyLikesListShow = true;
        }
        if (!isMySentLikesListShow &&
            (int.tryParse(mySubVal.likeSentList ?? '0') ?? 0) > 0) {
          _isMySentLikesListShow = true;
        }
        if (!isMyVisitorListShow &&
            (int.tryParse(mySubVal.visitorlist ?? '0') ?? 0) > 0) {
          _isMyVisitorListShow = true;
        }
      }
    }else{
      _isMyLikesListShow = false;
      _isMySentLikesListShow = false;
      _isMyVisitorListShow = false;
    }
      notifyListeners();
    
    fetchLikes();
    fetchLikesSent();
    fetchVisitors();
    fetchMatches();
  }

  Future<void> fetchTotalCount() async {
    try {
      Map<String, dynamic> apiResponse =
          await HomeRepository().getTotalCountForLikes();

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        totalLikeCounts = apiResponse[UiString.dataText]['total_likes'];
      } else {
        totalLikeCounts = 0;
      }
    } catch (e) {
      if (kDebugMode) {
        // print(e);
      }
    }
  }

  Future<void> fetchLikes() async {
    try {
      if (_likeState != DataState.No_More_Data) {
        if (_likePageNo == 1) {
          fetchTotalCount();
        }
        if (_likeState != DataState.Refreshing) {
          _likeState = (_likeState == DataState.Uninitialized)
              ? DataState.Initial_Fetching
              : DataState.More_Fetching;
        }
        Map<String, dynamic> apiResponse =
            await HomeRepository().fetchLikes(data: {
          "page_number": _likePageNo.toString(),
          "records_per_page": recordSize,
        });

        if (apiResponse[UiString.successText] &&
            apiResponse[UiString.dataText] != null) {
          List<UserBasicInfo> tempUsers = List.from(
              (apiResponse[UiString.dataText] as List)
                  .map((e) => UserBasicInfo.fromJson(e)));

          if (_likeState == DataState.Initial_Fetching ||
              _likeState == DataState.Refreshing) {
            _likeList = [...tempUsers];
          } else {
            _likeList.addAll(tempUsers);
          }
          if (tempUsers.length >= recordSize) {
            _likePageNo += 1;
            _likeState = DataState.Fetched;
          } else {
            _likeState = DataState.No_More_Data;
          }
          notifyListeners();
        } else {
          _likeState = DataState.Error;
          _likeMessage = apiResponse[UiString.messageText];
          notifyListeners();
        }
      }
    } on Exception catch (e) {
      _likeState = DataState.Error;
      _likeMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchMatches({bool refresh = false}) async {
    try {
      if (_matchLoadingState != DataState.No_More_Data || refresh) {
        if (refresh) {
          _matchLoadingState = DataState.Refreshing;
          _matchPageNo = 1;
          notifyListeners();
        } else {
          _matchLoadingState = (_matchLoadingState == DataState.Uninitialized)
              ? DataState.Initial_Fetching
              : DataState.More_Fetching;
          notifyListeners();
        }
        Map<String, dynamic> apiResponse =
            await HomeRepository().fetchMatches(data: {
          "page_number": _matchPageNo.toString(),
          "records_per_page": recordSize,
        });

        if (apiResponse[UiString.successText] &&
            apiResponse[UiString.dataText] != null) {
          List<UserBasicInfo> tempUsers = List.from(
              (apiResponse[UiString.dataText] as List)
                  .map((e) => UserBasicInfo.fromJson(e)));

          if (_matchLoadingState == DataState.Initial_Fetching ||
              _matchLoadingState == DataState.Refreshing) {
            _matchesList = [...tempUsers];
          } else {
            _matchesList.addAll(tempUsers);
          }
          // print(tempUsers.length >= recordSize);
          if (tempUsers.length >= recordSize) {
            _matchPageNo += 1;
            _matchLoadingState = DataState.Fetched;
          } else {
            _matchLoadingState = DataState.No_More_Data;
          }
          notifyListeners();
        } else {
          _matchLoadingState = DataState.Error;
          // _likeMessage = apiResponse[UiString.messageText];
          notifyListeners();
        }
      }
    } on Exception {
      _matchLoadingState = DataState.Error;
      // _likeMessage = e.toString();
      notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchLikesSent() async {
    try {
      if (_likeSentState != DataState.No_More_Data) {
        if (_likeSentState != DataState.Refreshing) {
          _likeSentState = (_likeSentState == DataState.Uninitialized)
              ? DataState.Initial_Fetching
              : DataState.More_Fetching;
        }
        Map<String, dynamic> apiResponse =
            await HomeRepository().fetchLikesSent(data: {
          "page_number": _likeSentPageNo.toString(),
          "records_per_page": recordSize,
        });
        if (apiResponse[UiString.successText] &&
            apiResponse[UiString.dataText] != null) {
          List<UserBasicInfo> tempUsers = List.from(
              (apiResponse[UiString.dataText] as List)
                  .map((e) => UserBasicInfo.fromJson(e)));

          if (_likeSentState == DataState.Initial_Fetching ||
              _likeSentState == DataState.Refreshing) {
            _likeSentList = [...tempUsers];
          } else {
            _likeSentList.addAll(tempUsers);
          }
          if (tempUsers.length >= recordSize) {
            _likeSentPageNo += 1;
            _likeSentState = DataState.Fetched;
          } else {
            _likeSentState = DataState.No_More_Data;
          }
          notifyListeners();
        } else {
          _likeSentState = DataState.Error;
          _likeSentMessage = apiResponse[UiString.messageText];
          notifyListeners();
        }
      }
    } on Exception catch (e) {
      _likeSentState = DataState.Error;
      _likeSentMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchVisitors() async {
    try {
      if (_visitorState != DataState.No_More_Data) {
        if (_visitorState != DataState.Refreshing) {
          _visitorState = (_visitorState == DataState.Uninitialized)
              ? DataState.Initial_Fetching
              : DataState.More_Fetching;
        }
        Map<String, dynamic> apiResponse =
            await HomeRepository().fetchVisitors(data: {
          "page_number": _visitorPageNo.toString(),
          "records_per_page": recordSize,
        });
        if (apiResponse[UiString.successText] &&
            apiResponse[UiString.dataText] != null) {
          List<UserBasicInfo> tempUsers = List.from(
              (apiResponse[UiString.dataText] as List)
                  .map((e) => UserBasicInfo.fromJson(e)));

          if (_visitorState == DataState.Initial_Fetching ||
              _visitorState == DataState.Refreshing) {
            _visitorMessage =
                sl<SharedPrefsManager>().getUserDataInfo()?.isProfileVerified ==
                        '0'
                    ? apiResponse[UiString.messageText]
                    : '';
            _visitorList = [...tempUsers];
          } else {
            _visitorList.addAll(tempUsers);
          }
          if (tempUsers.length >= recordSize) {
            _visitorPageNo += 1;
            _visitorState = DataState.Fetched;
          } else {
            _visitorState = DataState.No_More_Data;
          }
          notifyListeners();
        } else {
          _visitorState = DataState.Error;
          _visitorMessage = apiResponse[UiString.messageText];
          notifyListeners();
        }
      }
    } on Exception catch (e) {
      _visitorState = DataState.Error;
      _visitorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchingNextPage(int index) async {
    if (index == 0) {
      await fetchLikes();
    } else if (index == 1) {
      await fetchLikesSent();
    } else {
      await fetchVisitors();
    }
  }

  void clearProvider() {
    _likePageNo = 1;
    _likeSentPageNo = 1;
    _visitorPageNo = 1;
    _likeList = [];
    _likeSentList = [];
    _visitorList = [];
    _likeState = DataState.Uninitialized;
    _likeSentState = DataState.Uninitialized;
    _visitorState = DataState.Uninitialized;
    _likeMessage = '';
    _likeSentMessage = '';
    _visitorMessage = '';
    _matchesList = [];
    _matchPageNo = 1;
    _matchLoadingState = DataState.Uninitialized;
  }
}
