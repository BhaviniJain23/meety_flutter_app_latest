import 'dart:convert';

Interest interestFromJson(String str) => Interest.fromJson(json.decode(str));

String interestToJson(Interest data) => json.encode(data.toJson());

class Interest {
  String id;
  String interest;

  Interest({
    required this.id,
    required this.interest,
  });

  factory Interest.fromJson(Map<String, dynamic> json) => Interest(
        id: json["id"].toString(),
        interest: json["interest"],
      );

  static Interest empty() => Interest(id: "-1", interest: "interest");

  Map<String, dynamic> toJson() => {
        "id": id,
        "interest": interest,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Interest && other.id == id && other.interest == interest;
  }

  @override
  String toString() {
    return id;
  }

  @override
  int get hashCode => super.hashCode;
}
