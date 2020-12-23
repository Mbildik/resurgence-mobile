import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:intl/locale.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/authentication/token.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/network/error.dart';
import 'package:sentry/sentry.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class Client {
  final AuthenticationState _state;

  static final Set<String> securityPaths =
      Set.of(['login', 'security/refresh']);

  Dio _dio;

  Client(this._state) {
    var options = BaseOptions(
      baseUrl: S.baseUrl,
      headers: {HttpHeaders.userAgentHeader: S.userAgent},
      contentType: 'application/json',
    );
    _dio = Dio(options);
    loadInterceptors();
  }

  loadInterceptors() {
    _dio.interceptors.add(AcceptLanguageInterceptor(Locale.parse('tr-TR')));
    _dio.interceptors.add(accessTokenFilter());
    _dio.interceptors.add(refreshTokenFilter());
    _dio.interceptors.add(SentryInterceptor());
    _dio.interceptors.add(apiErrorInterceptor());
    _dio.interceptors.add(DioFirebasePerformanceInterceptor());
  }

  Interceptor logInterceptor() {
    return LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
      error: false,
      logPrint: (_log) => log(_log),
    );
  }

  Interceptor apiErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (e) {
        if (e.type == DioErrorType.RESPONSE &&
            e.response?.data != null &&
            e.response?.data != '' &&
            e.response?.data is Map &&
            e.response?.data['message'] != null) {
          throw ApiError(e);
        } else {
          throw e;
        }
      },
    );
  }

  Interceptor accessTokenFilter() {
    return InterceptorsWrapper(
      onRequest: (RequestOptions options) {
        if (_state.isLoggedIn && !securityPaths.contains(options.path)) {
          options.headers[HttpHeaders.authorizationHeader] =
              'Bearer ${_state.token.accessToken}';
        }
      },
    );
  }

  Interceptor refreshTokenFilter() {
    return InterceptorsWrapper(onError: (e) {
      if (e.type == DioErrorType.RESPONSE &&
          !securityPaths.contains(e.request.path) &&
          e.response.statusCode == 401) {
        var failedRequest = e.request;
        return this.refreshToken().then(
              (_) => _dio.request(
                failedRequest.path,
                options: failedRequest,
              ),
            );
      }

      return e;
    });
  }

  Future<void> refreshToken() {
    var refreshTokenOptions = Options(
      headers: {'Refresh-Token': _state.token.refreshToken},
    );
    return _dio
        .post('security/refresh', options: refreshTokenOptions)
        .then((response) => Token.fromJson(response.data))
        .catchError((e) {
      _state.logout();
      throw RefreshTokenExpiredError(e);
    }).then((token) => _state.login(token));
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
  }) {
    return _dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}

class RefreshTokenExpiredError extends DioError {
  RefreshTokenExpiredError(DioError e)
      : super(
          request: e.request,
          response: e.response,
          type: e.type,
          error: e.error,
        );

  @override
  String toString() {
    var msg = 'RefreshTokenExpiredError [$type]: $message';
    if (error is Error) {
      msg += '\n${error.stackTrace}';
    }
    return msg;
  }
}

class AcceptLanguageInterceptor extends Interceptor {
  final Locale _locale;

  AcceptLanguageInterceptor(this._locale);

  @override
  Future onRequest(RequestOptions options) async {
    options.headers[HttpHeaders.acceptLanguageHeader] = _locale.toString();
    return options;
  }
}

class SentryInterceptor extends Interceptor {
  @override
  Future onError(DioError e) {
    try {
      dynamic request;
      if (e.request?.data is FormData) {
        request = 'FormData';
      } else {
        request = e.request.data;
      }
      Sentry.captureEvent(
        SentryEvent(
          logger: 'http_logger',
          release: S.version,
          throwable: e,
          level: SentryLevel.fatal,
          extra: {
            'request': request,
            'response': e.response?.data,
          },
          tags: {
            'path': e.request?.path,
            'method': e.request?.method,
            'statusCode': '${e.response?.statusCode ?? 0}',
          },
        ),
      );
    } catch (e, stacktrace) {
      try {
        Sentry.captureException(e, stackTrace: stacktrace);
      } catch (ignored) {}
    }

    return super.onError(e);
  }
}

