// ignore_for_file: iterable_contains_unrelated_type, unrelated_type_equality_checks, list_remove_unrelated_type

import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/contact_model.dart';
import 'package:meety_dating_app/providers/block_provider.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:provider/provider.dart';

class ImportBlockContact extends StatefulWidget {
  const ImportBlockContact({super.key});

  @override
  State<ImportBlockContact> createState() => _ImportBlockContactState();
}

class _ImportBlockContactState extends State<ImportBlockContact> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BlockProvider>(
      builder: (context, value, child) {
        final uniqueContactsList = value.contactsList..toSet().toList();

        if (value.importContactLoading == LoadingState.Success) {
          return ListView.separated(
            itemCount: uniqueContactsList.length,
            itemBuilder: (context, index) {
              ContactModel c = uniqueContactsList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 25, left: 25),
                child: ListTile(
                  title: Text(c.displayName ?? ""),
                  subtitle: Text(c.phone.toString()),
                  selectedColor: red,
                  onTap: () {
                    context.read<BlockProvider>().selectContactModel(c);
                  },
                  selected: value.selectedContactModel
                      .any((element) => element.phone == c.phone),
                  trailing: SizedBox(
                    width: ResponsiveDesign.width(120, context),
                    height: ResponsiveDesign.height(35, context),
                    child: FillBtnX(
                      elevation: 5,
                      color: red,
                      radius: 8,
                      onPressed: () async {
                        //single block : pass contact model
                        // for multiple don\'t pass contact model
                        await context
                            .read<BlockProvider>()
                            .blockUserAPICall(context, c: c);
                      },
                      text: "Block",
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Divider(
                  height: 0,
                  color: grey,
                ),
              );
            },
          );
        } else if (value.importContactLoading == LoadingState.Failure ||
            (value.errorMessageForImport?.isNotEmpty ?? false)) {
          return Padding(
              padding: const EdgeInsets.only(top: 150),
              child: EmptyWidget(
                titleText: value.errorMessageForImport ?? '',
              ));
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 150),
          child: Center(
            child: Loading(
              height: ResponsiveDesign.height(250, context),
            ),
          ),
        );
      },
    );
  }
}
//kw
