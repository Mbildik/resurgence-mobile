import 'package:dio/dio.dart';

class ApiError extends DioError {
  String message;

  ApiError(DioError e)
      : message = e.response.data['message'],
        super(
          request: e.request,
          response: e.response,
          type: e.type,
          error: e.error,
        );

  @override
  String toString() {
    return 'ApiError{message: $message}';
  }
}
