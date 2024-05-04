import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/size_config.dart';
import '../../../../../constants/utils.dart';
import '../../../../../providers/edit_provider.dart';
import '../../../../../services/navigation_service.dart';
import '../../../../../services/singleton_locator.dart';
import '../../../../../widgets/core/alerts.dart';

class ManagePayment extends StatefulWidget {
  const ManagePayment({super.key});

  @override
  State<ManagePayment> createState() => _ManagePaymentState();
}

class _ManagePaymentState extends State<ManagePayment> {
  @override
  Widget build(BuildContext context) {
    final subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    return Scaffold(
      appBar: const AppBarX(
        title: UiString.managePaymentMethod,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 15, bottom: 10),
            child: Text(
              UiString.availablePaymentMethod,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Card(
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  onTap: () {
                    // AlertService.subscriptionPaymentSuccessfully(
                    //     context, subscriptionProvider.currentSubscription!);
                    // AlertService.subscriptionPaymentFailed(context,subscriptionProvider.currentSubscription!);
                  },
                  leading: const Icon(
                    Icons.credit_card_outlined,
                    size: 35,
                  ),
                  tileColor: white,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      UiString.addCreditOrDebitCard,
                      style:
                          context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  horizontalTitleGap: 0,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 10, left: 15, bottom: 10),
            child: Text(
              UiString.yourPlan,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Card(
            elevation: 5,
            shadowColor: Colors.grey.withOpacity(0.2),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sl<SharedPrefsManager>()
                          .getUserDataInfo()!
                          .pastSubscription!
                          .planId!
                          .isNotEmpty) ...[
                        Utils.calculateDaysRemaining() <= 0
                            ? Padding(
                                padding:
                                    ResponsiveDesign.only(context, left: 13),
                                child: Text(
                                  "Your Plan is Expired.",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w700,
                                      fontSize: ResponsiveDesign.fontSize(
                                          17, context)),
                                ),
                              )
                            : Padding(
                                padding:
                                    ResponsiveDesign.only(context, left: 13),
                                child: Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: "Your Plan will Expire ",
                                      style: TextStyle(
                                          color: black,
                                          fontSize: ResponsiveDesign.fontSize(
                                              15, context),
                                          fontWeight: FontWeight.w500)),
                                  TextSpan(
                                      text:
                                          "After ${Utils.calculateDaysRemaining() != 1 ? '${Utils.calculateDaysRemaining()} Days.' : 'Day.'}",
                                      style: TextStyle(
                                          color: black,
                                          fontSize: ResponsiveDesign.fontSize(
                                              15, context),
                                          fontWeight: FontWeight.bold))
                                ])),
                              ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ],
                  ),
                  tileColor: white,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text(
                      "${sl<SharedPrefsManager>().getUserDataInfo()!.pastSubscription!.planTitle}",
                      style: context.textTheme.bodyLarge,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  horizontalTitleGap: 0,
                ),
              ],
            ),
          ),

          /// Auto Renew
          Selector<EditUserProvider, String?>(
            selector: (context, provider) => provider.loginUser!.isAutoRenew,
            builder: (context, isAutoRenewVal, child) {
              return Card(
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: SwitchListTile(
                    title: Text(
                      UiString.autoRenew,
                      style:
                          context.textTheme.bodyMedium?.copyWith(fontSize: 14),
                    ),
                    tileColor: white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    value: isAutoRenewVal == "1" ? true : false,
                    onChanged: (newVal) {
                      isAutoRenewVal == "1"
                          ? AlertService.showAlertMessageWithTwoBtn(
                              noTap: () {
                                sl<NavigationService>().pop();
                              },
                              context: context,
                              alertTitle: "To Disable Automatic Renewal",
                              alertMsg:
                                  "Turning off renewal means your subscription won't renew automatically at the end of each billing cycle. Your premium features will remain active until the end of your current subscription period. You're in control of your Meety experience.",
                              positiveText: 'Yes',
                              negativeText: 'Cancel',
                              yesTap: () {
                                Provider.of<EditUserProvider>(context,
                                        listen: false)
                                    .autoRenew(context, newVal ? "1" : "0");
                              })
                          : Provider.of<EditUserProvider>(context,
                                  listen: false)
                              .autoRenew(context, newVal ? "1" : "0");
                    },
                  ));
            },
          ),
        ],
      ),
    );
  }
}