/// [Dio] client interceptor that hooks into request/response process
/// and calls Firebase Metric API in between. The request key is calculated
/// based upon [extra] field hash code which appears to be the same across
/// [onRequest], [onResponse] and [onError] calls.
///
/// Additionally there is no good API of obtaining content length from interceptor
/// API so we're "approximating" the byte length based on headers & request data.
/// If you're not fine with this, you can provide your own implementation in the constructor
///
/// This interceptor might be counting parsing time into elapsed API call duration.
/// I am not fully aware of [Dio] internal architecture.
class DioFirebasePerformanceInterceptor extends Interceptor {
  DioFirebasePerformanceInterceptor(
      {this.requestContentLengthMethod = defaultRequestContentLength,
      this.responseContentLengthMethod = defaultResponseContentLength});

  /// key: requestKey hash code, value: ongoing metric
  final _map = <int, HttpMetric>{};
  final RequestContentLengthMethod requestContentLengthMethod;
  final ResponseContentLengthMethod responseContentLengthMethod;

  @override
  Future onRequest(RequestOptions options) async {
    try {
      final metric = FirebasePerformance.instance.newHttpMetric(
          options.uri.normalized(), options.method.asHttpMethod());

      final requestKey = options.extra.hashCode;
      _map[requestKey] = metric;
      final requestContentLength = requestContentLengthMethod(options);
      await metric.start();
      if (requestContentLength != null) {
        metric.requestPayloadSize = requestContentLength;
      }
    } catch (error) {
      log('Http onRequest metric error', error: error);
    }
    return super.onRequest(options);
  }

  @override
  Future onResponse(Response response) async {
    try {
      final requestKey = response.request.extra.hashCode;
      final metric = _map[requestKey];
      metric.setResponse(response, responseContentLengthMethod);
      await metric.stop();
      _map.remove(requestKey);
    } catch (error) {
      log('Http onResponse metric error', error: error);
    }
    return super.onResponse(response);
  }

  @override
  Future onError(DioError err) async {
    try {
      final requestKey = err.request.extra.hashCode;
      final metric = _map[requestKey];
      metric.setResponse(err.response, responseContentLengthMethod);
      await metric.stop();
      _map.remove(requestKey);
    } catch (error) {
      log('Http onError metric error', error: error);
    }
    return super.onError(err);
  }
}

typedef RequestContentLengthMethod = int Function(RequestOptions options);

int defaultRequestContentLength(RequestOptions options) {
  try {
    if (options.data is String || options.data is Map) {
      return options.headers.toString().length +
          (options.data?.toString()?.length ?? 0);
    }
  } catch (_) {
    return null;
  }
  return null;
}

typedef ResponseContentLengthMethod = int Function(Response options);

int defaultResponseContentLength(Response response) {
  if (response.data is String) {
    return (response?.headers?.toString()?.length ?? 0) + response.data.length;
  } else {
    return null;
  }
}

extension _ResponseHttpMetric on HttpMetric {
  void setResponse(
      Response value, ResponseContentLengthMethod responseContentLengthMethod) {
    if (value == null) {
      return;
    }
    final responseContentLength = responseContentLengthMethod(value);
    if (responseContentLength != null) {
      responsePayloadSize = responseContentLength;
    }
    final contentType = value?.headers?.value?.call(Headers.contentTypeHeader);
    if (contentType != null) {
      responseContentType = contentType;
    }
    if (value.statusCode != null) {
      httpResponseCode = value.statusCode;
    }
  }
}

extension _UriHttpMethod on Uri {
  String normalized() {
    return "$scheme://$host$path";
  }
}

extension _StringHttpMethod on String {
  HttpMethod asHttpMethod() {
    if (this == null) {
      return null;
    }

    switch (toUpperCase()) {
      case "POST":
        return HttpMethod.Post;
      case "GET":
        return HttpMethod.Get;
      case "DELETE":
        return HttpMethod.Delete;
      case "PUT":
        return HttpMethod.Put;
      case "PATCH":
        return HttpMethod.Patch;
      case "OPTIONS":
        return HttpMethod.Options;
      default:
        return null;
    }
  }
}
