// ignore_for_file: hash_and_equals, unnecessary_this

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/user_subscription.dart';

class User {
  User(
      {required this.id,
      required this.fname,
      required this.lname,
      required this.email,
      this.phone,
      required this.dob,
      required this.age,
      required this.gender,
      required this.isGenderShow,
      required this.isSexOrientationShow,
      required this.showme,
      this.about,
      required this.fcmToken,
      required this.isVerified,
      required this.loginType,
      required this.sexOrientation,
      required this.lookingFor,
      required this.interest,
      required this.isProfileSharable,
      this.zodiac,
      this.futurePlan,
      this.covidVaccine,
      this.personalityType,
      this.education,
      this.school,
      this.jobTitle,
      this.occupation,
      this.hometown,
      this.languageKnown,
      this.habit,
      this.basicDetail,
      required this.currentLat,
      required this.currentLong,
      this.findingLat,
      this.findingLong,
      required this.images,
      this.token,
      this.calDistance,
      this.imageIndex = 0,
      this.showCurrent = true,
      this.ageRange,
      this.showAgeRange,
      this.notificationType,
      this.distance,
      this.measure = UiString.km,
      this.isGlobal,
      this.nameUpdateAt,
      this.dobUpdateAt,
      this.visitedStatus,
      this.socialId,
      this.isShowMe,
      this.isProfileVerified,
      this.isIos,
      this.appLanguage,
      this.createdAt,
      this.updateAt,
      this.isEducationShow,
      this.isOccupationShow,
      this.findingDistance,
      this.subscription,
      this.isProfileVerifiedStatus,
      this.isProfileVerifiedView,
      this.profileVerificationReason,
      this.getRemainingValue,
      this.lastLogOut,
      this.showOnline,
      this.showVerifiedProfile,
      this.isAutoRenew,
      this.notiLike,
      this.notiVisitor,
      this.notiMsgRequests,
      this.notiMsgMatch,
      this.notiMatch,
      required this.canMsgSend,
      required this.channelId,
      this.educationId,
      this.deviceId,
      this.occupationId,
      this.educationName,
      this.occupationName,
      this.pastSubscription});

  final String? id;
  final String? fname;
  final String? lname;
  final String? email;
  final String? socialId;
  final String? loginType;
  final String? phone;
  final String? dob;
  final String? gender;
  final String? isGenderShow;
  final String? sexOrientation;
  final String? isSexOrientationShow;
  final String? showme;
  final String? isShowMe;
  final String? lookingFor;
  final String? about;
  final String? interest;
  final dynamic ageRange;
  final String? showAgeRange;
  final String? notificationType;
  final String? fcmToken;
  final String? isVerified;
  final String? isProfileVerified;
  final String? isIos;
  final String? isProfileSharable;
  final String? appLanguage;
  final DateTime? createdAt;
  final DateTime? updateAt;
  final dynamic nameUpdateAt;
  final dynamic dobUpdateAt;
  final String? zodiac;
  final String? futurePlan;
  final String? covidVaccine;
  final String? personalityType;
  final String? education;
  final String? school;
  final String? jobTitle;
  final String? occupation;
  final String? isEducationShow;
  final String? isOccupationShow;
  final String? hometown;
  final String? languageKnown;
  final String? habit;
  final String? age;
  final String? currentLat;
  final String? currentLong;
  final String? findingDistance;
  final String? isGlobal;
  final dynamic basicDetail;
  final List<String>? images;
  final List<UserSubscription>? subscription;
  final String? token;
  final String? findingLat;
  final String? findingLong;
  final dynamic visitedStatus;
  final bool showCurrent;
  final String? calDistance;
  int imageIndex;
  final String? distance;
  final String? measure;
  final String? isProfileVerifiedStatus;
  final String? isProfileVerifiedView;
  final String? profileVerificationReason;
  final GetRemainingValue? getRemainingValue;
  final String? lastLogOut;
  final String? showOnline;
  final String? showVerifiedProfile;
  final String? isAutoRenew;
  final dynamic channelId;
  final int? canMsgSend;
  final String? notiLike;
  final String? notiVisitor;
  final String? notiMsgRequests;
  final String? notiMsgMatch;
  final String? notiMatch;
  final String? educationId;
  final String? deviceId;
  final String? occupationId;
  final String? educationName;
  final String? occupationName;
  final UserSubscription? pastSubscription;

