import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/models/block_user_model.dart';
import 'package:meety_dating_app/providers/block_provider.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/ui_strings.dart';

class BlockScreen extends StatefulWidget {
  const BlockScreen({super.key});

  @override
  State<BlockScreen> createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<BlockProvider>(
      builder: (context, blockProvider, child) {
        if (blockProvider.blockNumberLoading == LoadingState.Success) {
          if (blockProvider.blockNumber.isNotEmpty) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: blockProvider.blockNumber.length,
              itemBuilder: (context, index) {
                BlockUser blockUser = blockProvider.blockNumber[index];
                return ListTile(
                    selectedColor: red,
                    onTap: () {
                      blockProvider.selectBlockContact(blockUser);
                    },
                    title: Text(
                      blockUser.pName.toString(),
                    ),
                    subtitle: Text(
                      blockUser.pNumber.toString(),
                    ),
                    selected:
                        blockProvider.selectedContacts.contains(blockUser));
              },
            );
          } else {
            return const Column(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 200),
                    child: Text(
                      UiString.noBlockedContacts,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ),
                Text(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  UiString.blockPeoplebyUsingtheContacts,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                ),
              ],
            );
          }
        } else if (blockProvider.blockNumberLoading == LoadingState.Failure ||
            (blockProvider.errorMessageForBlockNumber?.isNotEmpty ?? false)) {
          return Padding(
              padding: const EdgeInsets.only(top: 150),
              child: EmptyWidget(
                titleText: blockProvider.errorMessageForBlockNumber ?? '',
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
