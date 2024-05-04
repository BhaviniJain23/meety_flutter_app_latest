// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/chat_message.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/screens/home/tabs/chat/one_to_one_chat_screen.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class UserChatListProvider extends ChangeNotifier {
  final int _pageSize = 100;

  UserChatListProvider() : _chatRepository = sl<ChatRepository>();
  final ChatRepository _chatRepository;
  int _chatPage = 1;
  int _chatRequestPage = 1;
  int _chatSentPage = 1;

  String _visitChannelId = '';
  String totalCountForRequest = '0';
  String totalCountForSent = '0';

  List<ChatUser> _chatUsers = [];
  List<ChatUser1> _chatUsers1 = [];

  List<ChatUser1> _requestsUser = [];
  List<ChatUser1> _sentUser = [];

  DataState _chatLoadingState = DataState.Uninitialized;
  DataState _requestLoadingState = DataState.Uninitialized;
  DataState _sentLoadingState = DataState.Uninitialized;

  List<ChatUser> get chatUser => _chatUsers;
  List<ChatUser1> get chatUser1 => _chatUsers1;
  List<ChatUser1> get requestsUser => _requestsUser;
  List<ChatUser1> get sentUser => _sentUser;

  DataState get chatLoadingState => _chatLoadingState;
  DataState get requestLoadingState => _requestLoadingState;
  DataState get sentLoadingState => _sentLoadingState;

  String get visitChannelId => _visitChannelId;

  set chatUsers1(List<ChatUser1> value) {
    _chatUsers1 = value;
  }

  set visitChannelId(String value) {
    _visitChannelId = value;
    // if (value.isNotEmpty) {
    //   updateReadCountInList(
    //       _chatUsers.indexWhere((element) => element.channelName == value),
    //       isReading: true);
    // }
    sl<ChatRepository>().setUserOnlineStatus(
        isOnline: Constants.onlineState, isChannelOn: value);
    notifyListeners();
  }

  void updatePages(int pageNo) {
    _chatPage = pageNo;
    notifyListeners();
  }

  Future<void> updateUserListFromMessage(
      {String? channelId,
      Message? message,
      ChatUser? user,
      String? unreadCount}) async {
    if (user != null) {
      final index = _chatUsers.indexWhere((e) => e.id == user.id);
      var tempUsers = List.from(_chatUsers);
      if (index == -1) {
        // final tempUsers = List.from(_chatUsers..add(user));
        tempUsers.add(user.copyWith(unreadCount: '1'));
      } else {
        tempUsers[index] = user.copyWith(
            unreadCount:
                '${unreadCount ?? int.parse(tempUsers[index].unreadCount) + 1}');
      }

      tempUsers.sortByCreatedAt();
      _chatUsers = List.from(tempUsers);
    } else if (channelId != null && message != null) {
      final index =
          _chatUsers.indexWhere((user) => user.channelName == channelId);
      if (index != -1) {
        _chatUsers[index] = _chatUsers[index].copyWith(lastMsg: message);
        _chatUsers = List.from(_chatUsers);
      }
    }
    notifyListeners();
    await sl<SharedPrefsManager>().saveChatMessages(_chatUsers);
  }

  Future<void> updateReadCountInList(int index,
      {required bool isReading}) async {
    _chatUsers[index] = _chatUsers[index].copyWith(
        unreadCount: isReading
            ? '0'
            : '${(int.tryParse(_chatUsers[index].unreadCount) ?? 0) + 1}');
    _chatUsers = List.from(_chatUsers);
    await sl<SharedPrefsManager>().saveChatMessages(_chatUsers);
    notifyListeners();
  }

  Future<void> searchChats(String query) async {
    if (query.isEmpty) {
      _chatPage = 1;
      await getUserChatList();
    } else {
      _chatLoadingState = DataState.Searching;
      notifyListeners();
      List<ChatUser> searchChatUser = List.from(_chatUsers
          .where((e) => '${e.fname} ${e.lname ?? ''}'.contains(query)));
      _chatUsers = [...searchChatUser];
      notifyListeners();
    }
  }

  Future<void> fetchChats() async {
    getUserChatList(refresh: true);
    getUserRequestList(refresh: true);
    getUserSentList(refresh: true);
  }

  Future<void> getUserChatList({bool refresh = false}) async {
    try {
      if (refresh) {
        _chatPage = 1;
        if (_chatLoadingState == DataState.Uninitialized) {
          _chatLoadingState = DataState.Initial_Fetching;
        } else {
          _chatLoadingState = DataState.Refreshing;
        }
      } else {
        _chatLoadingState = DataState.More_Fetching;
      }

      notifyListeners();

      final apiResponse =
          await _chatRepository.getUserChatList(_chatPage, _pageSize);

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        if ((apiResponse[UiString.dataText] as List).isNotEmpty) {
          List<ChatUser1> tempUsers = List.from(
              (apiResponse[UiString.dataText] as List)
                  .map((e) => ChatUser1.fromMap(e)));

          if (_chatPage == 1 || refresh) {
            _chatUsers1 = List<ChatUser1>.from(tempUsers);
          } else {
            _chatUsers1.addAll(tempUsers);
          }
          if (_pageSize <= tempUsers.length) {
            _chatPage++;
            _chatLoadingState = DataState.Fetched;
          } else {
            _chatLoadingState = DataState.No_More_Data;
          }
        } else {
          if (_chatPage == 1 || refresh) {
            _chatUsers1 = List<ChatUser1>.from([]);
            _chatLoadingState = DataState.Fetched;
          }
        }

        sl<SharedPrefsManager>().saveUserChatMessage(_chatUsers1);
      } else {
        _chatUsers1 = List.from(sl<SharedPrefsManager>().getUserChatMessages());
        _chatLoadingState = DataState.Fetched;
      }
    } on Exception {
      // TODO
    } finally {
      notifyListeners();
    }
  }

  Future<void> getUserRequestList({bool refresh = false}) async {
    try {
      if (refresh) {
        _chatRequestPage = 1;
        if (_requestLoadingState == DataState.Uninitialized) {
          _requestLoadingState = DataState.Initial_Fetching;
        } else {
          _requestLoadingState = DataState.Refreshing;
        }
      } else {
        _requestLoadingState = DataState.More_Fetching;
      }
      notifyListeners();

      final apiResponse = await _chatRepository.getUserMessageRequestList(
          _chatRequestPage, _pageSize);

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        final dataResponse = apiResponse[UiString.dataText];

        if (dataResponse.containsKey("messageData") &&
            (dataResponse["messageData"] as List).isNotEmpty) {
          List<ChatUser1> tempUsers = List.from(
              (dataResponse["messageData"] as List)
                  .map((e) => ChatUser1.fromMap(e)));

          // tempUsers.sortByCreatedAt();

          if (_chatRequestPage == 1 || refresh) {
            _requestsUser = List<ChatUser1>.from(tempUsers);
          } else {
            _requestsUser.addAll(tempUsers);
          }
          if (_pageSize <= tempUsers.length) {
            _chatRequestPage++;
            _requestLoadingState = DataState.Fetched;
          } else {
            _requestLoadingState = DataState.No_More_Data;
          }
        } else {
          _requestsUser = List.from([]);
          _requestLoadingState = DataState.Fetched;
        }

        if (dataResponse.containsKey("count")) {
          totalCountForRequest = dataResponse["count"].toString();
        } else {
          totalCountForRequest = _requestsUser.length.toString();
        }
        sl<SharedPrefsManager>().saveUserMessageRequest(_requestsUser);
      } else {
        _requestsUser =
            List.from(sl<SharedPrefsManager>().getUserMessagesRequest());
        _requestLoadingState = DataState.Fetched;
        totalCountForRequest = _requestsUser.length.toString();
      }
    } on Exception {
      // TODO
    } finally {
      notifyListeners();
    }
  }

  Future<void> getUserSentList({bool refresh = false}) async {
    try {
      if (refresh) {
        _chatSentPage = 1;
        if (_sentLoadingState == DataState.Uninitialized) {
          _sentLoadingState = DataState.Initial_Fetching;
        } else {
          _sentLoadingState = DataState.Refreshing;
        }
      } else {
        _sentLoadingState = DataState.More_Fetching;
      }
      notifyListeners();

      final apiResponse =
          await _chatRepository.getSentMessagesList(_chatSentPage, _pageSize);

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        final dataResponse = apiResponse[UiString.dataText];

        if (dataResponse.containsKey("messageData") &&
            (dataResponse["messageData"] as List).isNotEmpty) {
          List<ChatUser1> tempUsers = List.from(
              (dataResponse["messageData"] as List)
                  .map((e) => ChatUser1.fromMap(e)));

          tempUsers.sortByCreatedAt();

          if (_chatSentPage == 1 || refresh) {
            _sentUser = List<ChatUser1>.from(tempUsers);
          } else {
            _sentUser.addAll(tempUsers);
          }
          if (_pageSize <= tempUsers.length) {
            _chatSentPage++;
            _sentLoadingState = DataState.Fetched;
          } else {
            _sentLoadingState = DataState.No_More_Data;
          }
        } else {
          _sentUser = List.from([]);
          _sentLoadingState = DataState.Fetched;
        }
        if (dataResponse.containsKey("count")) {
          totalCountForSent = dataResponse["count"].toString();
        } else {
          totalCountForSent = _sentUser.length.toString();
        }
        sl<SharedPrefsManager>().saveUserMessageSent(_sentUser);
      } else {
        _sentUser = List.from(sl<SharedPrefsManager>().getUserSentMessages());
        _sentLoadingState = DataState.Fetched;
        totalCountForSent = _sentUser.length.toString();
      }
    } on Exception {
      // TODO
    } finally {
      notifyListeners();
    }
  }

  Future<void> navigateToSingleChats(
      BuildContext context, ChatUser1 chatUser) async {
    final loggedInUser =
        UserBasicInfo.fromUser(sl<SharedPrefsManager>().getUserDataInfo()!);

    int index = _chatUsers1.indexWhere((element) =>
        element.channelId == chatUser.channelId &&
        element.userRecord?.id == element.userRecord?.id);

    if (index != -1 && (_chatUsers1[index].totalUnreadMessage ?? 0) > 0) {
      updateUnReadCount(index: index, isChatList: true, isToZero: true);
    } else if (index == -1) {
      int requestIndex = _requestsUser.indexWhere((element) =>
          element.channelId == chatUser.channelId &&
          element.userRecord?.id == element.userRecord?.id);

      if (requestIndex != -1 &&
          (_requestsUser[requestIndex].totalUnreadMessage ?? 0) > 0) {
        updateUnReadCount(
            index: requestIndex, isChatList: false, isToZero: true);
      }
    }
    _visitChannelId = chatUser.channelId.toString();
    await sl<NavigationService>().navigateTo(
      RoutePaths.oneToOneScreen,
      nextScreen: OneToOneChatScreen.create(context, chatUser, loggedInUser),
    );
    _visitChannelId = "";
    notifyListeners();
  }

  Future<void> updateUnReadCount(
      {required bool isChatList,
      required int index,
      required bool isToZero}) async {
    if (isChatList) {
      _chatUsers1[index] = _chatUsers1[index].copyWith(
          totalUnreadMessage:
              isToZero ? 0 : (_chatUsers1[index].totalUnreadMessage ?? 0) + 1);

      _chatUsers1 = List.from(_chatUsers1.unique((X) => X.userRecord?.id));
      await sl<SharedPrefsManager>().saveUserChatMessage(_chatUsers1);
    } else {
      _requestsUser[index] = _requestsUser[index].copyWith(
          totalUnreadMessage: isToZero
              ? 0
              : (_requestsUser[index].totalUnreadMessage ?? 0) + 1);

      _requestsUser = List.from(_requestsUser.unique((X) => X.userRecord?.id));
      await sl<SharedPrefsManager>().saveUserMessageRequest(_requestsUser);
    }
    notifyListeners();
  }

  Future<void> updateSentRequestList({
    required ChatUser1 chatUser1,
  }) async {
    _sentUser = List.from(_sentUser
      ..insert(0, chatUser1)
      ..unique((X) => X.userRecord?.id)
      ..sortByCreatedAt());

    await sl<SharedPrefsManager>().saveUserMessageSent(_sentUser);

    totalCountForSent = ((int.tryParse(totalCountForSent) ?? 0) + 1).toString();

    notifyListeners();
  }

  Future<void> updateChatUserLastMessage(
      {required ChatUser1 chatUser1, int? unreadCount}) async {
    try {
      int index = _chatUsers1.indexWhere((element) =>
          element.channelId == chatUser1.channelId &&
          element.userRecord?.id == element.userRecord?.id);

      if (chatUser1.isBothRead == 1) {
        updateLastMessageInList(
            chatUser1: chatUser1,
            index: index,
            isChatList: true,
            unreadCount: unreadCount);
      } else if (chatUser1.isBothRead == 0) {
        int requestIndex = _requestsUser.indexWhere((element) =>
            element.channelId == chatUser1.channelId &&
            element.userRecord?.id == element.userRecord?.id);

        updateLastMessageInList(
            chatUser1: chatUser1,
            index: requestIndex,
            isChatList: false,
            unreadCount: unreadCount);
      }
    } on Exception catch (_) {}
  }

  Future<void> updateLastMessageInList(
      {required bool isChatList,
      required int index,
      required ChatUser1 chatUser1,
      int? unreadCount}) async {

    if (isChatList) {
      if (index != -1) {
        _chatUsers1[index] = _chatUsers1[index].copyWith(
            totalUnreadMessage:
                unreadCount ?? (_chatUsers1[index].totalUnreadMessage ?? 0) + 1,
            lastMessage: chatUser1.lastMessage);

        _chatUsers1 = List.from(
            _chatUsers1.unique((X) => X.userRecord?.id)..sortByCreatedAt());
      } else {
        _chatUsers1 = List.from(_chatUsers1
          ..insert(0, chatUser1)
          ..unique((X) => X.userRecord?.id)
          ..sortByCreatedAt());

        int? index = _sentUser.indexWhere(
            (element) => element.userRecord?.id == chatUser1.userRecord?.id);
        if (index != -1) {
          _sentUser.removeAt(index);
          await sl<SharedPrefsManager>().saveUserMessageSent(_sentUser);
        }

        int requestIndex = _requestsUser.indexWhere(
            (element) => element.userRecord?.id == chatUser1.userRecord?.id);

        if (requestIndex != -1) {
          _requestsUser.removeAt(requestIndex);
          await sl<SharedPrefsManager>().saveUserMessageRequest(_requestsUser);
        }
      }
      await sl<SharedPrefsManager>().saveUserChatMessage(_chatUsers1);
    } else {
      if (index != -1) {
        _requestsUser[index] = _requestsUser[index].copyWith(
            totalUnreadMessage: unreadCount ??
                (_requestsUser[index].totalUnreadMessage ?? 0) + 1,
            lastMessage: chatUser1.lastMessage);

        _requestsUser = List.from(
            _requestsUser.unique((X) => X.userRecord?.id)..sortByCreatedAt());
      } else {
        _requestsUser = List.from(_requestsUser
          ..insert(0, chatUser1)
          ..unique((X) => X.userRecord?.id)
          ..sortByCreatedAt());

        totalCountForRequest =
            "${(int.tryParse(totalCountForRequest) ?? 0) + 1}";
        notifyListeners();
      }
      await sl<SharedPrefsManager>().saveUserMessageRequest(_requestsUser);
    }
    notifyListeners();
  }

  void clearProvider() {
    _chatPage = 1;
    _visitChannelId = '';
    _chatUsers = [];
    _chatUsers1 = [];
    _chatLoadingState = DataState.Uninitialized;
    _requestLoadingState = DataState.Uninitialized;
    _sentLoadingState = DataState.Uninitialized;
  }
}
