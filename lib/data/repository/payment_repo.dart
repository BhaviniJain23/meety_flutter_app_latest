import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class PaymentRepository {
  Future<Map<String, dynamic>> getAllSubscriptionPlan() async {
    try {
      Either<String, Response?> response =
      await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.GET_ALL_SUBSCRIPTION_PLAN_API,
        data: {

        },
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }

  Future<Map<String, dynamic>> initPayment() async {
    try {
      Either<String, Response?> response =
      await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.POST_CREATE_SETUP_INTENT_API,
        data: {
          "priceId":"price_1Np3QySDLKc8inuYHLZwu26K",
          "cards": {
            "card_name": "Zhang Sen",
            "card_number": "4242 4242 4242 4242",
            "card_exp_month": 12,
            "card_exp_year": 34,
            "card_CVC": 123
          }
        },
      );
      return response.fold((l) {
        return UiString.fixFailResponse(errorMsg: l);
      }, (r) {
        return r?.data as Map<String, dynamic>;
      });
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }
}