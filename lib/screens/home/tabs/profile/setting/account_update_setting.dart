import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/textfields.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

class AccountSetting extends StatefulWidget {
  final String title;
  final String value;
  final String? value1;

  const AccountSetting(
      {Key? key, required this.title, required this.value, this.value1})
      : super(key: key);

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final TextEditingController _editingCont = TextEditingController();
  final TextEditingController _fnameEditingCont = TextEditingController();
  final TextEditingController _lnameEditingCont = TextEditingController();
  final TextEditingController _phoneCont = TextEditingController();
  String _countryCode = "+";
  final _formKey = GlobalKey<FormState>();
  DateTime? _dateTime;
  ValueNotifier<bool> isChanged = ValueNotifier(false);
  ValueNotifier<bool> isBtnEnable = ValueNotifier(false);

  // ValueNotifier<bool> isDOBChanged = ValueNotifier(true);

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    if (widget.title == UiString.myNameText) {
      if (sl<SharedPrefsManager>().getUserDataInfo()?.nameUpdateAt != null) {
        _dateTime = DateTime.parse(
            sl<SharedPrefsManager>().getUserDataInfo()?.nameUpdateAt);
      }
      _fnameEditingCont.text = widget.value;
      _lnameEditingCont.text = widget.value1 ?? '';
      isChanged.value = _dateTime != null
          ? (_dateTime?.isAfter(DateTime.now()) ?? true)
          : true;
    } else if (widget.title == UiString.emailText) {
      _editingCont.text = widget.value;
      isChanged = ValueNotifier(true);
    } else if (widget.title == UiString.phoneText) {
      if (widget.value.contains(" ")) {
        _phoneCont.text = widget.value.split(" ").last;
        _countryCode = widget.value.split(" ").first.toString();
      } else {
        _phoneCont.text = widget.value;
      }
      isChanged = ValueNotifier(true);
    } else if (widget.title == UiString.myBirthText) {
      String? dobDateTime =
          sl<SharedPrefsManager>().getUserDataInfo()?.dobUpdateAt;
      if (dobDateTime != null) {
        _dateTime = DateTime.parse(dobDateTime);
      }
      isChanged = ValueNotifier(_dateTime?.isAfter(DateTime.now()) ?? true);
      _editingCont.text = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(
        title: UiString.accountSetting,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  widget.title,
                  style: context.textTheme.titleLarge,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                if (widget.title == UiString.myNameText) ...[
                  TextFieldX(
                    controller: _fnameEditingCont,
                    hint: UiString.firstNameText,
                    label: UiString.firstNameText,
                    onChanged: checkBtnUpdate,
                  ),
                  const SizedBox(height: 10),
                  TextFieldX(
                    controller: _lnameEditingCont,
                    hint: UiString.lastNameText,
                    label: UiString.lastNameText,
                    onChanged: (value) {
                      if (value != widget.value1) {
                        isBtnEnable.value = true;
                      } else if (isBtnEnable.value && value == widget.value1) {
                        isBtnEnable.value = false;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                ] else if (widget.title == UiString.emailText) ...[
                  EmailTextField(
                    textController: _editingCont,
                    onChanged: checkBtnUpdate,
                  ),
                ] else if (widget.title == UiString.phoneText) ...[
                  PhoneTextField(
                    textController: _phoneCont,
                    onChanged: (value) {
                      if (widget.value.contains("+")) {
                        if ("$_countryCode $value" == widget.value) {
                          isBtnEnable.value = true;
                        } else if (isBtnEnable.value &&
                            "$_countryCode $value" == widget.value) {
                          isBtnEnable.value = false;
                        }
                      } else {
                        if (value != widget.value) {
                          isBtnEnable.value = true;
                        } else if (isBtnEnable.value && value == widget.value) {
                          isBtnEnable.value = false;
                        }
                      }
                    },
                    leading: CountryCodePicker(
                      onChanged: (value) {
                        if (widget.value.contains(value.dialCode ?? '') &&
                            widget.value.contains(_phoneCont.text)) {
                          isBtnEnable.value = false;
                        } else {
                          isBtnEnable.value = true;
                        }
                        _countryCode = value.dialCode ?? '';
                      },
                      initialSelection: _countryCode,
                      favorite: const ['+91', 'IND'],
                      showCountryOnly: true,
                      showOnlyCountryWhenClosed: false,
                      alignLeft: false,
                    ),
                  ),
                ] else ...[
                  DateTextFieldX(
                      controller: _editingCont,
                      hint: "dd/MM/yyyy",
                      onChanged: checkBtnDateUpdate),
                ],
                const SizedBox(height: 10),
                if (widget.title == UiString.myNameText) ...[
                  Text(
                    UiString.accountSettingUpdateName,
                    style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(11, context),
                        fontWeight: FontWeight.w500),
                  ),
                ] else if (widget.title == UiString.emailText) ...[
                  Text(
                    UiString.accountSettingUpdateDesc,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: ResponsiveDesign.fontSize(11, context),
                    ),
                  ),
                ] else if (widget.title == UiString.phoneText) ...[
                  Text(
                    UiString.accountSettingUpdatePhone,
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: ResponsiveDesign.fontSize(11, context),
                    ),
                  ),
                ] else ...[
                  Text.rich(TextSpan(children: [
                    TextSpan(
                      text: UiString.importants,
                      style: context.textTheme.titleSmall?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(11, context),
                        fontWeight: FontWeight.w500,
                        //    color: black
                      ),
                    ),
                    TextSpan(
                      text:
                          "Please note that some criteria, like birthdate, cannot be changed after you submit them.",
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(11, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: UiString.accountSettingUpdateDOB,
                      style: context.textTheme.bodySmall?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(11, context),
                      ),
                    ),
                    TextSpan(
                      text: UiString.accountSettingDOB,
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontSize: ResponsiveDesign.fontSize(11, context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ])),
                ],
                MultiValueListenableBuilder(
                    valueListenables: [isBtnEnable, isChanged],
                    builder: (context, value, _) {
                      if (value[1]) {
                        return Column(
                          children: [
                            const SizedBox(height: 50),
                            FillBtnX(
                              onPressed: () async {
                                if (value[0]) {
                                  if (widget.title == UiString.myNameText) {
                                    await Provider.of<EditUserProvider>(context,
                                            listen: false)
                                        .updateName(
                                            context,
                                            _fnameEditingCont.text,
                                            _lnameEditingCont.text);
                                    isChanged.value = false;
                                  } else if (widget.title ==
                                      UiString.emailText) {
                                    await resendOTP();
                                    // await Provider.of<EditUserProvider>(context,listen:false)
                                    //     .updateEmail(context, _editingCont.text);
                                  } else if (widget.title ==
                                      UiString.phoneText) {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      await Provider.of<EditUserProvider>(
                                              context,
                                              listen: false)
                                          .updateMobile(context,
                                              "$_countryCode ${_phoneCont.text}");
                                    } else {
                                      context.showSnackBar(
                                          "Enter valid phone number.",
                                          snackType: SnackType.error);
                                    }
                                  } else if (widget.title ==
                                      UiString.myBirthText) {
                                    await Provider.of<EditUserProvider>(context,
                                            listen: false)
                                        .updateDOB(context, _editingCont.text);
                                    isChanged.value = false;
                                  }
                                }
                              },
                              text: UiString.update,
                              color: !value[0] ? grey : null,
                            ),
                          ],
                        );
                      } else if (_dateTime != null) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              ' Your name last changed on ${_dateTime!.toDayMonthYear()}',
                              style: context.textTheme.bodySmall?.copyWith(
                                  fontSize:
                                      ResponsiveDesign.fontSize(14, context),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      }
                      return Container();
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }

  void checkBtnUpdate(String value) {
    if (value != widget.value) {
      isBtnEnable.value = true;
    } else if (isBtnEnable.value && value == widget.value) {
      isBtnEnable.value = false;
    }
  }

  void checkBtnDateUpdate(String val) {
    if (val != widget.value) {
      isBtnEnable.value = true;
    } else if (isBtnEnable.value && val == widget.value) {
      isBtnEnable.value = false;
    }
  }

  Future<void> resendOTP() async {
    try {
      FocusScope.of(context).unfocus(); //to hide the keyboard - if an
      bool isInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (isInternet) {
        Map<String, dynamic> apiResponse = await UserRepository()
            .sendEmailOTPFromSetting(email: _editingCont.text);

        if (apiResponse[UiString.successText]) {
          sl<NavigationService>()
              .navigateTo(RoutePaths.otpVerification, arguments: {
            'email': _editingCont.text,
            'isFromForgotPassword': false,
            'isFromAccountSetting': true
          });
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
