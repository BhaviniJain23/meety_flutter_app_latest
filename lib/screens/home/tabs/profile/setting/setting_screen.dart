// ignore_for_file: use_build_context_synchronously, unrelated_type_equality_checks

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/location.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/providers/home_provider.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/setting/account_update_setting.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/setting/block_contact_tab.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/setting/delete_account.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/setting/manage_payment_account.dart';
import 'package:meety_dating_app/screens/home/tabs/profile/setting/notification_setting.dart';
import 'package:meety_dating_app/screens/locations/search_location.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/bottomsheets.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/webview.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../../config/routes_path.dart';
import '../../../../../services/navigation_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  User? loginUser;
  String email = '';
  String phone = '';

  ValueNotifier isUpdate = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();

    loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    final user = Provider.of<EditUserProvider>(context, listen: false);
    if (loginUser != null) {
      if (loginUser!.email != null && loginUser!.email!.isNotEmpty) {
        email = loginUser!.email!;
      }
      if (loginUser!.phone != null &&
          loginUser!.phone!.isNotEmpty &&
          loginUser!.phone.toString() != "undefined") {
        phone = loginUser!.phone!;
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        user.setUser(loginUser!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whitesmoke,
      appBar: const AppBarX(
        title: UiString.setting,
        elevation: 2.5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),

              /// Account Section
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                    child: Text(
                      UiString.accountSetting,
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, bottom: 2),
                    child: Text('+18%',
                        style:
                            TextStyle(color: red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Selector<EditUserProvider,
                  Tuple5<String?, String?, String?, String?, String?>>(
                selector: (context, provider) => Tuple5(
                    provider.loginUser?.fname,
                    provider.loginUser?.lname,
                    provider.loginUser?.email,
                    provider.loginUser?.dob,
                    provider.loginUser?.phone),
                builder: (context, value, child) {
                  // log(value.item1.toString());
                  // log(value.item2.toString());
                  log(value.item5.toString());
                  return Card(
                    elevation: 5,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            sl<NavigationService>()
                                .navigateTo(RoutePaths.accountSetting,
                                    nextScreen: AccountSetting(
                                      title: UiString.myNameText,
                                      value: value.item1 ?? '',
                                      value1: value.item2 ?? '',
                                    ));
                          },
                          tileColor: white,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                UiString.nameText,
                                style: context.textTheme.bodyMedium
                                    ?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text(
                                  '${value.item1 ?? ''} ${value.item2 ?? ''}',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.end,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          horizontalTitleGap: 0,
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            sl<NavigationService>()
                                .navigateTo(RoutePaths.accountSetting,
                                    nextScreen: AccountSetting(
                                      title: UiString.emailText,
                                      value: value.item3 ?? '',
                                    ));
                          },
                          tileColor: white,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                UiString.emailText,
                                style: context.textTheme.bodyMedium
                                    ?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text(
                                  value.item3 ?? '',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.end,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          horizontalTitleGap: 0,
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            sl<NavigationService>()
                                .navigateTo(RoutePaths.accountSetting,
                                    nextScreen: AccountSetting(
                                      title: UiString.myBirthText,
                                      value: value.item4 ?? '',
                                    ));
                          },
                          tileColor: white,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                UiString.dobText.replaceFirst("*", ""),
                                style: context.textTheme.bodyMedium
                                    ?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text(
                                  value.item4 ?? '',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.end,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          horizontalTitleGap: 0,
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 18,
                          ),
                        ),
                        ListTile(
                          onTap: () {
                            sl<NavigationService>().navigateTo(
                                RoutePaths.accountSetting,
                                nextScreen: AccountSetting(
                                  title: UiString.phoneText,
                                  value: (value.item5 != null &&
                                          value.item5.toString() != "undefined")
                                      ? value.item5.toString()
                                      : '',
                                ));
                          },
                          tileColor: white,
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                UiString.phoneText,
                                style: context.textTheme.bodyMedium
                                    ?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Text(
                                  // value.item5 ?? '',
                                  (value.item5 != null &&
                                          value.item5.toString() != "undefined")
                                      ? value.item5.toString()
                                      : '',
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.end,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            ],
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
                  );
                },
              ),

              const SizedBox(
                height: 15,
              ),

              /// Discover Section
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                child: Text(
                  UiString.discoverSetting,
                  style: context.textTheme.titleMedium,
                ),
              ),

              Card(
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.2),
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        UiString.location,
                        style: context.textTheme.bodySmall?.copyWith(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.end,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Selector<EditUserProvider, List<Tuple2<Location, bool>>>(
                        selector: (context, provider) =>
                            provider.selectedLocation,
                        builder: (context, value, child) {
                          return ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: value.length,
                              itemBuilder: (context, index) {
                                final tupleData = value[index];

                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.location_on,
                                    color: red,
                                    size: 40,
                                  ),
                                  title: Text(
                                    tupleData.item1.name ?? '',
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                            fontSize: 15, color: Colors.black),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: tupleData.item2
                                      ? const Icon(
                                          CupertinoIcons.checkmark_alt,
                                          color: red,
                                          size: 40,
                                        )
                                      : null,
                                  onTap: () {
                                    Provider.of<EditUserProvider>(context,
                                            listen: false)
                                        .updateFindingLocationList(
                                            tupleData.item1,
                                            index: index)
                                        .then((value) {
                                      Provider.of<HomeProvider>(context,
                                              listen: false)
                                          .fetchUsers(page: 1);
                                    });
                                  },
                                );
                              });
                        },
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Center(
                        child: TextBtnX(
                            color: red,
                            onPressed: () async {
                              final response = await sl<NavigationService>()
                                  .navigateTo(RoutePaths.searchLocation,
                                      nextScreen: const SearchLocation());
                              if (response != null) {
                                Future.delayed(Duration.zero, () async {
                                  Provider.of<EditUserProvider>(context,
                                          listen: false)
                                      .updateFindingLocationList(response)
                                      .then((value) {
                                    Provider.of<HomeProvider>(context,
                                            listen: false)
                                        .fetchUsers(page: 1);
                                  });
                                });
                              }
                            },
                            text: UiString.addNewLocation),
                      )
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              ///Block
              Card(
                elevation: 5,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shadowColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  onTap: () async {
                    if (await Permission.contacts.isGranted) {
                      await sl<NavigationService>().navigateTo(
                        RoutePaths.blockContactTab,
                        nextScreen: BlockTabScreen.create(context),
                      );
                    } else {
                      showImportContactDialog();
                    }
                  },
                  tileColor: white,
                  title: Text(
                    UiString.blockContact,
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  horizontalTitleGap: 0,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),

              /// Global section
              Selector<EditUserProvider, String?>(
                selector: (context, provider) {
                  return provider.loginUser?.isGlobal;
                },
                builder: (context, isGlobalVal, child) {
                  return Card(
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: SwitchListTile(
                        title: Text(
                          UiString.global,
                          style: context.textTheme.bodyMedium
                              ?.copyWith(fontSize: 16),
                        ),
                        tileColor: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        value: isGlobalVal == '1' ? true : false,
                        onChanged: (newVal) {
                          Provider.of<EditUserProvider>(context, listen: false)
                              .updateGlobalStatus(context, newVal ? '1' : '0');
                        },
                      ));
                },
              ),

              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                child: Text(
                  "Only wants to see verified profiles",
                  style: context.textTheme.titleMedium,
                ),
              ),
              Selector<EditUserProvider, String>(
                selector: (context, provider) =>
                    provider.loginUser!.showVerifiedProfile.toString(),
                builder: (context, profileVarifieds, child) {
                  return Card(
                    elevation: 5,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: SwitchListTile(
                      title: Text(
                        UiString.profileVerified,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontSize: 15, color: Colors.black),
                      ),
                      tileColor: white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      value: profileVarifieds == "1" ? true : false,
                      onChanged: (newVal) {
                        final subscriptionPlan = sl<SharedPrefsManager>()
                            .getUserDataInfo()!
                            .pastSubscription;
                        if (subscriptionPlan?.planId == null) {
                          // AlertService.premiumPopUpService(context);
                          Utils.printingAllPremiumInfo(context,
                              isForProfileVerified: true);
                        } else {
                          Provider.of<EditUserProvider>(context, listen: false)
                              .updateShowProfileVerifiedStatus(context, newVal);
                        }
                      },
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                child: Text(
                  "Want to share your online activity status",
                  style: context.textTheme.titleMedium,
                ),
              ),
              Selector<EditUserProvider, String>(
                builder: (context, online, child) {
                  return Card(
                    elevation: 5,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: SwitchListTile(
                      title: Text(
                        UiString.onlineOffline,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontSize: 15, color: Colors.black),
                      ),
                      tileColor: white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      value: online == "1" ? true : false,
                      onChanged: (newVal) {
                        AlertService.showAlertMessageWithTwoBtn(
                            context: context,
                            alertTitle: "Change activity status?",
                            alertMsg:
                                "Are you sure you want to change activity status?",
                            positiveText: "Update",
                            negativeText: "Cancel",
                            yesTap: () {
                              final subscriptionPlan = sl<SharedPrefsManager>()
                                  .getUserDataInfo()!
                                  .pastSubscription;
                              if (subscriptionPlan?.planId == null) {
                                // AlertService.premiumPopUpService(context);

                                Utils.printingAllPremiumInfo(context,
                                    isForOnlineOfflineStatus: true);
                              } else {
                                Provider.of<EditUserProvider>(context,
                                        listen: false)
                                    .updateShowOnlineStatus(context, newVal);
                              }
                            });
                      },
                    ),
                  );
                },
                selector: (context, provider) =>
                    provider.loginUser!.showOnline.toString(),
              ),
              const SizedBox(
                height: 15,
              ),

              /// Maximum distance section
              Selector<EditUserProvider, Tuple2<String?, String?>>(
                selector: (context, provider) => Tuple2(
                    provider.loginUser?.measure, provider.loginUser?.distance),
                builder: (context, value, child) {
                  double distance = value.item1 == UiString.km
                      ? double.tryParse(value.item2?.toString() ??
                              '${Constants.defaultMaximumDistance}') ??
                          Constants.defaultMaximumDistance
                      : Utils.convertKMToMiles(double.tryParse(value.item2 ??
                              '${Constants.defaultMaximumDistance}') ??
                          Constants.defaultMaximumDistance);

                  return InkWell(
                    onTap: () {
                      showBottomSheetOfDistance(
                          value.item1 == UiString.km ? true : false, distance);
                    },
                    child: Card(
                        elevation: 5,
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              /*
                          left: 15.0, right: 15.0, top:*/
                              15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      UiString.maximumDistance,
                                      style: context.textTheme.titleLarge
                                          ?.copyWith(fontSize: 18),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Text(
                                    '$distance${value.item1}',
                                    style: context.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),

              const SizedBox(
                height: 15,
              ),

              /// Maximum age section
              Selector<EditUserProvider, Tuple2<String?, String?>>(
                selector: (context, provider) => Tuple2(
                    provider.loginUser?.ageRange,
                    provider.loginUser?.showAgeRange?.toString()),
                builder: (context, value, child) {
                  return InkWell(
                    onTap: () {
                      int minAge =
                          int.parse(Constants.defaultAgeRange.split("-").first);
                      int maxAge =
                          int.parse(Constants.defaultAgeRange.split("-").last);
                      if (value.item1 != null && value.item1!.contains("-")) {
                        minAge = int.tryParse(value.item1!.split("-").first) ??
                            int.parse(
                                Constants.defaultAgeRange.split("-").first);
                        maxAge = int.tryParse(value.item1!.split("-").last) ??
                            int.parse(
                                Constants.defaultAgeRange.split("-").last);
                      }

                      showBottomSheetOfAge(minAge, maxAge,
                          value.item2 ?? '${Constants.toShowInAgeRange}');
                    },
                    child: Card(
                        elevation: 5,
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, right: 15.0, top: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      UiString.ageRange,
                                      style: context.textTheme.titleLarge
                                          ?.copyWith(fontSize: 18),
                                      maxLines: 2,
                                    ),
                                  ),
                                  Text(
                                    value.item1 ?? Constants.defaultAgeRange,
                                    style: context.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  UiString.onlyShowPeople,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                      fontSize: 15, color: Colors.grey),
                                ),
                                tileColor: white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                value: value.item2.toString() == '1'
                                    ? true
                                    : false,
                                onChanged: (newVal) async {
                                  final editProvider =
                                      context.read<EditUserProvider>();

                                  await editProvider.updateAgeRange(
                                    context,
                                    value.item1 ?? Constants.defaultAgeRange,
                                    isShowRange: newVal ? "1" : '0',
                                  );
                                },
                              ),
                            ],
                          ),
                        )),
                  );
                },
              ),

              if (loginUser?.pastSubscription?.planId!.isNotEmpty ?? false) ...[
                const SizedBox(
                  height: 15,
                ),

                /// manage payment method
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                  child: Text(
                    UiString.paymentAccount,
                    style: context.textTheme.titleMedium,
                  ),
                ),
                Card(
                  elevation: 5,
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  shadowColor: Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                              RoutePaths.managePayment,
                              nextScreen: const ManagePayment());
                        },
                        tileColor: white,
                        title: Text(
                          UiString.managePaymentMethod,
                          style: context.textTheme.bodyMedium
                              ?.copyWith(fontSize: 16),
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
              ],

              const SizedBox(
                height: 15,
              ),

              /// notification section
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                child: Text(
                  UiString.notificationSettings,
                  style: context.textTheme.titleMedium,
                ),
              ),
              Selector<EditUserProvider, User?>(
                selector: (context, provider) => provider.loginUser,
                builder: (context, value, child) {
                  return Card(
                    elevation: 5,
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    shadowColor: Colors.grey.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            if (value != null) {
                              sl<NavigationService>().navigateTo(
                                  RoutePaths.notificationSetting,
                                  nextScreen: NotificationSettingScreen(
                                      loginUser: value));
                            }
                          },
                          tileColor: white,
                          title: Text(
                            UiString.notifications,
                            style: context.textTheme.bodyMedium
                                ?.copyWith(fontSize: 16),
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
                  );
                },
              ),

              const SizedBox(
                height: 15,
              ),

              /// contactUs section
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                child: Text(
                  UiString.contactUs,
                  style: context.textTheme.titleMedium,
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shadowColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  onTap: () {
                    sl<NavigationService>().navigateTo(RoutePaths.webViews,
                        nextScreen: const WebViews(
                            title: UiString.helpSupport, value: "false"));
                  },
                  tileColor: white,
                  title: Text(
                    UiString.helpSupport,
                    style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                  ),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  horizontalTitleGap: 0,
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                  ),
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              /// community section
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                child: Text(
                  UiString.legal,
                  style: context.textTheme.titleMedium,
                ),
              ),
              Card(
                elevation: 5,
                color: Colors.white,
                surfaceTintColor: Colors.white,
                shadowColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () {
                        sl<NavigationService>().navigateTo(RoutePaths.webViews,
                            nextScreen: const WebViews(
                                title: UiString.privacyPolicy, value: "false"));
                      },
                      tileColor: white,
                      title: Text(
                        UiString.privacyPolicy,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontSize: 16),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      horizontalTitleGap: 0,
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                      ),
                    ),
                    ListTile(
                      onTap: () {
                        sl<NavigationService>().navigateTo(RoutePaths.webViews,
                            nextScreen: const WebViews(
                                title: UiString.termsAndConditions,
                                value: "false"));
                      },
                      tileColor: white,
                      title: Text(
                        UiString.termsAndConditions,
                        style: context.textTheme.bodyMedium
                            ?.copyWith(fontSize: 16),
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

              const SizedBox(
                height: 15,
              ),

              /// Share Section
              ListTile(
                onTap: () async {
                  await Utils().shareApp();
                },
                tileColor: white,
                title: Text(
                  UiString.shareTinder,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                horizontalTitleGap: 0,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
              ),
              const SizedBox(
                height: 15,
              ),

              /// Deactivate Account Section
              ListTile(
                onTap: () {
                  sl<NavigationService>().navigateTo(RoutePaths.deleteAccount,
                      nextScreen: const DeleteAccountScreen(
                        isDeactivate: true,
                      ));
                },
                tileColor: white,
                title: Text(
                  UiString.deactivateAccount,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                horizontalTitleGap: 0,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              /// Delete Account Section
              ListTile(
                onTap: () {
                  sl<NavigationService>().navigateTo(RoutePaths.deleteAccount,
                      nextScreen: const DeleteAccountScreen(
                        isDeactivate: false,
                      ));
                },
                tileColor: white,
                title: Text(
                  UiString.deleteAccount,
                  style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                horizontalTitleGap: 0,
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              /// logout
              FillBtnX(
                  onPressed: () async {
                    sl<SharedPrefsManager>().logoutUser(context);
                  },
                  text: UiString.logout),

              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showImportContactDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
            elevation: 5,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                SizedBox(
                  width: ResponsiveDesign.width(300, context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        UiString.knowOnMeety,
                        style: context.textTheme.titleLarge,
                      ),
                      SizedBox(
                        height: context.height * 0.01,
                      ),
                      Text(
                        UiString.contactsWithMeety,
                        style: context.textTheme.bodyMedium,
                      ),
                      SizedBox(
                        height: context.height * 0.01,
                      ),
                    ],
                  ),
                ),
                FillBtnX(
                    onPressed: () async {
                      await getContacts(ctx);
                    },
                    text: UiString.importContact),
                SizedBox(
                  height: context.height * 0.02,
                ),
                OutLineBtnX(
                  radius: 15,
                  color: red,
                  onPressed: () {
                    sl<NavigationService>().pop();
                  },
                  child: const Text(UiString.mayBeLaterText),
                )
              ],
            ));
      },
    );
  }

