import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/chat_user.dart';
import 'package:meety_dating_app/models/location.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/providers/like_list_provider.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/providers/photo_provider.dart';
import 'package:meety_dating_app/providers/user_chat_list_provider.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import 'singleton_locator.dart';

class SharedPrefsManager {
  late final SharedPreferences _instance;

  // More abstraction
  static const String usersPref = "usersPref";
  static const String signUpPref = "signUpPref";
  static const String isSaveBoardingPref = "isSaveBoardingPref";
  static const String tokenPref = "AuthorizationToken";
  static const String locationPrefs = "locationPrefs";
  static const String chatPrefs = "chatPrefs";
  static const String chatPrefs1 = "chatPrefs1";
  static const String chatRequestPrefs = "chatRequestPrefs";
  static const String sentRequestPrefs = "sentRequestPrefs";
  static const String rememberUserDataPreference = "rememberUserDataPreference";
  static const String isSaveBoardingPref2 = "isSaveBoardingPref2";
  static const String locationListPrefs = "locationListPrefs";

  Future<SharedPreferences> init() async =>
      _instance = await SharedPreferences.getInstance();

  Future<bool> saveUserInfo(User userData, {bool isToSaveMeasure = false}) {
    User? tempData = getUserDataInfo();

    if (tempData != null && !isToSaveMeasure) {
      userData = userData.copyWith(measure: tempData.measure);
    }

    String user = json.encode(userData.toJson());

    return _instance.setString(usersPref, user);
  }

  Future<bool> saveToken(String token) {
    return _instance.setString(tokenPref, token);
  }

  String getToken() {
    return _instance.getString(tokenPref) ?? '';
  }

  Future<bool> saveSignUpData(Map<String, dynamic> data) async {
    return await _instance.setString(signUpPref, jsonEncode(data));
  }

  Map<String, dynamic> getSignUpData() {
    final savedData = _instance.getString(signUpPref);
    return savedData != null ? jsonDecode(savedData) : {};
  }

  Future<bool> saveLocationInfo(List<Tuple2<Location, bool>> list) async {
    await removeLocationInfo();
    List<String> stringList = list.map((item) {
      return jsonEncode({
        'location': item.item1.toJson(),
        'bool': item.item2,
      });
    }).toList();
    return _instance.setStringList(locationPrefs, stringList);
  }

  Future<bool> saveLocation(List<Location> list) async {
    List<String> stringList = list.map((item) {
      return jsonEncode(item.toJson());
    }).toList();
    return _instance.setStringList(locationListPrefs, stringList);
  }

  List<Location> getLocationList() {
    var stringList = _instance.getStringList(locationListPrefs);
    if (stringList != null) {
      try {
        List<Location> list = List.from(stringList.map((e) {
          Map<String, dynamic> json = jsonDecode(e);
          return Location.fromJson(json);
        }));
        return list;
      } on Exception catch (_) {
        // TODO
      }
    }
    return [];
  }

  Future<void> saveFilteredLocations(List<Location> locations) async {
    // Convert the list of locations to JSON
    String jsonLocations =
        jsonEncode(locations.map((location) => location.toJson()).toList());
    // Save the JSON string to Shared Preferences
    await _instance.setString('filtered_locations', jsonLocations);
  }

  Future<List<Location>> getFilteredLocations() async {
    String? jsonLocations = _instance.getString('filtered_locations');
    if (jsonLocations != null) {
      // Parse the JSON string back to a list of locations
      List<dynamic> decodedLocations = jsonDecode(jsonLocations);
      List<Location> locations =
          decodedLocations.map((json) => Location.fromJson(json)).toList();
      return locations;
    } else {
      return [];
    }
  }

  Future<bool> saveUserChatMessage(List<ChatUser1> list) async {
    await removeUserChatInfo(isAll: true);
    List<String> stringList = list.map((item) {
      return jsonEncode(item.toJson());
    }).toList();
    return _instance.setStringList(chatPrefs1, stringList);
  }

