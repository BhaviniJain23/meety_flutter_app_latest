import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/login_repo.dart';
import 'package:meety_dating_app/models/user.dart' as model_user;
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';

import '../../services/internet_service.dart';


class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {

  final TextEditingController _phoneController = TextEditingController();
  String phoneNumber= "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(
        title: '',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              HeadingStyles.boardingHeading(context, UiString.myMobile),
              const SizedBox(height: 12),
              HeadingStyles.boardingHeadingCaption(context, UiString.myMobileSubCaption),
              const SizedBox(height: 30),
              PhoneTextField(textController: _phoneController,
               onChanged: (phoneVal){
                phoneNumber = phoneVal;
               },
              ),
              const SizedBox(height: 30),
              FillBtnX(
                onPressed: loginWithPhone,
                text: UiString.sendOTPText,
              ),
              const SizedBox(height: 56),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> loginWithPhone() async {
    if (_phoneController.text.length >= 10) {
      bool isInternet =
      await InternetConnectionService.getInstance().hasInternetConnection();
      if (isInternet) {
        Map<String, dynamic> apiResponse = await AuthRepository().checkUserExistWithPhoneNumber(
            phone: _phoneController.text
        );
        if (apiResponse[UiString.successText]) {
          if (apiResponse[UiString.dataText] != null) {


            model_user.User user = model_user.User.fromJson(apiResponse[UiString.dataText]);
            await sl<SharedPrefsManager>().saveUserInfo(user);
            Future.delayed(const Duration(seconds: 0), () {
              if(user.dob != null && user.dob!.isNotEmpty){
                context.showSnackBar(apiResponse[UiString.messageText]);
                Navigator.pushNamedAndRemoveUntil(
                    context, RoutePaths.home, (route) => false);
              }else{
                context.showSnackBar(apiResponse[UiString.messageText]);
                Navigator.pushNamedAndRemoveUntil(
                    context, RoutePaths.boardingProfile, (route) => false);
              }

            });
          }else{
            await verifyUserPhoneNumber();

          }
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
    }
  }


  Future<void> verifyUserPhoneNumber() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {

      },
      verificationFailed: (FirebaseAuthException e) {
      },
      codeSent: (String verificationId, int? resendToken) {
        context.showSnackBar("We have sent you an otp to a registered phone number.");
        Navigator.pushNamed(
            context, RoutePaths.otpVerification,
         arguments: {
         'phone_number':phoneNumber,
          'verification_id':verificationId,
         }
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

}
