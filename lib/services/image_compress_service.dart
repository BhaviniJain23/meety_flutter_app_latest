import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:light_compressor/light_compressor.dart' as light;
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ImageCompressService {
  final File file;

  ImageCompressService({required this.file});

  Future<File?> exec() async {
    return await _compressAndGetList(file);
  }

  Future<File?> execVideo({OnUploadProgressCallback? onUploadProgress}) async {
    return (await compressVideo(onUploadProgress:onUploadProgress));
  }

  String _timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<File?> _compressAndGetList(File file) async {
    final result = await FlutterImageCompress.compressWithList(
      file.readAsBytesSync(),
      minHeight: 1080,
      minWidth: 1080,
      quality: 96,
      format: CompressFormat.webp,
    );
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = "${dir.absolute.path}/${_timestamp()}.webp";
    final File file1 = await File(targetPath).create();
    await file1.writeAsBytes(result);
    return file1;
  }

   Future<File?> compressVideo({OnUploadProgressCallback? onUploadProgress}) async {
     var compressedVideo =  light.LightCompressor();
     if(onUploadProgress != null){
      compressedVideo.onProgressUpdated.listen((event) {
        onUploadProgress(event.toInt());
      });
    }
    light.Result resullt = await compressedVideo.compressVideo(
        path: file.path,
        android: light.AndroidConfig(
          isSharedStorage: false
        ),
        ios: light.IOSConfig(
          saveInGallery: false
        ),
        video: light.Video(videoName: file.path.split("/").last),
        videoQuality: light.VideoQuality.high,
        isMinBitrateCheckEnabled: false,
    );

     if(resullt is light.OnSuccess){
       return File(resullt.destinationPath);

     }else{
       return file;

     }
  }

}