  List<ChatUser1> getUserChatMessages() {
    var stringList = _instance.getStringList(chatPrefs1);
    if (stringList != null) {
      try {
        List<String> userDataMap = stringList;
        List<ChatUser1> list = List.from(userDataMap.map((e) {
          final val = jsonDecode(e);
          if (val is String) {
            return ChatUser1.fromJson(val);
          } else {
            Map<String, dynamic> json = jsonDecode(e);
            return ChatUser1.fromMap(json);
          }
        }));
        return list;
      } on Exception catch (_) {
        // TODO
      }
    }
    return [];
  }

  Future<bool> saveUserMessageRequest(List<ChatUser1> list) async {
    await removeUserChatInfo(isRequest: true);
    List<String> stringList = list.map((item) {
      return jsonEncode(item.toJson());
    }).toList();
    return _instance.setStringList(chatRequestPrefs, stringList);
  }

  List<ChatUser1> getUserMessagesRequest() {
    var stringList = _instance.getStringList(chatRequestPrefs);
    if (stringList != null) {
      List<String> userDataMap = stringList;
      List<ChatUser1> list = List.from(userDataMap.map((e) {
        final val = jsonDecode(e);
        if (val is String) {
          return ChatUser1.fromJson(val);
        } else {
          Map<String, dynamic> json = jsonDecode(e);
          return ChatUser1.fromMap(json);
        }
      }));
      return list;
    } else {
      return [];
    }
  }

  Future<bool> saveUserMessageSent(List<ChatUser1> list) async {
    await removeUserChatInfo(isSent: true);
    List<String> stringList = list.map((item) {
      return jsonEncode(item.toJson());
    }).toList();
    return _instance.setStringList(sentRequestPrefs, stringList);
  }

  List<ChatUser1> getUserSentMessages() {
    var stringList = _instance.getStringList(sentRequestPrefs);
    if (stringList != null) {
      List<String> userDataMap = stringList;
      List<ChatUser1> list = List.from(userDataMap.map((e) {
        final val = jsonDecode(e);
        if (val is String) {
          return ChatUser1.fromJson(val);
        } else {
          Map<String, dynamic> json = jsonDecode(e);
          return ChatUser1.fromMap(json);
        }
      }));
      return list;
    } else {
      return [];
    }
  }

  Future<bool> saveChatMessages(List<ChatUser> list) async {
    await removeUserChatInfo(isAll: true);
    List<String> stringList = list.map((item) {
      return jsonEncode(item.toJson());
    }).toList();
    return _instance.setStringList(chatPrefs, stringList);
  }

  Future<bool> updateLastChatMessages(
    ChatUser user,
  ) async {
    await removeUserChatInfo();
    List<ChatUser> stringList =
        List.from((_instance.getStringList(chatPrefs) ?? []).map((e) {
      Map<String, dynamic> json = jsonDecode(e);
      return ChatUser.fromJson(json);
    }));
    int index = stringList.indexWhere((element) => element.id == user.id);
    if (index != -1) {
      stringList[index] = user;
    } else {
      stringList.insert(0, user);
    }
    return saveChatMessages(stringList);
  }

  User? getUserDataInfo() {
    if (_instance.getString(usersPref) != null) {
      Map<String, dynamic> userDataMap =
          jsonDecode(_instance.getString(usersPref)!);

      User userDataModel = User.fromJson(userDataMap, calculateDistance: false);
      return userDataModel;
    } else {
      return null;
    }
  }

  List<Tuple2<Location, bool>>? getLocationInfo() {
    if (_instance.getStringList(locationPrefs) != null) {
      List<String> userDataMap = _instance.getStringList(locationPrefs)!;
      List<Tuple2<Location, bool>> list = List.from(userDataMap.map((e) {
        Map<String, dynamic> json = jsonDecode(e);
        return Tuple2<Location, bool>(
            Location.fromJson(json['location']), json['bool']);
      }));

      return list;
    } else {
      return null;
    }
  }