  User copyWith(
      {String? id,
      String? fname,
      String? lname,
      String? email,
      String? socialId,
      String? loginType,
      String? password,
      String? phone,
      String? dob,
      String? gender,
      String? isGenderShow,
      String? sexOrientation,
      String? isSexOrientationShow,
      String? showme,
      String? isShowMe,
      String? lookingFor,
      String? about,
      String? interest,
      dynamic ageRange,
      String? showAgeRange,
      String? notificationType,
      String? fcmToken,
      String? verificationOtp,
      dynamic deativeDays,
      dynamic deactiveTime,
      String? isVerified,
      String? isProfileVerified,
      String? isIos,
      String? isProfileSharable,
      String? appLanguage,
      DateTime? createdAt,
      DateTime? updateAt,
      dynamic nameUpdateAt,
      dynamic dobUpdateAt,
      String? isDeleted,
      String? userId,
      String? zodiac,
      String? futurePlan,
      String? covidVaccine,
      String? personalityType,
      String? education,
      String? occupation,
      String? isEducationShow,
      String? isOccupationShow,
      String? hometown,
      String? languageKnown,
      String? habit,
      String? age,
      String? currentLat,
      String? currentLong,
      String? findingDistance,
      String? isGlobal,
      String? isProfileVerifiedStatus,
      String? isProfileVerifiedView,
      String? profileVerificationReason,
      dynamic basicDetail,
      List<String>? images,
      List<UserSubscription>? subscription,
      String? token,
      String? findingLat,
      String? findingLong,
      dynamic calDistance,
      dynamic visitedStatus,
      bool? showCurrent,
      int? imageIndex,
      String? distance,
      GetRemainingValue? getRemainingValue,
      String? measure,
      String? lastLogOuts,
      String? showOnlines,
      String? showVerifiedProfiles,
      String? isAutoRenews,
      String? chanelId,
      int? canMsgSend,
      String? notiLike,
      String? notiVisitor,
      String? notiMsgRequests,
      String? notiMsgMatch,
      String? notiMatch,
      String? educationId,
      String? educationName,
      String? occupationId,
      String? deviceId,
      String? occupationName,
      UserSubscription? pastSubscription}) {
    return User(
        id: id ?? this.id,
        fname: fname ?? this.fname,
        lname: lname ?? this.lname,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        dob: dob ?? this.dob,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        isGenderShow: isGenderShow ?? this.isGenderShow,
        isSexOrientationShow: isSexOrientationShow ?? this.isSexOrientationShow,
        showme: showme ?? this.showme,
        isShowMe: isShowMe ?? this.isShowMe,
        about: about ?? this.about,
        fcmToken: fcmToken ?? this.fcmToken,
        isVerified: isVerified ?? this.isVerified,
        loginType: loginType ?? this.loginType,
        sexOrientation: sexOrientation ?? this.sexOrientation,
        lookingFor: lookingFor ?? this.lookingFor,
        interest: interest ?? this.interest,
        isProfileSharable: isProfileSharable ?? this.isProfileSharable,
        zodiac: zodiac ?? this.zodiac,
        futurePlan: futurePlan ?? this.futurePlan,
        covidVaccine: covidVaccine ?? this.covidVaccine,
        personalityType: personalityType ?? this.personalityType,
        education: education ?? this.education,
        occupation: occupation ?? this.occupation,
        hometown: hometown ?? this.hometown,
        languageKnown: languageKnown ?? this.languageKnown,
        habit: habit ?? this.habit,
        currentLat: currentLat ?? this.currentLat,
        currentLong: currentLong ?? this.currentLong,
        findingLat: findingLat ?? this.findingLat,
        findingLong: findingLong ?? this.findingLong,
        images: images != null ? List.from(images) : this.images,
        token: token ?? this.token,
        showCurrent: showCurrent ?? this.showCurrent,
        calDistance: calDistance ?? this.calDistance,
        imageIndex: imageIndex ?? this.imageIndex,
        visitedStatus: visitedStatus ?? this.visitedStatus,
        basicDetail: basicDetail ?? this.basicDetail,
        distance: distance ?? this.distance,
        isGlobal: isGlobal ?? this.isGlobal,
        nameUpdateAt: nameUpdateAt ?? this.nameUpdateAt,
        dobUpdateAt: dobUpdateAt ?? this.dobUpdateAt,
        ageRange: ageRange ?? this.ageRange,
        showAgeRange: showAgeRange ?? this.showAgeRange,
        notificationType: notificationType ?? this.notificationType,
        measure: measure ?? this.measure,
        getRemainingValue: getRemainingValue ?? this.getRemainingValue,
        subscription: subscription ?? this.subscription,
        socialId: socialId ?? this.socialId,
        lastLogOut: lastLogOuts ?? this.lastLogOut,
        showOnline: showOnlines ?? this.showOnline,
        showVerifiedProfile: showVerifiedProfiles ?? this.showVerifiedProfile,
        isAutoRenew: isAutoRenews ?? this.isAutoRenew,
        notiLike: notiLike ?? this.notiLike,
        notiMsgMatch: notiMsgMatch ?? this.notiMsgMatch,
        notiMsgRequests: notiMsgRequests ?? this.notiMsgRequests,
        notiVisitor: notiVisitor ?? this.notiVisitor,
        notiMatch: notiMatch ?? this.notiMatch,
        channelId: chanelId ?? this.channelId,
        canMsgSend: canMsgSend ?? this.canMsgSend,
        educationId: educationId ?? this.educationId,
        educationName: educationName ?? this.educationName,
        occupationId: occupationId ?? this.occupationId,
        deviceId: deviceId ?? deviceId,
        occupationName: occupationName ?? this.occupationName,
        pastSubscription: pastSubscription ?? this.pastSubscription);
  }

