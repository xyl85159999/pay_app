library flutter_tron_api;

import 'package:flutter_tron_api/models/eth_config.dart';
import 'package:flutter_tron_api/tron/services/service/eth_transaction.dart';

import 'models/tron_exception.dart';

class EthManager {
  EthTransaction _ethTransaction = EthTransaction();
  EthConfig _config;
  EthManager(this._config);
  EthManager setConfig(String ownerAddress, String privateKey) {
    _config.ownerAddress = ownerAddress;
    _config.privateKey = privateKey;
    return this;
  }

  /**
   * Eth 转账 函数
   *
   */
  Future<List<dynamic>?> transferEth(String toAddress, double amount) async {
    if (amount > 0 && amount <= _config.maxEthAmount) {
      return await _ethTransaction.transEth(
        _config.ownerAddress,
        _config.privateKey,
        toAddress,
        amount,
      );
    } else {
      throw ParameterException(
          '转账数额不少于${_config.minEthAmount}，不大于${_config.maxEthAmount}');
    }
  }

   // 预估能量
  Future<double?> estimateenergy(String toAddress, double amount) async {
    return await _ethTransaction.estimateenergy(
        _config.contractAddress, _config.ownerAddress, toAddress, amount);
  }

  /**
   * ERC20 转账 函数
   *
   */
  Future<List<dynamic>?> transferUSDT(
      String toAddress, double amount, double? ethBalance) async {
    if (amount > _config.minAmount && amount <= _config.maxAmount) {
      return await _ethTransaction.transErc20(
          _config.contractAddress,
          _config.ownerAddress,
          _config.privateKey,
          toAddress,
          amount,
          ethBalance);
    } else {
      throw ParameterException(
          '转账数额不少于${_config.minAmount}，不大于${_config.maxAmount}');
    }
  }

  // 获取getEth余额
  Future<double?> getEthBalance({String? ownerAddress}) async {
    return await _ethTransaction
        .getEthBalance(ownerAddress ?? _config.ownerAddress);
  }

  // 获取getErc20Balance余额
  Future<double?> getErc20Balance({String? ownerAddress}) async {
    return await _ethTransaction.getErc20Balance(
        ownerAddress ?? _config.ownerAddress, _config.contractAddress);
  }

  // 通过交易id获取交易数据
  Future<dynamic> gettransactionbyid(String transaction_id) async {
    return await _ethTransaction.gettransactionbyid(transaction_id);
  }
}
