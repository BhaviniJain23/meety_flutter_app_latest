class UserSubscription {
  final String? price;
  final String? planId;
  final String? likelist;
  final String? dayLimit;
  final String? isAddons;
  final String? msgLimit;
  final String? likeLimit;
  final dynamic planImage;
  final String? planTitle;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final String? visitorlist;
  final String? rewindLimit;
  final String? dislikeLimit;
  final String? likeSentList;
  final String? priorityLikes;
  final String? subscriptionId;
  final String? planDescription;


  UserSubscription({
    this.price,
    this.planId,
    this.likelist,
    this.dayLimit,
    this.isAddons,
    this.msgLimit,
    this.likeLimit,
    this.planImage,
    this.planTitle,
    this.startDate,
    this.expiryDate,
    this.visitorlist,
    this.rewindLimit,
    this.dislikeLimit,
    this.likeSentList,
    this.priorityLikes,
    this.subscriptionId,
    this.planDescription,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) =>
      UserSubscription(
        price: json["price"]?.toString() ?? '',
        planId: json["plan_id"]?.toString() ?? '',
        likelist: json["likelist"]?.toString() ?? '',
        dayLimit: json["day_limit"]?.toString() ?? '',
        isAddons: json["is_addons"]?.toString() ?? '',
        msgLimit: json["msg_limit"]?.toString() ?? '',
        likeLimit: json["like_limit"]?.toString() ?? '',
        planImage: json["plan_image"] ?? '',
        planTitle: json["plan_title"]?.toString() ?? '',
        startDate: json["start_date"] == null
            ? null
            : DateTime.parse(json["start_date"]),
        expiryDate: json["expiry_date"] == null
            ? null
            : DateTime.parse(json["expiry_date"]),
        visitorlist: json["visitorlist"]?.toString() ?? '',
        rewindLimit: json["rewind_limit"]?.toString() ?? '',
        dislikeLimit: json["dislike_limit"]?.toString() ?? '',
        likeSentList: json["like_sent_list"]?.toString() ?? '',
        priorityLikes: json["priority_likes"]?.toString() ?? '',
        subscriptionId: json["subscription_id"]?.toString() ?? '',
        planDescription: json["plan_description"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "plan_id": planId,
        "likelist": likelist,
        "day_limit": dayLimit,
        "is_addons": isAddons,
        "msg_limit": msgLimit,
        "like_limit": likeLimit,
        "plan_image": planImage,
        "plan_title": planTitle,
        "start_date": startDate?.toIso8601String(),
        "expiry_date": expiryDate?.toIso8601String(),
        "visitorlist": visitorlist,
        "rewind_limit": rewindLimit,
        "dislike_limit": dislikeLimit,
        "like_sent_list": likeSentList,
        "priority_likes": priorityLikes,
        "subscription_id": subscriptionId,
        "plan_description": planDescription,
      };
}
