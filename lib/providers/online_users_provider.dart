import 'package:action_broadcast/action_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class OnlineUserProvider extends ChangeNotifier {
  OnlineUserProvider() : _chatRepository = sl<ChatRepository>();
  final ChatRepository _chatRepository;

  int _pageNumber = 1;
  final int _pageSize = 15;
  List<GetOnlineUsersInfo> onlineUsers = [];

  DataState loadingDataState = DataState.Uninitialized;

  // final _onlineUsersController = StreamController<List<GetOnlineUsersInfo>>.broadcast();
  // Stream<List<GetOnlineUsersInfo>> get onlineUsersStream => _onlineUsersController.stream;

  Future<void> getOnlineUsers({bool refresh = false}) async {
    try {
      if (refresh) {
        _pageNumber = 1;
        if (loadingDataState == DataState.Uninitialized) {
          loadingDataState = DataState.Initial_Fetching;
        } else {
          loadingDataState = DataState.Refreshing;
        }
        notifyListeners();
      }
      final users =
      await _chatRepository.getOnlineUsersPaginated(_pageNumber, _pageSize);
      if (users.isNotEmpty) {
        var tempList = List.from(onlineUsers);

        final userIdsList =
        List<String>.from(users.map((e) => e['user_id'].toString()));

        for (int i = 0; i < userIdsList.length; i++) {
          int index = tempList.indexWhere((element) =>
          element.userBasicInfo?.id.toString() == userIdsList[i]);
          if (index != -1) {
            tempList[index] = tempList[index].copyWith(
              isOnline: users[i][Constants.isOnlineKey].toString() == '1' ?
              Utils.isRecentlyOnline(users[i][Constants.lastOnlineAtKey])
                  : "0",
              lastOnlineAt: users[i][Constants.lastOnlineAtKey],
            );

            users.removeAt(i);
            userIdsList.removeAt(i--);
          }
        }

        if (userIdsList.isEmpty) {
          loadingDataState = DataState.No_More_Data;
          notifyListeners();
          return;
        }

        final apiResponse = await _chatRepository.getOnlineUsers(userIdsList);

        if (apiResponse.isNotEmpty) {
          if (_pageNumber == 1) {
            tempList.clear();
          }
          for (var element in apiResponse) {
            int index = users.indexWhere((u) =>
            u['user_id'].toString() == element.id.toString());

            if (index != -1) {
              final getData = GetOnlineUsersInfo(
                // isOnline: users[index][Constants.isOnlineKey],
                isOnline: users[index][Constants.isOnlineKey].toString() == '1'
                    ?
                Utils.isRecentlyOnline(users[index][Constants.lastOnlineAtKey])
                    : "0",
                lastOnlineAt: users[index][Constants.lastOnlineAtKey],
                userBasicInfo: element,
              );

              tempList.add(getData);
            }
          }
        }

        _pageNumber++;
        loadingDataState = DataState.Fetched;

        onlineUsers.clear();
        onlineUsers.addAll(List.from(tempList));

        //
        // onlineUsers.addAll(users);
        // _onlineUsersController.sink.add(onlineUsers); // Notify the UI
      } else {
        // Handle no more data available

        loadingDataState = DataState.No_More_Data;
      }
    } on Exception {
      // TODO
    } finally {
      notifyListeners();
    }
  }


}
