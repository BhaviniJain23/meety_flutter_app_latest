// ignore_for_file: unused_field, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/data/repository/chat_repo.dart';
import 'package:meety_dating_app/models/user_basic_info.dart';
import 'package:meety_dating_app/providers/single_chats_provider.dart';
import 'package:meety_dating_app/services/image_compress_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/textfields.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

import '../../../../constants/ui_strings.dart';
import '../../../../services/navigation_service.dart';
import '../../../../services/singleton_locator.dart';

class ImageCropPreview extends StatefulWidget {
  final SingleChatProvider singleChatProvider;
  final String imagePath;
  final String channelId;

  const ImageCropPreview(
      {Key? key, required this.imagePath, required this.channelId, required this.singleChatProvider})
      : super(key: key);

  @override
  State<ImageCropPreview> createState() => _ImageCropPreviewState();
}

class _ImageCropPreviewState extends State<ImageCropPreview> {
  CroppedFile? croppedFile;
  TextEditingController controller = TextEditingController();
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(
        title: '',
        height: 80,
        trailing: IconButton(
          onPressed: () async {
            croppedFile = await ImageCropper().cropImage(
              sourcePath: widget.imagePath,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
              uiSettings: [
                AndroidUiSettings(
                  toolbarTitle: '',
                  toolbarColor: white,
                  toolbarWidgetColor: Colors.black,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false,
                ),
              ],
            );
            setState(() {});
          },
          icon: const Icon(
            Icons.crop,
            color: black,
            size: 28,
          ),
        ),
      ),
      backgroundColor: white,
      body: Column(
        children: [
          Expanded(
              child: Stack(
            children: [
              SizedBox(
                height: context.height * 0.9,
                width: double.maxFinite,
                // color:Colors.black,
                child: Image.file(File(croppedFile != null
                    ? croppedFile!.path
                    : widget.imagePath)),
              ),
            ],
          )),
          SizedBox(
            height: ResponsiveDesign.height(20, context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextFieldX(
                controller: controller,
                hint: "Add a Caption...",
                hintStyle: const TextStyle(fontSize: 15)),
          ),
          SizedBox(
            height: ResponsiveDesign.height(10, context),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: SizedBox(
                height: 50,
                width: 50,
                child: OutLineBtnX2(
                  onPressed: () async {
                    ImageCompressService imageCompressService;
                    if (croppedFile != null) {
                      imageCompressService = ImageCompressService(
                        file: File(croppedFile!.path),
                      );
                    } else {
                      imageCompressService = ImageCompressService(
                        file: File(widget.imagePath),
                      );
                    }
                    // ignore: unused_local_variable
                    final resultFile = await imageCompressService.exec();
                    if (resultFile != null) {
                      await uploadChatImages(resultFile.path);
                    }
                  },
                  radius: 12,
                  child: const Icon(Icons.send),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> uploadChatImages(String imagePath) async {
    try {
      isLoading.value = true;
      // User? user = sl<SharedPrefsManager>().getUserDataInfo();
      Map<String, dynamic> apiResponse =
          await ChatRepository().uploadChatImage(data: {}, images: imagePath);
      if (apiResponse[UiString.successText]) {
        context.showSnackBar(apiResponse[UiString.messageText]);

        final loggedInUser =
        UserBasicInfo.fromUser(sl<SharedPrefsManager>().getUserDataInfo()!);

        widget.singleChatProvider.chatController.text = controller.text;
        await widget.singleChatProvider.sendMessage(context,loggedInUser,file:apiResponse[UiString.dataText] );

        Future.delayed(const Duration(seconds: 0), () {
          sl<NavigationService>().pop();
        });

      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
        });
      }
    } catch (e) {
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(e.toString());
      });
    } finally {
      isLoading.value = false;
    }
  }
}
