import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/models/gender_model.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/screens/profile/widgets/custom_cards.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../../../../../constants/ui_strings.dart';

class GenderScreen extends StatefulWidget {
  final String gender;
  final int isGenderShow;
  final String showMe;
  final int isShowMe;
  final String sexOrientation;
  final int isSexOrientation;

  const GenderScreen({
    Key? key,
    required this.gender,
    required this.isGenderShow,
    required this.showMe,
    required this.isShowMe,
    required this.sexOrientation,
    required this.isSexOrientation,
  }) : super(key: key);

  @override
  State<GenderScreen> createState() => _GenderScreenState();
}

class _GenderScreenState extends State<GenderScreen> {
  final ValueNotifier<List<Gender>> genderList = ValueNotifier([]);
  final ValueNotifier<List<Gender>> showList = ValueNotifier([]);
  final ValueNotifier<List<SexOrientation>> sexOrientation = ValueNotifier([]);

  final ValueNotifier<String> _genderVal = ValueNotifier("");
  final ValueNotifier<String> _showMeNewValue = ValueNotifier("");
  final ValueNotifier<String> _sexOrientationValue = ValueNotifier("");
  final ValueNotifier<int> _isVisible = ValueNotifier(1);
  final ValueNotifier<int> _isShowMeBoolean = ValueNotifier(1);
  final ValueNotifier<int> _sexValueBoolean = ValueNotifier(1);
  final ValueNotifier<bool> showMeShow = ValueNotifier(false);

