import 'dart:developer';
import 'dart:ui' as ui show PlaceholderAlignment;
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/screens/auth/widgets/social_login_buttons.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';

import '../../config/routes_path.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final NavigationService _navigationService = sl<NavigationService>();
  final ValueNotifier<bool> _isApiCall = ValueNotifier(false);
  ValueNotifier<bool> _isAgree = ValueNotifier(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserEmailPassword();
  }

  void _loadUserEmailPassword() async {
    try {
      final data = sl<SharedPrefsManager>().getRememberUserDataInfo();
      if (data != null &&
          data.containsKey("email") &&
          data.containsKey("password")) {
        _emailController.text = data['email'];
        _passController.text = data['password'];
        _isAgree = ValueNotifier(true);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: white,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Image.asset(
              Assets.dummyLogin,
              fit: BoxFit.fitWidth,
              height: ResponsiveDesign.height(380, context),
              width: ResponsiveDesign.width(200, context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ValueListenableBuilder(
                  valueListenable: _isApiCall,
                  builder: (context, value, child) {
                    return IgnorePointer(
                      ignoring: value,
                      child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: ResponsiveDesign.height(0, context),
                              ),
                              EmailTextField(textController: _emailController),
                              SizedBox(
                                height: ResponsiveDesign.height(13, context),
                              ),
                              PassTextField(textController: _passController),
                              // const SizedBox(height: 8),

                              /// Forgot Password Button
                              Flexible(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ValueListenableBuilder(
                                        valueListenable: _isAgree,
                                        builder: (context, value, child) {
                                          return SizedBox(
                                            width: 20,
                                            height: 24,
                                            child: Checkbox(
                                              value: value,
                                              onChanged: (checkNewVal) {
                                                _isAgree.value =
                                                    checkNewVal ?? false;
                                              },
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(3)),
                                            ),
                                          );
                                        }),
                                    SizedBox(
                                      width: ResponsiveDesign.width(5, context),
                                    ),
                                    const Text("Remember Me"),
                                    const Flexible(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          // SizedBox(
                                          //   width:
                                          //       ResponsiveDesign.width(150, context),
                                          // ),
                                          ForgotPassBtn(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveDesign.height(2, context),
                              ),
                              FillBtnX(
                                onPressed: login,
                                text: UiString.signInText,
                              ),
                              SizedBox(
                                height: ResponsiveDesign.height(18, context),
                              ),
                              const OrSigninWith(),
                              SizedBox(
                                height: ResponsiveDesign.height(18, context),
                              ),
                              const SocialLoginBtns(),
                              SizedBox(
                                height: ResponsiveDesign.height(5, context),
                              ),
                              Text.rich(
                                TextSpan(
                                    text: UiString.signInCaptionText,
                                    children: [
                                      WidgetSpan(
                                          alignment:
                                              ui.PlaceholderAlignment.middle,
                                          child: UnderlineTextBtnX(
                                            onPressed: () {
                                              _navigationService.navigateTo(
                                                  RoutePaths.register);
                                            },
                                            text: UiString.signUpText,
                                          )),
                                    ]),
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13),
                              ),
                              SizedBox(
                                height: height * 0.01,
                              ),
                            ],
                          )),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      if (_formKey.currentState!.validate()) {
        _isApiCall.value = true;
        FocusScope.of(context).unfocus(); //to hide the keyboard - if an
        bool isInternet = await InternetConnectionService.getInstance()
            .hasInternetConnection();
        if (isInternet) {
          Map<String, dynamic> apiResponse = await AuthRepository()
              .userLoggedIn(
                  email: _emailController.text,
                  password: _passController.text,
                  loginType: '0',
                  socialId: '');
          log("login apiResponse: ${apiResponse.toString()}");
          if (apiResponse[UiString.successText]) {
            if (apiResponse[UiString.dataText] != null) {
              if ((apiResponse[UiString.dataText] as Map)
                  .containsKey("access_token")) {
                await sl<SharedPrefsManager>()
                    .saveToken(apiResponse[UiString.dataText]['access_token']);
              }
              if (_isAgree.value) {
                await sl<SharedPrefsManager>().saveRememberUserDataInfo({
                  "email": _emailController.text,
                  "password": _passController.text
                });
              } else {
                await sl<SharedPrefsManager>().removeRememberUserDataInfo();
              }
              User user = User.fromJson(apiResponse[UiString.dataText]);
              await sl<SharedPrefsManager>().saveUserInfo(user);
              String? currentDeviceId;
              if (Platform.isIOS) {
                currentDeviceId =
                    (await DeviceInfoPlugin().iosInfo).identifierForVendor ??
                        '';
              } else {
                currentDeviceId =
                    (await DeviceInfoPlugin().androidInfo).id ?? '';
              }
              String? userLastDeviceId = user.deviceId;
              if (userLastDeviceId != null &&
                  currentDeviceId != null &&
                  currentDeviceId == userLastDeviceId) {
                if (user.dob != null && user.dob!.isNotEmpty) {
                  if (user.images != null && user.images!.isEmpty) {
                    log("Nav to images");
                    _navigationService.navigateTo(RoutePaths.addPhotos,
                        withPushAndRemoveUntil: true);
                  } else {
                    log("Nav to location !!");
                    // context.showSnackBar(apiResponse[UiString.messageText]);
                    _navigationService.navigateTo(RoutePaths.enableLocation,
                        withPushAndRemoveUntil: true, arguments: true);
                  }
                } else {
                  log("Nav to boardingProfile");
                  _navigationService.navigateTo(
                    RoutePaths.boardingProfile,
                    withPushAndRemoveUntil: true,
                  );
                }
              } else {
                log("Nav to otpVerification");
                Future.delayed((Duration.zero), () {
                  _navigationService.navigateTo(RoutePaths.otpVerification,
                      arguments: {
                        'email': _emailController.text,
                        'isFromForgotPassword': false
                      });
                });
              }
            } else {
              if (context.mounted) {
                Future.delayed(const Duration(seconds: 0), () {
                  context.showSnackBar(apiResponse[UiString.messageText]);
                });
              }
            }
          } else {
            if (context.mounted) {
              Future.delayed(const Duration(seconds: 0), () {
                context.showSnackBar(apiResponse[UiString.messageText]);
              });
            }
          }
        } else {
          if (context.mounted) {
            Future.delayed(const Duration(seconds: 0), () {
              context.showSnackBar(UiString.noInternet);
            });
          }
        }
      }
    } on Exception {
      // // log("on login function: $e");
    } finally {
      _isApiCall.value = false;
    }
  }
}

class ForgotPassBtn extends StatelessWidget {
  const ForgotPassBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          overlayColor: MaterialStateProperty.all(whitesmoke),
        ),
        onPressed: () {
          Navigator.pushNamed(context, RoutePaths.forgotPassword);
        },
        child: Text(
          'Forgot password?',
          style: TextStyle(
            color: 0xff868D95.toColor,
          ),
        ),
      ),
    );
  }
}
