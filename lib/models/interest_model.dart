class InterestModel {
  InterestModel({
    required this.id,
    required this.interest,
    this.image,
    this.tagline,
  });

  final int id;
  final String interest;
  final dynamic image;
  final dynamic tagline;

  InterestModel copyWith({
    String? interest,
    dynamic image,
    dynamic tagline,
  }) =>
      InterestModel(
        id: id,
        interest: interest ?? this.interest,
        image: image ?? this.image,
        tagline: tagline ?? this.tagline,
      );

  factory InterestModel.fromJson(Map<String, dynamic> json) => InterestModel(
    id: json["id"],
    interest: json["interest"],
    image: json["image"],
    tagline: json["tagline"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "interest": interest,
    "image": image,
    "tagline": tagline,
  };
}