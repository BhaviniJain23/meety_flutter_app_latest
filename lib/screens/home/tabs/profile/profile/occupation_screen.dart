// ignore_for_file: must_be_immutable, prefer_is_empty, list_remove_unrelated_type, iterable_contains_unrelated_type, unnecessary_string_escapes, prefer_typing_uninitialized_variables, unnecessary_null_comparison, invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/data/repository/list_repo.dart';
import 'package:meety_dating_app/models/education_model.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/ui_strings.dart';
import '../../../../../providers/edit_provider.dart';
import '../../../../../widgets/core/buttons.dart';
import '../../../../../widgets/empty_widget.dart';

class Occupation extends StatefulWidget {
  const Occupation(
      {super.key, required this.selectedEducation, this.isOccupation = true});

  final EducationModel selectedEducation;
  final bool isOccupation;

  @override
  State<Occupation> createState() => _OccupationState();
}

class _OccupationState extends State<Occupation> {
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<EducationModel>> mainList = ValueNotifier([]);
  final ValueNotifier<List<EducationModel>> filteredList = ValueNotifier([]);
  final ValueNotifier<EducationModel?> selectedVal = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await loadData();
    });
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;

      List<EducationModel> list = [];
      List<EducationModel> restrictedList = [];

      if (widget.isOccupation) {
        List<EducationModel> allData =
            await ListRepository().getOccupationList();
        allData.forEach((element) {
          if (element.isRestricted == 0) {
            list.add(element);
          } else {
            restrictedList.add(element);
          }
        });
      } else {
        list = await ListRepository().getEducationNameList();
      }

      mainList.value = List.from(list);
      filteredList.value = List.from(list);

      int index = filteredList.value
          .indexWhere((element) => element.name == widget.selectedEducation);
      if (index != -1) {
        selectedVal.value = filteredList.value[index];
      } else if (widget.selectedEducation.educationId != null &&
          widget.selectedEducation.educationId!.trim().isNotEmpty) {
        mainList.value.insert(
            0,
            EducationModel(
                educationId: widget.selectedEducation.educationId,
                name: widget.selectedEducation.name,
                isRestricted: widget.selectedEducation.isRestricted));
        filteredList.value.insert(
            0,
            EducationModel(
                educationId: widget.selectedEducation.educationId,
                name: widget.selectedEducation.name,
                isRestricted: widget.selectedEducation.isRestricted));
        selectedVal.value = filteredList.value[0];
      }
    } on Exception catch (_) {
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchTextChanged(String value) {
    List<EducationModel> temp = mainList.value.where((element) =>
        (element.name ?? '')
            .toLowerCase()
            .contains(value.trim().toLowerCase())) as List<EducationModel>;
    if (temp.isEmpty) {
      filteredList.value.clear();
      filteredList.value.addAll(temp);
      // filteredList.value.add(
      //     EducationModel(educationId: value, name: value, isRestricted: ''));
    } else {
      filteredList.value = List.from(temp);
    }
    filteredList.notifyListeners();
  }

  void onChipValueChanged(String? value) {
    int index = filteredList.value
        .indexWhere((element) => element.educationId == value);
    if (index != -1) {
      selectedVal.value = filteredList.value[index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiValueListenableBuilder(
      valueListenables: [mainList, filteredList, selectedVal, isLoading],
      builder: (context, values, child) {
        return Scaffold(
          appBar: AppBarX(
              title: widget.isOccupation
                  ? UiString.occupations
                  : UiString.education,
              trailing: getAppTrailingWidget()),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: ResponsiveDesign.height(10, context),
                  ),
                  if (!widget.isOccupation) ...[
                    Text(
                      UiString.educationQue,
                      style: context.textTheme.titleMedium,
                    ),
                    Text(
                      UiString.educationNote,
                      style: context.textTheme.bodySmall,
                    ),
                  ] else ...[
                    Text(
                      "What \'s your Occupation ?",
                      style: context.textTheme.titleMedium,
                    )
                  ],
                  SizedBox(
                    height: ResponsiveDesign.height(15, context),
                  ),
                  TextField(
                    cursorColor: red,
                    controller: searchController,
                    onChanged: onSearchTextChanged,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        prefixIcon: const Icon(
                          CupertinoIcons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: buildSuffixIcon(),
                        isCollapsed: true,
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(10)),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  if (!isLoading.value) ...[
                    if (filteredList.value.isNotEmpty) ...[
                      ChipsChoice<String?>.single(
                        padding: const EdgeInsets.all(5),
                        value: selectedVal.value?.educationId,
                        onChanged: onChipValueChanged,
                        wrapped: true,
                        choiceItems: C2Choice.listFrom<String?, EducationModel>(
                          source: filteredList.value,
                          value: (index, item) => item.educationId,
                          label: (index, item) => item.name ?? '',
                        ),
                        choiceBuilder: buildChoiceBuilder,
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
          ),
        );
      },
    );
  }

  Widget? getAppTrailingWidget() {
    if (selectedVal.value != null &&
        selectedVal.value!.name != widget.selectedEducation) {
      return TextBtnX(
          color: red,
          onPressed: () {
            //searchController.text.trim() == selectedVal.value!.name;
            final provider =
                Provider.of<EditUserProvider>(context, listen: false);
            if (widget.isOccupation) {
              provider.updateJobTitle(selectedVal.value?.educationId ?? '0',
                  selectedVal.value?.name ?? searchController.text.trim());
            } else {
              provider.updateEducation(
                selectedVal.value?.educationId ?? '0',
                selectedVal.value?.name ?? searchController.text.trim(),
              );
            }
            Navigator.pop(context);
          },
          text: 'Done');
    }
    return null;
  }

  Widget? buildSuffixIcon() {
    if (searchController.text.isNotEmpty) {
      return IconButton(
        onPressed: () {
          searchController.clear();
          filteredList.value = List.from(mainList.value);
        },
        icon: Container(
          decoration:
              const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
          padding: const EdgeInsets.all(2),
          child: const Icon(
            Icons.close,
            color: white,
            size: 20,
          ),
        ),
      );
    }
    return null;
  }

  Widget buildChoiceBuilder(C2Choice choice, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        choice.select!(!choice.selected);
      },
      child: Container(
        width: (context.width * 0.40),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: choice.selected ? red : grey.toMaterialColor.shade100,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: choice.selected ? red : grey.toMaterialColor.shade100,
              blurRadius: 3.0,
              offset: const Offset(0.0, 0.75),
            ),
          ],
        ),
        constraints: const BoxConstraints(minHeight: 55),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: Center(
          child: Text(
            choice.label,
            style: buildChoiceTextStyle(choice),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  TextStyle buildChoiceTextStyle(C2Choice choice) {
    return context.textTheme.titleMedium!.copyWith(
      color: choice.selected ? red : Colors.black,
      fontWeight: FontWeight.w600,
      fontSize: ResponsiveDesign.fontSize(12, context),
      letterSpacing: 0.1,
    );
  }
}
