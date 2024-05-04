import 'dart:convert';

import 'package:meety_dating_app/models/user_basic_info.dart';

List<BlockUser> blockUserModelFromJson(String str) =>
    List<BlockUser>.from(json.decode(str).map((x) => BlockUser.fromJson(x)));

String blockUserModelToJson(List<BlockUser> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BlockUser {
  String blockedId;
  String pNumber;
  String pName;
  dynamic pEmail;
  dynamic identifier;
  UserBasicInfo? userRecord;

  BlockUser({
    required this.blockedId,
    required this.pNumber,
    required this.pName,
    required this.pEmail,
    required this.identifier,
    this.userRecord,
  });

  factory BlockUser.fromJson(Map<String, dynamic> json) => BlockUser(
        blockedId: json["blocked_id"].toString(),
        pNumber: json["p_number"] ?? '',
        pEmail: json["p_email"],
        pName: json["p_name"],
        identifier: json["identifier"],
        userRecord: json["user_record"] == null
            ? null
            : UserBasicInfo.fromJson(json["user_record"]),
      );

  Map<String, dynamic> toJson() {
    return {
      "blocked_id": blockedId,
      "p_number": pNumber,
      "p_email": pEmail,
      "p_name": pName,
      "identifier": pEmail,
      "user_record": userRecord?.toJson()
    };
  }

  @override
  bool operator ==(Object other) {
    return other is BlockUser &&
        blockedId == other.blockedId &&
        pNumber == other.pNumber &&
        pEmail == other.pEmail &&
        identifier == other.identifier &&
        userRecord?.toJson() == other.userRecord?.toJson();
  }

  @override
  // ignore: unnecessary_overrides,
  int get hashCode => super.hashCode;



}
