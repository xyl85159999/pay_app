import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../models/general_response.dart';

class ApiService {
  final DioUtil _dioUtil = DioUtil();

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  //================================= SETTER ===================================
  void setCurrEnv(Environment environment) => _dioUtil.env = environment;

  void setMainUrl(String url) => _dioUtil.mainUrl = url;

  //================================= REQUEST ==================================
  Future<T> fetch<T>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? headers,
    Object? body,
    ResponseType? responseType,
    CancelToken? cancelToken,
  }) async {
    final Response<T> response = await getResponse<T>(
      fetchType,
      url: url,
      queryParameters: queryParameters,
      pathParameters: pathParameters,
      body: body,
      headers: headers,
      responseType: responseType,
      cancelToken: cancelToken,
    );
    return response.data!;
  }

  Future<Response<T>> getResponse<T>(
    FetchType fetchType, {
    required String url,
    Map<String, String>? queryParameters,
    Map<String, String>? pathParameters,
    Map<String, dynamic>? headers,
    Object? body,
    ResponseType? responseType,
    CancelToken? cancelToken,
  }) async {
    /// Request Url
    String requestUrl = _dioUtil.mainUrl + url;

    /// Request Header
    Map<String, dynamic> effectiveHeaders = <String, dynamic>{};

    if (headers == null) {
      effectiveHeaders = _dioUtil.options.headers;
    } else {
      effectiveHeaders = <String, dynamic>{
        ..._dioUtil.options.headers,
        ...headers
      };
    }

    /// Replace Request Url if query parameter is not null
    Uri replacedUri = Uri.parse(requestUrl).replace(
      queryParameters: queryParameters,
    );

    pathParameters?.forEach((String key, String value) {
      if (replacedUri.path.contains(key)) {
        replacedUri = Uri.parse(replacedUri.toString().replaceAll(key, value));
      }
    });

    final Options options = Options(
      headers: effectiveHeaders,
      responseType: responseType,
      receiveDataWhenStatusError: true,
    );

    final Response<T> response;
    switch (fetchType) {
      case FetchType.head:
        response = await _dioUtil.dio!.headUri(
          replacedUri,
          data: body,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case FetchType.get:
        response = await _dioUtil.dio!.getUri(
          replacedUri,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case FetchType.post:
        response = await _dioUtil.dio!.postUri(
          replacedUri,
          data: body,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case FetchType.put:
        response = await _dioUtil.dio!.putUri(
          replacedUri,
          data: body,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case FetchType.patch:
        response = await _dioUtil.dio!.patchUri(
          replacedUri,
          data: body,
          options: options,
          cancelToken: cancelToken,
        );
        break;
      case FetchType.delete:
        response = await _dioUtil.dio!.deleteUri(
          replacedUri,
          data: body,
          options: options,
          cancelToken: cancelToken,
        );
        break;
    }

    return response;
  }
}

class DioUtil {
  static final DioUtil _instance = DioUtil._init();

  /// Dio 对象
  Dio? _dio;

  /// Dio 配置
  BaseOptions options = getDefOptions();

  /// Domain 网址
  String mainUrl = '';

  /// 当前运行环境
  Environment env = Environment.dev;

  //================================= GETTER ===================================
  Dio? get dio => _dio;

  factory DioUtil() {
    return _instance;
  }

  DioUtil._init() {
    _dio = Dio();
    _dio!.options = options;
    _dio!.interceptors.add(PrettyDioLogger(
      requestHeader: false,
      requestBody: false,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
  }

  static BaseOptions getDefOptions() {
    BaseOptions options = BaseOptions();
    options.connectTimeout = 30 * 1000;
    options.receiveTimeout = 60 * 1000;
    options.sendTimeout = 60 * 1000;

    Map<String, dynamic> headers = <String, dynamic>{};
    headers['Accept'] = 'application/json';
    headers['Content-Type'] = 'application/json';

    // String? platform;
    // if (Platform.isAndroid) {
    //   platform = "Android";
    // } else if (Platform.isIOS) {
    //   platform = "iOS";
    // }
    // headers['Platform'] = platform;
    options.headers = headers;

    return options;
  }

  //================================= SETTER ===================================
  void setOptions(BaseOptions options) {
    options = options;
    _dio!.options = options;
  }
}

/**
 * Enum 枚举
 */

enum Environment {
  dev('DEV'),
  production('PRODUCTION');

  const Environment(this.value);

  final String value;
}

enum FetchType { head, get, post, put, patch, delete }

/*  getError  */
ErrorType getError(dynamic e) {
  if (e is DioError) {
    DioError error = e;
    if (error.type == DioErrorType.response) {
      /*  Clear user data if error 401  */
      if (error.response?.statusCode == 401) {
        return ErrorType.sessionExpired;
      }
    }
  }

  return getErrorAPI(e);
}

ErrorType getErrorAPI(dynamic e) {
  if (e is DioError) {
    DioError error = e;

    switch (error.type) {
      case DioErrorType.response:
        Map loginResp = error.response!.data;
        GeneralResponse? response = GeneralResponse.fromMap(loginResp);
        if (response != null && response.message != null) {
          if (error.response?.statusCode == 500 &&
              response.message != null &&
              response.message!.contains('Connection timed out')) {
            return ErrorType.serverMaintenance;
          } else {
            return ErrorType.responseError;
          }
        } else {
          return ErrorType.connectionError;
        }
        break;
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
      case DioErrorType.sendTimeout:
        return ErrorType.timeoutError;
      default:
        if (error.message.toLowerCase().contains('socket') ||
            error.message.toLowerCase().contains('network') ||
            error.message.toLowerCase().contains('server')) {
          return ErrorType.connectionError;
        } else {
          return ErrorType.connectionError;
        }
    }
  } else {
    return ErrorType.responseError;
  }
}

enum ErrorType {
  sessionExpired,
  serverMaintenance,
  responseError,
  connectionError,
  timeoutError
}
