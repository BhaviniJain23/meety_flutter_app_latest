import 'dart:convert';

List<SubscriptionModel> subscriptionModelFromJson(String str) =>
    List<SubscriptionModel>.from(
        json.decode(str).map((x) => SubscriptionModel.fromJson(x)));

String subscriptionModelToJson(List<SubscriptionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubscriptionModel {
  final int? planId;
  final String? planTitle;
  final String? planDescription;
  final dynamic planImage;
  final int? likeLimit;
  final int? dislikeLimit;
  final int? rewindLimit;
  final int? msgLimit;
  final int? likelist;
  final int? likeSentList;
  final int? visitorlist;
  final int? priorityLikes;
  final int? isAddons;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? isDeleted;
  final String? isRecommended;
  final List<PriceInfo>? priceInfo;
  final int? isActivate;
  final PriceInfo? selectedPriceInfo;

  SubscriptionModel({
    this.planId,
    this.planTitle,
    this.planDescription,
    this.planImage,
    this.likeLimit,
    this.dislikeLimit,
    this.rewindLimit,
    this.msgLimit,
    this.likelist,
    this.likeSentList,
    this.visitorlist,
    this.priorityLikes,
    this.isAddons,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
    this.isRecommended,
    this.priceInfo,
    this.isActivate,
    this.selectedPriceInfo,
  });

  SubscriptionModel copyWith({
    int? planId,
    String? planTitle,
    String? planDescription,
    dynamic planImage,
    int? likeLimit,
    int? dislikeLimit,
    int? rewindLimit,
    int? msgLimit,
    int? likelist,
    int? likeSentList,
    int? visitorlist,
    int? priorityLikes,
    int? isAddons,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? isDeleted,
    String? isRecommended,
    List<PriceInfo>? priceInfo,
    int? isActivate,
    PriceInfo? selectedPriceInfo,
  }) =>
      SubscriptionModel(
        planId: planId ?? this.planId,
        planTitle: planTitle ?? this.planTitle,
        planDescription: planDescription ?? this.planDescription,
        planImage: planImage ?? this.planImage,
        likeLimit: likeLimit ?? this.likeLimit,
        dislikeLimit: dislikeLimit ?? this.dislikeLimit,
        rewindLimit: rewindLimit ?? this.rewindLimit,
        msgLimit: msgLimit ?? this.msgLimit,
        likelist: likelist ?? this.likelist,
        likeSentList: likeSentList ?? this.likeSentList,
        visitorlist: visitorlist ?? this.visitorlist,
        priorityLikes: priorityLikes ?? this.priorityLikes,
        isAddons: isAddons ?? this.isAddons,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        isRecommended: isRecommended ?? this.isRecommended,
        priceInfo: priceInfo ?? this.priceInfo,
        isActivate: isActivate ?? this.isActivate,
        selectedPriceInfo: selectedPriceInfo ?? this.selectedPriceInfo,
      );

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      SubscriptionModel(
        planId: json["plan_id"],
        planTitle: json["plan_title"],
        planDescription: json["plan_description"],
        planImage: json["plan_image"],
        likeLimit: json["like_limit"],
        dislikeLimit: json["dislike_limit"],
        rewindLimit: json["rewind_limit"],
        msgLimit: json["msg_limit"],
        likelist: json["likelist"],
        likeSentList: json["like_sent_list"],
        visitorlist: json["visitorlist"],
        priorityLikes: json["priority_likes"],
        isAddons: json["is_addons"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        isDeleted: json["is_deleted"],
        priceInfo: json["price_info"] == null
            ? []
            : List<PriceInfo>.from(
                json["price_info"]!.map((x) => PriceInfo.fromJson(x))),
        isActivate: json["is_activate"],
        isRecommended: json["is_recommended"]?.toString() ?? '0',
      );

  Map<String, dynamic> toJson() => {
        "plan_id": planId,
        "plan_title": planTitle,
        "plan_description": planDescription,
        "plan_image": planImage,
        "like_limit": likeLimit,
        "dislike_limit": dislikeLimit,
        "rewind_limit": rewindLimit,
        "msg_limit": msgLimit,
        "likelist": likelist,
        "like_sent_list": likeSentList,
        "visitorlist": visitorlist,
        "priority_likes": priorityLikes,
        "is_addons": isAddons,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "is_deleted": isDeleted,
        "price_info": priceInfo == null
            ? []
            : List<dynamic>.from(priceInfo!.map((x) => x.toJson())),
        "is_activate": isActivate,
        "is_recommended": isRecommended,
      };
}

class PriceInfo {
  final int? totalPlanPrice;
  final int? planDayLimit;
  final int? discount;
  final String? stripePriceId;
  final int? planPricePerM;
  final int? planPriceId;

  PriceInfo(
      {this.totalPlanPrice,
      this.planDayLimit,
      this.stripePriceId,
      this.discount,
      this.planPricePerM,
     required this.planPriceId});

  PriceInfo copyWith({
    int? planPrice,
    int? planDayLimit,
    int? discount,
    String? stripePriceId,
    int? planPricePerM,
    int? planPriceId,
  }) =>
      PriceInfo(
          totalPlanPrice: planPrice ?? totalPlanPrice,
          planDayLimit: planDayLimit ?? this.planDayLimit,
          discount: discount ?? this.discount,
          stripePriceId: stripePriceId ?? this.stripePriceId,
          planPricePerM: planPricePerM ?? this.planPricePerM,
          planPriceId: planPriceId ?? this.planPriceId);

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    final princeInfo = PriceInfo(
      totalPlanPrice: json["plan_price"],
      planDayLimit: json["plan_day_limit"],
      discount: json["discount"],
      stripePriceId: json["stripe_price_id"],
      planPriceId: json['plan_price_id'],
    );

    if (princeInfo.totalPlanPrice != null && princeInfo.planDayLimit != null) {
      final pricePerM = (princeInfo.totalPlanPrice ?? 1) ~/
          ((princeInfo.planDayLimit ?? 1) / 30).round();
      return princeInfo.copyWith(planPricePerM: pricePerM);
    }

    return princeInfo;
  }

  Map<String, dynamic> toJson() => {
        "plan_price": totalPlanPrice,
        "plan_day_limit": planDayLimit,
        "discount": discount,
        "stripe_price_id": stripePriceId,
        'plan_price_id': planPriceId
      };
}