  factory User.fromJson(Map<String, dynamic> json,
      {bool calculateDistance = true}) {
    return User(
      id: json["id"].toString(),
      fname: json["fname"],
      lname: json["lname"] ?? '',
      email: json["email"],
      phone: json["phone"],
      dob: json["dob"],
      age: json["age"] != null ? json["age"].toString() : "0",
      gender: Utils.getGenderString(json["gender"]),
      isGenderShow: json["is_gender_show"]?.toString() ?? "0",
      sexOrientation: json["sex_orientation"],
      isSexOrientationShow: json["is_sex_orientation_show"]?.toString() ?? "0",
      showme: json["showme"]?.toString() ?? '',
      isShowMe: json["is_show_me"],
      ageRange: json["age_range"] ?? Constants.defaultAgeRange,
      showAgeRange:
          json["show_age_range"]?.toString() ?? '${Constants.toShowInAgeRange}',
      about: json["about"],
      fcmToken: json["fcm_token"],
      isVerified: json["is_verified"]?.toString() ?? "1",
      loginType: json["login_type"]?.toString(),
      lookingFor: json["looking_for"] ?? '',
      interest: json["interest"],
      isProfileVerified: json["is_profile_verified"]?.toString() ?? '0',
      isProfileSharable: json["is_profile_sharable"]?.toString() ?? '0',
      zodiac: json["zodiac"] ?? '',
      futurePlan: json["future_plan"] ?? '',
      covidVaccine: json["covid_vaccine"] ?? '',
      personalityType: json["personality_type"] ?? '',
      education: json["education"] ?? '',
      isEducationShow: json["is_education_show"]?.toString() ?? '0',
      isOccupationShow: json["is_occupation_show"]?.toString() ?? '0',
      occupation: json["occupation"] ?? '',
      hometown: json["hometown"],
      languageKnown: json["language_known"],
      habit: json["habit"],
      currentLat: json["current_lat"]?.toString() ?? '0',
      currentLong: json["current_long"]?.toString() ?? '0',
      findingLat: json["finding_lat"]?.toString() ?? '0',
      findingLong: json["finding_long"],
      findingDistance:
          json["finding_distance"] ?? '${Constants.defaultMaximumDistance}',
      token: json["token"],
      calDistance: json["cal_distance"] != null && calculateDistance
          ? Utils.showDistanceInMeasurement(json["cal_distance"].toString())
          : '0',
      imageIndex: json["image_index"] ?? 0,
      visitedStatus: json["visited_status"]?.toString(),
      basicDetail: json["basic_detail"],
      notificationType: json["notification_type"]?.toString() ?? '4',
      distance:
          json["finding_distance"] ?? '${Constants.defaultMaximumDistance}',
      isGlobal: json["is_global"].toString(),
      nameUpdateAt: json["name_update_at"],
      dobUpdateAt: json["dob_updated_at"],
      isProfileVerifiedStatus: json["is_profile_verified_status"]?.toString(),
      isProfileVerifiedView: json["is_profile_verified_view"]?.toString(),
      profileVerificationReason:
          json["profile_verification_reason"]?.toString(),
      measure: json["measure"] != null ? json['measure'] : UiString.km,
      showCurrent: json['show_current'] ?? true,
      images: json["images"] != null
          ? List<String>.from(json["images"].map((x) => x))
          : [],
      subscription: json["subscription"] == null
          ? []
          : List<UserSubscription>.from(
              json["subscription"]!.map((x) => UserSubscription.fromJson(x))),
      getRemainingValue: json["getRemainingValue"] == null
          ? null
          : GetRemainingValue.fromJson(json["getRemainingValue"]),
      notiVisitor: json["noti_visitor"]?.toString(),
      notiMsgRequests: json["noti_msg_request"]?.toString(),
      notiMsgMatch: json["noti_msg_match"]?.toString(),
      notiLike: json["noti_likes"]?.toString(),
      notiMatch: json["noti_match"]?.toString(),
      lastLogOut: json["last_logout"]?.toString(),
      showOnline: json["show_online"]?.toString(),
      showVerifiedProfile: json["show_verified_profile"]?.toString(),
      isAutoRenew: json["is_auto_renew"]?.toString(),
      channelId: json["channel_id"]?.toString(),
      canMsgSend: json["can_msg_send"],
      educationId: json["education_id"],
      educationName: json['education_name'] ?? json['education'],
      occupationId: json["occupation_id"],
      deviceId: json["device_id"],
      occupationName: json['occupation_name'] ?? json['occupation'],
      pastSubscription: (json['past_subscription'] != null)
          ? UserSubscription.fromJson(json['past_subscription'])
          : json['past_subscription'],
    );
  }

