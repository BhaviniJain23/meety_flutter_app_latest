import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/assets.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OrSigninWith extends StatelessWidget {
  const OrSigninWith({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
            child: Divider(
          color: grey,
          endIndent: 15,
          indent: 15,
          thickness: 1.2,
        )),
        Text(
          UiString.signInWith,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
        ),
        Expanded(
            child: Divider(
          color: grey,
          endIndent: 15,
          indent: 15,
          thickness: 1.2,
        )),
      ],
    );
  }
}

class SocialLoginBtns extends StatefulWidget {
  const SocialLoginBtns({
    super.key,
  });

  @override
  State<SocialLoginBtns> createState() => _SocialLoginBtnsState();
}

class _SocialLoginBtnsState extends State<SocialLoginBtns> {
  BuildContext? dialogContext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SocialBtnX(
        //   onPressed: signInWithFacebook,
        //   icon: Image.asset(
        //     Assets.facebook,
        //   ),
        // ),
        // const SizedBox(width: 24),
        SocialBtnX(
          onPressed: signInWithGoogle,
          icon: Image.asset(
            Assets.google,
            //height: ResponsiveDesign.height(0, context),
          ),
        ),
        if (Platform.isIOS) ...[
          const SizedBox(width: 24),
          SocialBtnX(
            onPressed: signInWithApple,
            icon: Image.asset(
              Assets.apple,
            ),
          ),
        ]
      ],
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      Future.delayed(const Duration(milliseconds: 200), () {
        _showLoadingDialog(context, 'Signing in with Google...');
      });
      final GoogleSignInAccount googleSignInAccount =
          (await googleSignIn.signIn())!;