  List<ChatUser> getChatUserInfo() {
    if (_instance.getStringList(chatPrefs) != null) {
      List<String> userDataMap = _instance.getStringList(chatPrefs)!;
      List<ChatUser> list = List.from(userDataMap.map((e) {
        Map<String, dynamic> json = jsonDecode(e);
        return ChatUser.fromJson(json);
      }));

      return list;
    } else {
      return [];
    }
  }

  Future<bool> removeUserDataInfo() async {
    return await _instance.clear();
  }

  Future<bool> removeLocationInfo() async {
    if (_instance.getStringList(locationPrefs) != null) {
      return _instance.remove(locationPrefs);
    } else {
      return false;
    }
  }

  Future<bool> removeUserChatInfo({
    bool isAll = false,
    bool isRequest = false,
    bool isSent = false,
  }) async {
    if (isAll) {
      if (_instance.getStringList(chatPrefs) != null) {
        return _instance.remove(chatPrefs);
      } else {
        return false;
      }
    }
    if (isRequest) {
      if (_instance.getStringList(chatRequestPrefs) != null) {
        return _instance.remove(chatRequestPrefs);
      } else {
        return false;
      }
    }
    if (isSent) {
      if (_instance.getStringList(sentRequestPrefs) != null) {
        return _instance.remove(sentRequestPrefs);
      } else {
        return false;
      }
    }
    return false;
  }

  bool getIsLogin() {
    return _instance.containsKey(usersPref);
  }

  Future<Map<String, dynamic>> getAppleInfo(String appleLoginId) async {
    String? userData = _instance.getString(appleLoginId);
    if (userData != null && userData.isNotEmpty) {
      Map<String, dynamic> userDataMap = jsonDecode(userData);
      return userDataMap;
    }
    return {};
  }

  Future<bool> saveAppleInfo(
      String appleLoginId, String email, String familyName) async {
    String user = json.encode({
      'apple_id': appleLoginId,
      'email': email,
      'name': familyName,
    });
    return _instance.setString(appleLoginId, user);
  }

  Future<bool> saveBoardingScreen(String isSaveBoarding) async {
    return await _instance.setString(isSaveBoardingPref, isSaveBoarding);
  }

  String getBoardingScreen() {
    return _instance.getString(isSaveBoardingPref) ?? 'false';
  }

  void logoutUser(BuildContext? context) {
    Future.delayed(const Duration(seconds: 0), () async {
      // Clear all providers
if(context != null){      Provider.of<HomeProvider>(context, listen: false).clearProvider();
      Provider.of<UserChatListProvider>(context, listen: false).clearProvider();
      Provider.of<LikeListProvider>(context, listen: false).clearProvider();
      Provider.of<LoginUserProvider>(context, listen: false).clearProvider();
      Provider.of<PhotosProvider>(context, listen: false).clearProvider();}

      UserRepository().logout().then((value) async {
        var isBoardingScreen = getBoardingScreen();
        var rememberMe = getRememberUserDataInfo();
        await removeUserDataInfo();
        saveBoardingScreen(isBoardingScreen);
        if (rememberMe != null) {
          saveRememberUserDataInfo(rememberMe);
        }
      });

      await sl<ChatRepository>().setUserOnlineStatus(
          isOnline: Constants.offlineState,
          isChannelOn: '',
          isOnlineTimeUpdate: true);
      sl<NavigationService>().navigateTo(
        RoutePaths.login,
        withPushAndRemoveUntil: true,
      );
    });
  }

  Future<bool> saveRememberUserDataInfo(Map<String, dynamic> userData) async {
    String user = jsonEncode(userData);
    return _instance.setString(rememberUserDataPreference, user);
  }

  Map<String, dynamic>? getRememberUserDataInfo() {
    if (_instance.getString(rememberUserDataPreference) != null) {
      Map<String, dynamic> userDataMap =
          jsonDecode(_instance.getString(rememberUserDataPreference)!);
      return userDataMap;
    } else {
      return null;
    }
  }

  Future<void> removeRememberUserDataInfo() async {
    if (_instance.getString(rememberUserDataPreference) != null) {
      _instance.remove(rememberUserDataPreference);
    }
  }
}
