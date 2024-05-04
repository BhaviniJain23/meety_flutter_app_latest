import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/home_repo.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:provider/provider.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  LoadingState _profileState = LoadingState.Uninitialized;

  String _message = '';

  User? get user => _user;

  LoadingState get profileState => _profileState;

  String get message => _message;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> fetchUsers(
      {required String userId, required BuildContext context,bool refresh = false}) async {
    try {
      bool checkInternet =
          await sl<InternetConnectionService>().hasInternetConnection();

      if (checkInternet) {
        _profileState = LoadingState.Loading;
        notifyListeners();

        Map<String, dynamic> apiResponse =
            await UserRepository().getUserProfile(userId: userId);

        if (apiResponse[UiString.successText]) {
          if (apiResponse[UiString.dataText] != null) {
            log(User.fromJson(apiResponse[UiString.dataText]).toString());
            _profileState = LoadingState.Success;
            _user = User.fromJson(apiResponse[UiString.dataText]);

            if (_user?.id == sl<SharedPrefsManager>().getUserDataInfo()?.id &&
                _user != null) {
              await sl<SharedPrefsManager>().saveUserInfo(_user!);
              // ignore: use_build_context_synchronously
              Provider.of<EditUserProvider>(context, listen: false)
                  .setUser(_user!);
            }
            notifyListeners();
          } else {
            _profileState = LoadingState.Failure;
            _message = apiResponse[UiString.messageText];
            notifyListeners();
          }
        } else {
          _profileState = LoadingState.Failure;
          notifyListeners();
        }
      } else {
        _profileState = LoadingState.NoInternet;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
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

  Future<Either<String,bool>> blockUser(
      {required String loginUserId, required String userId}) async {
    try {
      Map<String, dynamic> apiResponse = await UserRepository().blockUser(
        userId: userId,
      );
      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.messageText] != null) {
        return const Right(true);
      }else{
        return Left(apiResponse[UiString.messageText]);
      }
    } catch (_) {}
    return const Left(UiString.error);

  }

  Future<void> updateVisitorStatus(String status) async {
    User? loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    try {
      HomeRepository().updateVisitorStatus(data: {
        "user_id": loginUser?.id,
        "visited_id": _user?.id.toString(),
        "status": status
      });
    } catch (e) {
      rethrow;
    }
  }
}
