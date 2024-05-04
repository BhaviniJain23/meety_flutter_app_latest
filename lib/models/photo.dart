import 'dart:io';

class Photo {
  String? id;
  String? url;
  File? file;

  Photo({required this.id, this.url, this.file});

  bool get isUploaded => url != null;

  bool get isLocal => file != null;

  bool get isNew => id == null;
}