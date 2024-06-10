import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/screens/auth/widgets/headings.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

class ResetPassword extends StatefulWidget {
  final String userId;
  const ResetPassword({Key? key, required this.userId}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(title: ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const Heading(text: UiString.createNewPasswordText),
                const SizedBox(height: 15),
                const SubHeading(
                  text: UiString.resetPasswordCaptionText,
                ),
                const SizedBox(height: 30),
                PassTextField(textController: _password),
                const SizedBox(height: 30),
                ConfirmPassTextField(
                  passwordTextController: _password,
                  textController: _confirmPassword,
                ),
                const SizedBox(height: 30),
                FillBtnX(
                  onPressed: resetPassword,
                  text: UiString.resetPasswordText,
                ),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        FocusScope.of(context).unfocus(); //to hide the keyboard - if an
        bool isInternet =
            await sl<InternetConnectionService>().hasInternetConnection();
        if (isInternet) {
          Map<String, dynamic> apiResponse =
              await AuthRepository().resetPassword(
            userId: widget.userId,
            newPassword: _password.text,
          );

          log("apiResponse: ${apiResponse.toString()}");
          if (apiResponse[UiString.successText]) {
            sl<NavigationService>().popUntil((route) => route.isFirst);
          } else {
            Future.delayed(const Duration(seconds: 0), () {
              context.showSnackBar(UiString.changePasswordSnackbarText);
            });
          }
        } else {
          Future.delayed(const Duration(seconds: 0), () {
            context.showSnackBar(UiString.noInternet);
          });
        }
      } on Exception catch (e) {
        if (kDebugMode) {
          print("On register:$e");
        }
      }
    }
  }
}
