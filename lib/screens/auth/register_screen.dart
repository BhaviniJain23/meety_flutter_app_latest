import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/screens/auth/widgets/social_login_buttons.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/webview.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final NavigationService _navigationService = sl<NavigationService>();
  final ValueNotifier<bool> _isApiCall = ValueNotifier(false);
  final ValueNotifier<bool> _isAgree = ValueNotifier(false);

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBarX(
        title: '',
        height: ResponsiveDesign.screenHeight(context) * 0.050,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SizedBox(
              height: ResponsiveDesign.height(380, context),
              child: Image.asset(
                Assets.dummyLogin,
                fit: BoxFit.fitWidth,
              )),
          ValueListenableBuilder(
              valueListenable: _isApiCall,
              builder: (context, value, child) {
                return IgnorePointer(
                  ignoring: value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
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
                              height: ResponsiveDesign.height(12, context),
                            ),
                            PassTextField(textController: _passController),
                            // const SizedBox(height: 8),
                            SizedBox(
                              height: ResponsiveDesign.height(15, context),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: _isAgree,
                                    builder: (context, value, child) {
                                      return SizedBox(
                                        width:
                                            ResponsiveDesign.width(25, context),
                                        height: ResponsiveDesign.height(
                                            25, context),
                                        child: Checkbox(
                                          value: value,
                                          onChanged: (checkNewVal) {
                                            _isAgree.value =
                                                checkNewVal ?? false;
                                          },
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(3)),
                                        ),
                                      );
                                    }),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Text.rich(
                                    TextSpan(
                                        text: UiString
                                            .captionForTermsAndCondition,
                                        style: TextStyle(
                                            fontSize: ResponsiveDesign.fontSize(
                                                9, context)),
                                        children: [
                                          TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  sl<NavigationService>().navigateTo(
                                                      RoutePaths.webViews,
                                                      nextScreen: const WebViews(
                                                          title: UiString
                                                              .termsAndConditions,
                                                          value: "false"));
                                                },
                                              text: UiString.termsAndConditions,
                                              style:
                                                  const TextStyle(color: red)),
                                          const TextSpan(
                                            text: UiString.andText,
                                          ),
                                          TextSpan(
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  sl<NavigationService>().navigateTo(
                                                      RoutePaths.webViews,
                                                      nextScreen: const WebViews(
                                                          title: UiString
                                                              .privacyPolicy,
                                                          value: "false"));
                                                },
                                              text: UiString.privacyPolicy,
                                              style:
                                                  const TextStyle(color: red)),
                                          const TextSpan(
                                            text: ".",
                                          ),
                                        ]),
                                    style: const TextStyle(fontSize: 8.8),
                                  ),
                                )
                              ],
                            ),

                            SizedBox(
                              height: ResponsiveDesign.height(18, context),
                            ),
                            FillBtnX(
                              onPressed: () async {
                                if (!value) {
                                  if (_isAgree.value) {
                                    await register();
                                  } else {
                                    context.showSnackBar(
                                        "Please accept the terms and conditions.");
                                  }
                                }
                              },
                              text: UiString.signUpText,
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

                            SizedBox(
                              height: height * 0.01,
                            ),
                          ],
                        )),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Future<void> register() async {
    // try {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus(); //to hide the keyboard - if an
      // _isApiCall.value = true;
      bool isInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (isInternet) {
        Map<String, dynamic> apiResponse = await AuthRepository().userSignedUp(
            email: _emailController.text, password: _passController.text);

        // if (apiResponse[UiString.successText]) {
        //   if (apiResponse[UiString.dataText] != null) {
        //     if ((apiResponse[UiString.dataText] as Map)
        //         .containsKey("access_token")) {
        //       await sl<SharedPrefsManager>()
        //           .saveToken(apiResponse[UiString.dataText]['access_token']);
        //     }
        //     if ((apiResponse[UiString.dataText] as Map)
        //         .containsKey("refresh_token")) {
        //       await sl<SharedPrefsManager>().saveRefreshToken(
        //           apiResponse[UiString.dataText]['refresh_token']);
        //     }
        //     Future.delayed(const Duration(seconds: 0), () {
        //       context.showSnackBar(apiResponse[UiString.messageText]);
        //       _navigationService.navigateTo(RoutePaths.otpVerification,
        //           arguments: {
        //             'email': _emailController.text,
        //             'isFromForgotPassword': false
        //           });
        //     });
        //   } else {
        //     Future.delayed(const Duration(seconds: 0), () {
        //       context.showSnackBar(apiResponse[UiString.messageText]);
        //     });
        //   }
        // } else {
        //   Future.delayed(const Duration(seconds: 0), () {
        //     context.showSnackBar(apiResponse[UiString.messageText]);
        //   });
        // }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.noInternet);
        });
      }
    }
    // } on Exception {
    //   if (kDebugMode) {
    //     // print("On register:$e");
    //   }
    // } finally {
    //   _isApiCall.value = false;
    // }
  }
}
