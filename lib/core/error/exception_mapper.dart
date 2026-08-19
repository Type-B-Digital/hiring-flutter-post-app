import 'package:dio/dio.dart';
import 'package:postsapp/core/error/failures.dart';

Failure mapDioExceptionToFailure(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return TimeOutFailure('Connection timeout');

    case DioExceptionType.sendTimeout:
      return TimeOutFailure();

    case DioExceptionType.receiveTimeout:
      return TimeOutFailure();

    case DioExceptionType.connectionError:
      return const NetworkFailure();

    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;

      if (statusCode == 400 || statusCode == 401) {
        return const InvalidCredentialsFailure();
      }

      return ServerFailure(
        'Server error (${statusCode ?? 'unknown'})',
        statusCode: statusCode,
      );

    case DioExceptionType.cancel:
      return const UnknownFailure('Request cancelled');

    default:
      return const UnknownFailure();
  }
}
