// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/screens/subscriptions/subscription_list.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../../../config/routes_path.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/size_config.dart';
import '../../../../../constants/ui_strings.dart';
import '../../../../../data/repository/user_repo.dart';
import '../../../../../providers/edit_provider.dart';
import '../../../../../services/internet_service.dart';
import '../../../../../services/navigation_service.dart';
import '../../../../../services/singleton_locator.dart';
import '../../../../../widgets/CacheImage.dart';
import '../../../../../widgets/core/buttons.dart';
import '../../../../auth/widgets/texfields.dart';

class UpgradePlanScreen extends StatefulWidget {
  UpgradePlanScreen(this.subscriptionProvider, this.loginUserVal, {super.key});

  SubscriptionProvider subscriptionProvider;
  User loginUserVal;

  @override
  State<UpgradePlanScreen> createState() => _UpgradePlanScreenState();
}

class _UpgradePlanScreenState extends State<UpgradePlanScreen> {
  final TextEditingController _editingCont = TextEditingController();
  final TextEditingController _phoneCont = TextEditingController();
  String _countryCode = "+";
  ValueNotifier<bool> isChanged = ValueNotifier(false);
  ValueNotifier<bool> isBtnEnable = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();
  bool autoRenew = true;
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.loginUserVal.email != null) {
      _editingCont.text = widget.loginUserVal.email!;
      isChanged = ValueNotifier(true);
    }
    if (widget.loginUserVal.phone != null) {
      if (widget.loginUserVal.phone!.contains(" ")) {
        _phoneCont.text = widget.loginUserVal.phone!.split(" ").last;
        _countryCode = widget.loginUserVal.phone!.split(" ").first.toString();
      } else {
        _phoneCont.text = widget.loginUserVal.phone!;
      }
      isChanged = ValueNotifier(true);
    }
  }

  void checkBtnUpdate(String value) {
    if (value != widget.loginUserVal.email) {
      isBtnEnable.value = true;
    } else if (isBtnEnable.value && value == widget.loginUserVal.email) {
      isBtnEnable.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const AppBarX(
          title: "Upgrade Plan",
          //elevation: 5,
        ),
        body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: ResponsiveDesign.only(context, left: 20),
                        child: CacheImage(
                          imageUrl: (widget.loginUserVal.pastSubscription
                                      ?.planImage?.isNotEmpty ??
                                  false)
                              ? widget.loginUserVal.pastSubscription
                                      ?.planImage![0] ??
                                  ''
                              : '',
                          width: ResponsiveDesign.width(150, context),
                          boxFit: BoxFit.contain,
                        ),
                      ),
                      if (widget.loginUserVal.pastSubscription != null &&
                          Utils.calculateDaysRemaining() == 0) ...[
                        Padding(
                            padding: ResponsiveDesign.only(context, right: 20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: () {
                                sl<NavigationService>().navigateTo(
                                    RoutePaths.subscriptionScreen,
                                    nextScreen: const SubscriptionListScreen());
                              },
                              child: const Text(
                                "Change Plan",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline),
                              ),
                            ))
                      ]
                    ],
                  ),
                  if (widget
                      .loginUserVal.pastSubscription!.planId!.isNotEmpty) ...[
                    Utils.calculateDaysRemaining() <= 0
                        ? Padding(
                            padding: ResponsiveDesign.only(context, left: 20),
                            child: Text(
                              "Your Plan is Expired.",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w700,
                                  fontSize:
                                      ResponsiveDesign.fontSize(17, context)),
                            ),
                          )
                        : Padding(
                            padding: ResponsiveDesign.only(context, left: 20),
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: "Your Plan will Expire ",
                                  style: TextStyle(
                                      fontSize: ResponsiveDesign.fontSize(
                                          15, context),
                                      fontWeight: FontWeight.w500)),
                              TextSpan(
                                  text:
                                      "After ${Utils.calculateDaysRemaining() != 1 ? '${Utils.calculateDaysRemaining()} Days.' : 'Day.'}",
                                  style: TextStyle(
                                      fontSize: ResponsiveDesign.fontSize(
                                          15, context),
                                      fontWeight: FontWeight.bold))
                            ])),
                          ),
                  ],
                  const SizedBox(
                    height: 15,
                  ),
                  if (widget.loginUserVal.pastSubscription!.planId != "3" &&
                          widget.loginUserVal.pastSubscription!.planId !=
                              null ||
                      Utils.calculateDaysRemaining() <= 0) ...[
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: SizedBox(
                          height: ResponsiveDesign.height(45, context),
                          width: ResponsiveDesign.width(125, context),
                          child: FillBtnX(
                              elevation: 5,
                              color: red,
                              radius: 10,
                              onPressed: () async {
                                if (Utils.calculateDaysRemaining() <= 0) {
                                  int index = widget.subscriptionProvider
                                      .subscriptionsWithOutMeetyExplorer
                                      .indexWhere((element) {
                                    return element.planId.toString() ==
                                        widget.loginUserVal.pastSubscription
                                            ?.planId;
                                  });
                                  if (index != -1) {
                                    Utils.showBottomSheet(
                                        widget.subscriptionProvider
                                                .subscriptionsWithOutMeetyExplorer[
                                            index],
                                        context);
                                  }
                                } else {
                                  sl<NavigationService>().navigateTo(
                                      RoutePaths.subscriptionScreen,
                                      nextScreen:
                                          const SubscriptionListScreen());
                                }
                              },
                              text: Utils.calculateDaysRemaining() <= 0
                                  ? "Renew"
                                  : 'Upgrade'),
                        )),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                  const Divider(
                    endIndent: 20,
                    indent: 20,
                    thickness: 1,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 20, right: 20),
                    child: EmailTextField(
                      onChanged: checkBtnUpdate,
                      textController: _editingCont,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 15, left: 20, right: 20),
                    child: PhoneTextField(
                      textController: _phoneCont,
                      onChanged: (value) {
                        if (widget.loginUserVal.phone!.contains("+")) {
                          if ("$_countryCode $value" !=
                              widget.loginUserVal.phone) {
                            isBtnEnable.value = true;
                          } else if (isBtnEnable.value &&
                              "$_countryCode $value" ==
                                  widget.loginUserVal.phone) {
                            isBtnEnable.value = false;
                          }
                        } else {
                          if (value != widget.loginUserVal.phone) {
                            isBtnEnable.value = true;
                          } else if (isBtnEnable.value &&
                              value == widget.loginUserVal.phone) {
                            isBtnEnable.value = false;
                          }
                        }
                      },
                      leading: CountryCodePicker(
                        onChanged: (value) {
                          if (widget.loginUserVal.phone!
                                  .contains(value.dialCode ?? '') &&
                              widget.loginUserVal.phone!
                                  .contains(_phoneCont.text)) {
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
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, left: 20, right: 20),
                    child: Text(
                      "Your Registered Mobile Number",
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MultiValueListenableBuilder(
                      valueListenables: [isBtnEnable, isChanged],
                      builder: (context, values, child) {
                        return SizedBox(
                          height: ResponsiveDesign.height(60, context),
                          width: double.infinity,
                          child: FillBtnX(
                              elevation: 5,
                              color: !values[0] ? grey : null,
                              radius: 10,
                              onPressed: () async {
                                if (values[0]) {
                                  if (_editingCont.text.trim().isNotEmpty &&
                                      sl<SharedPrefsManager>()
                                              .getUserDataInfo()
                                              ?.email !=
                                          _editingCont.text) {
                                    await resendOTP();
                                  } else if (sl<SharedPrefsManager>()
                                          .getUserDataInfo()
                                          ?.phone !=
                                      _phoneCont.text) {
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
                                  }
                                }
                              },
                              text: UiString.update),
                        );
                      },
                    ),
                  )
                ],
              ),
            )));
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
