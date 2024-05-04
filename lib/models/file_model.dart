class FileModel {
  FileModel({
    required this.url,
    required this.thumbnailImage,
    required this.filename,
    required this.size,
    required this.extension,
  });

  String url;
  String thumbnailImage;
  String filename;
  String size;
  String extension;

  factory FileModel.fromJson(Map<String, dynamic> json) => FileModel(
    url: json["url"],
    thumbnailImage: json["thumbnailImage"],
    filename: json["filename"],
    size: json["size"],
    extension: json["extension"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "thumbnailImage": thumbnailImage,
    "filename": filename,
    "size": size,
    "extension": extension,
  };

  @override
  String toString() {
    // TODO: implement toString
    return toJson().toString();
  }

}
