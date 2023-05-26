import 'package:flutter_tron_api/models/tron_transaction_history.dart';
import 'package:meta/meta.dart';

abstract class BlockchainMgr<T> {
  T config;
  late String addr;
  BlockchainMgr(this.config);
  BlockchainMgr<T> setConfig(String ownerAddress, String privateKey);

  /**
   * 创建本地地址
   */
  Map<String, dynamic> generateAddress();

  /**
   * 主货币 转账 函数
   * 用tron api
   *
   */
  Future<List<dynamic>?> transferBasicCur(String toAddress, double amount);

  // 预估能量
  Future<double?> estimateenergy(String toAddress, double amount);

  /**
   * 转账 函数
   * 用tron api
   *
   */
  Future<List<dynamic>?> transferUSDT(
      String toAddress, double amount, double? trxBalance);

  /**
   * 基本货币 历史 函数
   * 用tron api
   *
   */
  Future<TronTransactionHistory?> getTransactionHistory(String address);

  // 获取基本货币余额
  Future<double?> getBasicCurBalance({String? ownerAddress});

  // 获取USDT余额
  Future<double?> getUsdtBalance({String? ownerAddress});

  // 通过交易id获取交易数据
  Future<dynamic> gettransactionbyid(String transaction_id);
}