  Map<String, dynamic> toJson() => {
        "getRemainingValue": getRemainingValue?.toJson(),
        "id": id,
        "fname": fname,
        "lname": lname,
        "email": email,
        "phone": phone,
        "dob": dob,
        "age": age,
        "gender": gender,
        "is_gender_show": isGenderShow,
        "is_sex_orientation_show": isSexOrientationShow,
        "showme": showme,
        "is_show_me": isShowMe,
        "age_range": ageRange,
        "show_age_range": showAgeRange,
        "finding_distance": distance,
        "measure": measure,
        "is_verified": isVerified,
        "login_type": loginType,
        "sex_orientation": sexOrientation,
        "looking_for": lookingFor,
        "interest": interest,
        "app_language": 1,
        "is_auto_renew": isAutoRenew,
        "show_online": showOnline,
        "show_verified_profile": showVerifiedProfile,
        "is_profile_sharable": isProfileSharable,
        "is_profile_verified_status": isProfileVerifiedStatus,
        "is_profile_verified_view": isProfileVerifiedView,
        "profile_verification_reason": profileVerificationReason,
        "zodiac": zodiac,
        "future_plan": futurePlan,
        "covid_vaccine": covidVaccine,
        "personality_type": personalityType,
        "hometown": hometown,
        "language_known": languageKnown,
        "habit": habit,
        "current_lat": currentLat,
        "current_long": currentLong,
        "finding_lat": findingLat,
        "finding_long": findingLong,
        "images": images,
        "token": token,
        "cal_distance": calDistance,
        "image_index": imageIndex,
        "visit_status": visitedStatus,
        "basic_detail": basicDetail,
        "subscription": subscription,
        "last_logout": null,
        "noti_likes": notiLike,
        "noti_visitor": notiVisitor,
        "noti_msg_request": notiMsgRequests,
        "noti_msg_match": notiMsgMatch,
        "noti_match": notiMatch,
        "can_msg_send": canMsgSend,
        "channel_id": channelId,
        "notification_type": notificationType,
        "is_global": isGlobal,
        "name_update_at": nameUpdateAt,
        "dob_updated_at": dobUpdateAt,
        "show_current": showCurrent,
        "about": about,
        "fcm_token": fcmToken,
        "education_id": educationId,
        "education_name": educationName,
        "education": education,
        "occupation_id": occupationId,
        "occupation": occupation,
        "occupation_name": occupationName,
        "device_id": deviceId,
        'past_subscription': pastSubscription?.toJson()
      };

