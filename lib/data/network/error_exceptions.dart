import 'package:dio/dio.dart';

class DeadlineExceededException extends DioException {
  DeadlineExceededException({required super.requestOptions});
}

class BadRequestException extends DioException {
  BadRequestException({required super.requestOptions, this.response});
  @override
  final Response<dynamic>? response;
}

class UnauthorizedException extends DioException {
  UnauthorizedException({required super.requestOptions, this.response});
  @override
  final Response<dynamic>? response;
}

class NotFoundException extends DioException {
  NotFoundException({required super.requestOptions});
}

class InternalServerErrorException extends DioException {
  InternalServerErrorException({required super.requestOptions});
}

class NoInternetConnectionException extends DioException {
  NoInternetConnectionException({required super.requestOptions});
}

class ConflictException extends DioException {
  ConflictException({required super.requestOptions, this.response});
  @override
  final Response<dynamic>? response;
}