// Function to get permission from the user
  _contactsPermissions() async {
    PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }

  //Function to import contacts
  Future<void> getContacts(ctx) async {
    final PermissionStatus contactsPermissionsStatus =
        await _contactsPermissions();
    if (contactsPermissionsStatus == PermissionStatus.granted) {
      await sl<NavigationService>().navigateTo(
        RoutePaths.blockContactTab,
        nextScreen: BlockTabScreen.create(context),
      );
    } else {
      Navigator.pop(ctx);
      Future.delayed(const Duration(seconds: 0), () {
        AlertService.showAlertMessageWithTwoBtn(
          context: context,
          alertTitle: UiString.selectContact,
          alertMsg: UiString.selectContactDesc,
          positiveText: UiString.openSetting,
          negativeText: UiString.notNow,
          yesTap: () async {
            await openAppSettings();

            ///
            bool permissionGranted = await checkPermission();
            if (permissionGranted) {
              print("=======");
              await sl<NavigationService>().navigateTo(
                RoutePaths.blockContactTab,
                nextScreen: BlockTabScreen.create(context),
              );
            }
          },
        );
        return;
      });
    }
  }

  Future<bool> checkPermission() async {
    // Check if permission is granted
    PermissionStatus status = await Permission.contacts.status;
    if (status.isGranted) {
      // Permission is already granted
      return true;
    } else {
      // Permission is not granted, request permission
      PermissionStatus status = await Permission.contacts.request();
      if (status.isGranted) {
        // Permission granted after request
        return true;
      } else {
        // Permission denied
        return false;
      }
    }
  }

  void showBottomSheetOfAge(int minAge, int maxAge, String toShowAgeRange) {
    RangeValues tempAgeRange =
        RangeValues(minAge.toDouble(), maxAge.toDouble());
    bool isShowRange = toShowAgeRange == "1" ? true : false;

    BottomSheetService.showBottomSheet(
        context: context,
        builder: (ctx, state) {
          bool isUpdate = tempAgeRange.start.round().toInt() != minAge ||
              tempAgeRange.end.round().toInt() != maxAge ||
              isShowRange != (toShowAgeRange == "1" ? true : false);
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            UiString.ageRange,
                            style: context.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "${tempAgeRange.start.round().toInt()}-${tempAgeRange.end.round().toInt()}",
                            style: context.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                RangeSlider(
                  activeColor: red,
                  values: tempAgeRange,
                  min: 18,
                  max: 100,
                  labels: RangeLabels(
                    tempAgeRange.start.round().toString(),
                    tempAgeRange.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    state(() {
                      tempAgeRange = values;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      UiString.onlyShowPeople,
                      style: context.textTheme.bodyMedium
                          ?.copyWith(fontSize: 15, color: Colors.grey),
                    ),
                    tileColor: white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    value: isShowRange,
                    onChanged: (newVal) {
                      state(() {
                        isShowRange = newVal;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: OutLineBtnX(
                        onPressed: () async {
                          tempAgeRange =
                              RangeValues(minAge.toDouble(), maxAge.toDouble());
                          isShowRange = toShowAgeRange == "1" ? true : false;
                          state(() {});
                        },
                        radius: 15,
                        color: red,
                        text: 'Clear'.toUpperCase(),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: FillBtnX(
                        onPressed: () async {
                          if (isUpdate) {
                            final editProvider =
                                context.read<EditUserProvider>();

                            await editProvider.updateAgeRange(
                              context,
                              "${tempAgeRange.start.round().toInt()}-${tempAgeRange.end.round().toInt()}",
                              isShowRange: isShowRange ? "1" : '0',
                            );

                            Navigator.pop(context);
                          }
                        },
                        isDisabled: !isUpdate,
                        text: 'Update',
                      ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          );
        });
  }

  void showBottomSheetOfDistance(bool measure, double distance) {
    bool showKm = measure;
    double tempDistance = distance + 0;
    BottomSheetService.showBottomSheet(
        context: context,
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        UiString.showDistance,
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            Expanded(
                                child: OutLineBtnX(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              fillColor: showKm ? red : null,
                              textColor: showKm ? white : Colors.black,
                              color: showKm ? red : Colors.grey.shade400,
                              onPressed: () async {
                                if (!showKm) {
                                  showKm = true;
                                  tempDistance =
                                      Utils.convertMilesToKm(tempDistance);
                                  state(() {});
                                }
                              },
                              text: UiString.km,
                            )),
                            Container(
                              height: 20,
                              color: Colors.grey,
                            ),
                            Expanded(
                                child: OutLineBtnX(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              ),
                              fillColor: !showKm ? red : null,
                              textColor: !showKm ? white : Colors.black,
                              color: !showKm ? red : Colors.grey.shade400,
                              onPressed: () async {
                                if (showKm) {
                                  showKm = false;
                                  tempDistance =
                                      Utils.convertKMToMiles(tempDistance);
                                  state(() {});
                                  24;
                                }
                              },
                              text: UiString.mi,
                            ))
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            UiString.distance,
                            style: context.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$tempDistance ${showKm ? UiString.km : UiString.mi}',
                            style: context.textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Slider(
                  activeColor: red,
                  value: tempDistance,
                  min: showKm == true ? 40 : 24,
                  max: int.parse(tempDistance.round().toString()) > 100
                      ? tempDistance
                      : 100,
                  divisions: int.parse(tempDistance.round().toString()) > 100
                      ? int.parse(tempDistance.round().toString())
                      : 100,
                  label: tempDistance.round().toString(),
                  onChanged: (double value) {
                    state(() {
                      tempDistance = value.round().toDouble();
                    });
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: OutLineBtnX(
                        onPressed: () async {
                          showKm = measure;
                          tempDistance = distance;
                          state(() {});
                        },
                        radius: 15,
                        color: red,
                        text: 'Clear'.toUpperCase(),
                      )),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: FillBtnX(
                        onPressed: () async {
                          await Provider.of<EditUserProvider>(context,
                                  listen: false)
                              .updateDistance(
                            context,
                            tempDistance,
                            measure: showKm ? UiString.km : UiString.mi,
                          );
                          Navigator.pop(context);
                        },
                        text: 'Update'.toUpperCase(),
                      ))
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          );
        });
  }
}
