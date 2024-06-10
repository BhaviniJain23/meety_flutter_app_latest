import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/screens/auth/widgets/headings.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class ForgotPassScreen extends StatefulWidget {
  const ForgotPassScreen({super.key});

  @override
  State<ForgotPassScreen> createState() => _ForgotPassScreenState();
}

class _ForgotPassScreenState extends State<ForgotPassScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isApiCall = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isApiCall,
      builder: (context, value, child) {
        return IgnorePointer(
          ignoring: value,
          child: Scaffold(
            appBar: const AppBarX(title: ''),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Heading(
                      text: UiString.forgotPasswordText,
                    ),
                    const SizedBox(height: 15),
                    const SubHeading(text: UiString.forgotPasswordCaptionText),
                    const SizedBox(height: 30),
                    EmailTextField(textController: _emailController),
                    const SizedBox(height: 30),
                    FillBtnX(
                      onPressed: forgotPassword,
                      text: UiString.sendMailText,
                    ),
                    const SizedBox(height: 56),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> forgotPassword() async {
    try {
      if (_formKey.currentState!.validate()) {
        FocusScope.of(context).unfocus(); //to hide the keyboard - if an
        bool isInternet =
            await sl<InternetConnectionService>().hasInternetConnection();
        if (isInternet) {
          Map<String, dynamic> apiResponse =
              await AuthRepository().forgotPassword(
            email: _emailController.text,
          );

          log("apiResponse: ${apiResponse.toString()}");
          if (apiResponse[UiString.successText]) {
            if (apiResponse[UiString.dataText] != null) {
              if ((apiResponse[UiString.dataText] as Map)
                  .containsKey("token")) {
                await sl<SharedPrefsManager>()
                    .saveToken(apiResponse[UiString.dataText]['token']);
              }
              Future.delayed(const Duration(seconds: 0), () {
                context.showSnackBar(apiResponse[UiString.messageText]);
                Future.delayed(const Duration(seconds: 0), () {
                  context.showSnackBar(apiResponse[UiString.messageText]);
                  sl<NavigationService>().navigateTo(RoutePaths.otpVerification,
                      arguments: {
                        'email': _emailController.text,
                        'isFromForgotPassword': true
                      });
                });
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
      }
    } on Exception {
      if (kDebugMode) {
        // print("On register:$e");
      }
    }
  }
}
