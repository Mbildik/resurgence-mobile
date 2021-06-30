import 'package:dio/dio.dart';

bool checkHttpResponseCode(Exception error, int code) {
  if (error is DioError && error.type == DioErrorType.response) {
    return error.response?.statusCode == code;
  }
  return false;
}
