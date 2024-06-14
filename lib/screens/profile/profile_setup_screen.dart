// ignore_for_file: non_constant_identifier_names, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'dart:io';
import 'dart:math';
import 'dart:developer' as d;

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/user_repo.dart';
import 'package:meety_dating_app/models/gender_model.dart';
import 'package:meety_dating_app/models/interest.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/screens/profile/widgets/custom_cards.dart';
import 'package:meety_dating_app/services/internet_service.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/notification_function.dart';
import 'package:meety_dating_app/services/shared_pref_manager.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/alerts.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/core/textfields.dart';
import 'package:meety_dating_app/widgets/core/validator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../constants/size_config.dart';
import '../../constants/utils.dart';
import '../../data/repository/list_repo.dart';
import '../../models/education_model.dart';
import '../../widgets/empty_widget.dart';

class ProfileSetUpScreen extends StatefulWidget {
  const ProfileSetUpScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetUpScreen> createState() => _ProfileSetUpScreenState();
}

class _ProfileSetUpScreenState extends State<ProfileSetUpScreen>
    with ValidateMixin {
  final PageController _pageController = PageController(initialPage: 0);
  final _nameFormKey = GlobalKey<FormState>();
  final _aboutFormKey = GlobalKey<FormState>();
  final ValueNotifier<int> currentPage = ValueNotifier(0);
  final ValueNotifier<bool> btnEnable = ValueNotifier(false);
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _mobileNumber = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController searchEducation = TextEditingController();
  List<Interest> allInterests = [Interest.empty()];

  final ValueNotifier<List<EducationModel>> mainList = ValueNotifier([]);
  final ValueNotifier<List<EducationModel>> filteredLists = ValueNotifier([]);
  final ValueNotifier<EducationModel?> selectedVal = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<List<Gender>> genderList = ValueNotifier([]);
  final ValueNotifier<List<SexOrientation>> sexOrientation = ValueNotifier([]);
  final ValueNotifier<List<Gender>> showMeList = ValueNotifier([]);
  final ValueNotifier<List<LookingFor>> lookingForList = ValueNotifier([]);
  final ValueNotifier<List<FuturePlan>> futurePlans = ValueNotifier([]);
  final ValueNotifier<List<Education>> educationList = ValueNotifier([]);
  final ValueNotifier<List<Interest>> myInterestList = ValueNotifier([]);
  final ValueNotifier<List<Interest>> filteredList = ValueNotifier([]);
  final TextEditingController _searchController = TextEditingController();

  final ValueNotifier<bool> isGenderVisible = ValueNotifier(true);
  final ValueNotifier<bool> isSexOrientationVisible = ValueNotifier(true);
  final ValueNotifier<bool> isShowMe = ValueNotifier(true);
  final NavigationService _navigationService = sl<NavigationService>();
  final ValueNotifier<bool> isAPICall = ValueNotifier(false);
  final ValueNotifier<String> _countryCode = ValueNotifier("+91");
  final List educationMain = [];
  final String selectEducation = '';

  @override
  void initState() {
    genderList.value.clear();
    genderList.value = List.from(ConstantList.genderList.map((e) {
      e.isSelected = false;
      return e;
    }).toList());

    sexOrientation.value.clear();
    sexOrientation.value = List.from(ConstantList.sexOrientation.map((e) {
      if (e.val == Constants.straight) {
        e.isSelected = true;
      } else {
        e.isSelected = false;
      }
      return e;
    }).toList());

    showMeList.value.clear();
    showMeList.value = List.from(ConstantList.showMeList.map((e) {
      e.isSelected = false;
      return e;
    }).toList());

    lookingForList.value.clear();
    lookingForList.value = List.from(ConstantList.lookingForList.map((e) {
      if (e.val == Constants.openToOptions) {
        e.isSelected = true;
      } else {
        e.isSelected = false;
      }
      return e;
    }).toList());

    mainList.value.clear();
    filteredLists.value.clear();
    mainList.value = List.from(ConstantList.educationList);
    filteredLists.value = List.from(ConstantList.educationList);

    futurePlans.value.clear();
    futurePlans.value = List.from(ConstantList.futurePlan.map((e) {
      e.isSelected = false;
      return e;
    }).toList());

    allInterests.clear();
    filteredList.value.clear();
    allInterests =
        List.from(ConstantList.interestList.map((e) => Interest.fromJson(e)));
    filteredList.value =
        List.from(ConstantList.interestList.map((e) => Interest.fromJson(e)));

    setInitialValue();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await notificationPermissions(context);
      await loadData();
      scheduleProfileCompletionNotification();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (_pageController.page != 0) {
          _pageController.previousPage(
              duration: const Duration(milliseconds: 100),
              curve: Curves.slowMiddle);
        } else {
          if (Platform.isAndroid) {
            SystemNavigator.pop();
          } else if (Platform.isIOS) {
            exit(0);
          }
        }
        return false;
      },
      child: MultiValueListenableBuilder(
        valueListenables: [currentPage, isAPICall],
        builder: (context, values, _) {
          // ignore: deprecated_member_use
          return WillPopScope(
            onWillPop: () async {
              _showExitAppAlert(context);
              return false;
            },
            child: Scaffold(
              appBar: AppBarX(
                title: UiString.profileDetailText,
                centerTitle: true,
                leading: BackBtnX(
                  onPressed: () async {
                    if (_pageController.page != 0) {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.slowMiddle);
                    } else {
                      AlertService.showAlertMessageWithBtn(
                        context: context,
                        alertMsg: ConstantList.msgList[
                            Random().nextInt(ConstantList.msgList.length)],
                        noTap: () async {
                          Navigator.pop(context);
                          if (Platform.isAndroid) {
                            SystemNavigator.pop();
                          } else if (Platform.isIOS) {
                            exit(0);
                          }
                        },
                        barrierDismissible: true,
                        yesTap: () {},
                        positiveText: 'OK, Convinced',
                        negativeText: 'Still Exit',
                      );
                    }
                  },
                  padding: const EdgeInsets.all(2),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: TextBtnX(
                      color: red,
                      onPressed: () {
                        AlertService.showAlertMessageWithBtn(
                            context: context,
                            alertMsg: "Are you sure you want to logout?",
                            yesTap: () async {
                              cancelProfileCompletionNotification();
                              sl<SharedPrefsManager>().logoutUser(context);
                            },
                            positiveText: 'Yes',
                            negativeText: 'No');
                      },
                      text: UiString.logout),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                      child: PageView.builder(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: getProfilePages().length,
                          onPageChanged: (value) {
                            currentPage.value = value;
                            checkBtnValidation();
                          },
                          itemBuilder: (context, index) {
                            return getProfilePages()[index];
                          })),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0, top: 8),
                        child: Text.rich(TextSpan(children: [
                          TextSpan(
                              text: '${values[0] + 1}',
                              style: const TextStyle(fontSize: 26, color: red)),
                          TextSpan(
                              text: '/${getProfilePages().length}',
                              style: const TextStyle(
                                  fontSize: 23, color: lightRed))
                        ])),
                      ),
                      ValueListenableBuilder(
                          valueListenable: btnEnable,
                          builder: (context, btnValListener, _) {
                            return Row(
                              children: [
                                if (currentPage.value == 5 ||
                                    currentPage.value == 6) ...[
                                  SizedBox(
                                    height:
                                        ResponsiveDesign.height(30, context),
                                    child: TextBtnX(
                                        color: red,
                                        onPressed: () async {
                                          if (currentPage.value == 5) {
                                            if (/*myInterestList.value.length == 1 ||
                                                myInterestList.value.length ==
                                                    2 ||
                                                myInterestList.value.length ==
                                                    3 ||
                                                myInterestList.value.length ==
                                                    4 ||*/
                                                myInterestList.value.isEmpty ||
                                                    myInterestList
                                                            .value.length ==
                                                        5 ||
                                                    myInterestList
                                                            .value.length ==
                                                        6 ||
                                                    myInterestList
                                                            .value.length ==
                                                        7 ||
                                                    myInterestList
                                                            .value.length ==
                                                        8 ||
                                                    myInterestList
                                                            .value.length ==
                                                        9) {
                                              AlertService
                                                  .showAlertMessageWithTwoBtn(
                                                context: context,
                                                alertMsg:
                                                    "Select at least 4 OR 0 of your Interest ",
                                                positiveText: "Ok",
                                                negativeText: "Skip",
                                                noTap: () {
                                                  _pageController.nextPage(
                                                      duration: const Duration(
                                                          milliseconds: 100),
                                                      curve:
                                                          Curves.fastOutSlowIn);
                                                  Navigator.of(context).pop();
                                                },
                                                alertTitle: '',
                                                yesTap: () {
                                                  //Navigator.pop(context);
                                                },
                                              );
                                            } else {
                                              _pageController.nextPage(
                                                  duration: const Duration(
                                                      milliseconds: 100),
                                                  curve: Curves.fastOutSlowIn);
                                            }
                                          } else if (currentPage.value == 6) {
                                            await CheckApiCalling(
                                                btnValListener, values);
                                          } else {}
                                        },
                                        text: "Skip",
                                        radius: 5),
                                  ),
                                ],
                                IconButtonX(
                                  onPressed: () async {
                                    await CheckApiCalling(
                                        btnValListener, values);
                                  },
                                  color: btnValListener ? red : grey,
                                  icon: !values[1]
                                      ? const Icon(
                                          Icons.arrow_forward_ios,
                                          color: white,
                                        )
                                      : const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                ),
                              ],
                            );
                          }),
                    ],
                  ),
                  SizedBox(
                    height: context.height * 0.015,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            context.width < 400 ? context.width * 0.05 : 20),
                    child: StepProgressIndicator(
                      totalSteps: getProfilePages().length,
                      currentStep: values[0] + 1,
                      selectedColor: red,
                      unselectedColor: lightRed,
                      roundedEdges: const Radius.circular(10),
                    ),
                  ),
                  SizedBox(
                    height: context.height * 0.02,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      List<EducationModel> list = [];

      list = await ListRepository().getEducationNameList();

      mainList.value = List.from(list);
      filteredLists.value = List.from(list);

      int index = filteredLists.value
          .indexWhere((element) => element.name == selectEducation);
      if (index != -1) {
        selectedVal.value = filteredLists.value[index];
      } else if (selectEducation.trim().isNotEmpty) {
        mainList.value.insert(
            0,
            EducationModel(
                educationId: selectEducation, name: selectEducation));
        filteredLists.value.insert(
            0,
            EducationModel(
                educationId: selectEducation, name: selectEducation));

        selectedVal.value = filteredLists.value[0];
      }
    } on Exception catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  setInitialValue() {
    var data = sl<SharedPrefsManager>().getSignUpData();
    _firstName.text = data.containsKey("fname") ? data['fname'] : '';
    _lastName.text = data.containsKey("lname") ? data['lname'] : '';
    _mobileNumber.text = data.containsKey("phone")
        ? data['phone'].contains("+")
            ? data['phone'].toString().split(" ").last
            : data['phone']
        : '';
    _countryCode.value = data.containsKey("phone")
        ? data['phone'].contains("+")
            ? data['phone'].toString().split(" ").first
            : "+91"
        : '+91';
    _dateController.text = data.containsKey("dob") ? data['dob'] : '';
    _aboutController.text = data.containsKey("about") ? data['about'] : '';
    isGenderVisible.value = data.containsKey("is_gender_show")
        ? data['is_gender_show'] == '1'
        : true;
    isSexOrientationVisible.value = data.containsKey("is_sex_orientation_show")
        ? data['is_sex_orientation_show'] == '1'
        : true;
    if (data.containsKey("gender") && data['gender'].toString().isNotEmpty) {
      int index = genderList.value
          .indexWhere((element) => element.val == data['gender']);
      if (index != -1) {
        genderList.value[index].isSelected = true;
      }
    }
    if (data.containsKey("sex_orientation") &&
        data['sex_orientation'].toString().isNotEmpty) {
      final tempValue = data['sex_orientation'].split(",");
      for (var v in tempValue) {
        int selectedIndex = sexOrientation.value.indexWhere((element) {
          return v == element.val;
        });
        if (selectedIndex != -1) {
          sexOrientation.value[selectedIndex].isSelected = true;
        }
      }
    }
    if (data.containsKey("interest") &&
        data['interest'].toString().isNotEmpty) {
      // myInterestList.value = data['interest'].toString().split(",");
      d.log('interest: ${data['interest']}');
      // myInterestList.value = List<Interest>.from(data['interest'].map(e) => Interest.from(e));
    } else {
      myInterestList.value = List.from([]);
    }
    if (data.containsKey("show_me") && data['show_me'].toString().isNotEmpty) {
      int index = showMeList.value
          .indexWhere((element) => element.val == data['show_me']);
      if (index != -1) {
        showMeList.value[index].isSelected = true;
      }
    }
    if (data.containsKey("looking_for") &&
        data['looking_for'].toString().isNotEmpty) {
      int index = lookingForList.value
          .indexWhere((element) => element.val == data['looking_for']);
      if (index != -1) {
        lookingForList.value[index].isSelected = true;
      }
    }
    if (data.containsKey("education") &&
        data['education'].toString().isNotEmpty &&
        data.containsKey('education_name') &&
        data['education_name'].toString().isNotEmpty) {
      int index = filteredLists.value
          .indexWhere((element) => element.educationId == data['education']);
      int selectIndex = filteredLists.value
          .indexWhere((element) => element.name == data['education_name']);
      if (index != -1 && selectIndex != -1) {
        selectedVal.value?.educationId = filteredLists.value[index].educationId;
        selectedVal.value?.name = filteredLists.value[index].name;
      }
    }
    if (data.containsKey("future_plan") &&
        data['future_plan'].toString().isNotEmpty) {
      List<String> futurePlanList = data['future_plan'].toString().split(",");

      for (int i = 0; i < futurePlans.value.length; i++) {
        if (futurePlanList.contains(futurePlans.value[i].val)) {
          futurePlans.value[i].isSelected = true;
        }
      }
    }
    checkBtnValidation();
  }

  void checkBtnValidation() {
    switch (currentPage.value) {
      case 0:
        if (btnEnable.value && !_nameFormKey.currentState!.validate()) {
          btnEnable.value = false;
        }
        if (_nameFormKey.currentState != null &&
            _nameFormKey.currentState!.validate()) {
          btnEnable.value = true;
        } else if (_nameFormKey.currentState == null) {
          if (_firstName.text.isNotEmpty && _dateController.text.isNotEmpty) {
            btnEnable.value = true;
          }
        }

        break;
      case 1:
        int selectedIndex =
            genderList.value.indexWhere((element) => element.isSelected);

        int selectingSexOrientCount =
            sexOrientation.value.countWhere((p0) => p0.isSelected);
        if (selectedIndex != -1 && selectingSexOrientCount >= 1) {
          btnEnable.value = true;
        } else if (btnEnable.value) {
          btnEnable.value = false;
        }
        break;

      case 2:
        int selectedIndex =
            lookingForList.value.indexWhere((element) => element.isSelected);
        if (selectedIndex != -1) {
          btnEnable.value = true;
        } else if (btnEnable.value) {
          btnEnable.value = false;
        }
        break;

      case 3:
        if (selectedVal.value != null) {
          btnEnable.value = true;
        } else if (btnEnable.value) {
          btnEnable.value = false;
        }

        break;
      case 4:
        int selectingFuturePlan =
            futurePlans.value.indexWhere((element) => element.isSelected);
        if (selectingFuturePlan != -1) {
          btnEnable.value = true;
        } else if (btnEnable.value) {
          btnEnable.value = false;
        }
        break;
      case 5:
        d.log("condition: ${btnEnable.value}");
        d.log("myInterestList.value: ${myInterestList.value}");
        if (myInterestList.value.length >= Utils.minInterestLength ||
            myInterestList.value.isEmpty) {
          btnEnable.value = true;
        } else if (btnEnable.value) {
          btnEnable.value = false;
        }
        break;
      case 6:
        btnEnable.value = true;

        break;
      default:
        // Do something when the switch is turned off
        break;
    }
  }

  List<Widget> getProfilePages() {
    final pages = [
      basicInfo(),
      genderInfo(),
      // sexOrientationInfo(),
      // showMeInfo(),
      lookingForWidget(),
      education(),
      futurePlan(),
      interestInfo(),
      aboutMe(),
    ];
    return pages;
  }

  void _showExitAppAlert(BuildContext context) {
    AlertService.showAlertMessageWithBtn(
      context: context,
      alertMsg:
          ConstantList.msgList[Random().nextInt(ConstantList.msgList.length)],
      noTap: () async {
        Navigator.pop(context);
        if (Platform.isAndroid) {
          SystemNavigator.pop();
        } else if (Platform.isIOS) {
          exit(0);
        }
      },
      barrierDismissible: true,
      yesTap: () {},
      positiveText: 'OK, Convinced',
      negativeText: 'Still Exit',
    );
  }

  Widget basicInfo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _nameFormKey,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: context.width < 400 ? context.width * 0.05 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.height * 0.02,
              ),
              HeadingStyles.boardingHeading(context, UiString.myName,
                  fontSize: 18),
              SizedBox(
                height: context.height * 0.03,
              ),
              TextFieldX(
                controller: _firstName,
                hint: "James" /*UiString.firstNameText*/,
                label: UiString.firstNameText,
                validator: (value) {
                  return nameValidator(value, UiString.enterYourFirstName,
                      checkEmpty: true);
                },
                onChanged: (value) {
                  checkBtnValidation();
                },
              ),
              SizedBox(
                height: ResponsiveDesign.height(15, context),
              ),
              TextFieldX(
                controller: _lastName,
                hint: "D'Souza",
                label: UiString.lastNameText,
                validator: (value) {
                  return nameValidator(value, UiString.enterYourLastName);
                },
                onChanged: (value) {
                  checkBtnValidation();
                },
              ),
              SizedBox(
                height: ResponsiveDesign.height(15, context),
              ),
              DateTextFieldX(
                label: UiString.dobText,
                controller: _dateController,
                hint: 'DD/MM/YYYY',
                validator: (value) {
                  if (value == null || value.isEmpty || value.length != 10) {
                    return UiString.enterYourDOB;
                  }
                  return null;
                },
                onChanged: (value) {
                  checkBtnValidation();
                },
              ),
              SizedBox(
                height: ResponsiveDesign.height(15, context),
              ),
              // TextFieldX(
              //   controller: _mobileNumber,
              //   keyboardType: TextInputType.number,
              //   hint: UiString.phoneText,
              //   label: UiString.phoneText,
              //   onChanged: (phoneVal) {
              //     checkBtnValidation();
              //   },
              //   leading: ValueListenableBuilder(
              //       valueListenable: _countryCode,
              //       builder: (context, val, _) {
              //         return CountryCodePicker(
              //           initialSelection: val,
              //           favorite: const ['+91'],
              //           showCountryOnly: true,
              //           showOnlyCountryWhenClosed: false,
              //           alignLeft: false,
              //         );
              //       }),
              //   validator: (value) {
              //     return (value == null || value.toString().isEmpty)
              //         ? null
              //         : phoneValidator(value);
              //   },
              // ),
              // SizedBox(
              //   height: ResponsiveDesign.height(15, context),
              // ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                      text: UiString.important,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: ResponsiveDesign.fontSize(9.5, context))),
                  TextSpan(
                      text: UiString.dobImportantText,
                      style: TextStyle(
                          fontSize: ResponsiveDesign.fontSize(9.5, context)))
                ])),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget genderInfo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: context.width < 400 ? context.width * 0.05 : 24),
        child: ValueListenableBuilder(
            valueListenable: genderList,
            builder: (context, genderValListener, _) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: context.height * 0.02,
                  ),
                  HeadingStyles.boardingHeading(
                      context, UiString.whatYourGenderText,
                      fontSize: 18),
                  SizedBox(
                    height: ResponsiveDesign.height(15, context),
                  ),
                  Container(
                    width: double.maxFinite,
                    alignment: Alignment.center,
                    child: Wrap(
                      runAlignment: WrapAlignment.spaceBetween,
                      // alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                          genderValListener.length,
                          (index) => InkWell(
                              onTap: () {
                                int selectedIndex =
                                    genderValListener.indexWhere(
                                        (element) => element.isSelected);
                                if (selectedIndex != -1) {
                                  genderValListener[selectedIndex].isSelected =
                                      false;
                                }
                                genderValListener[index].isSelected = true;
                                genderList.value = List.from(genderValListener);
                                checkBtnValidation();
                              },
                              child: CustomRadio(genderValListener[index]))),
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveDesign.height(5, context),
                  ),
                  ValueListenableBuilder(
                      valueListenable: isGenderVisible,
                      builder: (context, genderValListener, _) {
                        return InkWell(
                          onTap: () {
                            isGenderVisible.value = !isGenderVisible.value;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: isGenderVisible.value,
                                  visualDensity: const VisualDensity(
                                      horizontal: -4, vertical: -4),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: (value) {
                                    isGenderVisible.value =
                                        !isGenderVisible.value;
                                  },
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  UiString.showGenderText,
                                  style: context.textTheme.titleMedium
                                      ?.copyWith(fontSize: 13),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                  SizedBox(
                    height: ResponsiveDesign.height(10, context),
                  ),
                  if (genderValListener
                          .indexWhere((element) => element.isSelected) ==
                      2) ...[showMeInfo()] else ...[sexOrientationInfo()]
                ],
              );
            }),
      ),
    );
  }

  Widget sexOrientationInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: ResponsiveDesign.height(10, context),
        ),
        HeadingStyles.boardingHeading(context, UiString.mySexOrientationText,
            fontSize: 18),
        SizedBox(
          height: ResponsiveDesign.height(15, context),
        ),
        ValueListenableBuilder(
            valueListenable: sexOrientation,
            builder: (context, sexOrientationVal, _) {
              return Wrap(
                spacing: 10,
                children: List.generate(
                    sexOrientationVal.length,
                    (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: MultipleCheckBtnX<SexOrientation>(
                              value: sexOrientationVal[index],
                              text: sexOrientationVal[index].val,
                              isSelected: sexOrientationVal[index].isSelected,
                              height: 60,
                              onChanged: (value) {
                                if (value != null) {
                                  int index = sexOrientationVal.indexWhere(
                                      (element) => value.val == element.val);
                                  int totalCount = sexOrientationVal
                                      .countWhere((p0) => p0.isSelected);
                                  if (value.isSelected) {
                                    sexOrientationVal[index].isSelected = false;
                                  } else if (totalCount < 3) {
                                    sexOrientationVal[index].isSelected = true;
                                  }
                                  sexOrientation.value =
                                      List.from(sexOrientationVal);
                                  checkBtnValidation();
                                }
                              }),
                        )),
              );
            }),
        SizedBox(
          height: ResponsiveDesign.height(5, context),
        ),
        ValueListenableBuilder(
            valueListenable: isSexOrientationVisible,
            builder: (context, sexOrientationValListener, _) {
              return InkWell(
                onTap: () {
                  isSexOrientationVisible.value =
                      !isSexOrientationVisible.value;
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: isSexOrientationVisible.value,
                      visualDensity:
                          const VisualDensity(horizontal: -4, vertical: -4),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onChanged: (value) {
                        isSexOrientationVisible.value =
                            !isSexOrientationVisible.value;
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      UiString.showSexOrientationText,
                      style:
                          context.textTheme.titleMedium?.copyWith(fontSize: 13),
                    )
                  ],
                ),
              );
            }),
      ],
    );
  }

  Widget showMeInfo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: context.height * 0.02,
          ),
          HeadingStyles.boardingHeading(context, UiString.showMe, fontSize: 18),
          SizedBox(
            height: ResponsiveDesign.height(15, context),
          ),
          Container(
            width: double.maxFinite,
            alignment: Alignment.center,
            child: ValueListenableBuilder(
                valueListenable: showMeList,
                builder: (context, showMeValListener, _) {
                  return Wrap(
                    // alignment: WrapAlignment.center,
                    runSpacing: 10,
                    spacing: 5,
                    children: List.generate(
                        showMeValListener.length,
                        (index) => InkWell(
                            onTap: () {
                              int selectedIndex = showMeValListener
                                  .indexWhere((element) => element.isSelected);
                              if (selectedIndex != -1) {
                                showMeValListener[selectedIndex].isSelected =
                                    false;
                              }
                              showMeValListener[index].isSelected = true;
                              showMeList.value = List.from(showMeValListener);
                              checkBtnValidation();
                            },
                            child: CustomRadio(showMeValListener[index]))),
                  );
                }),
          ),
          SizedBox(
            height: ResponsiveDesign.height(15, context),
          ),
          ValueListenableBuilder(
              valueListenable: isShowMe,
              builder: (context, sexOrientationValListener, _) {
                return InkWell(
                  onTap: () {
                    isShowMe.value = !isShowMe.value;
                  },
                  child: Row(
                    children: [
                      Checkbox(
                        value: isShowMe.value,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          isShowMe.value = !isShowMe.value;
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        UiString.showMeMyShowText,
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontSize: 13),
                      )
                    ],
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget lookingForWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: context.width < 400 ? context.width * 0.05 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: context.height * 0.01,
            ),
            HeadingStyles.boardingHeading(context, UiString.iAmLookingFOr,
                fontSize: 18),
            SizedBox(
              height: context.height * 0.005,
            ),
            HeadingStyles.boardingHeadingCaption(
                context, UiString.lookingForSubCaption,
                fontSize: ResponsiveDesign.fontSize(13, context)),
            SizedBox(
              height: context.height * 0.02,
            ),
            Container(
              width: double.maxFinite,
              alignment: Alignment.center,
              child: ValueListenableBuilder(
                  valueListenable: lookingForList,
                  builder: (context, lookingForValListener, _) {
                    return Wrap(
                      runAlignment: WrapAlignment.spaceBetween,
                      // alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(
                          lookingForValListener.length,
                          (index) => InkWell(
                              onTap: () {
                                int selectedIndex =
                                    lookingForValListener.indexWhere(
                                        (element) => element.isSelected);
                                if (selectedIndex != -1) {
                                  lookingForValListener[selectedIndex]
                                      .isSelected = false;
                                }

                                lookingForValListener[index].isSelected = true;

                                lookingForList.value =
                                    List.from(lookingForValListener);
                                checkBtnValidation();
                              },
                              child: LookingForCard(
                                  lookingFor: lookingForValListener[index]))),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Type getChipType(final values) {
    if (values[0] == 3) {
      return String;
    } else {
      return Interest;
    }
  }

  Widget interestInfo() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(
              horizontal: context.width < 400 ? context.width * 0.05 : 24),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.height * 0.015,
                ),
                HeadingStyles.boardingHeading(context, UiString.yourInterest,
                    fontSize: 18),
                SizedBox(
                  height: context.height * 0.004,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: UiString.interestSubCaptionBold,
                        style: context.textTheme.bodyMedium!.copyWith(
                            color: 0xff6a6b70.toColor,
                            fontWeight: FontWeight.bold,
                            fontSize: ResponsiveDesign.fontSize(13, context)),
                      ),
                      const TextSpan(
                        text: UiString.interestSubCaption,
                      ),
                    ]),
                    style: context.textTheme.bodyMedium!.copyWith(
                        color: 0xff6a6b70.toColor,
                        fontSize: ResponsiveDesign.fontSize(13, context)),
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: context.height * 0.008,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: ResponsiveDesign.only(context, bottom: 9),
          sliver: SliverAppBar(
            surfaceTintColor: Colors.transparent,
            foregroundColor: Colors.transparent,
            leadingWidth: 5,
            pinned: true,
            backgroundColor: Colors.white,
            title: TextField(
              controller: _searchController,
              onChanged: (value) {
                List<Interest> temp = [];
                if (value.trim().isNotEmpty) {
                  temp = allInterests
                      .where((element) => element.interest
                          .toLowerCase()
                          .contains(value.trim().toLowerCase()))
                      .toList();
                } else {
                  temp = List.from(allInterests);
                }
                // filteredList.value = List.from(temp);
                filteredList.value =
                    List.from(temp.sortBySelected(myInterestList.value));
              },
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Colors.grey,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              final temp = List.from(allInterests);
                              filteredList.value = List.from(
                                  temp.sortBySelected(myInterestList.value));
                            });
                          },
                          icon: Container(
                            decoration: const BoxDecoration(
                                color: Colors.grey, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.close,
                              color: white,
                              size: 20,
                            ),
                          ),
                        )
                      : null,
                  isCollapsed: true,
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildListDelegate([
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(
                horizontal: context.width < 400 ? context.width * 0.05 : 15),
            child: MultiValueListenableBuilder(
                valueListenables: [myInterestList, filteredList],
                builder: (context, values, _) {
                  return ChipsChoice<dynamic>.multiple(
                    value: values[0],
                    wrapped: true,
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5),
                    onChanged: (val) {
                      if (values[0].length < Utils.maxInterestLength) {
                        myInterestList.value = List.from(val);
                      } else if (val.length < Utils.maxInterestLength) {
                        myInterestList.value = List.from(val);
                      } else {
                        context.showSnackBar("Select a maximum of 9 interests");
                      }
                      filteredList.value = List.from(filteredList.value
                          .sortBySelected(myInterestList.value));
                      checkBtnValidation();
                    },
                    choiceItems: C2Choice.listFrom<Interest, Interest>(
                      source: List.from(values[1]),
                      value: (index, item) => item,
                      label: (index, item) => item.interest,
                    ),
                    choiceBuilder: (C2Choice choice, index) {
                      return InkWell(
                        onTap: () {
                          choice.select!(!choice.selected);
                        },
                        child: Container(
                          key: ValueKey(choice.value.toString()),
                          width: (context.width * 0.44),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: choice.selected
                                    ? red
                                    : grey.toMaterialColor.shade100),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: choice.selected
                                      ? red
                                      : grey.toMaterialColor.shade100,
                                  blurRadius: 3.0,
                                  offset: const Offset(0.0, 0.75))
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          constraints: const BoxConstraints(minHeight: 55),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Text(
                            choice.label,
                            style: context.textTheme.titleMedium!.copyWith(
                                color: choice.selected ? red : Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    ResponsiveDesign.fontSize(12, context),
                                letterSpacing: 0.1),
                          ),
                        ),
                      );
                    },
                    crossAxisAlignment: CrossAxisAlignment.start,
                  );
                }),
          ),
        ]))
      ],
    );
  }

  Widget aboutMe() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _aboutFormKey,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: context.width < 400 ? context.width * 0.05 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.height * 0.02,
              ),
              HeadingStyles.boardingHeading(context, UiString.aboutMe,
                  fontSize: 18),
              SizedBox(
                height: context.height * 0.002,
              ),
              HeadingStyles.boardingHeadingCaption(
                  context, UiString.aboutMeSubCaption,
                  isCenter: false),
              SizedBox(
                height: context.height * 0.01,
              ),
              TextFieldX(
                controller: _aboutController,
                validator: null,
                hint: UiString.aboutText,
                maxlength: 500,
                maxlines: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget futurePlan() {
    return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: context.width < 400 ? context.width * 0.05 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: context.height * 0.01,
              ),
              HeadingStyles.boardingHeading(context, UiString.futurePlan,
                  fontSize: 18),
              SizedBox(
                height: context.height * 0.005,
              ),
              HeadingStyles.boardingHeadingCaption(
                  context, UiString.selectOptions,
                  isCenter: false,
                  fontSize: ResponsiveDesign.fontSize(13, context)),
              SizedBox(
                height: context.height * 0.02,
              ),
              Container(
                width: double.maxFinite,
                alignment: Alignment.center,
                child: ValueListenableBuilder(
                    valueListenable: futurePlans,
                    builder: (context, Futureplans, _) {
                      return Wrap(
                        runAlignment: WrapAlignment.spaceEvenly,
                        // alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: List.generate(
                            Futureplans.length,
                            (index) => InkWell(
                                onTap: () {
                                  if (Futureplans.isNotEmpty) {
                                    int selectedIndex = Futureplans.indexWhere(
                                        (element) =>
                                            Futureplans[index].val ==
                                            element.val);
                                    int totalCount = Futureplans.countWhere(
                                        (p0) => p0.isSelected);
                                    if (Futureplans[selectedIndex].isSelected) {
                                      Futureplans[selectedIndex].isSelected =
                                          false;
                                    } else if (totalCount < 2) {
                                      Futureplans[selectedIndex].isSelected =
                                          true;
                                    }
                                    futurePlans.value = List.from(Futureplans);
                                    checkBtnValidation();
                                  }
                                  //Futureplans[index].isSelected = true;
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Futureplans[index].isSelected
                                            ? red
                                            : grey.toMaterialColor.shade100),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(
                                          color: Futureplans[index].isSelected
                                              ? red
                                              : grey.toMaterialColor.shade100,
                                          blurRadius: 3.0,
                                          offset: const Offset(0.0, 0.75))
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 8),
                                  child: Text(
                                    Futureplans[index].val,
                                    style: context.textTheme.titleMedium!
                                        .copyWith(
                                            color: Futureplans[index].isSelected
                                                ? red
                                                : Colors.black,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            letterSpacing: 0.1),
                                  ),
                                ))),
                      );
                    }),
              ),
            ],
          ),
        ));
  }

  Widget education() {
    return MultiValueListenableBuilder(
      valueListenables: [mainList, selectedVal, filteredLists, isLoading],
      builder: (context, values, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: context.width < 400 ? context.width * 0.05 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: context.height * 0.01,
                ),
                HeadingStyles.boardingHeading(context, UiString.educationQue,
                    fontSize: 18),
                SizedBox(
                  height: context.height * 0.005,
                ),
                HeadingStyles.boardingHeadingCaption(
                  context,
                  UiString.educationNote,
                  isCenter: false,
                  fontSize: ResponsiveDesign.fontSize(13, context),
                ),
                SizedBox(
                  height: context.height * 0.01,
                ),
                TextField(
                  controller: searchEducation,
                  onChanged: (value) {
                    var temp = mainList.value.where((element) =>
                        (element.name?.trim() ?? '')
                            .toLowerCase()
                            .contains(value.trim().toLowerCase()));
                    if (temp.isEmpty) {
                      filteredLists.value.clear();
                      filteredLists.value
                          .add(EducationModel(educationId: value, name: value));
                    } else {
                      filteredLists.value = List.from(temp);
                    }
                    filteredLists.notifyListeners();
                    checkBtnValidation();
                  },
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 15),
                      prefixIcon: const Icon(
                        CupertinoIcons.search,
                        color: Colors.grey,
                      ),
                      suffixIcon: searchEducation.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                searchEducation.clear();
                                filteredLists.value = List.from(mainList.value);
                              },
                              icon: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.grey, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(2),
                                child: const Icon(
                                  Icons.close,
                                  color: white,
                                  size: 20,
                                ),
                              ),
                            )
                          : null,
                      isCollapsed: true,
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(10))),
                ),
                SizedBox(
                  height: context.height * 0.01,
                ),
                if (!isLoading.value) ...[
                  if (filteredLists.value.isNotEmpty) ...[
                    ChipsChoice<String?>.single(
                      padding: const EdgeInsets.all(5),
                      value: selectedVal.value?.educationId,
                      onChanged: (value) {
                        int index = filteredLists.value.indexWhere(
                            (element) => element.educationId == value);
                        if (index != -1) {
                          selectedVal.value = filteredLists.value[index];
                        }
                        checkBtnValidation();
                      },
                      wrapped: true,
                      choiceItems: C2Choice.listFrom<String?, EducationModel>(
                        source: filteredLists.value,
                        value: (index, item) => item.educationId,
                        label: (index, item) => item.name ?? '',
                      ),
                      choiceBuilder: (C2Choice choice, i) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            choice.select!(!choice.selected);
                          },
                          child: Container(
                            width: (context.width * 0.41),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: choice.selected
                                    ? red
                                    : grey.toMaterialColor.shade100,
                              ),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: choice.selected
                                      ? red
                                      : grey.toMaterialColor.shade100,
                                  blurRadius: 3.0,
                                  offset: const Offset(0.0, 0.75),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(minHeight: 55),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 8),
                            child: Center(
                              child: Text(
                                choice.label,
                                style: context.textTheme.titleMedium!.copyWith(
                                    color: choice.selected ? red : Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize:
                                        ResponsiveDesign.fontSize(12, context),
                                    letterSpacing: 0.1),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ] else ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 100.0),
                      child: Center(
                        child: EmptyWidget(),
                      ),
                    )
                  ]
                ] else ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: red,
                      ),
                    ),
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    d.log("data: ${data.toString()}");
    try {
      bool isInternet =
          await sl<InternetConnectionService>().hasInternetConnection();
      if (isInternet) {
        Map<String, dynamic> apiResponse = await UserRepository().updateProfile(
          data: data,
        );
        d.log("apiResponse: ${apiResponse.toString()}");
        if (apiResponse[UiString.successText]) {
          if (apiResponse[UiString.dataText] != null) {
            User user = User.fromJson(apiResponse[UiString.dataText]);
            await sl<SharedPrefsManager>().saveUserInfo(user);
            cancelProfileCompletionNotification();

            Future.delayed(const Duration(seconds: 0), () {
              context.showSnackBar(apiResponse[UiString.messageText]);
              _navigationService.navigateTo(RoutePaths.addPhotos,
                  withPushAndRemoveUntil: true, arguments: false);
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
    } on Exception catch (e) {
      Future.delayed(const Duration(seconds: 0), () {
        context.showSnackBar(e.toString());
      });
    } finally {
      isAPICall.value = false;
    }
  }

  Future<void> CheckApiCalling(
      bool btnValListener, List<dynamic> values) async {
    FocusScope.of(context).unfocus();
    Future.delayed(const Duration(milliseconds: 200), () async {
      if (btnValListener) {
        int genderIndex =
            genderList.value.indexWhere((element) => element.isSelected);
        int showMeIndex =
            showMeList.value.indexWhere((element) => element.isSelected);
        int lookingForIndex =
            lookingForList.value.indexWhere((element) => element.isSelected);
        int educationIndex = mainList.value.indexWhere(
            (element) => element.educationId == selectedVal.value?.educationId);
        Map<String, dynamic> data = {
          // ignore: unnecessary_string_escapes
          'fname': _firstName.text.trim().replaceAll("'", "\\'"),
          // ignore: unnecessary_string_escapes
          'lname': _lastName.text.trim().replaceAll("'", "\\'"),
          'dob': _dateController.text.trim(),
          // 'phone':
          //     "${_countryCode.value} ${_mobileNumber.text.trim()}",
          'gender': genderIndex != -1 ? genderList.value[genderIndex].val : '',
          'is_gender_show': isGenderVisible.value ? '1' : '0',
          'sex_orientation': sexOrientation.value
              .where((element) => element.isSelected)
              .map((e) => e.val)
              .toList()
              .join(","),
          'is_sex_orientation_show': isSexOrientationVisible.value ? '1' : '0',
          'show_me': showMeIndex != -1 ? showMeList.value[showMeIndex].val : '',
          'is_show_me': isShowMe.value ? '1' : '0',
          'looking_for': lookingForIndex != -1
              ? lookingForList.value[lookingForIndex].val
              : '',
          'interest': (myInterestList.value.isEmpty)
              ? []
              : myInterestList.value.join(","),
          'about': _aboutController.text.trim(),
          'education': educationIndex != -1
              ? mainList.value[educationIndex].educationId
              : 0,
          'education_name': selectedVal.value?.name ?? '',
          'future_plan': futurePlans.value
              .where((element) => element.isSelected)
              .toList()
              .map((e) => e.val)
              .join(","),
        };
        sl<SharedPrefsManager>().saveSignUpData(data);
        if (currentPage.value != getProfilePages().length - 1) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 100),
              curve: Curves.fastOutSlowIn);

          checkBtnValidation();
        } else {
          if (!values[1]) {
            isAPICall.value = true;
            FocusScope.of(context).unfocus();
            await updateProfile(data);
          }
        }
      }
    });
  }
}
