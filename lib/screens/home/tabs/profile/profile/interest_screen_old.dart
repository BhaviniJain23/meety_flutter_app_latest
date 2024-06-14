import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/data/repository/interest_repo.dart';
import 'package:meety_dating_app/models/Languages/languages.dart';
import 'package:meety_dating_app/models/Languages/languages.g.dart';
import 'package:meety_dating_app/models/interest.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';

class InterestScreenOld extends StatefulWidget {
  const InterestScreenOld(
      {Key? key, required this.givenList, this.isInterest = true})
      : super(key: key);
  final List<String> givenList;
  final bool isInterest;

  @override
  State<InterestScreenOld> createState() => _InterestScreenOldState();
}

class _InterestScreenOldState extends State<InterestScreenOld> {
  List<String> myList = [];
  // final List<String> list = [];
  List<String> list = [];
  List<String> filteredList = [];
  List<String> filtered = [];
  List<String> nonEmptyValue = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      isLoading = true;
    });
    myList.addAll(widget.givenList);
    if (widget.isInterest) {
      InterestRepository().getInterestNameList().then((value) {
        list.clear();
        // list.addAll(value);
        list = List.from(value);
        filteredList.clear();
        nonEmptyValue = myList.where((element) => element.isNotEmpty).toList();
        filteredList.addAll(List.from(ConstantList.interestList));
        filteredList.insertAll(
            0,
            widget.givenList.where(
                (element) => !ConstantList.interestList.contains(element)));
        filteredList = List.from(filteredList.sortBySelected(myList));
        isLoading = false;
        setState(() {});
      });
    } else {
      list.clear();
      list.addAll(Languages.defaultLanguages.map((e) => e.name).toList());
      filteredList.clear();
      filteredList.addAll(List.from(list));
      nonEmptyValue = myList.where((element) => element.isNotEmpty).toList();
      filteredList = List.from(filteredList.sortBySelected(myList));
      isLoading = false;
      setState(() {});
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(
        title: widget.isInterest ? UiString.interest : UiString.languages,
        trailing: !widget.givenList.equals(nonEmptyValue)
            ? TextBtnX(
                color: red,
                onPressed: () {
                  final provider =
                      Provider.of<EditUserProvider>(context, listen: false);
                  if (widget.isInterest) {
                    provider.updateInterest(nonEmptyValue.join(","));
                  } else {
                    nonEmptyValue.remove("");
                    provider.updateLanguages(nonEmptyValue.join(","));
                  }
                  Navigator.pop(context);
                },
                text: 'Done')
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (widget.isInterest) {
                    if (value.trim().isNotEmpty) {
                      var temp = list.where((element) => element
                          .toLowerCase()
                          .contains(value.trim().toLowerCase()));
                      setState(() {
                        filteredList = List.from(temp);
                      });
                    } else {
                      setState(() {
                        filteredList = List.from(list);
                      });
                    }
                  } else {
                    if (value.trim().isNotEmpty) {
                      var temp = Languages.defaultLanguages.where((language) =>
                          language.name
                              .toLowerCase()
                              .contains(value.trim().toLowerCase()) ||
                          language.s
                              .toLowerCase()
                              .contains(value.trim().toLowerCase()));
                      setState(() {
                        filteredList =
                            List.from(temp.map((language) => language.name));
                      });
                    } else {
                      setState(() {
                        filteredList = List.from(list);
                      });
                    }
                  }
                },
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    prefixIcon: const Icon(
                      CupertinoIcons.search,
                      color: Colors.grey,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                filteredList = List.from(list);
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
              const SizedBox(
                height: 15,
              ),
              if (!isLoading) ...[
                if (filteredList.isNotEmpty) ...[
                  ChipsChoice<String>.multiple(
                    value: myList,
                    wrapped: true,
                    padding: const EdgeInsets.all(5),
                    onChanged: (val) {
                      print("val:$val");
                      if (widget.isInterest) {
                        if (val.length >= Utils.minInterestLength ||
                            val.length <= Utils.minInterestLength) {
                          if (myList.length > Utils.minInterestLength &&
                              myList.length < Utils.maxInterestLength) {
                            myList = List.from(val);
                          } else if (val.length < Utils.maxInterestLength) {
                            myList = List.from(val);
                          } else {
                            context.showSnackBar(
                                "Select a maximum of 9 interests");
                          }
                        } else {
                          context.showSnackBar("Select at least 4 interests");
                        }
                      } else {
                        if (myList.length > Utils.minInterestLength &&
                            myList.length < Utils.maxInterestLength) {
                          myList = List.from(val);
                        } else if (val.length < Utils.maxInterestLength) {
                          myList = List.from(val);
                        } else {
                          context
                              .showSnackBar("Select a maximum of 9 language");
                        }
                      }
                      filteredList =
                          List.from(filteredList.sortBySelected(myList));

                      setState(() {});
                    },
                    choiceItems: C2Choice.listFrom<String, String>(
                      source: filteredList,
                      value: (i, v) => v,
                      label: (i, v) => v,
                    ),
                    choiceBuilder: (C2Choice choice, index) {
                      return choice.label.isNotEmpty
                          ? InkWell(
                              onTap: () {
                                setState(() {
                                  choice.select!(!choice.selected);
                                });
                              },
                              child: Container(
                                width: (context.width * 0.42),
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
                                constraints:
                                    const BoxConstraints(minHeight: 55),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                child: Center(
                                  child: Text(
                                    choice.label,
                                    style: context.textTheme.titleMedium!
                                        .copyWith(
                                            color: choice.selected
                                                ? red
                                                : Colors.black,
                                            fontWeight: FontWeight.w600,
                                            fontSize: ResponsiveDesign.fontSize(
                                                12, context),
                                            letterSpacing: 0.1),
                                    softWrap: true,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ))
                          : const Row();
                    },
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
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
  }
}
