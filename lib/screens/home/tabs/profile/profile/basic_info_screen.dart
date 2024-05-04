// ignore_for_file: unrelated_type_equality_checks

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/models/user.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

import '../../../../../services/singleton_locator.dart';
import '../../../../../widgets/core/alerts.dart';

class BasicInfoScreen extends StatefulWidget {
  final String expansionStr;
  final User loginUser;

  const BasicInfoScreen(
      {Key? key, required this.expansionStr, required this.loginUser})
      : super(key: key);

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  String _zodiac = '';
  String _education = '';

  // String _futurePlan = '';
  String _covidVaccine = '';
  String _personalityType = '';

  // String _habits = '';
  List<String> futurePlanVal = [];
  List<String> _habitVal = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _zodiac = widget.loginUser.zodiac ?? '';
    _education = widget.loginUser.education ?? '';
    futurePlanVal = widget.loginUser.futurePlan?.toString().split(",") ?? [];
    _covidVaccine = widget.loginUser.covidVaccine ?? '';
    _personalityType = widget.loginUser.personalityType ?? '';
    _habitVal = widget.loginUser.habit?.toString().split(",") ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (widget.loginUser.zodiac != _zodiac ||
            widget.loginUser.education != _education ||
            widget.loginUser.futurePlan != futurePlanVal.join(",") ||
            widget.loginUser.covidVaccine != _covidVaccine ||
            widget.loginUser.personalityType != _personalityType ||
            widget.loginUser.habit != _habitVal.join(",")) {
          _showExitAppAlert(context);
          return false;
        } else {
          sl<NavigationService>().pop();
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBarX(
          title: UiString.basic,
          leading: BackBtnX(
            onPressed: () {
              if (widget.loginUser.zodiac != _zodiac ||
                  widget.loginUser.education != _education ||
                  widget.loginUser.futurePlan != futurePlanVal.join(",") ||
                  widget.loginUser.covidVaccine != _covidVaccine ||
                  widget.loginUser.personalityType != _personalityType ||
                  widget.loginUser.habit != _habitVal.join(",")) {
                _showExitAppAlert(context);
              } else {
                sl<NavigationService>().pop();
              }
            },
          ),
          trailing: widget.loginUser.zodiac != _zodiac ||
                  widget.loginUser.education != _education ||
                  widget.loginUser.futurePlan != futurePlanVal.join(",") ||
                  widget.loginUser.covidVaccine != _covidVaccine ||
                  widget.loginUser.personalityType != _personalityType ||
                  widget.loginUser.habit != _habitVal.join(",")
              ? SizedBox(
                  width: ResponsiveDesign.width(90, context),
                  child: OutLineBtnX(
                    radius: 10,
                    color: black,
                    onPressed: () {
                      final provider =
                          Provider.of<EditUserProvider>(context, listen: false);
                      provider.updateBasicProfile(
                          _zodiac,
                          _education,
                          futurePlanVal.join(","),
                          _covidVaccine,
                          _personalityType,
                          _habitVal.join(","));

                      sl<NavigationService>().pop();
                    },
                    text: '',
                    child: const Text(
                      "Save",
                      style: TextStyle(color: black),
                    ),
                  ),
                )
              : null,
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeadingStyles.boardingHeading(context, UiString.basic),
                const SizedBox(
                  height: 5,
                ),
                HeadingStyles.boardingHeadingCaption(
                    context, UiString.basicSubCaption,
                    isCenter: false),
                const SizedBox(
                  height: 5,
                ),
                customExpansionTile(
                    onChanged: (val) {
                      setState(() => _zodiac = val == _zodiac ? '' : val);
                    },
                    iconData: CupertinoIcons.moon_stars_fill,
                    que: UiString.zodiacQue,
                    answer: ConstantList.zodiacSign,
                    isExpanded: widget.expansionStr == UiString.zodiacQue,
                    selectingVal: _zodiac),
                customExpansionTile(
                    isExpanded: widget.expansionStr == UiString.familyPlanQue,
                    iconData: Icons.diversity_3,
                    que: UiString.familyPlanQue,
                    answer: ConstantList.futurePlans,
                    selectingVal: futurePlanVal.join(",")),
                customExpansionTile(
                    onChanged: (val) {
                      setState(() =>
                          _covidVaccine = val == _covidVaccine ? '' : val);
                    },
                    isExpanded: widget.expansionStr == UiString.vaccinatedQue,
                    iconData: Icons.vaccines,
                    que: UiString.vaccinatedQue,
                    answer: ConstantList.vaccinatedList,
                    selectingVal: _covidVaccine),
                customExpansionTile(
                    onChanged: (val) {
                      setState(() => _personalityType =
                          val == _personalityType ? '' : val);
                    },
                    isExpanded: widget.expansionStr == UiString.personalityQue,
                    iconData: CupertinoIcons.cube,
                    que: UiString.personalityQue,
                    answer: ConstantList.personalityList,
                    selectingVal: _personalityType,
                    showHelp: true),
                habitExpansionTile(
                  isExpanded: widget.expansionStr == UiString.habit,
                  iconData: CupertinoIcons.sun_haze,
                  que: UiString.habit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget customExpansionTile({
    required IconData iconData,
    required String que,
    required List<String> answer,
    required bool isExpanded,
    Function(dynamic)? onChanged,
    bool showHelp = false,
    String? selectingVal,
  }) {
    return ExpansionTile(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              children: [
                Icon(
                  iconData,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  que,
                  style: TextStyle(
                      fontSize: ResponsiveDesign.fontSize(15, context),
                      fontWeight: FontWeight.w800),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          if (que == UiString.familyPlanQue) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                textAlign: TextAlign.start,
                UiString.selectOptions,
                style: context.textTheme.bodySmall,
                maxLines: 2,
              ),
            ),
          ]
        ],
      ),
      initiallyExpanded: isExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.centerLeft,
      children: [
        if (que == UiString.familyPlanQue) ...[
          ChipsChoice<String>.multiple(
            value: futurePlanVal,
            onChanged: (value) {
              if (futurePlanVal.length < 2) {
                futurePlanVal = List.from(value);
              } else if (value.length < 2) {
                futurePlanVal = List.from(value);
              } else if (value.length > 2) {
                context.showSnackBar("Select a maximum of 2 interests");
              }

              setState(() {});
            },
            wrapped: true,
            padding: const EdgeInsets.all(5),
            choiceItems: C2Choice.listFrom<String, String>(
              source: answer,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          )
        ] else ...[
          ChipsChoice<String>.single(
            value: selectingVal,
            onChanged: onChanged!,
            wrapped: true,
            padding: const EdgeInsets.all(5),
            choiceItems: C2Choice.listFrom<String, String>(
              source: answer,
              value: (i, v) => v,
              label: (i, v) => v,
            ),
          )
        ],
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  Widget habitExpansionTile({
    required IconData iconData,
    required String que,
    required bool isExpanded,
    bool showHelp = false,
    String? selectingVal,
  }) {
    return ExpansionTile(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              children: [
                Icon(
                  iconData,
                  size: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  que,
                  style: const TextStyle(
                      fontSize: 13.0, fontWeight: FontWeight.w800),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
      initiallyExpanded: isExpanded,
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      expandedAlignment: Alignment.centerLeft,
      children: [
        const Text(
          "Smoking Habits ?",
          style: TextStyle(
              fontSize: 12.0, fontWeight: FontWeight.w800, color: grey),
          maxLines: 2,
        ),
        const SizedBox(
          height: 2,
        ),
        ChipsChoice<String>.single(
          value: _habitVal
                  .where(
                      (element) => ConstantList.smokerHabits.contains(element))
                  .isNotEmpty
              ? _habitVal
                  .where(
                      (element) => ConstantList.smokerHabits.contains(element))
                  .first
              : null,
          onChanged: (value) {
            int index = _habitVal.indexWhere(
                (element) => ConstantList.smokerHabits.contains(element));
            if (index != -1) {
              _habitVal.removeAt(index);
            }
            _habitVal.add(value);
            setState(() {});
          },
          wrapped: true,
          padding: const EdgeInsets.all(5),
          choiceItems: C2Choice.listFrom<String, String>(
            source: ConstantList.smokerHabits,
            value: (i, v) => v,
            label: (i, v) => v,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        const Text(
          "Drinking Habits ?",
          style: TextStyle(
              fontSize: 12.0, fontWeight: FontWeight.w800, color: grey),
          maxLines: 2,
        ),
        const SizedBox(
          height: 2,
        ),
        ChipsChoice<String>.single(
          value: _habitVal
                  .where(
                      (element) => ConstantList.drinkerHabits.contains(element))
                  .isNotEmpty
              ? _habitVal
                  .where(
                      (element) => ConstantList.drinkerHabits.contains(element))
                  .first
              : null,
          onChanged: (value) {
            int index = _habitVal.indexWhere(
                (element) => ConstantList.drinkerHabits.contains(element));
            if (index != -1) {
              _habitVal.removeAt(index);
            }
            _habitVal.add(value);
            setState(() {});
          },
          wrapped: true,
          padding: const EdgeInsets.all(5),
          choiceItems: C2Choice.listFrom<String, String>(
            source: ConstantList.drinkerHabits,
            value: (i, v) => v,
            label: (i, v) => v,
          ),
        ),
        const SizedBox(
          height: 8,
        )
      ],
    );
  }

  void _showExitAppAlert(BuildContext context) {
    AlertService.showAlertMessageWithTwoBtn(
        context: context,
        alertTitle: "",
        alertMsg: "Are you sure,you don't want to save the changes ?",
        positiveText: "Save",
        negativeText: "Don't want",
        noTap: () {
          //close pop up
          Navigator.pop(context);

          // screen pop up
          sl<NavigationService>().pop();
        },
        yesTap: () {
          final provider =
              Provider.of<EditUserProvider>(context, listen: false);
          provider.updateBasicProfile(
              _zodiac,
              _education,
              futurePlanVal.join(","),
              _covidVaccine,
              _personalityType,
              _habitVal.join(","));
          Navigator.pop(context);
        });
  }
}
