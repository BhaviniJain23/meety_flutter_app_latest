class Location {
  Location({
    this.name,
    this.latitude,
    this.longitude,
  });

  final String? name;
  final String? latitude;
  final String? longitude;

  Location copyWith({
    String? name,
    String? latitude,
    String? longitude,
  }) =>
      Location(
        name: name ?? this.name,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    name: json['name'] ?? '${json["city"]}, ${json["state"]}',
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "latitude": latitude,
    "longitude": longitude,
  };

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }
}
