import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';
import 'package:meety_dating_app/data/end_points.dart';
import 'package:meety_dating_app/data/network/api_helper.dart';
import 'package:meety_dating_app/services/singleton_locator.dart';

class SubscriptionRepository {
  Future<Map<String, dynamic>> getAllSubscriptionPlan() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_ALL_SUBSCRIPTION_PLAN_API,
        data: {},
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

  Future<Map<String, dynamic>> takeSubscription(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.TAKE_SUBSCRIPTION_API,
        data: data,
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

  Future<Map<String, dynamic>> takeAddOns(
      {required Map<String, dynamic> data}) async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().postCallWithoutHeader(
        api: EndPoints.TAKE_ADDONS_API,
        data: data,
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

  Future<Map<String, dynamic>> sendInvoicesThroughMail() async {
    try {
      try {
        Either<String, Response?> response =
            await sl<ApiHelper>().postCallWithoutHeader(
          api: EndPoints.SEND_INVOICES_THROUGH_MAIL,
          data: {},
        );
        return response.fold((l) {
          return UiString.fixFailResponse(errorMsg: l);
        }, (r) {

          return r?.data as Map<String, dynamic>;
        });
      } catch (e) {
        return UiString.fixFailResponse();
      }
    } catch (e) {
      return UiString.fixFailResponse();
    }
  }
}
