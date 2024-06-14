// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/education_model.dart';
import 'package:meety_dating_app/models/location.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class EditUserProvider extends ChangeNotifier {
  LoginUserProvider? loginUserProvider;

  User? _loginUser;
  EducationModel? _educationModel;
  List<Tuple2<Location, bool>> _selectedLocation;

  bool _isProfileEdit = false;

  User? get loginUser => _loginUser;

  EducationModel? get educationModel => _educationModel;

  bool get isProfileEdit => _isProfileEdit;

  List<Tuple2<Location, bool>> get selectedLocation => _selectedLocation;

  EditUserProvider({required LoginUserProvider loginProvider})
      : loginUserProvider = loginProvider,
        _loginUser = loginProvider.user,
        _selectedLocation = [
          Tuple2(
              Location(
                name: UiString.myCurrentLocation,
                latitude: loginProvider.user?.currentLat,
                longitude: loginProvider.user?.currentLong,
              ),
              loginProvider.user?.showCurrent ?? true)
        ] {
    final location = sl<SharedPrefsManager>().getLocationInfo();
    if (location != null && location.isNotEmpty) {
      _selectedLocation = location;
      notifyListeners();
    }
  }

  void setUser(User user) {
    _loginUser = user;
    notifyListeners();
  }

  void setIsProfileEdit(bool isProfileEdit) {
    _isProfileEdit = isProfileEdit;
    notifyListeners();
  }

  void updateAbout(String about) {
    _loginUser = _loginUser?.copyWith(about: about);
    notifyListeners();
  }

  void updateJobTitle(String i, String jobTitle) {
    _loginUser = _loginUser?.copyWith(
        occupationId: i.toString(),
        occupation: jobTitle,
        occupationName: jobTitle);
    notifyListeners();
  }

  // void updateCompany(String company) {
  //   _loginUser = _loginUser?.copyWith(occupation: company);
  //   notifyListeners();
  // }

  void updateEducation(
    String i,
    String school,
  ) {
    _loginUser = _loginUser?.copyWith(
        educationId: i.toString(), education: school, educationName: school);
    notifyListeners();
  }

  void updateCity(String city) {
    _loginUser = _loginUser?.copyWith(hometown: city);
    notifyListeners();
  }

  Future<void> updateFindingLocationList(Location location,
      {int? index}) async {
    _selectedLocation =
        List.from(_selectedLocation.map((e) => e.withItem2(false)).toList());
    if (index != null) {
      _selectedLocation[index] = Tuple2(_selectedLocation[index].item1, true);
    } else {
      _selectedLocation.add(Tuple2(location, true));
    }
    _loginUser = _loginUser?.copyWith(
        showCurrent: location.name == UiString.myCurrentLocation ? true : false,
        findingLat: location.name == UiString.myCurrentLocation
            ? ''
            : location.latitude,
        findingLong: location.name == UiString.myCurrentLocation
            ? ''
            : location.longitude);
    await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
    await sl<SharedPrefsManager>().saveLocationInfo(_selectedLocation);
    notifyListeners();
  }

  void updateInterest(String interest) {
    _loginUser = _loginUser?.copyWith(interest: interest);
    notifyListeners();
  }

  void updateLookingFor(String lookingFor) {
    _loginUser = _loginUser?.copyWith(lookingFor: lookingFor);
    notifyListeners();
  }

  void updateLanguages(String language) {
    _loginUser = _loginUser?.copyWith(languageKnown: language);
    notifyListeners();
  }

  void updateImages(List<String> images) {
    _loginUser = _loginUser?.copyWith(images: images);
    loginUserProvider?.setUser(_loginUser);
    _isProfileEdit = true;
    notifyListeners();
  }

  void updateBasicProfile(String zodiac, String education, String familyPlan,
      String covidVaccine, String personalityType, String habits) {
    _loginUser = _loginUser?.copyWith(
        zodiac: zodiac,
        education: education,
        futurePlan: familyPlan,
        covidVaccine: covidVaccine,
        personalityType: personalityType,
        habit: habits);

    notifyListeners();
  }

  void updateSexOrientation(String sexOrientation) {
    _loginUser = _loginUser?.copyWith(sexOrientation: sexOrientation);
    notifyListeners();
  }

  void updateSexOrientationShow(String sexOrientate) {
    _loginUser = _loginUser?.copyWith(isSexOrientationShow: sexOrientate);
    notifyListeners();
  }

  void updateGender(String gender) {
    _loginUser = _loginUser?.copyWith(gender: gender);
    notifyListeners();
  }

  void updateGenderShow(String gender) {
    _loginUser = _loginUser?.copyWith(isGenderShow: gender);
    notifyListeners();
  }

  void updateShowMeValue(String showme) {
    _loginUser = _loginUser?.copyWith(showme: showme);
    notifyListeners();
  }

  void updateShowMeIsVal(String showme) {
    _loginUser = _loginUser?.copyWith(isShowMe: showme);
    notifyListeners();
  }

  void updateNotificationType(
      {required bool isEmailAddress, required bool isNotification}) {
    // isRecentlyActive = newVal;
    String newNotificationVal = "0";
    if (isEmailAddress && isNotification) {
      newNotificationVal = Constants.allNotification;
    } else if (!isEmailAddress && isNotification) {
      newNotificationVal = Constants.pushNotification;
    } else if (isEmailAddress && !isNotification) {
      newNotificationVal = Constants.emailAddress;
    } else if (!isEmailAddress && !isNotification) {
      newNotificationVal = Constants.noneOfNotification;
    }
    _loginUser = _loginUser?.copyWith(notificationType: newNotificationVal);
    notifyListeners();
  }

  Future<void> updateEmail(
      BuildContext context, String email, String otp) async {
    _loginUser = _loginUser?.copyWith(email: email);
    notifyListeners();

    await updateEmailAccountSetting(context, otp);
  }

  Future<void> updateMobile(BuildContext context, String mobile) async {
    _loginUser = _loginUser?.copyWith(phone: mobile);
    notifyListeners();
    await updateAccountSetting(context, {"phone": mobile});
    notifyListeners();
  }

  Future<void> updateName(
      BuildContext context, String fname, String lname) async {
    Map<String, dynamic> data = {};
    if (lname != _loginUser?.fname) {
      data.addAll({"fname": fname});
    }
    if (lname != _loginUser?.lname) {
      data.addAll({"lname": lname});
    }
    _loginUser = _loginUser?.copyWith(fname: fname, lname: lname);
    notifyListeners();
    await updateAccountSetting(context, data);
  }

  Future<void> updateDOB(BuildContext context, String tDob) async {
    _loginUser = _loginUser?.copyWith(dob: tDob);
    notifyListeners();
    await updateAccountSetting(context, {
      "dob": tDob,
    });
  }

  Future<void> updateProfile(BuildContext context,
      {bool refresh = false}) async {
    try {
      Map<String, dynamic> apiResponse =
          await UserRepository().updateProfile(data: loginUser?.toMap() ?? {});
      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        _loginUser = User.fromJson(apiResponse[UiString.dataText]);
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        loginUserProvider?.profileCompleteProgress();
      }
    } catch (e) {
      // Future.delayed((Duration.zero), () {
      context.showSnackBar(e.toString());
      // });
      return;
    }
  }

  Future<void> updateAccountSetting(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      Map<String, dynamic> apiResponse =
          await UserRepository().updateAccountSetting(data: data);
      if (apiResponse[UiString.successText]) {
        if (data.containsKey("fname") || data.containsKey("lname")) {
          _loginUser = _loginUser?.copyWith(
              nameUpdateAt: DateTime.now().toIso8601String());
        }

        if (data.containsKey("dob")) {
          _loginUser = _loginUser?.copyWith(
              dobUpdateAt: DateTime.now().toIso8601String());
        }
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);

        loginUserProvider?.setUser(_loginUser);
        context.read<LoginUserProvider>().profileCompleteProgress();

        Future.delayed((Duration.zero), () {
          Navigator.pop(context);
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      return;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateEmailAccountSetting(
      BuildContext context, String otp) async {
    try {
      Map<String, dynamic> apiResponse = await UserRepository()
          .updateEmailAccountSetting(email: _loginUser?.email ?? '', otp: otp);

      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        context.read<LoginUserProvider>().profileCompleteProgress();

        Future.delayed((Duration.zero), () {
          Navigator.pop(context);
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      return;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateGlobalStatus(BuildContext context, String isGlobal) async {
    try {
      _loginUser = _loginUser?.copyWith(isGlobal: isGlobal);
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().updateGlobalStatus(data: {
        'user_id': _loginUser?.id.toString(),
        'is_global': _loginUser?.isGlobal ?? '0',
        'distance': _loginUser?.distance ?? '25',
      });
      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        context.read<LoginUserProvider>().profileCompleteProgress();

        notifyListeners();
        // Future.delayed((Duration.zero), () {
        //   context.read<HomeProvider>().fetchUsers();
        // });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      rethrow;
    }
  }

  Future<void> autoRenew(BuildContext context, String isAutoRenew) async {
    try {
      _loginUser = _loginUser?.copyWith(isAutoRenews: isAutoRenew);
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().autoRenewAPICall(data: {
        'auto_Renew': _loginUser?.isAutoRenew ?? '0'.toString(),
      });
      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!
            .copyWith(isAutoRenews: _loginUser?.isAutoRenew ?? '0'.toString()));
        loginUserProvider?.setUser(_loginUser);
        context.read<LoginUserProvider>().profileCompleteProgress();

        notifyListeners();
        Future.delayed((Duration.zero), () {
          context.read<HomeProvider>().fetchUsers();
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      rethrow;
    }
  }

  Future<void> updateShowOnlineStatus(
    BuildContext context,
    bool isOnline,
  ) async {
    try {
      _loginUser = _loginUser?.copyWith(showOnlines: isOnline ? '1' : '0');
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().fetchUpdateShowProfileAndOnline(data: {
        'offline_status': _loginUser?.showOnline ?? '0',
      });
      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        notifyListeners();
        Future.delayed((Duration.zero), () {
          context.read<HomeProvider>().fetchUsers();
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      rethrow;
    }
  }

  Future<void> updateShowProfileVerifiedStatus(
    BuildContext context,
    bool isVerified,
  ) async {
    try {
      _loginUser =
          _loginUser?.copyWith(showVerifiedProfiles: isVerified ? '1' : '0');
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().fetchUpdateShowProfileAndOnline(data: {
        'profile_verified': _loginUser?.showVerifiedProfile ?? '0',
      });
      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        notifyListeners();
        // Future.delayed((Duration.zero), () {
        //   context.read<HomeProvider>().fetchUsers();
        // });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      rethrow;
    }
  }

  Future<void> updateAgeRange(BuildContext context, String ageRange,
      {String? isShowRange}) async {
    try {
      _loginUser = _loginUser?.copyWith(
          ageRange: ageRange, showAgeRange: isShowRange ?? '0');
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().updateAgeRange(data: {
        'age_range': _loginUser?.ageRange ?? '',
        'show_acc_age': _loginUser?.showAgeRange ?? '0',
      });
      if (apiResponse[UiString.successText]) {
        sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        Future.delayed((Duration.zero), () {
          context.read<HomeProvider>().fetchUsers();
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
    } finally {
      _loginUser = _loginUser?.copyWith(
          ageRange: sl<SharedPrefsManager>().getUserDataInfo()?.ageRange,
          showAgeRange:
              sl<SharedPrefsManager>().getUserDataInfo()?.showAgeRange);
      notifyListeners();
    }
  }

  Future<void> updateDistance(BuildContext context, double distance,
      {String? measure}) async {
    try {
      var tempDistance = measure == UiString.km
          ? distance.toStringAsFixed(3)
          : Utils.convertMilesToKm(distance).toStringAsFixed(3);

      if (measure != _loginUser?.measure || measure != _loginUser?.distance) {
        _loginUser =
            _loginUser?.copyWith(measure: measure, distance: tempDistance);
      }
      notifyListeners();
      Map<String, dynamic> apiResponse =
          await UserRepository().updateMaximumDistance(data: {
        'distance': tempDistance,
      });

      if (apiResponse[UiString.successText]) {
        sl<SharedPrefsManager>()
            .saveUserInfo(_loginUser!, isToSaveMeasure: true);
        loginUserProvider?.setUser(_loginUser);
        Future.delayed((Duration.zero), () {
          context.read<HomeProvider>().fetchUsers();
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
    } finally {
      _loginUser = _loginUser?.copyWith(
          ageRange: sl<SharedPrefsManager>().getUserDataInfo()?.ageRange,
          showAgeRange:
              sl<SharedPrefsManager>().getUserDataInfo()?.showAgeRange);
      notifyListeners();
    }
  }

  Future<void> updateNotificationTypeApi(BuildContext context) async {
    try {
      Map<String, dynamic> apiResponse =
          await UserRepository().updateNotificationType(data: {
        'user_id': _loginUser?.id.toString(),
        'notification_type': _loginUser?.notificationType ?? '0',
      });

      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        notifyListeners();
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
          Navigator.pop(context);
        });
      } else {
        notifyListeners();
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      rethrow;
    }
  }

  Future<void> updateNotificationApi(BuildContext context,
      {required String notiVisitor,
      required String notiLike,
      required String notiMsgMatch,
      required String notiMsgRequests,
      required String notiMatch}) async {
    try {
      _loginUser = _loginUser?.copyWith(
          notiVisitor: notiVisitor,
          notiLike: notiLike,
          notiMsgMatch: notiMsgMatch,
          notiMsgRequests: notiMsgRequests,
          notiMatch: notiMatch);

      Map<String, dynamic> apiResponse =
          await UserRepository().notificationAPICall(data: {
        'noti_visitor': _loginUser?.notiVisitor ?? '0'.toString(),
        'noti_likes': _loginUser?.notiLike ?? '0'.toString(),
        'noti_msg_request': _loginUser?.notiMsgRequests ?? '0'.toString(),
        'noti_msg_match': _loginUser?.notiMsgMatch ?? '0'.toString(),
        'noti_match': _loginUser?.notiMatch ?? '0'.toString(),
      });

      if (apiResponse[UiString.successText]) {
        await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
        loginUserProvider?.setUser(_loginUser);
        notifyListeners();
        Future.delayed((Duration.zero), () {
          context.read<HomeProvider>().fetchUsers();
        });
      } else {
        Future.delayed((Duration.zero), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed((Duration.zero), () {
        context.showSnackBar(e.toString());
      });
      rethrow;
    }
  }

  // Future<void> updateEducations(BuildContext context, String education) async {
  //   try {
  //     _loginUser = _loginUser?.copyWith(
  //       education: education,
  //     );
  //     Map<String, dynamic> apiResponse =
  //         await OccupationRepository().getEducationNameList(data: {
  //       'education_id': _loginUser?.id.toString(),
  //       'name': _loginUser?.educationName ?? '',
  //     });
  //     if (apiResponse[UiString.successText]&&apiResponse[UiString.dataText] != null) {
  //       await sl<SharedPrefsManager>().saveUserInfo(_loginUser!);
  //       loginUserProvider?.setUser(_loginUser);
  //       context.read<LoginUserProvider>().profileCompleteProgress();
  //       List<EducationModel> tempList =
  //       List.from((apiResponse[UiString.dataText] as List).map((e) {
  //         return EducationModel.fromJson(e);
  //       }));
  //       print(tempList);
  //       print(apiResponse.toString());
  //       notifyListeners();
  //       Future.delayed((Duration.zero), () {
  //         Provider.of<HomeProvider>(context, listen: false).fetchUsers(page: 1);
  //         context.showSnackBar(apiResponse[UiString.messageText]);
  //
  //         Navigator.pop(context);
  //       });
  //     } else {
  //       notifyListeners();
  //     }
  //   } catch (e) {
  //     Future.delayed((Duration.zero), () {
  //       context.showSnackBar(e.toString());
  //     });
  //     rethrow;
  //   }
  // }

  @override
  void dispose() {
    loginUserProvider = null;
    _loginUser = null;
    _selectedLocation = [];
    _isProfileEdit = false;
    super.dispose();
  }
}
