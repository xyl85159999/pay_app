import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/manager/data/pay_out_task.dart';
import 'package:bobi_pay_out/manager/timer_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/model/sql/DBUtil.dart';
import 'package:bobi_pay_out/service/service_bobi.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:flutter_tron_api/blockchain_mgr.dart';
import 'package:flutter_tron_api/eth_mgr.dart';
import 'package:flutter_tron_api/models/eth_config.dart';
import 'package:flutter_tron_api/models/tron_config.dart';
import 'package:flutter_tron_api/tron_mgr.dart';
import 'package:oktoast/oktoast.dart';

final PayOutMgr guiJiMgr = PayOutMgr();

class PayOutMgr extends OnUpdateActor {
  final tbName = 'tb_pay_out';

  ///心跳
  @override
  Future<void> updateTick(int diff) async {
    PayOutTask? task = await getPayOutTaskFromLocal();
    if (task == null) {
      return await getPayOutTaskFromRemote();
    }
    return await payOut(task);
  }

  ///从远端获取新任务
  Future<void> getPayOutTaskFromRemote() async {
    List res = await serviceBobi.getPayOutTask();
    if (res.isEmpty) return;
    for (var e in res) {}
  }

  ///从本地获取未完成的任务
  Future<PayOutTask?> getPayOutTaskFromLocal() async {
    await dbMgr.open();
    final sql =
        "select * from $tbName where status < ${PayOutStatus.payOutStatusCallbackOk.index} ORDER BY status DESC LIMIT 1;";
    List<Map<String, dynamic>> list = await dbMgr.queryList(sql);
    mypdebug('getPayOutTaskFromLocal $list');
    await dbMgr.close();

    if (list.isEmpty) return null;
    return PayOutTask.fromJson(list[0]);
  }

  ///
  Future<bool> updateTask(PayOutTask task) async {
    await dbMgr.open();
    task.updateTime = nowUnixTimeSecond();
    final count = await dbMgr.updateByHelper(
        tbName, Map.from(task.toJson()), 'task_id = ?', [task.taskId]);
    await dbMgr.close();

    return count > 0;
  }

  ///区块链工具类工厂方法
  Future<BlockchainMgr?> factor(String? type) async {
    BlockchainMgr? mgr;
    String ownerAddr = '';
    String priKey = '';
    if (type == 'trx') {
      ownerAddr = await confMgr.getValueByKey('trx_addr') ?? '';
      priKey = await confMgr.getValueByKey('trx_pri_key') ?? '';
      TronConfig conf = TronConfig(ownerAddr, priKey);
      mgr = TronManager(conf);
    }
    if (type == 'eth') {
      ownerAddr = await confMgr.getValueByKey('eth_addr') ?? '';
      priKey = await confMgr.getValueByKey('eth_pri_key') ?? '';
      EthConfig conf = EthConfig(ownerAddr, priKey);
      mgr = EthManager(conf);
    }
    if (ownerAddr.trim() == '' || priKey.trim() == '') {
      mgr = null;
    }
    return mgr;
  }

  Future<void> tranUsdt(BlockchainMgr bcMgr, PayOutTask task) async {
    assert(task.transactionId.trim() == '');
    assert(task.toAddr.trim() != '');
    double? trxBalance = await bcMgr.getBasicCurBalance();
    if (trxBalance == null) {
      showToast('获取矿工费失败，重试。。');
      return;
    }

    final double? energyUsed =
        await bcMgr.estimateenergy(task.toAddr, task.amount);
    if (energyUsed == null) {
      showToast('获取矿工费失败，重试。。');
      return;
    }

    List? result =
        await bcMgr.transferUSDT(task.toAddr, task.amount, energyUsed);
    if (result == null) {
      showToast('发生未知错误');
      return;
    }

    if (result[0] is String) {
      task.fromAddr = bcMgr.addr;
      task.transactionId = result[0];
      task.status = PayOutStatus.payOutStatusProcessing;
    } else {
      task.status = PayOutStatus.payOutStatusFail;
      task.remark = result.last;
    }
  }

  Future<void> checkTran(BlockchainMgr bcMgr, PayOutTask task) async {
    bool? result = await bcMgr.gettransactionbyid(task.transactionId);
    if (result == null) {
      showToast('发生未知错误');
      return;
    }
    if (result) {
    } else {}
  }

  ///出款
  Future<void> payOut(PayOutTask task) async {
    BlockchainMgr? bcMgr = await factor(task.walletType);

    if (bcMgr == null) {
      showToast('获取区块链工具失败');
      return;
    }

    switch (task.status) {
      case PayOutStatus.payOutStatusNone:
        await tranUsdt(bcMgr, task);
        break;
      case PayOutStatus.payOutStatusProcessing:
        await checkTran(bcMgr, task);
        break;
      case PayOutStatus.payOutStatusSucceed:
        // TODO: Handle this case.
        break;
      case PayOutStatus.payOutStatusCallbackOk:
        // TODO: Handle this case.
        break;
      case PayOutStatus.payOutStatusFail:
        // TODO: Handle this case.
        break;
    }
  }

  int _dataTm = 0;

  ///当前查询用的时间戳
  int get dataTm => _dataTm;

  ///获取今日数据
  Future<List<PayOutTask>> getTodayData() async {
    _dataTm = getTime(DateTime.now());
    return [];
  }

  ///获取上一日数据
  Future<List<PayOutTask>> getPreviousDayData() async {
    _dataTm = _dataTm - 86400;
    return [];
  }

  ///获取下一日数据
  Future<List<PayOutTask>> getNextDayData() async {
    _dataTm = _dataTm + 86400;
    return [];
  }
}
