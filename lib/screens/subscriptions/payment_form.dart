// ignore_for_file: must_be_immutable, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meety_dating_app/constants/colors.dart';
import 'package:meety_dating_app/constants/enums.dart';
import 'package:meety_dating_app/models/subscription_model.dart';
import 'package:meety_dating_app/screens/auth/widgets/texfields.dart';
import 'package:meety_dating_app/widgets/core/validator.dart';
import 'package:meety_dating_app/widgets/utils/extensions.dart';
import 'package:meety_dating_app/widgets/utils/material_color.dart';
import 'package:provider/provider.dart';

import '../../constants/ui_strings.dart';
import '../../providers/payment_provider.dart';
import '../../widgets/CacheImage.dart';
import '../../widgets/core/appbars.dart';
import '../../widgets/core/buttons.dart';
import '../../widgets/core/textfields.dart';

class PaymentFormScreen extends StatefulWidget {
  final SubscriptionModel subscriptionModel;
  final String? title;

  const PaymentFormScreen(
      {super.key, required this.subscriptionModel, this.title});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen>
    with ValidateMixin {
  CardType? cardType;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => PaymentFormProvider(),
      child: Consumer<PaymentFormProvider>(
        builder: (BuildContext context, paymentFormProvider, _) {
          return Scaffold(
            appBar: AppBarX(
              title: widget.title,
              height: 60,
              elevation: 2.5,
            ),
            body: SingleChildScrollView(
              child: Form(
                key: paymentFormProvider.validation,
                child: Column(
                  children: [
                    SizedBox(
                      height: context.height * 0.015,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: TextFieldX(
                        onChanged: (value) {},
                        label: "Card Number",
                        // keyboardType: TextInputType.phone,
                        controller: paymentFormProvider.cardController,
                        hint: '',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            var text = newValue.text;
                            if (newValue.selection.baseOffset == 0) {
                              return newValue;
                            }
                            var buffer = StringBuffer();
                            for (int i = 0; i < text.length; i++) {
                              buffer.write(text[i]);
                              var nonZeroIndex = i + 1;
                              if (nonZeroIndex % 4 == 0 &&
                                  nonZeroIndex != text.length) {
                                buffer.write('  '); // Add double spaces.
                              }
                            }
                            var string = buffer.toString();
                            return newValue.copyWith(
                                text: string,
                                selection: TextSelection.collapsed(
                                    offset: string.length));
                          })
                        ],
                        trailing: PaymentFormProvider.getCardIcon(cardType),
                        validator: (p0) {
                          if (paymentFormProvider.cardController.text.length <=
                              6) {
                            String input = getCleanedNumber(
                                paymentFormProvider.cardController.text);
                            CardType? type = getCardTypeFrmNumber(input);
                            if (type != cardType) {
                              setState(() {
                                cardType = type;
                              });
                            }
                          }
                          return validateCardNum(p0);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: TextFieldX(
                        onChanged: (value) {},
                        label: "Cardholder Name",
                        controller: paymentFormProvider.cardholderController,
                        hint: '',
                        validator: (p0) {
                          return validateName(p0);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 10, bottom: 10),
                            child: TextFieldX(
                              onChanged: (value) {},
                              label: "MM/YY",
                              trailing: IconButton(
                                  onPressed: () {
                                    paymentFormProvider.onpressed(context);
                                  },
                                  icon: const Icon(Icons.calendar_month)),
                              keyboardType: TextInputType.none,
                              validator: (p0) {
                                return emptyValidator(p0);
                              },
                              controller:
                                  paymentFormProvider.monthYearController,
                              hint: '',
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 10, bottom: 10),
                            child: TextFieldX(
                              onChanged: (value) {},
                              label: "CVV",
                              keyboardType: TextInputType.phone,
                              controller: paymentFormProvider.cvcController,
                              hint: '',
                              trailing: const Icon(Icons.credit_card),
                              validator: (value) {
                                return validateCVV(value!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 190, top: 10, bottom: 10),
                      child: TextFieldX(
                        onChanged: (value) {},
                        label: "Zip Code",
                        controller: paymentFormProvider.zipcodeController,
                        hint: '',
                        validator: (p0) {
                          return postalCodeValidator(p0);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 10, bottom: 10),
                      child: EmailTextField(
                          textController: paymentFormProvider.emailController),
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: paymentFormProvider.saveCard,
                        builder: (context, autoRenewValue, child) {
                          return Row(
                            children: [
                              Checkbox(
                                focusColor: Colors.grey.shade600,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                                value: autoRenewValue,
                                onChanged: (value) {
                                  paymentFormProvider.saveCard.value =
                                      value ?? false;
                                },
                              ),
                              Text(UiString.saveThisCard,
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13))
                            ],
                          );
                        }),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Text(UiString.deleteYourCardDetails,
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: context.height * 0.01,
                    ),
                    if (widget.title == UiString.addCard)
                      ...[
                        const SizedBox.shrink()
                      ]
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, right: 15, top: 10, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                              color: grey.toMaterialColor.withOpacity(0.1),
                              border: Border.all(
                                color: black.toMaterialColor.shade200,
                              ),
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 15),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (widget.subscriptionModel.planImage !=
                                      null) ...[
                                    CacheImage(
                                      imageUrl:
                                          widget.subscriptionModel.planImage[0],
                                      height: 30,
                                      width: context.width * 0.35,
                                      boxFit: BoxFit.contain,
                                    ),
                                  ] else ...[
                                    Text(
                                      widget.subscriptionModel.planTitle
                                              ?.toString() ??
                                          '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  Text.rich(TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: '₹ ',
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal)),
                                        TextSpan(
                                          text:
                                              '${widget.subscriptionModel.selectedPriceInfo?.planPricePerM ?? 0}/m',
                                        ),
                                      ],
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold))),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(
                                  color: black.toMaterialColor.shade200,
                                ),
                              ),
                              buildRow("Tax:", "--"),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Divider(
                                  color: black.toMaterialColor.shade200,
                                ),
                              ),
                              buildRow("Total:",
                                  "${widget.subscriptionModel.selectedPriceInfo?.totalPlanPrice ?? 0}"),
                            ],
                          ),
                        ),
                      ),
                    ],
                    SizedBox(
                      height: context.height * 0.02,
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.only(
                  bottom: context.height * 0.018, left: 15, right: 15, top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FillBtnX(
                    radius: 15,
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    onPressed: () async {
                      if (paymentFormProvider.validation.currentState
                              ?.validate() ??
                          false) {
                        await paymentFormProvider.paymentInitAPICalls();
                      }
                    },
                    text: widget.title == UiString.addCard
                        ? UiString.addCard
                        : UiString.payNow,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildRow(String text, String priceText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15, top: 3, bottom: 1),
          child: Text(
            text,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: black, fontSize: 15),
          ),
        ),
        if (priceText == '--') ...[
          Padding(
              padding: const EdgeInsets.only(right: 15, top: 3, bottom: 1),
              child: Text(
                priceText,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, color: black, fontSize: 15),
              ))
        ] else ...[
          Text.rich(TextSpan(
              children: [
                const TextSpan(
                    text: '₹ ',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                TextSpan(
                  text: priceText,
                ),
              ],
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
        ]
      ],
    );
  }
}
