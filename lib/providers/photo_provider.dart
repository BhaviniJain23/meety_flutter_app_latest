import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/photo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

class PhotosProvider with ChangeNotifier {
  final List<Photo> _photos = [];

  int _loadingIndex = -1;

  List<Photo> get photos => _photos;

  int get loadingIndex => _loadingIndex;

  bool get hasAtLeastTwoPhotos => _photos.length <= Utils.minPhotos;

  bool get checkIsAnyFileInList =>
      _photos.indexWhere((element) => element.isLocal) != -1;

  void clearProvider() {
    _photos.clear();
    _loadingIndex = 1;
    notifyListeners();

  }

  void updateLoadingIndex(int value) {
    _loadingIndex = value;
    notifyListeners();
  }

  void addAllPhoto(List<String> newPhotos) {
    // print("newPhotos:,$newPhotos");
    _photos.clear();
    for (int i = 0; i < newPhotos.length; i++) {
      _photos.add(Photo(id: i.toString(), url: newPhotos[i]));
    }
    notifyListeners();
  }

  void addPhoto(Photo photo) {
    _photos.add(photo);
    notifyListeners();
  }

  void editPhoto(Photo photo) {
    final index = _photos.indexWhere((p) => p.id == photo.id);
    _photos[index] = photo;
    notifyListeners();
  }

  void deletePhoto(String id) {
    _photos.removeWhere((p) => p.id == id);
    _loadingIndex = -1;
    notifyListeners();
  }

  void reOrderPhoto(int oldIndex, int newIndex) {

    Photo imgPhoto = _photos.removeAt(oldIndex);
    _photos.insert(newIndex, imgPhoto);
    notifyListeners();
  }


  Future<void> addPhotosInDatabase(BuildContext context) async {
    try {
      User? user = sl<SharedPrefsManager>().getUserDataInfo();

      List<String> images =
          List.from(_photos.map((e) => e.isLocal ? e.file?.path : e.url));

      Map<String, dynamic> apiResponse =
          await UserRepository().addMultiProfilePic(data: {
        // 'user_id': user?.id ?? '0',
     }, images: images);

      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null && apiResponse[UiString.dataText].containsKey('images')) {
          user = user!.copyWith(
              images: (apiResponse[UiString.dataText]['images'] as List)
                  .map((e) => e.toString())
                  .toList());
          await sl<SharedPrefsManager>().saveUserInfo(user);

          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(apiResponse[UiString.messageText]);
            Navigator.pushNamedAndRemoveUntil(
                context, RoutePaths.enableLocation, (route) => false,
                arguments: true);
          });
        }
        else {
          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(apiResponse[UiString.messageText]);
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.error);
        });
      }

    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePhotosInDatabase(
      BuildContext context, removeFilename) async {
    try {
      User? user = sl<SharedPrefsManager>().getUserDataInfo();

      List<String> images =
          List.from(_photos.map((e) => e.isLocal ? e.file?.path : e.url));




      Map<String, dynamic> apiResponse =
          await UserRepository().updateProfilePic(data: {
        'filenames': removeFilename.join(),
      }, images: images);

      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null) {
          user = user?.copyWith(
              images: (apiResponse[UiString.dataText] as List)
                  .map((e) => e.toString())
                  .toList());
          await sl<SharedPrefsManager>().saveUserInfo(user!);

          Future.delayed(const Duration(seconds: 0), () {
            final provider =
                Provider.of<EditUserProvider>(context, listen: false);


            provider.updateImages(user?.images ?? []);
            context.showSnackBar(apiResponse[UiString.messageText]);
            Navigator.pop(context);
          });
        } else {
          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(apiResponse[UiString.messageText]);
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.error);
        });
      }
    } catch (e) {
      rethrow;
    }
  }
}
