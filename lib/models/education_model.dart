import 'dart:convert';

List<EducationModel> educationModelFromJson(String str) =>
    List<EducationModel>.from(
        json.decode(str).map((x) => EducationModel.fromJson(x)));

String educationModelToJson(List<EducationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EducationModel {
  String? educationId;
  String? name;
  String? isRestricted;

  EducationModel({
    required this.educationId,
    required this.name,
    required this.isRestricted,
  });

  static EducationModel empty() =>
      EducationModel(educationId: "", name: "", isRestricted: "");

  EducationModel copyWith({
    String? educationId,
    String? name,
  }) =>
      EducationModel(
          educationId: educationId ?? this.educationId,
          name: name ?? this.name,
          isRestricted: isRestricted ?? this.isRestricted);

  factory EducationModel.fromJson(Map<String, dynamic> json) => EducationModel(
        educationId: json["id"]?.toString() ?? '0',
        name: json["name"],
        isRestricted: json["is_restricted"],
      );

  Map<String, dynamic> toJson() =>
      {"id": educationId, "name": name, "is_restricted": isRestricted};

  @override
  String toString() {
    // TODO: implement toString
    return super.toString();
  }

  @override
  int get hashCode => educationId.hashCode ^ name.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EducationModel &&
          runtimeType == other.runtimeType &&
          educationId == other.educationId &&
          name == other.name &&
          isRestricted == other.isRestricted;
}
