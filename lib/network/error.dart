import 'package:dio/dio.dart';

class ApiError extends DioError {
  String message;
  String url;

  ApiError(DioError e)
      : message = e?.response?.data['message'],
        url = e?.requestOptions?.path,
        super(
          requestOptions: e?.requestOptions,
          response: e?.response,
          type: e?.type,
          error: e?.error,
        );

  @override
  String toString() {
    // todo add DioError toString value.
    return 'ApiError{message: $message, url: $url, cause: ${super.toString()}}';
  }
}
