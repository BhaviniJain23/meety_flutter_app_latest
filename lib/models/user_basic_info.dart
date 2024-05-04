import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/user.dart';

class GetOnlineUsersInfo{

  final String? isOnline;
  final UserBasicInfo? userBasicInfo;
  final String? lastOnlineAt;

  GetOnlineUsersInfo(
      {this.isOnline, this.userBasicInfo,
        this.lastOnlineAt});


  GetOnlineUsersInfo copyWith({
    String? isOnline,
    String? lastOnlineAt,
    UserBasicInfo? userBasicInfo
  }) =>
      GetOnlineUsersInfo(
        isOnline: isOnline ?? this.isOnline,
        lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
        userBasicInfo: userBasicInfo ?? this.userBasicInfo,
      );

  @override
  String toString() {
    // TODO: implement toString
    return "${isOnline ?? ''} ${lastOnlineAt ?? ''}";
  }
}

class UserBasicInfo {
  final String id;
  final String? name;
  final int? isProfileVerified;
  final dynamic gender;
  final dynamic showme;
  final dynamic sexOrientation;
  final String? lookingFor;
  final String? about;
  final String? interest;
  final String? occupation;
  final String? education;
  final String? hometown;
  final String? futurePlan;
  final int? age;
  final int? showOnline;
  final dynamic channelId;
  final int? canMsgSend;
  final String? fcmToken;
  final dynamic basicDetail;
  int imageIndex;
  final String? habit;
  final String? visitStatus;
  final String? calDistance;
  final List<String>? images;

  UserBasicInfo({
    required this.id,
    this.name,
    this.isProfileVerified,
    this.habit,
    this.gender,
    this.showme,
    this.sexOrientation,
    this.lookingFor,
    this.about,
    this.interest,
    this.education,
    this.hometown,
    this.futurePlan,
    this.age,
    this.showOnline,
    this.channelId,
    this.occupation,
    this.canMsgSend,
    this.fcmToken,
    this.basicDetail,
    this.imageIndex = 0,
    this.visitStatus,
    this.calDistance,
    this.images,
  });

  UserBasicInfo copyWith({
    String? id,
    String? name,
    int? isProfileVerified,
    dynamic gender,
    dynamic showme,
    dynamic sexOrientation,
    String? lookingFor,
    String? about,
    String? habit,
    String? interest,
    String? occupation,
    String? education,
    String? hometown,
    String? futurePlan,
    int? age,
    int? showOnline,
    dynamic channelId,
    int? canMsgSend,
    String? fcmToken,
    dynamic basicDetail,
    int? imageIndex,
    String? visitStatus,
    String? calDistance,
    List<String>? images,
  }) =>
      UserBasicInfo(
        id: id ?? this.id,
        name: name ?? this.name,
        isProfileVerified: isProfileVerified ?? this.isProfileVerified,
        gender: gender ?? this.gender,
        showme: showme ?? this.showme,
        sexOrientation: sexOrientation ?? this.sexOrientation,
        lookingFor: lookingFor ?? this.lookingFor,
        futurePlan: futurePlan ?? this.futurePlan,
        about: about ?? this.about,
        interest: interest ?? this.interest,
        education: education ?? this.education,
        occupation: occupation ?? this.occupation,
        hometown: hometown ?? this.hometown,
        habit: habit ?? this.habit,
        age: age ?? this.age,
        showOnline: showOnline ?? this.showOnline,
        channelId: channelId ?? this.channelId,
        canMsgSend: canMsgSend ?? this.canMsgSend,
        fcmToken: fcmToken ?? this.fcmToken,
        basicDetail: basicDetail ?? this.basicDetail,
        imageIndex: imageIndex ?? this.imageIndex,
        visitStatus: visitStatus ?? this.visitStatus,
        calDistance: calDistance ?? this.calDistance,
        images: images ?? this.images,
      );

  factory UserBasicInfo.fromJson(Map<String, dynamic> json) {

    return UserBasicInfo(
      id: json["id"].toString(),
      name: json["name"]?.toString(),
      isProfileVerified: json["is_profile_verified"],
      gender: Utils.getGenderString(json["gender"]),
      showme: json["showme"],
      sexOrientation: json["sex_orientation"],
      lookingFor: json["looking_for"],
      about: json["about"],
      interest: json["interest"],
      hometown: json["hometown"],
      education: json["education"],
      habit: json["habit"],
      futurePlan: json["future_plan"],
      age: json["age"],
      showOnline: json["show_online"],
      channelId: json["channel_id"]?.toString(),
      canMsgSend: json["can_msg_send"] ,
      fcmToken: json["fcm_token"],
      basicDetail: json["basic_detail"],
      occupation: json["occupation"],
      imageIndex: json["image_index"] ?? 0,
      visitStatus: json["visit_status"].toString(),
      calDistance: json["cal_distance"] != null
          ? Utils.showDistanceInMeasurement(json["cal_distance"].toString())
          : '0',


      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]!.map((x) => x)),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "is_profile_verified": isProfileVerified,
        "gender": gender,
        "showme": showme,
        "sex_orientation": sexOrientation,
        "looking_for": lookingFor,
        "about": about,
        "interest": interest,
        "education": education,
        "future_plan": futurePlan,
        "age": age,
        "habit": habit,
        "occupation": occupation,
        "show_online": showOnline,
        "channel_id": channelId,
        "can_msg_send": canMsgSend,
        "fcm_token": fcmToken,
        "basic_detail": basicDetail,
        "image_index": imageIndex,
        "visit_status": visitStatus,
        "cal_distance": calDistance,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
      };

  factory UserBasicInfo.fromUser(User user) {
    return UserBasicInfo(
        id: user.id.toString(),
        name: '${user.fname ?? ''} ${user.lname ?? ''}',
        gender: user.gender,
        sexOrientation: user.sexOrientation,
        showme: user.showme,
        lookingFor: user.lookingFor,
        futurePlan: user.futurePlan,
        about: user.about,
        education: user.education,
        hometown: user.hometown,
        interest: user.interest ?? '',
        basicDetail: user.basicDetail ?? '',
        images: user.images ?? [],
        occupation: user.occupation ?? '',
        calDistance: user.calDistance ?? '',
        habit: user.habit ?? '',
        imageIndex: user.imageIndex,
        age: int.tryParse(user.age ?? '0') ?? 0,
        visitStatus: user.visitedStatus.toString() ??
            '0', // ignore: dead_null_aware_expression
        fcmToken: user.fcmToken);
  }
}

