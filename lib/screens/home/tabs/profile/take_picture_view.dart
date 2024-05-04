import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';

class TakePictureView extends StatefulWidget {
  const TakePictureView({Key? key}) : super(key: key);

  @override
  State<TakePictureView> createState() => _TakePictureViewState();
}

class _TakePictureViewState extends State<TakePictureView> {
  late CameraController _controller;
  File? capturedImage;
  String? errorMessage;
  final ValueNotifier<bool> isRecording = ValueNotifier(false);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<int> progress = ValueNotifier(-1);
  DateTime? recordingStartTime; // Variable to store the recording start time
  final _duration = ValueNotifier(const Duration(seconds: 5));
  // Define a Timer object
  Timer? _timer;
  final _countdownValue = ValueNotifier(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return !isLoading.value;
      },
      child: Scaffold(
        appBar: AppBarX(
          elevation: 0,
          title: "Verify your profile",
          leading: BackBtnX(
            onPressed: () {
              if (!isLoading.value) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: height * 0.01,
              ),
              Center(
                child: ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (BuildContext context, loadingVal, _) {
                      return FutureBuilder<void>(
                        future: initializeCamera(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              !loadingVal) {
                            // If the Future is complete, display the preview.
                            if (_controller.value.isInitialized) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Text(
                                      UiString.verificationDescription,
                                      style: context.textTheme.bodySmall,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                      width: width * 0.9,
                                      height: height * 0.6,
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: CameraPreview(_controller))),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  ValueListenableBuilder(
                                      valueListenable: isRecording,
                                      builder:
                                          (BuildContext context, recordVal, _) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          child: FillBtnX(
                                            onPressed: () async {
                                              if (!recordVal) {
                                                await startRecording();
                                                startTimer();
                                              }
                                            },
                                            text: !recordVal
                                                ? UiString
                                                    .startRecordingButtonText
                                                : UiString
                                                    .stopRecordingButtonText,
                                          ),
                                        );
                                      }),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: height * 0.3,
                                    width: width * 0.9,
                                    child: Image.asset(
                                      Assets.enableCamera,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: HeadingStyles.boardingHeading(
                                      context,
                                      UiString.enableCameraTitle,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child:
                                          HeadingStyles.boardingHeadingCaption(
                                              context,
                                              UiString.enableCameraCaption)),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30.0),
                                    child: FillBtnX(
                                      onPressed: () async {
                                        await openAppSettings();
                                        setState(() {});
                                      },
                                      text: UiString.openSetting,
                                    ),
                                  ),
                                ],
                              );
                            }
                          } else {
                            // Otherwise, display a loading indicator.
                            return Column(
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: progress,
                                    builder: (context, progressV, _) {
                                      if (progressV != -1) {
                                        return SizedBox(
                                          width: width * 0.8,
                                          height: width * 0.8,
                                          child: CircularPercentIndicator(
                                            radius: 60.0,
                                            lineWidth: 5.0,
                                            percent: (progressV / 100),
                                            center: Text(
                                                "${progressV.toString()}%"),
                                            progressColor: red,
                                          ),
                                        );
                                      }
                                      return Container(
                                        height: width * 0.5,
                                      );
                                    }),
                                InkWell(
                                  onTap: () async {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: Text(
                                      "Please Wait While Uploading The Video For Profile Verification",
                                      style: context.textTheme.titleMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              ],
                            );
                          }
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initializeCamera() async {
    List<CameraDescription> cameras = (await availableCameras());

    _controller = CameraController(cameras[1], ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);

    try {
      await _controller.initialize();
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          case 'CameraAccessDeniedWithoutPrompt':
          case 'CameraAccessRestricted':
            // Handle access errors here.
            errorMessage = "PermissionError";
            return;
          default:
            errorMessage = "${e.description}";

            return;
        }
      }
      errorMessage = e.toString();
      return;
    }
    return;
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_duration.value.inSeconds <= 0) {
        // Countdown is finished
        await stopRecording();
        _timer?.cancel();
        // Perform any desired action when the countdown is completed
      } else {
        // Update the countdown value and decrement by 1 second
        _countdownValue.value = _duration.value.inSeconds;
        _duration.value = _duration.value - const Duration(seconds: 1);
      }
    });
  }

  Future<void> startRecording() async {
    if (!isRecording.value) {
      recordingStartTime = DateTime.now(); // Start the timer
      isRecording.value = true;
      await _controller.startVideoRecording();
    }
  }

  Future<void> stopRecording() async {
    if (isRecording.value) {
      final xFile = await _controller.stopVideoRecording();
      final videoFile = File(xFile.path);
      _controller.pausePreview();
      isRecording.value = false;
      if (recordingStartTime != null) {
        final recordingDuration =
            DateTime.now().difference(recordingStartTime!);

        if (recordingDuration.inSeconds > 4) {
          recordingStartTime = null; // Reset the start time
          Future.delayed(Duration.zero, () {
            AlertService.showAlertMessageWithTwoBtn(
                context: context,
                alertTitle: UiString.uploadVerificationVideoTitle,
                alertMsg: UiString.uploadVerificationVideoMessage,
                positiveText: UiString.yesButtonText,
                negativeText: UiString.noButtonText,
                yesTap: () {
                  isLoading.value = true;
                  verifyYourPhotoApiCall(videoFile.path);
                },
                noTap: () {
                  Navigator.of(context).pop();
                  _controller.resumePreview();
                });
          });
        } else {
          Future.delayed(Duration.zero, () {
            context.showSnackBar(UiString.videoDurationErrorMessage);
          });
        }
      }
    }
  }

  Future<void> verifyYourPhotoApiCall(String imagePath) async {
    try {
      isLoading.value = true;
      // User? user = sl<SharedPrefsManager>().getUserDataInfo();
      progress.value = 0;
      Map<String, dynamic> apiResponse =
          await UserRepository().verifyYourProfile(
              data: {},
              images: imagePath,
              onUploadProgress: (percentage) async {
                progress.value = percentage;
              });
      progress.value = 100;

      if (apiResponse[UiString.successText]) {
        Future.delayed(const Duration(milliseconds: 100), () {
          context.showSnackBar(apiResponse[UiString.messageText]);
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
      progress.value = -1;
    }
  }
}