      if (googleSignIn.currentUser != null) {
        // ignore: unused_local_variable
        GoogleSignInAuthentication auth =
            await googleSignInAccount.authentication;
        await socialLogIn(
            googleSignIn.currentUser!.id,
            Constants.googleLogin,
            googleSignIn.currentUser!.email,
            googleSignIn.currentUser!.displayName ?? '');
        _dismissLoadingDialog(); // Dismiss the dialog when the sign-in process is done
      }
    } on Exception catch (e) {
      log('Exception: ${e.toString()}');
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(e.toString());
      });
    }
  }

  Future<void> _showLoadingDialog(BuildContext context, String message) async {
    dialogContext = context; // Store the dialog context
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void _dismissLoadingDialog() {
    if (dialogContext != null) {
      Navigator.of(dialogContext!).pop();
      dialogContext = null; // Reset the dialog context
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      FacebookAuth facebookAuth = FacebookAuth.instance;
      final LoginResult result = await facebookAuth.login();
      if (result.status == LoginStatus.success) {
        Map<String, dynamic> userData = await facebookAuth.getUserData();
        if (userData['email'] != null &&
            userData['email'].toString().isNotEmpty) {
          socialLogIn(userData['id'], Constants.facebookLogin,
              userData['email'] ?? '', userData['name'] ?? '');
        } else {
          // ignore: use_build_context_synchronously
          showEmailDialogBox(context, userData['id']);
        }
      }
    } on Exception catch (e) {
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(e.toString());
      });
    }
  }

  Future<void> signInWithApple() async {
    try {
      bool isAppleSignInAvailable = await SignInWithApple.isAvailable();
      if (isAppleSignInAvailable) {
        final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName
            ],
            webAuthenticationOptions: WebAuthenticationOptions(
                clientId:
                    "471137557888-c1461801sldsienge0vrp5d33e3mpuoq.apps.googleusercontent.com",
                redirectUri: Uri.parse(
                    'https://pub.dev/packages/sign_in_with_apple')) //required for android plateform
            );
        if (credential.userIdentifier != null) {
          final data = await sl<SharedPrefsManager>()
              .getAppleInfo(credential.userIdentifier.toString());

          if (data.isEmpty) {
            if (credential.email != null &&
                credential.email!.isNotEmpty &&
                credential.familyName != null &&
                credential.familyName!.isNotEmpty) {
              await sl<SharedPrefsManager>().saveAppleInfo(
                  credential.userIdentifier.toString(),
                  credential.email.toString(),
                  "${credential.givenName ?? ''} ${credential.familyName ?? ''}");

              socialLogIn(
                credential.userIdentifier ?? '',
                Constants.appleLogin,
                credential.email ?? '',
                "${credential.givenName ?? ''} ${credential.familyName ?? ''}",
              );
            } else {
              socialLogIn(credential.userIdentifier ?? '', Constants.appleLogin,
                  '', '');
            }
          } else {
            socialLogIn(
              credential.userIdentifier ?? '',
              Constants.appleLogin,
              data['email'],
              data['name'],
            );
          }
        } else {
          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(UiString.error);
          });
        }
      }
    } on Exception catch (e) {
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(e.toString());
      });
    }
  }

  socialLogIn(String socialId, String loginType, String emailAddress,
      String name) async {
    bool isInternet =
        await InternetConnectionService.getInstance().hasInternetConnection();
    if (isInternet) {
      String fname = '';
      String lname = '';
      if (name.isNotEmpty) {
        if (name.split(" ").length == 3) {
          fname = name.split(" ")[0];
          lname = name.split(" ")[2];
        } else if (name.split(" ").length == 2) {
          fname = name.split(" ")[0];
          lname = name.split(" ")[1];
        } else if (!name.contains(" ")) {
          fname = name;
        }
      }
      Map<String, dynamic> apiResponse = await AuthRepository().userLoggedIn(
          email: emailAddress,
          password: null,
          loginType: loginType,
          socialId: socialId,
          fname: fname,
          lname: lname);
      if (apiResponse[UiString.successText]) {
        if (apiResponse[UiString.dataText] != null) {
          if ((apiResponse[UiString.dataText] as Map).containsKey("token")) {
            await sl<SharedPrefsManager>()
                .saveToken(apiResponse[UiString.dataText]['token']);
          }
          User user = User.fromJson(apiResponse[UiString.dataText]);
          await sl<SharedPrefsManager>().saveUserInfo(user);

          Future.delayed(const Duration(seconds: 0), () {
            if (user.dob != null && user.dob!.isNotEmpty) {
              if (user.images != null && user.images!.isEmpty) {
                Future.delayed(const Duration(seconds: 0), () {
                  context.showSnackBar(apiResponse[UiString.messageText]);
                  Navigator.pushNamedAndRemoveUntil(
                      context, RoutePaths.addPhotos, (route) => false);
                });
              } else {
                context.showSnackBar(apiResponse[UiString.messageText]);
                Navigator.pushNamedAndRemoveUntil(
                    context, RoutePaths.enableLocation, (route) => false,
                    arguments: true);
              }
            } else {
              context.showSnackBar(apiResponse[UiString.messageText]);
              Navigator.pushNamedAndRemoveUntil(
                  context, RoutePaths.boardingProfile, (route) => false);
            }
          });
        }
      } else {
        Future.delayed(const Duration(seconds: 0), () {
          context.showSnackBar(UiString.error);
        });
      }
    } else {
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(UiString.error);
      });
    }
  }

  void showEmailDialogBox(BuildContext context, String? facebookId) async {
    final TextEditingController forgotEmailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              height: 350,
              padding: const EdgeInsets.only(left: 20, right: 20),
              color: white,
              child: Form(
                key: formKey,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: Text(
                          UiString.signUpText,
                          style: TextStyle(
                            fontSize: 23.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      EmailTextField(
                        textController: forgotEmailController,
                      ),
                      const SizedBox(
                        height: 30.0,
                      ),
                      FillBtnX(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(context);
                            socialLogIn(
                                facebookId.toString(),
                                Constants.facebookLogin,
                                forgotEmailController.text,
                                '');
                          }
                        },
                        text: UiString.signUpText,
                        width: 250.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
