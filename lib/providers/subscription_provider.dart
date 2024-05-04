import 'package:flutter/material.dart';
import 'package:meety_dating_app/config/routes_path.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/subscription_repo.dart';
import 'package:meety_dating_app/models/subscription_model.dart';
import 'package:meety_dating_app/models/user_subscription.dart';
import 'package:meety_dating_app/providers/login_user_provider.dart';
import 'package:meety_dating_app/screens/subscriptions/subscription_purchase.dart';
import 'package:meety_dating_app/services/navigation_service.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class SubscriptionProvider with ChangeNotifier {
  final List<SubscriptionModel> _subscriptions = [];
  final List<SubscriptionModel> _subscriptionsOnlyAddOns = [];
  final List<SubscriptionModel> _subscriptionsWithOutMeetyExplorer = [];
  LoginUserProvider? loginUserProvider;

  LoadingState _loadingState = LoadingState.Uninitialized;
  String? _error;

  SubscriptionModel? _currentSubscription;
  bool _isIHaveSubscription = false;
  bool _isIHaveMoreVisitor = false;
  bool _isIHaveMoreMessage = false;

  PriceInfo? _priceInfo;

  List<SubscriptionModel> get subscriptions => _subscriptions;

  List<SubscriptionModel> get subscriptionsOnlyAddOns =>
      _subscriptionsOnlyAddOns;

  List<SubscriptionModel> get subscriptionsWithOutMeetyExplorer =>
      _subscriptionsWithOutMeetyExplorer;

  SubscriptionModel? get currentSubscription => _currentSubscription;

  List<SubscriptionModel> get filterSubscription =>
      _currentSubscription != null && _currentSubscription?.planId != 0
          ? List.from(_subscriptions.where((element) {
              var myPlanId = (int.tryParse(
                      _currentSubscription?.planId.toString() ?? '0') ??
                  0);
              return (element.planId ?? 0) >= myPlanId;
            }))
          : _subscriptions;

  LoadingState get loadingState => _loadingState;

  String? get error => _error;

  PriceInfo? get priceInfo => _priceInfo;

  bool? get isIHaveSubscription => _isIHaveSubscription;

  bool? get isIHaveMoreVisitor => _isIHaveMoreVisitor;

  bool? get isIHaveMoreMessage => _isIHaveMoreMessage;

  SubscriptionProvider();

  Future<void> fetchSubscriptions(LoginUserProvider loginUserProvider) async {
    try {
      if (!(loadingState == LoadingState.Success)) {
        _loadingState = LoadingState.Loading;
        notifyListeners();
      }

      Map<String, dynamic> apiResponse =
          await SubscriptionRepository().getAllSubscriptionPlan();

      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        List<SubscriptionModel> tempList =
            List.from((apiResponse[UiString.dataText] as List).map((e) {
          return SubscriptionModel.fromJson(e);
        }));

        _isIHaveSubscription = loginUserProvider.user?.pastSubscription != null;

        if (_isIHaveSubscription) {
          int index = tempList.indexWhere((element) => element.planId == 4);
          if (index != -1) {
            tempList[index] = tempList[index]
              ..priceInfo
                  ?.removeWhere((element) => element.planDayLimit != null);
          } else {
            if (index != -1) {
              tempList[index] = tempList[index]
                ..priceInfo
                    ?.removeWhere((element) => element.planDayLimit != null);
            }
          }
        }

        subscriptions.clear();
        subscriptions.addAll(List.from(
            tempList.reversed.where((element) => element.isAddons == 0)));
        subscriptionsOnlyAddOns.addAll(List.from(
            tempList.reversed.where((element) => element.isAddons == 1)));
        subscriptionsWithOutMeetyExplorer.addAll(List.from(tempList.where(
            (element) =>
                element.isAddons == 0 && element.planId.toString() != '0')));
        _error = '';

        UserSubscription? mySubscriptionList;
        if (loginUserProvider.user?.subscription != null) {
          loginUserProvider.user?.subscription?.forEach((element) {
            var myPlanId = (int.tryParse(element.planId ?? '0') ?? 0);

            print("Elemeent:${element.toJson()}");
            if (myPlanId >= 1 && myPlanId <= 3) {
              mySubscriptionList = element;
            }
          });

          _isIHaveMoreVisitor = (loginUserProvider.user?.subscription
                  ?.indexWhere(
                      (element) => element.planId?.toString() == '4') !=
              -1);

          _isIHaveMoreMessage = (loginUserProvider.user?.subscription
                  ?.indexWhere(
                      (element) => element.planId?.toString() == '5') !=
              -1);
        }

        print("mySubscriptionList:${mySubscriptionList?.planId}");
        int index = subscriptions.indexWhere((element) {
          return element.isAddons == 0 &&
              element.planId == int.parse(mySubscriptionList?.planId ?? '0');
        });
        if (index != -1) {
          _currentSubscription = subscriptions[index];
          _subscriptions.removeAt(index);
          _subscriptions.insert(0, _currentSubscription!);
        }
        _loadingState = LoadingState.Success;
        notifyListeners();
      } else {
        _loadingState = LoadingState.Failure;
        notifyListeners();
      }
    } catch (e) {
      _loadingState = LoadingState.Failure;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchTakeSubscription(
      int? planPriceId, int? planId, bool value, bool isAddOns) async {
    try {
      notifyListeners();
      Map<String, dynamic> apiResponse = isAddOns
          ? await SubscriptionRepository().takeAddOns(
              data: {"plan_price_id": planPriceId, "is_auto_renew": value})
          : await SubscriptionRepository().takeSubscription(
              data: {"plan_price_id": planPriceId, "is_auto_renew": value});

      final subscriptionVal =
          (isAddOns ? subscriptionsOnlyAddOns : subscriptions)
              .indexWhere((element) => element.planId == planId);
      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
        sl<NavigationService>().navigateTo(RoutePaths.subscriptionPurchase,
            nextScreen: SubscriptionPurchaseScreen(
              paymentLink: apiResponse[UiString.dataText],
              subscriptionModel: subscriptionVal != -1
                  ? ((isAddOns
                      ? subscriptionsOnlyAddOns
                      : subscriptions)[subscriptionVal])
                  : null,
            ));
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> sendInvoiceWithEmail() async {
    try {
      if (!(loadingState == LoadingState.Success)) {
        _loadingState = LoadingState.Loading;
        notifyListeners();
      }
      Map<String, dynamic> apiResponse =
          await SubscriptionRepository().sendInvoicesThroughMail();
      print("apiResponse:$apiResponse");
      if (apiResponse[UiString.successText] &&
          apiResponse[UiString.dataText] != null) {
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  TextEditingController cardController = TextEditingController();
  TextEditingController cardholderController = TextEditingController();
  TextEditingController cvcController = TextEditingController();
  TextEditingController monthYearController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool saveCard = false;

  bool autoRenew = false;
}
