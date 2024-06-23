// ignore_for_file: prefer_is_empty, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/photo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/photo_provider.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

class AddPhotos extends StatefulWidget {
  final List<String> editImages;

  const AddPhotos({Key? key, this.editImages = const []}) : super(key: key);

  @override
  State<AddPhotos> createState() => _AddPhotosState();
}

class _AddPhotosState extends State<AddPhotos> {
  List<Photo> images = [];
  List<String> filename = [];
  User? user;
  final ValueNotifier<int> _reorderStart = ValueNotifier(-1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) =>
          PhotosProvider()..addAllPhoto(widget.editImages),
      child: Consumer<PhotosProvider>(
        builder: (context, provider, child) {
          images = List.from(provider.photos);

          if (provider.photos.isNotEmpty) {
            return Scaffold(
              appBar: _buildAppBar(),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _buildBodyChildren(context, provider),
                ),
              ),
              bottomNavigationBar: _buildBottomNavigationBar(provider),
            );
          } else {
            // ignore: deprecated_member_use
            return WillPopScope(
              onWillPop: () async {
                _showExitAppAlert(context);
                return false;
              },
              child: Scaffold(
                appBar: _buildAppBar(),
                body: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildBodyChildren(context, provider),
                  ),
                ),
                bottomNavigationBar: _buildBottomNavigationBar(provider),
              ),
            );
          }
        },
      ),
    );
  }

  AppBarX _buildAppBar() {
    return AppBarX(
      title: widget.editImages.isNotEmpty ? UiString.editPhotos : '',
      trailing: _buildAppBarTrailing(),
      leading: _buildAppBarLeading(),
    );
  }

  List<Widget> _buildBodyChildren(
      BuildContext context, PhotosProvider provider) {
    final children = <Widget>[];

    if (widget.editImages.isEmpty) {
      children.addAll([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: HeadingStyles.boardingHeading(context, UiString.addPhotos),
        ),
        SizedBox(height: ResponsiveDesign.height(5, context)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: HeadingStyles.boardingHeadingCaption(
            context,
            UiString.addPhotosSubCaption,
          ),
        ),
      ]);
    } else {
      children.addAll([
        SizedBox(height: ResponsiveDesign.height(5, context)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: HeadingStyles.boardingHeadingCaption(
            context,
            UiString.editPhotoSubCaption,
          ),
        )
      ]);
    }
    children.addAll([
      Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: ReorderableWrap(
            runSpacing: 10,
            spacing: 10,
            onReorder: (int oldIndex, int newIndex) {
              if (images.length > oldIndex && images.length > newIndex) {
                context.read<PhotosProvider>().reOrderPhoto(oldIndex, newIndex);
                _reorderStart.value = -1;
              }
            },
            onNoReorder: (int index) {
              _reorderStart.value = -1;
              debugPrint(
                  '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
            },
            onReorderStarted: (int index) {
              _reorderStart.value = index;
              debugPrint(
                  '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
            },
            children: List.generate(6, (index) {
              return buildImageContainer(index, provider);
            }),
          ),
        ),
      ),
      SizedBox(
        height: ResponsiveDesign.height(50, context),
      )
    ]);

    return children;
  }

  Widget buildImageContainer(int index, PhotosProvider provider) {
    final showLoaderValue = provider.loadingIndex == index
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Container();

    if (images.length <= index) {
      var width = context.width;

      return ValueListenableBuilder(
        valueListenable: _reorderStart,
        builder: (context, value, _) {
          return SizedBox(
            height:
                _reorderStart.value == index ? (width * 0.40) : (width * 0.42),
            width:
                _reorderStart.value == index ? (width * 0.40) : (width * 0.42),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    dashPattern: const [6, 6, 6, 6],
                    padding: EdgeInsets.zero,
                    strokeWidth: 2,
                    color: Colors.grey,
                    radius: const Radius.circular(8),
                    child: Container(),
                  ),
                ),
                buildReorderActions(provider, index),
                showLoaderValue,
              ],
            ),
          );
        },
      );
    } else {
      final image = images[index].isUploaded
          ? Image.network(images[index].url ?? '')
          : Image.file(
              File(images[index].file?.path ?? ''),
            );
      final completer = Completer<ui.Image>();

      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener(
          (ImageInfo info, bool synchronousCall) {
            completer.complete(info.image);
          },
        ),
      );

      return ValueListenableBuilder(
        valueListenable: _reorderStart,
        builder: (context, value, _) {
          return FutureBuilder<ui.Image>(
            future: completer.future,
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
              if (snapshot.hasData) {
                final ui.Image imageInfo = snapshot.data!;
                final imageHeight = imageInfo.height;
                final imageWidth = imageInfo.width;
                return Container(
                  height: context.width * 0.42,
                  width: context.width * 0.42,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: (imageWidth / imageHeight),
                            child: Container(
                              height: imageHeight.toDouble(),
                              width: imageWidth.toDouble(),
                              decoration: BoxDecoration(
                                color: const Color(0xffe9ebee),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: (images.length > index)
                                  ? SizedBox(
                                      height: imageHeight.toDouble(),
                                      width: imageWidth.toDouble(),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            (imageWidth / imageHeight) == 1
                                                ? 8
                                                : 0),
                                        child: images[index].isUploaded
                                            ? Image.network(
                                                images[index].url ?? '',
                                                errorBuilder:
                                                    (context, object, stack) {
                                                  return Text(stack.toString());
                                                },
                                                fit: BoxFit.cover,
                                              )
                                            : Image.file(
                                                File(images[index].file?.path ??
                                                    ''),
                                                errorBuilder:
                                                    (context, object, stack) {
                                                  return Text(stack.toString());
                                                },
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      buildReorderActions(provider, index),
                      showLoaderValue,
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                // Handle the error here.
              }

              return SizedBox(
                height: (context.height * 0.19),
                width: (context.width * 0.26),
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          );
        },
      );
    }
  }

  Widget buildReorderActions(PhotosProvider provider, int index) {
    if (_reorderStart.value != index) {
      return Positioned(
        right: 0,
        bottom: 0,
        child: Row(
          children: [
            if (widget.editImages.isEmpty && images.length > index) ...[
              InkWell(
                onTap: () async {
                  showImagePicker(index, provider);
                },
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: white,
                    boxShadow: [
                      BoxShadow(
                        color: grey,
                        offset: Offset(-1, 0),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: red,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(
                width: 2,
              )
            ],
            if ((images.length <= index) ||
                ((widget.editImages.isNotEmpty &&
                        !provider.hasAtLeastTwoPhotos) ||
                    widget.editImages.isEmpty))
              InkWell(
                onTap: () async {
                  if (widget.editImages.isNotEmpty) {
                    if (images.length > index) {
                      if (images.length > Utils.minPhotos) {
                        AlertService.showAlertMessageWithTwoBtn(
                          context: context,
                          alertTitle: "Are you sure you want to delete it ?",
                          alertMsg: "This action cannot be undone.",
                          positiveText: "Delete",
                          negativeText: "Cancel",
                          yesTap: () async {
                            deletePhoto(provider, index);
                          },
                        );
                      } else {
                        Future.delayed(const Duration(seconds: 0), () {
                          context.showSnackBar(UiString.photosRestriction);
                        });
                      }
                    } else {
                      showImagePicker(index, provider);
                    }
                  } else {
                    if (images.length > index) {
                      provider.deletePhoto(index.toString());
                    } else {
                      showImagePicker(index, provider);
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: grey,
                        offset: Offset(-0.5, 0),
                        blurRadius: 1,
                      ),
                    ],
                    color: red,
                  ),
                  child: images.length > index
                      ? (widget.editImages.isNotEmpty &&
                                  !provider.hasAtLeastTwoPhotos) ||
                              widget.editImages.isEmpty
                          ? const Icon(
                              Icons.close,
                              color: white,
                              size: 20,
                            )
                          : null
                      : const Icon(
                          Icons.add,
                          color: white,
                          size: 20,
                        ),
                ),
              ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildBottomNavigationBar(PhotosProvider provider) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: ResponsiveDesign.height(10, context), left: 15, right: 15),
      child: FillBtnX(
          onPressed: () async {
            if (widget.editImages.isNotEmpty &&
                (provider.checkIsAnyFileInList ||
                    provider.photos.length != widget.editImages.length)) {
              await provider.updatePhotosInDatabase(context, filename);
            } else if (widget.editImages.isEmpty &&
                images.length >= Utils.minPhotos) {
              await provider.addPhotosInDatabase(context);
            }
          },
          isDisabled: !((widget.editImages.isNotEmpty &&
                  (provider.checkIsAnyFileInList ||
                      provider.photos.length != widget.editImages.length)) ||
              (widget.editImages.isEmpty && images.length >= Utils.minPhotos)),
          text: widget.editImages.isNotEmpty ? UiString.update : UiString.next),
    );
  }

  Widget _iconWithTitle(
      {required Widget icon,
      required String title,
      required GestureTapCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Material(
            elevation: 5,
            shape: const CircleBorder(),
            shadowColor: const Color(0xffff9999),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: red,
              ),
              child: icon,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            title,
            style: context.textTheme.titleMedium,
          )
        ],
      ),
    );
  }

  void _showExitAppAlert(BuildContext context) {
    AlertService.showAlertMessageWithBtn(
      context: context,
      alertMsg: "Are you sure you want to exit the app?",
      yesTap: () async {
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
      positiveText: 'Yes',
      negativeText: 'No',
    );
  }

  Widget? _buildAppBarTrailing() {
    if (widget.editImages.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: TextBtnX(
          color: red,
          onPressed: () {
            AlertService.showAlertMessageWithBtn(
                context: context,
                alertMsg: "Are you sure you want to logout?",
                yesTap: () async {
                  sl<SharedPrefsManager>().logoutUser(context);
                },
                positiveText: 'Yes',
                negativeText: 'No');
          },
          text: UiString.logout,
        ),
      );
    }
    return null;
  }

  Widget? _buildAppBarLeading() {
    if (widget.editImages.isEmpty) {
      return BackBtnX(
        onPressed: () {
          _showExitAppAlert(context);
        },
      );
    }
    return null;
  }

  imagePicker(String type, int index, PhotosProvider provider) async {
    XFile? file;
    ImagePicker picker = ImagePicker();
    if (type == UiString.camera) {
      final cameraPermission = await Utils.checkCameraPermission(context);
      if (cameraPermission) {
        file = await picker.pickImage(source: ImageSource.camera);
      }
    } else if (type == UiString.gallery) {
      final galleryPermission = await Utils.checkGalleryPermission(context);

      if (galleryPermission) {
        file = await picker.pickImage(source: ImageSource.gallery);
      }
    }
    if (file != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedFile != null) {
        Photo tempPhoto =
            Photo(id: index.toString(), file: File(croppedFile.path));
        if (images.length <= index) {
          provider.addPhoto(tempPhoto);
        } else {
          provider.editPhoto(tempPhoto);
        }
      }
    }
  }

  void showImagePicker(int index, PhotosProvider provider) {
    BottomSheetService.showBottomSheet(
        context: context,
        builder: (bottomSheet, state) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
            child: Wrap(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _iconWithTitle(
                        onTap: () {
                          Navigator.pop(bottomSheet);
                          imagePicker(UiString.gallery, index, provider);
                        },
                        icon: const Icon(
                          Icons.photo_library,
                          color: white,
                          size: 25,
                        ),
                        title: UiString.gallery),
                    _iconWithTitle(
                        icon: const Icon(
                          Icons.camera_enhance,
                          color: white,
                          size: 25,
                        ),
                        title: UiString.camera,
                        onTap: () {
                          Navigator.pop(bottomSheet);
                          imagePicker(UiString.camera, index, provider);
                        }),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          );
        });
  }

  Future<void> deletePhoto(PhotosProvider provider, int index) async {
    if (images[index].isUploaded) {
      filename.add(images[index].url.toString().extractNameFromFilePath());
      Map<String, dynamic> apiResponse = await UserRepository()
          .deleteProfilePic(
              userId: user?.id ?? "", filename: images[index].file?.path ?? "");
      log("deletePhoto: ${apiResponse.toString()}");
      provider.updateLoadingIndex(index);
      Future.delayed(const Duration(seconds: 1), () {
        provider.deletePhoto(index.toString());
      });
    } else {
      provider.deletePhoto(index.toString());
    }
  }
}
