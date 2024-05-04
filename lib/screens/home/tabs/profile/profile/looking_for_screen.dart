import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/constants_list.dart';
import 'package:meety_dating_app/models/gender_model.dart';
import 'package:meety_dating_app/providers/edit_provider.dart';
import 'package:meety_dating_app/screens/profile/widgets/custom_cards.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:multi_value_listenable_builder/multi_value_listenable_builder.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/ui_strings.dart';

class LookingForScreen extends StatefulWidget {
  final String value;

  const LookingForScreen({Key? key, required this.value,})
      : super(key: key);

  @override
  State<LookingForScreen> createState() => _LookingForScreenState();
}

class _LookingForScreenState extends State<LookingForScreen> {
  final ValueNotifier<List<LookingFor>> lookingForList = ValueNotifier([]);

  final ValueNotifier<String> _newValue = ValueNotifier("");

  @override
  void initState() {
    _newValue.value = widget.value;
    lookingForList.value.clear();
    lookingForList.value = List.from(ConstantList.lookingForList
      ..forEach((element) {
        element.isSelected = false;
      }));
    int selectedIndex = lookingForList.value
        .indexWhere((element) => element.val == _newValue.value);
    if (selectedIndex != -1) {
      lookingForList.value[selectedIndex].isSelected = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EditUserProvider, String?>(
      selector: (context, provider) {
        return provider.loginUser?.lookingFor;
      },
      builder: (context, value, child) {
        return Scaffold(
          appBar: AppBarX(
            title: "",
            trailing: MultiValueListenableBuilder(
                valueListenables: [
                  _newValue,
                ],
                builder: (context, values, _) {
                  if (widget.value != values[0] ) {
                    return TextBtnX(
                        onPressed: () {
                          final provider = Provider.of<EditUserProvider>(
                              context,
                              listen: false);
                          provider.updateLookingFor(_newValue.value);
                          Navigator.pop(context);
                        },
                        text: 'Done');
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Builder(
                builder: (context) {
                  return lookingForInfo();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget lookingForInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          HeadingStyles.boardingHeading(context, UiString.iAmLookingFOr),
          const SizedBox(
            height: 5,
          ),
          HeadingStyles.boardingHeadingCaption(
              context, UiString.lookingForSubCaption,
              isCenter: false),
          const SizedBox(
            height: 30,
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
                              int selectedIndex = lookingForValListener
                                  .indexWhere((element) => element.isSelected);
                              if (selectedIndex != -1) {
                                lookingForValListener[selectedIndex]
                                    .isSelected = false;
                              }

                              lookingForValListener[index].isSelected = true;

                              lookingForList.value =
                                  List.from(lookingForValListener);

                              _newValue.value =
                                  lookingForValListener[index].val;
                            },
                            child: LookingForCard(
                                lookingFor: lookingForValListener[index]))),
                  );
                }),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}
