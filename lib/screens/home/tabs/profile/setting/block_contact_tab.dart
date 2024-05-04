import 'package:flutter/material.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/providers/block_provider.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:provider/provider.dart';

import 'block_contact_import.dart';
import 'block_screen.dart';

class BlockTabScreen extends StatefulWidget {
  const BlockTabScreen({
    super.key,
  });

  static Widget create(
    BuildContext context,
  ) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => BlockProvider()..init(),
      child: const BlockTabScreen(),
    );
  }

  @override
  State<BlockTabScreen> createState() => _BlockTabScreenState();
}

class _BlockTabScreenState extends State<BlockTabScreen>
    with TickerProviderStateMixin {
  late final TabController tabController;
  ValueNotifier<int> currentIndex = ValueNotifier(0);

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(_indexListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BlockProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: ValueListenableBuilder(
                  valueListenable: currentIndex,
                  builder: (context, value, _) {
                    if ((value == 1 && provider.selectedContacts.isNotEmpty) ||
                        (value == 0 &&
                            provider.selectedContactModel.isNotEmpty)) {
                      return SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      if (value == 1) {
                                        provider.selectAllForBlockTap(false);
                                      } else {
                                        provider.selectAllForContactTap(false);
                                      }
                                    },
                                    icon: const Icon(Icons.close)),
                                SizedBox(
                                  width: ResponsiveDesign.width(10, context),
                                ),
                                Text(
                                  "${value == 1 ? provider.selectedContacts.length : provider.selectedContactModel.length} Selected",
                                  style: context.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                )
                              ],
                            ),
                            TextButton(
                                onPressed: () {
                                  if (value == 1) {
                                    provider.selectAllForBlockTap(
                                        !provider.isSelectAll);
                                  } else {
                                    provider.selectAllForContactTap(
                                        !provider.isSelectAll);
                                  }
                                },
                                child: Text(
                                  !provider.isSelectAll
                                      ? "Select All"
                                      : "Deselect All",style: const TextStyle(color: red),
                                )),
                          ],
                        ),
                      );
                    }
                    return AppBarX(
                      // centerTitle: true,
                      title: UiString.blockContact,
                      elevation: 2,
                      height: ResponsiveDesign.screenHeight(context) * 0.07,
                    );
                  })),
          body: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: ResponsiveDesign.height(50, context),
                child: TabBar(
                  controller: tabController,
                  indicatorColor: Colors.black,
                  tabs: const [
                    Tab(
                      child: Text(
                        "Contacts",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "Blocked",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                  onTap: (value) {
                    currentIndex.value = value;
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                    controller: tabController,
                    children: const [ImportBlockContact(), BlockScreen()]),
              ),
            ],
          ),
          floatingActionButton: ValueListenableBuilder(
            valueListenable: currentIndex,
            builder: (context, value, _) {
              if ((value == 1 && provider.selectedContacts.isNotEmpty) ||
                  (value == 0 && provider.selectedContactModel.isNotEmpty)) {
                return FillBtnX(
                  onPressed: () async {
                    if (value == 0) {
                      await provider.blockUserAPICall(context);
                    } else {
                      await provider.unBlockAPICall(context);
                    }
                  },
                  text: value == 0 ? "Block" : "Unblock",
                  width: ResponsiveDesign.screenWidth(context) * 0.5,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  void _indexListener() {
    if (tabController.indexIsChanging) {
      currentIndex.value = tabController.index;
    }
  }
}