  Map<String, dynamic> toMap() => {
        "gender": gender,
        "is_gender_show": isGenderShow,
        "is_sex_orientation_show": isSexOrientationShow,
        "about": about,
        "sex_orientation":
            gender == ConstantList.genderList[2].val ? '' : sexOrientation,
        "show_me": gender == ConstantList.genderList[2].val ? showme : '',
        "is_show_me": isShowMe,
        "looking_for": lookingFor,
        "interest": interest,
        "zodiac": zodiac,
        "future_plan": futurePlan,
        "covid_vaccine": covidVaccine,
        "personality_type": personalityType,
        "education": int.tryParse(educationId ?? '0') ?? '0',
        "education_name": education,
        "occupation": int.tryParse(occupationId ?? '0') ?? '0',
        "occupation_name": occupation,
        "hometown": hometown,
        "language_known": languageKnown,
        "habit": habit,
        "device_id": deviceId,
      };

  static String getLookingFor(String jsonVal, {bool isText = true}) {
    var newOne = '';
    if (isText) {
      int index =
          ConstantList.lookingForList.indexWhere((e) => e.val == jsonVal);
      if (index != -1) {
        newOne = ConstantList.lookingForList[index].val;
        return newOne;
      }
      return '';
    } else {
      int index =
          ConstantList.lookingForList.indexWhere((e) => e.val == jsonVal);
      if (index != -1) {
        newOne = ConstantList.lookingForList[index].val;
        return newOne;
      }
      return '';
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is User &&
            fname == other.fname &&
            lname == other.lname &&
            dob == other.dob &&
            email == other.email &&
            phone == other.phone &&
            about == other.about &&
            hometown == other.hometown &&
            habit == other.habit &&
            sexOrientation == other.sexOrientation &&
            lookingFor == other.lookingFor &&
            interest == other.interest &&
            zodiac == other.zodiac &&
            futurePlan == other.futurePlan &&
            covidVaccine == other.covidVaccine &&
            personalityType == other.personalityType &&
            education == other.education &&
            habit == other.habit &&
            school == other.school &&
            jobTitle == other.jobTitle &&
            showme == other.showme &&
            isShowMe == other.isShowMe &&
            occupation == other.occupation &&
            hometown == other.hometown &&
            languageKnown == other.languageKnown &&
            gender == other.gender &&
            showOnline == other.showOnline &&
            showVerifiedProfile == other.showVerifiedProfile &&
            isGenderShow == other.isGenderShow &&
            isSexOrientationShow == other.isSexOrientationShow &&
            educationId == other.educationId &&
            deviceId == other.deviceId &&
            listEquals(images, other.images);
  }

  @override
  String toString() {
    // TODO: implement toString
    return jsonEncode(toJson());
  }
}

class GetRemainingValue {
  final int? remainingLikes;
  final int? remainingDisLikes;
  final int? remainingRewind;
  final int? remainingMessageLimit;

  GetRemainingValue({
    this.remainingLikes,
    this.remainingDisLikes,
    this.remainingRewind,
    this.remainingMessageLimit,
  });

  GetRemainingValue copyWith({
    int? remainingLikes,
    int? remainingDisLikes,
    int? remainingRewind,
    int? remainingMessageLimit,
  }) =>
      GetRemainingValue(
        remainingLikes: remainingLikes ?? this.remainingLikes,
        remainingDisLikes: remainingDisLikes ?? this.remainingDisLikes,
        remainingRewind: remainingRewind ?? this.remainingRewind,
        remainingMessageLimit:
            remainingMessageLimit ?? this.remainingMessageLimit,
      );

  factory GetRemainingValue.fromJson(Map<String, dynamic> json) =>
      GetRemainingValue(
        remainingLikes: json["remainingLikes"],
        remainingDisLikes: json["remainingDisLikes"],
        remainingRewind: json["remainingRewind"],
        remainingMessageLimit: json["remainingMessageLimit"],
      );

  Map<String, dynamic> toJson() => {
        "remainingLikes": remainingLikes,
        "remainingDisLikes": remainingDisLikes,
        "remainingRewind": remainingRewind,
        "remainingMessageLimit": remainingMessageLimit,
      };
}
