import 'dart:developer';

import 'package:flutter/material.dart';
import '../constants/enums.dart';
import '../constants/ui_strings.dart';
import '../data/repository/user_repo.dart';
import '../models/user.dart';
import '../services/shared_pref_manager.dart';
import '../services/singleton_locator.dart';

class LoginUserProvider extends ChangeNotifier {
  User? _loginUser;
  int profileCompletePercentage = 0;
  final DataState _viewProfileShow = DataState.Uninitialized;

  User? get user => _loginUser;

  void setLoginUser(User? value) {
    _loginUser = value;
  }

  String _message = '';

  LoadingState _loginState = LoadingState.Uninitialized;

  LoadingState get profileState => _loginState;

  String get message => _message;

  DataState get viewProfileShow => _viewProfileShow;

  LoginUserProvider({User? loginUser}) : _loginUser = loginUser;

  void setUser(User? user) {
    _loginUser = user;
    notifyListeners();
  }

  Future<void> fetchLoginUser({bool refresh = false}) async {
    try {
      if (refresh) {
        if (_loginState == LoadingState.Uninitialized) {
          _loginState = LoadingState.Success;
        } else {
          _loginState = LoadingState.Loading;
        }
      } else {
        _loginState = LoadingState.NoInternet;
      }
      String userId =
          sl<SharedPrefsManager>().getUserDataInfo()?.id.toString() ?? '0';
      _loginState = LoadingState.Loading;
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().getUserProfile(userId: userId);
      // log("getUserProfile apiResponse: ${apiResponse.toString()}");

      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null) {
          _loginState = LoadingState.Success;
          _loginUser = User.fromJson(apiResponse[UiString.dataText]);
          await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        } else {
          _loginState = LoadingState.Failure;
          _message = apiResponse[UiString.messageText];
        }
      } else {
        _loginState = LoadingState.Failure;
      }
      // log("_loginState: ${_loginState.toString()}");
    } catch (_) {
    } finally {
      profileCompleteProgress();

      notifyListeners();
    }
  }

  void profileCompleteProgress() {
    int profileCompletePer = 0;
    if (user?.email != null && user!.email!.isNotEmpty) {
      profileCompletePer = profileCompletePer + 2;
    }
    if (user?.fname != null && user!.fname!.isNotEmpty) {
      profileCompletePer += 2;
    }
    if (user?.lname != null && user!.lname!.isNotEmpty) {
      profileCompletePer += 2;
    }
    if (user?.dob != null && user!.dob!.isNotEmpty) {
      profileCompletePer += 5;
    }
    if (user?.gender != null && user!.gender!.isNotEmpty) {
      profileCompletePer += 2;
    }
    if (user?.sexOrientation != null && user!.sexOrientation!.isNotEmpty) {
      profileCompletePer += 2;
    }
    if (user?.lookingFor != null && user!.lookingFor!.isNotEmpty) {
      profileCompletePer += 4;
    }
    if (user?.futurePlan != null && user!.futurePlan!.isNotEmpty) {
      profileCompletePer += 7;
    }
    if (user?.interest != null && user!.interest!.isNotEmpty) {
      profileCompletePer += 7;
    }
    if (user?.education != null && user!.education!.isNotEmpty) {
      profileCompletePer += 5;
    }
    if (user?.images != null && user!.images!.isNotEmpty) {
      profileCompletePer += 9;
    }
    if (user?.about != null && user!.about!.isNotEmpty) {
      profileCompletePer += 7;
    }

    //till 54 %
    if (user?.occupation != null && user!.occupation!.isNotEmpty) {
      profileCompletePer += 10;
    }
    if (user?.languageKnown != null && user!.languageKnown!.isNotEmpty) {
      profileCompletePer += 4;
    }
    if (user?.phone != null && user!.phone!.isNotEmpty) {
      profileCompletePer += 7;
    }
    if (user?.hometown != null && user!.hometown!.isNotEmpty) {
      profileCompletePer += 7;
    }
    if (user?.zodiac != null && user!.zodiac!.isNotEmpty) {
      profileCompletePer += 5;
    }
    if (user?.habit != null && user!.habit!.isNotEmpty) {
      profileCompletePer += 7;
    }
    if (user?.personalityType != null && user!.personalityType!.isNotEmpty) {
      profileCompletePer += 5;
    }
    if (user?.covidVaccine != null && user!.covidVaccine!.isNotEmpty) {
      profileCompletePer += 0;
    }
    if (user?.isProfileVerified != null &&
        user!.isProfileVerified!.isNotEmpty) {
      profileCompletePer += 1;
    }
    profileCompletePercentage = profileCompletePer;
    notifyListeners();
  }

  clearProvider() {
    _loginUser = null;
  }
}
