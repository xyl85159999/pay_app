import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/enviroment.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  final Dio _httpClient = Dio();

  final int timeout = 30 * 1000;

  factory ApiService() => _instance;

  Environment currEnv = Environment.prod;

  ApiService._internal() {
    BaseOptions options = BaseOptions(
        connectTimeout: timeout, receiveTimeout: timeout, sendTimeout: timeout);
    options.headers = {
      'TRON-PRO-API-KEY': '9118b5b9-8ee1-4ecd-8a7e-cf42e562c92b'
    };
    _httpClient.options = options;
    _setLog();
  }

  void _setLog() {
    _httpClient!.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    ));
  }

  //================================= REQUEST ==================================
  Future<dynamic> getJson(String requestUrl,
      {Map<String, dynamic> params = const <String, dynamic>{}}) async {
    try {
      Response<dynamic> response =
          await _httpClient.get(requestUrl, queryParameters: params);

      if (response.statusCode == 200) {
        return response.data;
      } else {
        print('${response.statusCode} : ${response.data.toString()}');
        throw Exception();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> postJson(
    String requestUrl, {
    Map<String, dynamic> data = const <String, dynamic>{},
  }) async {
    try {
      Response<dynamic> response =
          await _httpClient.post(requestUrl, data: json.encode(data));
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
