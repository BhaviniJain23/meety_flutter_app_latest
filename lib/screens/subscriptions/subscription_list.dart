// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/size_config.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/constants/utils.dart';
import 'package:meety_dating_app/models/subscription_model.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/providers/subscription_provider.dart';
import 'package:meety_dating_app/widgets/CacheImage.dart';
import 'package:meety_dating_app/widgets/core/appbars.dart';
import 'package:meety_dating_app/widgets/core/buttons.dart';
import 'package:meety_dating_app/widgets/core/heading.dart';
import 'package:meety_dating_app/widgets/empty_widget.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';

class SubscriptionListScreen extends StatefulWidget {
  final SubscriptionModel? isToShowPop;
  const SubscriptionListScreen({super.key, this.isToShowPop});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  final ValueNotifier<SubscriptionModel?> selectedSubscription =
      ValueNotifier(null);
  Map<String, dynamic>? paymentIntent;

  SubscriptionProvider? subscriptionProvider;

  @override
  void initState() {
    subscriptionProvider = context.read<SubscriptionProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await subscriptionProvider!
          .fetchSubscriptions(context.read<LoginUserProvider>())
          .then((value) {
        selectedSubscription.value = subscriptionProvider!.currentSubscription;
        if (widget.isToShowPop != null) {
          selectedSubscription.value = widget.isToShowPop!;
          Utils.showBottomSheet(
            selectedSubscription.value!,
            context,
          );
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loadingState = context.select<SubscriptionProvider, LoadingState>(
      (provider) => provider.loadingState,
    );
    final subscriptions =
        context.select<SubscriptionProvider, List<SubscriptionModel>>(
      (provider) => provider.filterSubscription,
    );
    final currentSubscription =
        context.select<SubscriptionProvider, SubscriptionModel?>(
      (provider) => provider.currentSubscription,
    );
    selectedSubscription.value = currentSubscription;
    return Scaffold(
      appBar: AppBarX(
        title: UiString.subscriptionToPremium,
        height: ResponsiveDesign.height(50, context),
        elevation: 2.5,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              HeadingStyles.boardingHeadingCaption(
                context,
                UiString.subscriptionToPremiumCaption,
                isCenter: false,
              ),
              SizedBox(height: context.height * 0.02),
              Flexible(
                child: Builder(
                  builder: (
                    context,
                  ) {
                    if (loadingState == LoadingState.Loading) {
                      return Loading(height: context.height * 0.6);
                    } else if (loadingState == LoadingState.Failure) {
                      return ErrorWidget(subscriptionProvider?.error ??
                          'Failed to fetch subscriptions');
                    } else {
                      if (subscriptions.isEmpty) {
                        return const EmptyWidget();
                      } else {
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subscriptions.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final subscription = subscriptions[index];
                            return ValueListenableBuilder(
                              valueListenable: selectedSubscription,
                              builder: (context, val, _) {
                                return SubscriptionCard(
                                  subscriptionModel: subscription,
                                  isSelected:
                                      val?.planId == subscription.planId,
                                  onTap: () {
                                    if (val?.planId != subscription.planId) {
                                      selectedSubscription.value = subscription;
                                    }
                                  },
                                );
                              },
                            );
                          },
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder(
        valueListenable: selectedSubscription,
        builder: (context, val, _) {
          final currentSubscriptionPlanId = currentSubscription?.planId;
          final selectedPlanId = val?.planId ?? 0;

          if (selectedPlanId != currentSubscriptionPlanId &&
              subscriptions.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: context.height * 0.018, left: 15, right: 15),
              child: FillBtnX(
                onPressed: () async {
                  if (selectedSubscription.value != null) {
                    Utils.showBottomSheet(
                      selectedSubscription.value!,
                      context,
                    );
                  }
                },
                text: currentSubscriptionPlanId == 0
                    ? UiString.buyPlan
                    : UiString.upgradePlan,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscriptionModel;
  final bool isSelected;
  final GestureTapCallback? onTap;

  const SubscriptionCard(
      {super.key,
      required this.subscriptionModel,
      required this.isSelected,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: isSelected
                    ? red.toMaterialColor.shade500
                    : grey.toMaterialColor.shade500,
                offset: const Offset(0, 2),
                blurRadius: 5)
          ],
          color: white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? red : grey, width: 0.7)),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 10,
          ),
          if (subscriptionModel.planImage != null) ...[
            CacheImage(
              imageUrl: subscriptionModel.planImage[0],
              height: 35,
              width: context.width * 0.7,
              boxFit: BoxFit.contain,
            ),
          ] else ...[
            Text(
              subscriptionModel.planTitle?.toString() ?? '',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? red : black),
            ),
          ],
          const SizedBox(
            height: 5,
          ),
          subscriptionModel.planDescription?.toString().isHtml() ?? false
              ? Flexible(
                  child: Padding(
                    padding: ResponsiveDesign.horizontal(25, context),
                    child: Html(
                      data: subscriptionModel.planDescription?.toString() ?? '',
                      extensions: const [TableHtmlExtension()],
                      shrinkWrap: true,
                    ),
                  ),
                )
              : Text(
                  subscriptionModel.planDescription?.toString() ?? '',
                ),
        ],
      ),
    );
    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 5, 0, 20),
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              card,
              if (subscriptionModel.isRecommended == '1') ...[
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: const BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.circular(16))),
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'Recommended',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )
              ]
            ],
          ),
        ));
  }
}
