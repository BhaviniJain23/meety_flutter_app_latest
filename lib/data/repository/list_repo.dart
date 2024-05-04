import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:meety_dating_app/models/education_model.dart';

import '../../constants/constants_list.dart';
import '../../services/singleton_locator.dart';
import '../end_points.dart';
import '../network/api_helper.dart';

class ListRepository {
  Future<List<EducationModel>> getEducationNameList() async {
    try {
      Either<String, Response?> response =
          await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_EDUCATION_API,
        data: {},
      );
      return response.fold((l) {
        return ConstantList.educationList;
      }, (r) {
        List<EducationModel> list = List.from((r?.data['data'] as List<dynamic>)
            .map((e) => EducationModel.fromJson(e as Map<String, dynamic>)));
        if (list.isNotEmpty) {
          return list;
        }
        return ConstantList.educationList;
      });
    } on Exception catch (e) {
      return ConstantList.educationList;

    }
  }
  Future<List<EducationModel>> getOccupationList() async {
    try {
      Either<String, Response?> response =
      await sl<ApiHelper>().getCallWithoutHeader(
        api: EndPoints.GET_OCCUPATION_API,
        data: {},
      );
      return response.fold((l) {
        return ConstantList.occupation;
      }, (r) {
        List<EducationModel> list = List.from((r?.data['data'] as List<dynamic>)
            .map((e) => EducationModel.fromJson(e as Map<String, dynamic>)));
        if (list.isNotEmpty) {
          return list;
        }
        return ConstantList.occupation;
      });
    } on Exception catch (e) {
      return ConstantList.occupation;
    }
  }
}
