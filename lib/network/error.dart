import 'package:dio/dio.dart';

class ApiError extends DioError {
  String message;
  String url;

  ApiError(DioError e)
      : message = e?.response?.data['message'],
        url = e?.request?.path,
        super(
          request: e?.request,
          response: e?.response,
          type: e?.type,
          error: e?.error,
        );

  @override
  String toString() {
    return 'ApiError{message: $message, url: $url, cause: ${super.toString()}}';
  }
}
