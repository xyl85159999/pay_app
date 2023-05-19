// ignore_for_file: always_specify_types

import 'package:bs58check/bs58check.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tron_api/tron_global.dart';
import 'package:flutter_tron_api/tron_mgr.dart';
import 'package:flutter_tron_api/models/transaction.dart';
import 'package:flutter_tron_api/models/tron_transaction_history.dart';
import 'package:flutter_tron_api/utils/api_service.dart';
import 'package:web3dart/crypto.dart';

class TronApiTransaction {
  /// 建立 交易
  static Future<Map<String, dynamic>> createTransaction<T>(
    String requestUrl,
    String fromAddress,
    String toAddress,
    int amount,
  ) async {
    final Map<String, dynamic> result =
        await ApiService().postJson(requestUrl, data: {
      'to_address': toAddress,
      'owner_address': fromAddress,
      'amount': amount,
    });

    if (!result.containsKey('Error')) {
      return result;
    } else {
      String error = result['Error'];
      throw Exception(error);
    }
  }

  /// 建立 交易
  static Future<Map<String, dynamic>> broadcastTransaction<T>(
    String requestUrl,
    Transaction transaction,
  ) async {
    final Map<String, dynamic> result = await ApiService().postJson(
      requestUrl,
      data: transaction.toJson(),
    );

    if (!result.containsKey('Error')) {
      return result;
    } else {
      String error = result['Error'];
      throw Exception(error);
    }
  }

  /// 查询 历史交易
  static Future<TronTransactionHistory?> getTransactionHistory(String address,
      {String? onlyFrom}) async {
    try {
      final Map<String, dynamic> result = await ApiService().getJson(
        'https://apilist.tronscanapi.com/api/transaction',
        params: {
          'sort': '-timestamp',
          'count': 'true',
          'limit': '20',
          'start': '0',
          'address': address.toString(),
        },
      );
      return TronTransactionHistory.fromJson(result);
    } on DioError catch (e) {
      print('[TronPlugin] falied: ${e.message}');
    }
    return null;
  }

  static Future<double?> get_main_token_balance(String trx_node,String addr) async {
    try {
      Uint8List address = base58.decode(addr).sublist(1, 21);
      final String parameter = '0'*24 + bytesToHex(address);
      final Map<String, dynamic> result = await ApiService().postJson(
          '$trx_node:8090/wallet/triggerconstantcontract',
          data: {
            'owner_address': addr,
            'visible': true,
            'contract_address': 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
            'function_selector': 'balanceOf(address)',
            'parameter':parameter
          });
      if(result == null || result['result'] == null ||result['result']['result'] != true || result['constant_result'] == null || result['constant_result'].length < 1){
        return -1;
      }
      final BigInt balance = hexToInt(result['constant_result'][0]);
      if(balance == null){
        return -1;
      }
      return balance.toDouble() / tronGlobal.AMOUNT_SUN;
    } catch (e) {}

    return -1;
  }

 

 
}
