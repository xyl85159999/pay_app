library flutter_tron_api;

import 'package:flutter_tron_api/blockchain_mgr.dart';
import 'package:flutter_tron_api/models/eth_config.dart';
import 'package:flutter_tron_api/models/tron_transaction_history.dart';
import 'package:flutter_tron_api/tron/services/service/eth_transaction.dart';

import 'models/tron_exception.dart';

class EthManager extends BlockchainMgr<EthConfig> {
  EthTransaction _ethTransaction = EthTransaction();

  EthManager(super.config);
  EthManager setConfig(String ownerAddress, String privateKey) {
    this.addr = ownerAddress;
    config.ownerAddress = ownerAddress;
    config.privateKey = privateKey;
    return this;
  }

  /**
   * Eth 转账 函数
   *
   */
  Future<List<dynamic>?> transferBasicCur(
      String toAddress, double amount) async {
    if (amount > 0 && amount <= config.maxEthAmount) {
      return await _ethTransaction.transEth(
        config.ownerAddress,
        config.privateKey,
        toAddress,
        amount,
      );
    } else {
      throw ParameterException(
          '转账数额不少于${config.minEthAmount}，不大于${config.maxEthAmount}');
    }
  }

  // 预估能量
  Future<double?> estimateenergy(String toAddress, double amount) async {
    return await _ethTransaction.estimateenergy(
        config.contractAddress, config.ownerAddress, toAddress, amount);
  }

  /**
   * ERC20 转账 函数
   *
   */
  Future<List<dynamic>?> transferUSDT(
      String toAddress, double amount, double? ethBalance) async {
    if (amount > config.minAmount && amount <= config.maxAmount) {
      return await _ethTransaction.transErc20(
          config.contractAddress,
          config.ownerAddress,
          config.privateKey,
          toAddress,
          amount,
          ethBalance);
    } else {
      throw ParameterException(
          '转账数额不少于${config.minAmount}，不大于${config.maxAmount}');
    }
  }

  // 获取getEth余额
  Future<double?> getBasicCurBalance({String? ownerAddress}) async {
    return await _ethTransaction
        .getEthBalance(ownerAddress ?? config.ownerAddress);
  }

  // 获取getErc20Balance余额
  Future<double?> getUsdtBalance({String? ownerAddress}) async {
    return await _ethTransaction.getErc20Balance(
        ownerAddress ?? config.ownerAddress, config.contractAddress);
  }

  // 通过交易id获取交易数据
  Future<dynamic> gettransactionbyid(String transaction_id) async {
    return await _ethTransaction.gettransactionbyid(transaction_id);
  }

  @override
  Map<String, dynamic> generateAddress() {
    // TODO: implement generateAddress
    throw UnimplementedError();
  }

  @override
  Future<TronTransactionHistory?> getTransactionHistory(String address) {
    // TODO: implement getTransactionHistory
    throw UnimplementedError();
  }
}