  @override
  void initState() {
    _genderVal.value = widget.gender;
    _showMeNewValue.value = widget.showMe;
    _sexOrientationValue.value = widget.sexOrientation;
    _isVisible.value = widget.isGenderShow;
    _isShowMeBoolean.value = widget.isShowMe;
    _sexValueBoolean.value = widget.isSexOrientation;

    genderList.value.clear();
    genderList.value = List.from(ConstantList.genderList
      ..forEach((element) {
        element.isSelected = false;
      }));
    int selectedIndex = genderList.value
        .indexWhere((element) => element.val == _genderVal.value);
    if (selectedIndex != -1) {
      genderList.value[selectedIndex].isSelected = true;
    }

    if (_genderVal.value == ConstantList.genderList[2].val) {
      showMeShow.value = true;
    } else {
      showMeShow.value = false;
    }

    showList.value.clear();
    showList.value = List.from(ConstantList.showMeList
      ..forEach((element) {
        element.isSelected = false;
      }));
    int selectedShowIndex = showList.value
        .indexWhere((element) => element.val == _showMeNewValue.value);
    if (selectedShowIndex != -1) {
      showList.value[selectedShowIndex].isSelected = true;
    }

    final tempValue = _sexOrientationValue.value.split(",");
    sexOrientation.value.clear();
    sexOrientation.value = List.from(ConstantList.sexOrientation
      ..forEach((element) {
        element.isSelected = false;
      }));
    if (tempValue.isNotEmpty) {
      for (var v in tempValue) {
        int selectedIndex = sexOrientation.value.indexWhere((element) {
          return v == element.val;
        });
        if (selectedIndex != -1) {
          sexOrientation.value[selectedIndex].isSelected = true;
        }
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EditUserProvider, Tuple3<String?, String?, String?>>(
      selector: (context, provider) {
        return Tuple3(
            provider.loginUser?.gender?.toString(),
            provider.loginUser?.showme?.toString(),
            provider.loginUser?.sexOrientation?.toString());
      },
      builder: (context, allTuplesVal, child) {
        return Scaffold(
          appBar: AppBarX(
            title: "",
            trailing: MultiValueListenableBuilder(
                valueListenables: [
                  _genderVal,
                  _showMeNewValue,
                  _sexOrientationValue,
                  _isVisible,
                  _isShowMeBoolean,
                  _sexValueBoolean
                ],
                builder: (context, values, _) {
                  if (widget.gender != values[0] ||
                      widget.isGenderShow != values[1] ||
                      widget.showMe != values[2] ||
                      widget.isShowMe != values[3] ||
                      widget.sexOrientation != values[4] ||
                      widget.isSexOrientation != values[5]) {
                    return TextBtnX(
                        onPressed: () {
                          final provider = Provider.of<EditUserProvider>(
                              context,
                              listen: false);

                          provider.updateGender(_genderVal.value);
                          provider
                              .updateGenderShow(_isVisible.value.toString());

                          if (_genderVal.value ==
                              ConstantList.genderList[2].val) {
                            int showMeIndex = showList.value
                                .indexWhere((element) => element.isSelected);

                            if (showMeIndex != -1) {
                              provider.updateShowMeValue(_showMeNewValue.value);
                              provider.updateShowMeIsVal(
                                  _isShowMeBoolean.value.toString());
                            } else {
                              context
                                  .showSnackBar("Select at least a show me.");
                              return;
                            }
                          } else {
                            int sexOrientationIndex = sexOrientation.value
                                .indexWhere((element) => element.isSelected);
                            if (sexOrientationIndex != -1) {
                              provider.updateSexOrientation(
                                  _sexOrientationValue.value);
                              provider.updateSexOrientationShow(
                                  _sexValueBoolean.value.toString());
                            } else {
                              context.showSnackBar(
                                  "Select at least a sex orientation.");
                              return;
                            }
                          }
                          sl<NavigationService>().pop();
                        },
                        color: red,
                        text: 'Done');
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Builder(
                builder: (context) {
                  return genderInfo();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget genderInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: HeadingStyles.boardingHeading(
              context, UiString.whatYourGenderText),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          width: double.maxFinite,
          alignment: Alignment.center,
          child: ValueListenableBuilder(
              valueListenable: genderList,
              builder: (context, genderValListener, _) {
                return Wrap(
                  runAlignment: WrapAlignment.spaceBetween,
                  // alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(
                      genderValListener.length,
                      (index) => InkWell(
                          onTap: () {
                            int selectedIndex = genderValListener
                                .indexWhere((element) => element.isSelected);
                            if (selectedIndex != -1) {
                              genderValListener[selectedIndex].isSelected =
                                  false;
                            }
                            genderValListener[index].isSelected = true;
                            genderList.value = List.from(genderValListener);

                            _genderVal.value = genderValListener[index].val;

                            if (_genderVal.value ==
                                ConstantList.genderList[2].val) {
                              showList.value.clear();
                              showList.value = List.from(ConstantList.showMeList
                                ..forEach((element) {
                                  element.isSelected = false;
                                }));

                              _showMeNewValue.value = widget.showMe;
                              _isShowMeBoolean.value = widget.isShowMe;
                              int selectedIndex = showList.value.indexWhere(
                                  (element) =>
                                      element.val == _showMeNewValue.value);
                              if (selectedIndex != -1) {
                                showList.value[selectedIndex].isSelected = true;
                              }

                              showMeShow.value = true;
                            } else {
                              _sexOrientationValue.value =
                                  widget.sexOrientation;
                              _sexValueBoolean.value = widget.isSexOrientation;

                              final tempValue =
                                  _sexOrientationValue.value.split(",");
                              sexOrientation.value.clear();
                              sexOrientation.value =
                                  List.from(ConstantList.sexOrientation
                                    ..forEach((element) {
                                      element.isSelected = false;
                                    }));
                              if (tempValue.isNotEmpty) {
                                for (var v in tempValue) {
                                  int selectedIndex = sexOrientation.value
                                      .indexWhere((element) {
                                    return v == element.val;
                                  });
                                  if (selectedIndex != -1) {
                                    sexOrientation
                                        .value[selectedIndex].isSelected = true;
                                  }
                                }
                              }

                              showMeShow.value = false;
                            }
                          },
                          child: CustomRadio(genderValListener[index]))),
                );
              }),
        ),
        SizedBox(
          height: context.height * 0.03,
        ),
        ValueListenableBuilder(
            valueListenable: _isVisible,
            builder: (context, genderValListener, _) {
              return InkWell(
                onTap: () {
                  if (_isVisible.value == 0) {
                    _isVisible.value = 1;
                  } else {
                    _isVisible.value = 0;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        fillColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            // Color when checkbox is checked
                            return red; // Change this to the desired color
                          } else {
                            // Color when checkbox is not checked
                            return white; // Change this to the desired color
                          }
                        }),
                        value: _isVisible.value == 1 ? true : false,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          if (_isVisible.value == 0) {
                            _isVisible.value = 1;
                          } else {
                            _isVisible.value = 0;
                          }
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
        const SizedBox(
          height: 30,
        ),
        ValueListenableBuilder(
            valueListenable: showMeShow,
            builder: (context, value, _) {
              if (value) {
                return showMeInfo();
              } else {
                return sexOrientationInfo();
              }
            })
      ],
    );
  }

  Widget showMeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: HeadingStyles.boardingHeading(context, UiString.showMe),
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          width: double.maxFinite,
          alignment: Alignment.center,
          child: ValueListenableBuilder(
              valueListenable: showList,
              builder: (context, showMeValListener, _) {
                return Wrap(
                  runAlignment: WrapAlignment.spaceBetween,
                  // alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
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
                            showList.value = List.from(showMeValListener);

                            _showMeNewValue.value =
                                showMeValListener[index].val;
                          },
                          child: CustomRadio(showMeValListener[index]))),
                );
              }),
        ),
        SizedBox(
          height: context.height * 0.03,
        ),
        ValueListenableBuilder(
            valueListenable: _isShowMeBoolean,
            builder: (context, genderValListener, _) {
              return InkWell(
                onTap: () {
                  if (_isShowMeBoolean.value == 0) {
                    _isShowMeBoolean.value = 1;
                  } else {
                    _isShowMeBoolean.value = 0;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        fillColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            // Color when checkbox is checked
                            return red; // Change this to the desired color
                          } else {
                            // Color when checkbox is not checked
                            return white; // Change this to the desired color
                          }
                        }),                        value: _isShowMeBoolean.value == 1 ? true : false,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          if (_isShowMeBoolean.value == 0) {
                            _isShowMeBoolean.value = 1;
                          } else {
                            _isShowMeBoolean.value = 0;
                          }
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
                ),
              );
            }),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }

  Widget sexOrientationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          height: 15,
        ),
        HeadingStyles.boardingHeading(context, UiString.mySexOrientationText),
        const SizedBox(
          height: 15,
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
                                  if (value.isSelected && totalCount > 1) {
                                    sexOrientationVal[index].isSelected = false;
                                  } else if (value.isSelected &&
                                      totalCount == 1) {
                                    context.showSnackBar(
                                        "Select at least a orientation.",
                                        snackType: SnackType.error);
                                  } else if (totalCount < 3) {
                                    sexOrientationVal[index].isSelected = true;
                                  }
                                  sexOrientation.value =
                                      List.from(sexOrientationVal);

                                  final temp = [];
                                  for (var element in sexOrientationVal) {
                                    if (element.isSelected) {
                                      temp.add(element.val);
                                    }
                                  }

                                  _sexOrientationValue.value = temp.join(",");
                                }
                              }),
                        )),
              );
            }),
        SizedBox(
          height: context.height * 0.02,
        ),
        ValueListenableBuilder(
            valueListenable: _sexValueBoolean,
            builder: (context, sexOrientationValListener, _) {
              return InkWell(
                onTap: () {
                  if (_sexValueBoolean.value == 0) {
                    _sexValueBoolean.value = 1;
                  } else {
                    _sexValueBoolean.value = 0;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Checkbox(
                        fillColor:
                        MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) {
                            // Color when checkbox is checked
                            return red; // Change this to the desired color
                          } else {
                            // Color when checkbox is not checked
                            return white; // Change this to the desired color
                          }
                        }),
                        value: _sexValueBoolean.value == 1 ? true : false,
                        visualDensity:
                            const VisualDensity(horizontal: -4, vertical: -4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        onChanged: (value) {
                          if (_sexValueBoolean.value == 0) {
                            _sexValueBoolean.value = 1;
                          } else {
                            _sexValueBoolean.value = 0;
                          }
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        UiString.showSexOrientationText,
                        style: context.textTheme.titleMedium
                            ?.copyWith(fontSize: 13),
                      )
                    ],
                  ),
                ),
              );
            }),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
