library flutter_tron_api;

import 'dart:convert';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_tron_api/apis/tron_api_transaction.dart';
import 'package:flutter_tron_api/models/tron_transaction_history.dart';
import 'package:flutter_tron_api/tron/services/service/tron_swap.dart';
import 'package:flutter_tron_api/tron/services/service/tron_transaction.dart';
import 'package:secp256k1/secp256k1.dart' as secp256k1;
import 'package:sha3/sha3.dart';

import 'Base58Codec.dart';
import 'models/tron_config.dart';
import 'models/tron_exception.dart';

class TronManager {
  TronTransaction _tronTransaction = TronTransaction();
  TronSwap _tronSwap = TronSwap();
  TronConfig _config;
  TronManager(this._config);
  TronManager setConfig(String ownerAddress, String privateKey) {
    _config.ownerAddress = ownerAddress;
    _config.privateKey = privateKey;
    return this;
  }

  /**
   * 创建本地地址
   */
  Map<String, dynamic> generateAddress() {
    final secp256k1.PrivateKey privateKey = secp256k1.PrivateKey.generate();
    final secp256k1.PublicKey publicKey = privateKey.publicKey;

    final SHA3 k = SHA3(256, KECCAK_PADDING, 256);
    k.update(utf8.encode(publicKey.toString()));

    final List<int> hash = k.digest();
    final List<int> last20Hash = hash.sublist(hash.length - 20, hash.length);

    final String resultAddress =
        Base58CheckCodec.bitcoin().encode(Base58CheckPayload(0x41, last20Hash));
    return <String, dynamic>{
      'resultAddress': resultAddress,
      'privateKey': privateKey,
    };
  }

  /**
   * TRX 转账 函数
   * 用tron api
   *
   */
  Future<List<dynamic>?> transferTrx(String toAddress, int amount) async {
    if (amount > 0 && amount <= _config.maxAmount) {
      return await _tronTransaction.transTrx(
        _config.ownerAddress,
        _config.privateKey,
        toAddress,
        Int64(amount),
      );
    } else {
      throw ParameterException(
          '转账数额不少于${_config.minAmount}，不大于${_config.maxAmount}');
    }
  }

  // 预估能量
  Future<double?> estimateenergy(String toAddress, double amount) async {
    return await _tronTransaction.estimateenergy(
        _config.contractAddress, _config.ownerAddress, toAddress, amount);
  }

  /**
   * TRC20 转账 函数
   * 用tron api
   *
   */
  Future<List<dynamic>?> transferUSDT(
      String toAddress, double amount, double? trxBalance) async {
    if (amount > _config.minAmount && amount <= _config.maxAmount) {
      return await _tronTransaction.transTrc20(
          _config.contractAddress,
          _config.ownerAddress,
          toAddress,
          amount,
          _config.privateKey,
          trxBalance);
    } else {
      throw ParameterException(
          '转账数额不少于${_config.minAmount}，不大于${_config.maxAmount}');
    }
  }

  /**
   * TRX 历史 函数
   * 用tron api
   *
   */
  Future<TronTransactionHistory?> getTransactionHistory(String address) async {
    return TronApiTransaction.getTransactionHistory(address);
  }

  // 获取getTrx余额
  Future<double?> getTrxBalance({String? ownerAddress}) async {
    return await _tronSwap.getTrxBalance(ownerAddress ?? _config.ownerAddress);
  }

  // 获取getTrc20Balance余额
  Future<double?> getTrc20Balance({String? ownerAddress}) async {
    return await _tronSwap.getTrc20Balance(
        ownerAddress ?? _config.ownerAddress, _config.contractAddress);
  }

  // 通过交易id获取交易数据
  Future<dynamic> gettransactionbyid(String transaction_id) async {
    return await _tronSwap.gettransactionbyid(transaction_id);
  }
}
