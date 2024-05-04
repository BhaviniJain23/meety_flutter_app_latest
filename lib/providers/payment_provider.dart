
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/repository/payment_repo.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../constants/enums.dart';
import '../services/shared_pref_manager.dart';
import '../services/singleton_locator.dart';

class PaymentFormProvider with ChangeNotifier {
  TextEditingController cardController = TextEditingController();
  TextEditingController cardholderController = TextEditingController();
  TextEditingController cvcController = TextEditingController();
  TextEditingController monthYearController = TextEditingController();
  TextEditingController zipcodeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final validation = GlobalKey<FormState>();

  ValueNotifier<bool> saveCard = ValueNotifier<bool>(false);

  bool autoRenew = false;

  void onpressed(BuildContext context) {
    showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
      firstDate: DateTime(1990),
    ).then((date) {
      if (date != null) {
        monthYearController.text = "${date.month}/${date.year}";
      }
      notifyListeners();
    });
    notifyListeners();
  }

  PaymentFormProvider() {
    emailController.text =
        sl<SharedPrefsManager>().getUserDataInfo()?.email ?? '';
    notifyListeners();
  }

  static Widget? getCardIcon(CardType? cardType) {
    String img = "";
    Icon? icon;
    switch (cardType) {
      case CardType.Master:
        img = 'MasterCard_Logo.png';
        break;
      case CardType.Visa:
        img = 'visa.png';
        break;
      case CardType.AmericanExpress:
        img = 'american_express.png';
        break;
      case CardType.Discover:
        img = 'Discover-logo.png';
        break;
      case CardType.DinersClub:
        img = 'diners_club_card.png';
        break;
      case CardType.Jcb:
        img = 'jcb_emblem_logo.png';
        break;
      case null:
        // TODO: Handle this case.
        break;
    }
    Widget? widget;
    if (img.isNotEmpty) {
      widget = Image.asset(
        'assets/images/icons/$img',
        width: 40.0,
      );
    } else {
      widget = icon;
    }
    return widget;
  }


  Future<void> paymentInitAPICalls() async {
    try {

      Map<String, dynamic> apiResponse = await PaymentRepository()
          .initPayment();

      if(apiResponse[UiString.successText] && apiResponse[UiString.dataText] != null){

        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              // applePay: true,
              // googlePay: true,
              style: ThemeMode.dark,
              // testEnv: true,
              // merchantCountryCode: 'JP',
              merchantDisplayName: 'Flutter Stripe Store Demo',
              customerId: apiResponse[UiString.dataText]['customer'],
              paymentIntentClientSecret: apiResponse[UiString.dataText]['client_secret'],
            ));

        await Stripe.instance.presentPaymentSheet();
      }else{

      }

    } catch (e) {
      rethrow;
    }
  }
}
