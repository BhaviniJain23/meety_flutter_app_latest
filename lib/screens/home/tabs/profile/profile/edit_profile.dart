import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/models/education_model.dart';
import 'package:meety_dating_app/models/interest.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import '../../../../../widgets/utils/extensions.dart';
import '../../../../../config/routes_path.dart';
import '../../../../../constants/colors.dart';
import '../../../../../constants/constants_list.dart';
import '../../../../../constants/size_config.dart';
import '../../../../../constants/ui_strings.dart';
import '../../../../../constants/utils.dart';
import '../../../../../models/location.dart';
import '../../../../../models/user.dart';
import '../../../../../providers/edit_provider.dart';
import '../../../../../providers/login_user_provider.dart';
import '../../../../../services/navigation_service.dart';
import '../../../../../services/shared_pref_manager.dart';
import '../../../../../services/singleton_locator.dart';
import '../../../../../widgets/core/alerts.dart';
import '../../../../../widgets/core/appbars.dart';
import '../../../../../widgets/core/buttons.dart';
import '../../../../locations/search_location.dart';
import '../../../../profile/add_photos.dart';
import 'basic_info_screen.dart';
import 'gender_screen.dart';
import 'interest_screen.dart';
import 'interest_screen_old.dart';
import 'looking_for_screen.dart';
import 'occupation_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _lookingStr = '';
  String _interest = '';
  // Interest _interest = Interest.empty();
  String _languages = '';
  String _zodiac = '';
  String _education = '';
  String _futurePlan = '';
  String _covidVacinne = '';
  String _personalityType = '';
  String _habits = '';
  String _genderGroupValue = '';
  String _showMe = '';
  String _occupation = '';
  User? loginUser;
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    loginUser = sl<SharedPrefsManager>().getUserDataInfo();
    super.initState();
    final user =
        Provider.of<EditUserProvider>(context, listen: false).loginUser;

    _aboutController.text = user?.about ?? '';
    //_jobTitleController.text = user?.jobTitle ?? '';
    _companyController.text = user?.occupation ?? '';
    //_educationController.text = user?.school ?? '';
    _cityController.text = user?.hometown ?? '';
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final value = Provider.of<EditUserProvider>(context, listen: false);

        log("con: ${value.loginUser == loginUser}");
        if (value.loginUser == loginUser) {
          if (context.read<LoginUserProvider>().profileCompletePercentage <
              70) {
            AlertService.showAlertMessageWithTwoBtns(
                noTap: () {
                  sl<NavigationService>().pop();
                  Navigator.pop(context);
                },
                context: context,
                alertTitle: "",
                alertMsg: Utils.backWithoutChanges(
                    ConstantList.backWithoutAnyChanges),
                positiveText: "Ok,Go back to do some changes",
                negativeText: "Ok,Back without changes",
                yesTap: () {
                  Provider.of<EditUserProvider>(context, listen: false)
                      .setUser(sl<SharedPrefsManager>().getUserDataInfo()!);
                  // Navigator.pop(context);
                });
          }
          return true;
        } else {
          Provider.of<EditUserProvider>(context, listen: false)
              .updateProfile(context);
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: whitesmoke,
        appBar: AppBarX(
            title: UiString.editProfile,
            height: 60,
            elevation: 2.5,
            leading: BackBtnX(
              onPressed: () async {
                final value =
                    Provider.of<EditUserProvider>(context, listen: false);

                log('value.loginUser: ${value.loginUser!.toJson().toString()}');
                log('loginUser: ${loginUser!.toJson().toString()}');
                if (value.loginUser == loginUser) {
                  if (context
                          .read<LoginUserProvider>()
                          .profileCompletePercentage <
                      70) {
                    print("============");
                    AlertService.showAlertMessageWithTwoBtns(
                        noTap: () {
                          sl<NavigationService>().pop();
                          Navigator.pop(context);
                        },
                        context: context,
                        alertTitle: "",
                        alertMsg: Utils.backWithoutChanges(
                            ConstantList.backWithoutAnyChanges),
                        positiveText: "Ok,Go back to do some changes",
                        negativeText: "Ok,Back without changes",
                        yesTap: () {
                          Provider.of<EditUserProvider>(context, listen: false)
                              .setUser(
                                  sl<SharedPrefsManager>().getUserDataInfo()!);
                          //Navigator.pop(context);
                        });
                  } else {
                    sl<NavigationService>().pop();
                  }
                } else {
                  Provider.of<EditUserProvider>(context, listen: false)
                      .updateProfile(context);
                  sl<NavigationService>().pop();
                }
              },
            ),
            trailing: null),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Selector<EditUserProvider, Tuple2<User?, bool>>(
              selector: (context, provider) =>
                  Tuple2(provider.loginUser, provider.isProfileEdit),
              builder: (context, value, child) {
                _interest = value.item1?.interest ?? '';
                _lookingStr = value.item1?.lookingFor ?? '';
                _languages = value.item1?.languageKnown ?? '';
                _zodiac = value.item1?.zodiac ?? 'Not Selected';
                _education = value.item1?.education ?? 'Not Selected';
                _futurePlan = value.item1?.futurePlan ?? 'Not Selected';
                _covidVacinne = value.item1?.covidVaccine ?? 'Not Selected';
                _personalityType =
                    value.item1?.personalityType ?? 'Not Selected';
                _habits = value.item1?.habit ?? 'Not Selected';
                _genderGroupValue = value.item1?.gender.toString() ?? '';
                _showMe = value.item1?.showme.toString() ?? '';
                _occupation = value.item1?.occupation ?? 'Not Selected';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),

                    /// Photos Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                          child: Text(
                            'Photos',
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          child: Text('+9%',
                              style: TextStyle(
                                  color: red, fontWeight: FontWeight.bold)),
                        ),
                      ],
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
                          sl<NavigationService>().navigateTo(
                            RoutePaths.addPhotos,
                            nextScreen: AddPhotos(
                              editImages: value.item1?.images ?? [],
                            ),
                          );
                        },
                        tileColor: white,
                        leading: const Icon(Icons.photo),
                        title: const Text('Edit Photos'),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        horizontalTitleGap: 0,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// About Section
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 8),
                          child: Text(
                            'About Me',
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          child: Text('+7%',
                              style: TextStyle(
                                  color: red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: TextFormField(
                        controller: _aboutController,
                        decoration: const InputDecoration(
                          hintText: "About me",
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 15,
                          ),
                          border: InputBorder.none,
                        ),
                        maxLines: 5,
                        maxLength: 1000,
                        onChanged: (value) {
                          Provider.of<EditUserProvider>(context, listen: false)
                              .updateAbout(value);
                        },
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// Interests Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                          child: Text(
                            'Hobbies & Interests',
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          child: Text('+7%',
                              style: TextStyle(
                                  color: red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                            RoutePaths.addPhotos,
                            nextScreen: InterestScreen(
                              // givenList: _interest.split(","),
                              givenList: List.from(ConstantList.interestList
                                  .map((e) => Interest.fromJson(e))),
                            ),
                          );
                        },
                        tileColor: white,
                        title: Text(
                          maxLines: 5,
                          _interest.isNotEmpty
                              ? _interest.replaceAll(",", " , ")
                              : 'Not Selected',
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        horizontalTitleGap: 0,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// Looking for section
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                      child: Text(
                        UiString.matchPreferences,
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
                      child: ListTile(
                        onTap: () {
                          sl<NavigationService>().navigateTo(
                            RoutePaths.addPhotos,
                            nextScreen: LookingForScreen(
                              value: _lookingStr,
                            ),
                          );
                        },
                        tileColor: white,
                        leading: const Icon(Icons.remove_red_eye_outlined),
                        title: Row(
                          children: [
                            Text(
                              UiString.matchPreferencesGoals,
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                User.getLookingFor(_lookingStr),
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
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
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// Languages I know section
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                          child: Text(
                            UiString.knownLanguages,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          child: Text('+4%',
                              style: TextStyle(
                                  color: red, fontWeight: FontWeight.bold)),
                        ),
                      ],
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
                          sl<NavigationService>().navigateTo(
                            RoutePaths.addPhotos,
                            nextScreen: InterestScreenOld(
                              givenList: _languages.split(","),
                              isInterest: false,
                            ),
                          );
                        },
                        tileColor: white,
                        leading: const Icon(Icons.translate),
                        title: Text(
                          _languages.trim().isNotEmpty
                              ? _languages
                              : UiString.addLanguages,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        horizontalTitleGap: 0,
                        trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// Basic section
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                      child: Text(
                        UiString.basic,
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
                                RoutePaths.addPhotos,
                                nextScreen: BasicInfoScreen(
                                  expansionStr: UiString.zodiacQue,
                                  loginUser: value.item1!,
                                ),
                              );
                            },
                            tileColor: white,
                            leading: const Icon(CupertinoIcons.moon_stars_fill),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  UiString.zodiac,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    _zodiac.isNotEmpty
                                        ? _zodiac
                                        : 'Not Selected',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
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
                          // ListTile(
                          //   onTap: () {
                          //     // PersistentNavBarNavigator.pushNewScreen(
                          //     //   context,
                          //     //   screen: BasicInfoScreen(
                          //     //     expansionStr: UiString.educationQue,
                          //     //     loginUser: value.item1!,
                          //     //   ),
                          //     //   withNavBar: false,
                          //     //   pageTransitionAnimation:
                          //     //       PageTransitionAnimation.cupertino,
                          //     // );
                          //     sl<NavigationService>().navigateTo(
                          //       RoutePaths.addPhotos,
                          //       nextScreen: BasicInfoScreen(
                          //         expansionStr: UiString.educationQue,
                          //         loginUser: value.item1!,
                          //       ),
                          //     );
                          //   },
                          //   tileColor: white,
                          //   leading: const Icon(Icons.school_rounded),
                          //   title: Row(
                          //     crossAxisAlignment: CrossAxisAlignment.center,
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Text(
                          //         UiString.education,
                          //         style: context.textTheme.bodyMedium,
                          //       ),
                          //       const SizedBox(
                          //         width: 20,
                          //       ),
                          //       Expanded(
                          //         child: Text(
                          //           _education.isNotEmpty
                          //               ? _education
                          //               : 'Not Selected',
                          //           style:
                          //               context.textTheme.bodySmall?.copyWith(
                          //             fontSize: 14,
                          //           ),
                          //           textAlign: TextAlign.end,
                          //           softWrap: true,
                          //           overflow: TextOverflow.ellipsis,
                          //         ),
                          //       )
                          //     ],
                          //   ),
                          //   shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(15)),
                          //   horizontalTitleGap: 0,
                          //   trailing: const Icon(
                          //     Icons.arrow_forward_ios_rounded,
                          //     size: 18,
                          //   ),
                          // ),
                          ListTile(
                            onTap: () {
                              sl<NavigationService>().navigateTo(
                                RoutePaths.addPhotos,
                                nextScreen: BasicInfoScreen(
                                  expansionStr: UiString.familyPlanQue,
                                  loginUser: value.item1!,
                                ),
                              );
                            },
                            tileColor: white,
                            leading: const Icon(Icons.diversity_3),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  UiString.futurePlan,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    _futurePlan.isNotEmpty
                                        ? _futurePlan
                                        : 'Not Selected',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
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
                                RoutePaths.addPhotos,
                                nextScreen: BasicInfoScreen(
                                  expansionStr: UiString.vaccinatedQue,
                                  loginUser: value.item1!,
                                ),
                              );
                            },
                            tileColor: white,
                            leading: const Icon(Icons.vaccines),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  UiString.covidVaccine,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    _covidVacinne.isNotEmpty
                                        ? _covidVacinne
                                        : 'Not Selected',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
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
                                RoutePaths.addPhotos,
                                nextScreen: BasicInfoScreen(
                                  expansionStr: UiString.personalityQue,
                                  loginUser: value.item1!,
                                ),
                              );
                            },
                            tileColor: white,
                            leading: const Icon(CupertinoIcons.cube),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  UiString.personalityType,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    _personalityType.isNotEmpty
                                        ? _personalityType
                                        : 'Not Selected',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
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
                                RoutePaths.addPhotos,
                                nextScreen: BasicInfoScreen(
                                  expansionStr: UiString.habit,
                                  loginUser: value.item1!,
                                ),
                              );
                            },
                            tileColor: white,
                            leading: const Icon(CupertinoIcons.sun_haze),
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  UiString.habit,
                                  style: context.textTheme.bodyMedium,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  child: Text(
                                    _habits.isNotEmpty
                                        ? _habits
                                        : 'Not Selected',
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
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
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// Education
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 8),
                      child: Text(
                        UiString.education,
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
                          sl<NavigationService>().navigateTo(
                            RoutePaths.occupation,
                            nextScreen: Occupation(
                              // selectedEducation: _education,
                              selectedEducation: EducationModel(
                                  educationId: "",
                                  name: _education,
                                  isRestricted: 1),
                              isOccupation: false,
                            ),
                          );
                        },
                        tileColor: white,
                        leading: Padding(
                          padding: ResponsiveDesign.only(context, right: 15),
                          child: const Icon(Icons.school_rounded),
                        ),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              UiString.education,
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                _education.isNotEmpty
                                    ? _education
                                    : 'Not Selected',
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
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    ///Occupation
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 8),
                          child: Text(
                            UiString.occupations,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          child: Text('+10%',
                              style: TextStyle(
                                  color: red, fontWeight: FontWeight.bold)),
                        ),
                      ],
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
                          sl<NavigationService>().navigateTo(
                            RoutePaths.occupation,
                            nextScreen: Occupation(
                              // selectedEducation: _occupation,
                              selectedEducation: EducationModel(
                                  educationId: "",
                                  name: _occupation,
                                  isRestricted: 1),
                              //isOccupation: false,
                            ),
                          );
                        },
                        tileColor: white,
                        leading: Padding(
                          padding: ResponsiveDesign.only(context, right: 15),
                          child: const Icon(Icons.workspaces_rounded),
                        ),
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              UiString.occupations,
                              style: context.textTheme.bodyMedium,
                            ),
                            Expanded(
                              child: Text(
                                _occupation.isNotEmpty
                                    ? _occupation
                                    : 'Not Selected',
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
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    /// Living in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0, bottom: 8),
                          child: Text(
                            UiString.livingIn,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, bottom: 2),
                          child: Text('+7%',
                              style: TextStyle(
                                  color: red, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Card(
                      elevation: 5,
                      color: Colors.white,
                      surfaceTintColor: Colors.white,
                      shadowColor: Colors.grey.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                          hintText: UiString.addCity,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                        ),
                        readOnly: true,
                        maxLines: 1,
                        onTap: () async {
                          final response = await sl<NavigationService>()
                              .navigateTo(RoutePaths.searchLocation,
                                  context: context,
                                  nextScreen: const SearchLocation());
                          if (response != null) {
                            Future.delayed(Duration.zero, () async {
                              _cityController.text =
                                  (response as Location).name.toString();
                              Provider.of<EditUserProvider>(context,
                                      listen: false)
                                  .updateCity((response).name.toString());
                            });
                          }
                        },
                        keyboardType: TextInputType.none,
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    /// I am section
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                      child: Text(
                        "Gender",
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
                          sl<NavigationService>().navigateTo(
                            RoutePaths.addPhotos,
                            nextScreen: GenderScreen(
                              gender: _genderGroupValue,
                              isGenderShow: int.tryParse(
                                      value.item1?.isGenderShow ?? "-1") ??
                                  -1,
                              showMe: _showMe,
                              isShowMe:
                                  int.tryParse(value.item1?.isShowMe ?? "-1") ??
                                      -1,
                              sexOrientation:
                                  value.item1?.sexOrientation ?? '0',
                              isSexOrientation: int.tryParse(
                                      value.item1?.isSexOrientationShow ??
                                          '-1') ??
                                  -1,
                            ),
                          );
                        },
                        tileColor: white,
                        title: Text(
                          _genderGroupValue,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                          ),
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
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
                      height: 5,
                    ),

                    if (_genderGroupValue ==
                        ConstantList.genderList[2].val) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                        child: Text(
                          'Show Me',
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
                            sl<NavigationService>().navigateTo(
                              RoutePaths.addPhotos,
                              nextScreen: GenderScreen(
                                gender: _genderGroupValue,
                                isGenderShow: int.tryParse(
                                        value.item1?.isGenderShow ?? "-1") ??
                                    -1,
                                showMe: _showMe,
                                isShowMe: int.tryParse(
                                        value.item1?.isShowMe ?? "-1") ??
                                    -1,
                                sexOrientation:
                                    value.item1?.sexOrientation ?? '0',
                                isSexOrientation: int.tryParse(
                                        value.item1?.isSexOrientationShow ??
                                            '-1') ??
                                    -1,
                              ),
                            );
                          },
                          tileColor: white,
                          title: Text(
                            _showMe,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
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
                    ] else ...[
                      /// Sexual orientation section
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0, bottom: 5),
                        child: Text(
                          'Sexual orientation',
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
                            sl<NavigationService>().navigateTo(
                              RoutePaths.addPhotos,
                              nextScreen: GenderScreen(
                                gender: _genderGroupValue,
                                isGenderShow: int.tryParse(
                                        value.item1?.isGenderShow ?? "-1") ??
                                    -1,
                                showMe: _showMe,
                                isShowMe: int.tryParse(
                                        value.item1?.isShowMe ?? "-1") ??
                                    -1,
                                sexOrientation:
                                    value.item1?.sexOrientation ?? '0',
                                isSexOrientation: int.tryParse(
                                        value.item1?.isSexOrientationShow ??
                                            '-1') ??
                                    -1,
                              ),
                            );
                          },
                          tileColor: white,
                          title: Text(
                            value.item1?.sexOrientation ?? '',
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                            ),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
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
                    ],

                    const SizedBox(
                      height: 30,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
