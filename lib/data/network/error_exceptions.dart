import 'package:dio/dio.dart';
import 'package:meety_dating_app/constants/ui_strings.dart';

class DeadlineExceededException extends DioException {
  DeadlineExceededException({required super.requestOptions});
}

class BadRequestException extends DioException {
  BadRequestException({required super.requestOptions, this.response});
  @override
  final Response<dynamic>? response;

  @override
  String toString() {
    // TODO: implement toString
    return UiString.error;
  }
}

class UnauthorizedException extends DioException {
  UnauthorizedException({required super.requestOptions, this.response});
  @override
  final Response<dynamic>? response;

  @override
  String toString() {
    // TODO: implement toString
    return UiString.invalidAccessToken;
  }
}

class NotFoundException extends DioException {
  NotFoundException({required super.requestOptions});

  @override
  String toString() {
    // TODO: implement toString
    return "API not found";
  }
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException({required super.requestOptions});

  @override
  String toString() {
    // TODO: implement toString
    return UiString.error;
  }
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException({required super.requestOptions});

  @override
  String toString() {
    // TODO: implement toString
    return UiString.noInternet;
  }
}

class ConflictException extends DioException {
  ConflictException({required super.requestOptions, this.response});
  @override
  final Response<dynamic>? response;

  @override
  String toString() {
    // TODO: implement toString
    return UiString.error;
  }
}
