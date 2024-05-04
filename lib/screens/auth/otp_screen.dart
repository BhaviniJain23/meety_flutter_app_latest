import 'dart:async';
import 'dart:ui' as ui show PlaceholderAlignment;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../constants/size_config.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String sender;
  final bool isFromForgotPassword;
  final bool isFromAccountSetting;

  const OTPVerificationScreen({
    Key? key,
    required this.sender,
    required this.isFromForgotPassword,
    required this.isFromAccountSetting,
  }) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController _otpTextController = TextEditingController();
  late Timer _timer;
  Duration  _start = const Duration(minutes: 1);
  bool enableBtn = false;
  final NavigationService _navigationService = sl<NavigationService>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _otpTextController.addListener(() {
      if (_otpTextController.text.length > 3) {
        enableBtn = true;
        setState(() {});
      } else if (enableBtn) {
        enableBtn = false;
        setState(() {});
      }
    });
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_timer.isActive) {
          context.showSnackBar(
              "Please Wait for the verification Code until the timer stops.");
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBarX(
          title: '',
          leading: BackBtnX(
            onPressed: () {
              if (!_timer.isActive) {
                sl<NavigationService>().pop();
              } else {
                context.showSnackBar(
                    "Please Wait for the verification Code until the timer stops.");
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Text(
                    _start.toMinSecond(),
                    style: context.textTheme.displaySmall?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 34),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${UiString.otpCaption}${widget.sender}',
                  style: context.textTheme.bodyMedium!
                      .copyWith(color: 0xff868D95.toColor, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
                OtpInput(
                  textController: _otpTextController,
                ),
                const SizedBox(
                  height: 10,
                ),
                KeyboardPad(textController: _otpTextController),
                const SizedBox(
                  height: 20,
                ),
                FillBtnX(
                    onPressed: () async {
                      if (enableBtn) {
                        if (!widget.isFromAccountSetting) {
                          verifyOTPCode();
                        } else {
                          await Provider.of<EditUserProvider>(context,
                                  listen: false)
                              .updateEmail(context, widget.sender,
                                  _otpTextController.text);
                          _navigationService.pop();
                        }
                      }
                    },
                    color: enableBtn ? red : grey,
                    text: 'Verify OTP'),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  textAlign: TextAlign.center,
                  UiString.verificationEmailInYourInbox,
                  style: TextStyle(
                    fontSize: ResponsiveDesign.fontSize(9, context),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text.rich(
                  TextSpan(
                      text: 'Didn\'t receive any OTP ? ',
                      style: context.textTheme.titleMedium,
                      children: [
                        WidgetSpan(
                            alignment: ui.PlaceholderAlignment.middle,
                            child: UnderlineTextBtnX(
                                onPressed: () {
                                  if (_start == const Duration(seconds: 0)) {
                                    resendOTP();
                                  }
                                },
                                textStyle: context.textTheme.titleMedium,
                                color: _start != const Duration(seconds: 0)
                                    ? Colors.grey
                                    : red,
                                text: UiString.resendText)),
                      ]),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == const Duration(seconds: 0)) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start = _start - oneSec;
          });
        }
      },
    );
  }

/*  Future<void> loginWithPhone() async {
    bool isInternet =
        await InternetConnectionService.getInstance().hasInternetConnection();
    if (isInternet) {
      Map<String, dynamic> apiResponse =
          await AuthRepository().userSignedInWithPhone(phone: widget.sender);
      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null) {
          model_user.User user =
              model_user.User.fromJson(apiResponse[UiString.dataText]);
          await sl<SharedPrefsManager>().saveUserInfo(user);
          Future.delayed(const Duration(seconds: 0), () {
            if (user.dob != null && user.dob!.isNotEmpty) {
              context.showSnackBar(apiResponse[UiString.messageText]);
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutePaths.home, (route) => false);
            } else {
              context.showSnackBar(apiResponse[UiString.messageText]);
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutePaths.boardingProfile, (route) => false);
            }
          });
        } else {}
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.error);
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(UiString.noInternet);
      });
    }
  }*/

  Future<void> verifyOTPCode() async {
    try {
      FocusScope.of(context).unfocus(); //to hide the keyboard - if an
      bool isInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (isInternet) {
        Map<String, dynamic> apiResponse = await AuthRepository()
            .verifyEmailOTP(email: widget.sender, otp: _otpTextController.text);

        if (apiResponse[UiString.successText]) {
          if (apiResponse[UiString.dataText] != null) {
            if ((apiResponse[UiString.dataText] as Map).containsKey("token")) {
              await sl<SharedPrefsManager>()
                  .saveToken(apiResponse[UiString.dataText]['token']);
            }
            Future.delayed(const Duration(seconds: 0), () async {
              User user = User.fromJson(apiResponse[UiString.dataText]);

              if (!widget.isFromForgotPassword) {
                context.showSnackBar(apiResponse[UiString.messageText]);
                await sl<SharedPrefsManager>().saveUserInfo(user);

                if (user.dob != null && user.dob!.isNotEmpty) {
                  if (user.images != null && user.images!.isEmpty) {
                    _navigationService.navigateTo(RoutePaths.addPhotos,
                        withPushAndRemoveUntil: true);
                  } else {
                    // context.showSnackBar(apiResponse[UiString.messageText]);
                    _navigationService.navigateTo(RoutePaths.enableLocation,
                        withPushAndRemoveUntil: true, arguments: true);
                  }
                }else{
                  _navigationService.navigateTo(
                    RoutePaths.boardingProfile,
                    withPushAndRemoveUntil: true,
                  );
                }
              } else {
                _navigationService.navigateTo(RoutePaths.resetPassword,
                    withPopAndPush: true, arguments: user.id.toString());
              }
            });
          } else {
            Future.delayed(const Duration(seconds: 0), () {
              context.showSnackBar(apiResponse[UiString.messageText]);
            });
          }
        } else {
          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(apiResponse[UiString.messageText]);
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.noInternet);
        });
      }
    } on Exception {
      if (kDebugMode) {
        // print("On register:$e");
      }
    }
  }

  Future<void> resendOTP() async {
    try {
      FocusScope.of(context).unfocus(); //to hide the keyboard - if an
      bool isInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (isInternet) {
        Map<String, dynamic> apiResponse = {};
        if (widget.isFromForgotPassword) {
          apiResponse = await UserRepository()
              .sendEmailOTPFromSetting(email: widget.sender);
        } else {
          apiResponse =
              await AuthRepository().resendEmailOTP(email: widget.sender);
        }
        if (apiResponse[UiString.successText]) {
          if (apiResponse[UiString.dataText] != null) {
            Future.delayed(const Duration(seconds: 0), () {
              context.showSnackBar(apiResponse[UiString.messageText]);
            });
          } else {
            Future.delayed(const Duration(seconds: 0), () {
              context.showSnackBar(apiResponse[UiString.messageText]);
            });
          }
        } else {
          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(apiResponse[UiString.messageText]);
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.noInternet);
        });
      }
    } on Exception {
      if (kDebugMode) {
        // print("On register:$e");
      }
    }
  }
}

class OtpInput extends StatelessWidget {
  const OtpInput({
    super.key,
    required TextEditingController textController,
  }) : _textController = textController;

  final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: PinCodeTextField(
        appContext: context,
        onChanged: (val) {},
        length: 4,
        animationType: AnimationType.fade,
        textStyle: const TextStyle(
            color: white, fontWeight: FontWeight.bold, fontSize: 26),
        pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            fieldHeight: 50,
            fieldWidth: 50,
            selectedFillColor: white,
            selectedColor: red,
            activeColor: red,
            inactiveColor: 0xffE8E6EA.toColor,
            inactiveFillColor: white,
            activeFillColor: red,
            borderRadius: BorderRadius.circular(8)),
        cursorColor: context.theme.primaryColor,
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        keyboardType: TextInputType.none,
        controller: _textController,
        onCompleted: (v) {
          debugPrint('Completed');
        },
        beforeTextPaste: (text) {
          debugPrint('Allowing to paste $text');
          return true;
        },
      ),
    );
  }
}

class KeyboardPad extends StatelessWidget {
  const KeyboardPad({
    super.key,
    required TextEditingController textController,
  }) : _textController = textController;

  final TextEditingController _textController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [...renderKeyboard()],
    );
  }

  onKeyTap(val) {
    if (val.isNotEmpty && _textController.text.length < 4) {
      _textController.text = _textController.text + val;
    }
  }

  onBackspacePress() {
    if (_textController.text.isEmpty) {
      return;
    }

    _textController.text =
        _textController.text.substring(0, _textController.text.length - 1);
  }

  renderKeyboard() {
    return ConstantList.keys
        .map(
          (x) => Row(
            children: x.map(
              (y) {
                return Expanded(
                  child: KeyboardKey(
                    label: y,
                    value: y,
                    onTap: (val) {
                      if (val is Widget) {
                        onBackspacePress();
                      } else {
                        onKeyTap(val);
                      }
                    },
                  ),
                );
              },
            ).toList(),
          ),
        )
        .toList();
  }
}
