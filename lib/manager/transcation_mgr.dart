import 'package:flutter_tron_api/eth_global.dart';
import 'package:flutter_tron_api/eth_mgr.dart';
import 'package:flutter_tron_api/models/eth_config.dart';
import 'package:flutter_tron_api/models/tron_config.dart';
import 'package:flutter_tron_api/tron_global.dart';
import 'package:flutter_tron_api/tron_mgr.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/manager/data/msg_result.dart';
import 'package:bobi_pay_out/manager/data/transcation_log_data.dart';
import 'package:bobi_pay_out/manager/timer_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/model/sql/DBUtil.dart';
import 'package:bobi_pay_out/utils/utility.dart';

class _TransMsg {
  bool result;
  bool showMsg;
  TranscationLogData task;
  _TransMsg(this.result, this.task, {this.showMsg = false});
}

final TransactionMgr transactionMgr = TransactionMgr();

class TransactionMgr extends OnUpdateActor {
  final tbName = "tb_transaction_log";

  int _cleanSeconds = 0;
  int _timeoutSeconds = 0;
  final TronManager tronMgr = TronManager(TronConfig(
    '',
    '',
  ));
  final EthManager ethMgr = EthManager(EthConfig(
    '',
    '',
  ));
  TransactionMgr() {
    timer_mgr.add(this, ms: 1000);
  }

  dispose() {
    timer_mgr.del(this);
  }

  delayUpdate({int? ms}) {
    _timeoutSeconds =
        DateTime.now().add(Duration(seconds: ms ?? 3)).millisecondsSinceEpoch;
    _isRunning = false;
  }

  @override
  Future<void> updateTick(int diff) async {
    if (_timeoutSeconds - DateTime.now().millisecondsSinceEpoch < 0) {
      await update();
    }
    if (_cleanSeconds - DateTime.now().millisecondsSinceEpoch < 0) {
      await cleanDB();
    }
  }

  Future<_TransMsg> transactionUsdtTron(TranscationLogData task) async {
    mypdebug("33-transactionUsdtTron");
    if (task == null || task.fromAddr == null || task.toAddr == null) {
      mypdebug("33-transactionUsdtTron-1");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_FAIL
            ..remark = '无效的task',
          showMsg: true);
    }
    mypdebug("33-transactionUsdtTron-2");
    if (task.status == COLLECTION_STATUS_NONE) {
      mypdebug("33-transactionUsdtTron-3");
      if (task.transactionId != null && task.transactionId!.isNotEmpty) {
        mypdebug(
            "33-transactionUsdtTron-3-1 ${nowUnixTimeSecond() - task.updateTime!}");
        if (nowUnixTimeSecond() - task.updateTime! > 60) {
          mypdebug("33-transactionUsdtTron-3-1-1");
          final result = await tronMgr.gettransactionbyid(task.transactionId!);
          if (result) {
            mypdebug("33-transactionUsdtTron-3-1-1-1");
            return _TransMsg(
                true,
                task
                  ..status = COLLECTION_STATUS_COST
                  ..transactionId = ''
                  ..remark = '');
          } else {
            mypdebug("33-transactionUsdtTron-3-1-1-2");
            return _TransMsg(
                true,
                task
                  ..transactionId = ''
                  ..remark = '');
          }
        } else {
          mypdebug("33-transactionUsdtTron-3-1-2");
          return _TransMsg(false,
              task..remark = 'transaction_trx waitting transactionId result',
              showMsg: true);
        }
      }
      mypdebug("33-transactionUsdtTron-4");
      tronMgr.setConfig(task.fromAddr!, '');
      double? usdtBalance = await tronMgr.getUsdtBalance();
      if (usdtBalance == -1) {
        mypdebug("33-transactionUsdtTron-5");
        return _TransMsg(true, task..remark = '转账usdt失败,获取余额失败', showMsg: true);
      }
      mypdebug("33-transactionUsdtTron-6 usdtBalance: $usdtBalance");
      double usdtVal = task.usdtVal!;
      if (usdtBalance! < usdtVal) {
        mypdebug("33-transactionUsdtTron-7");
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_FAIL
              ..remark = 'usdt_balance: $usdtBalance, transfer_val: $usdtVal',
            showMsg: true);
      }
      mypdebug("33-transactionUsdtTron-8");
      tronMgr.setConfig(task.fromAddr!, '');
      final double? energyUsed =
          await tronMgr.estimateenergy(task.toAddr!, task.usdtVal!);
      if (energyUsed == null) {
        return _TransMsg(false, task..remark = 'estimateenergy fail',
            showMsg: true);
      }

      if (energyUsed > tronGlobal.trx_fee_limit * 1.5) {
        return _TransMsg(
            false,
            task
              ..remark = '费用太高了继续等待'
              ..status = COLLECTION_STATUS_HEIGHT_ENERGY,
            showMsg: true);
      }

      double? trxBalance = await tronMgr.getBasicCurBalance();
      if (trxBalance == null) {
        mypdebug("33-transactionUsdtTron-9");
        return _TransMsg(false, task..remark = 'get trx trxBalance null',
            showMsg: true);
      }
      mypdebug("33-transactionUsdtTron-10 trxBalance:$trxBalance");
      final double max_energy_used = energyUsed;
      final diff = max_energy_used - trxBalance;
      if (diff > 0) {
        mypdebug("33-transactionUsdtTron-11 diff: $diff");
        if (tronGlobal.trx_cost_addr.isEmpty ||
            tronGlobal.trx_cost_pri_key.isEmpty) {
          mypdebug("33-transactionUsdtTron-12");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'trx_cost_addr is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-13");
        tronMgr.setConfig(
            tronGlobal.trx_cost_addr, tronGlobal.trx_cost_pri_key);
        List<dynamic>? resultList =
            await tronMgr.transferBasicCur(task.fromAddr!, diff);
        mypdebug("33-transactionUsdtTron-14");
        if (resultList == null || resultList.length < 4) {
          mypdebug("33-transactionUsdtTron-15");
          return _TransMsg(
              true, task..remark = 'transfer_trx error result is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-16");
        String txid = resultList.removeAt(0);
        if (txid == null || txid.isEmpty) {
          mypdebug("33-transactionUsdtTron-17");
          return _TransMsg(true, task..remark = 'transfer_trx txid is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-18");
        final count = await update_transcation_task(task..transactionId = txid);
        if (!count) {
          mypdebug("33-transactionUsdtTron-19");
          return _TransMsg(
              true, task..remark = 'transfer_trx update_collect_task txid fail',
              showMsg: true);
        }

        mypdebug("33-transactionUsdtTron-20");
        final fn = resultList.removeAt(0);
        final sub = resultList.first;
        final agrs = resultList.last;
        showToastTip('正在转账');
        final resultList2 = await fn.call(sub, agrs);
        if (resultList2 == null) {
          mypdebug("33-transactionUsdtTron-21");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_trx error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2 == null || resultList2.first == null) {
          mypdebug("33-transactionUsdtTron-21-1");
          return _TransMsg(true,
              task..remark = 'transfer_trx error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2.first != true) {
          mypdebug("33-transactionUsdtTron-21-2");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_trx error result:${resultList2.last}');
        }
      }
      mypdebug("33-transactionUsdtTron-22");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..energyUsedMax = max_energy_used
            ..status = COLLECTION_STATUS_COST
            ..remark = '');
    } else if (task.status == COLLECTION_STATUS_COST) {
      mypdebug("33-transactionUsdtTron-23");
      if (task.transactionId != null && task.transactionId!.isNotEmpty) {
        mypdebug(
            "33-transactionUsdtTron-24 ${task.transactionId} ${nowUnixTimeSecond() - task.updateTime!}");
        if (nowUnixTimeSecond() - task.updateTime! > 60) {
          mypdebug("33-transactionUsdtTron-24-1");
          final result = await tronMgr.gettransactionbyid(task.transactionId!);
          if (result) {
            mypdebug("33-transactionUsdtTron-24-1-1");
            return _TransMsg(
                true,
                task
                  ..status = COLLECTION_STATUS_ING
                  ..remark = '');
          } else {
            mypdebug("33-transactionUsdtTron-24-1-2");
            return _TransMsg(
                true,
                task
                  ..status = COLLECTION_STATUS_NONE
                  ..transactionId = ''
                  ..remark = '');
          }
        } else {
          mypdebug("33-transactionUsdtTron-24-2");
          return _TransMsg(
              false,
              task
                ..remark = 'transactionUsdtTron waitting transactionId result',
              showMsg: true);
        }
      }
      mypdebug("33-transactionUsdtTron-25");
      tronMgr.setConfig(task.fromAddr!, '');
      double? trxBalance = await tronMgr.getBasicCurBalance();
      if (trxBalance == null) {
        mypdebug("33-transactionUsdtTron-26");
        return _TransMsg(false, task..remark = 'get trx trxBalance null',
            showMsg: true);
      }
      mypdebug("33-transactionUsdtTron-27 trxBalance:$trxBalance");
      if (trxBalance >= task.energyUsedMax!) {
        mypdebug("33-transactionUsdtTron-28");
        double? usdtBalance = await tronMgr.getUsdtBalance();
        if (usdtBalance == -1) {
          mypdebug("33-transactionUsdtTron-29");
          return _TransMsg(true, task..remark = '转账usdt失败,获取余额失败',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-30 usdtBalance:$usdtBalance");
        double usdtVal = task.usdtVal!;
        if (usdtVal < 1) {
          mypdebug("33-transactionUsdtTron-31");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'usdt_balance: $usdtBalance, min_collection_val: 1',
              showMsg: true);
        }
        if (usdtBalance! < usdtVal) {
          mypdebug("33-transactionUsdtTron-31");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'usdt_balance: $usdtBalance, transfer_val: $usdtVal',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-32");
        final priList = await addrMgr.getPriByAdress(task.fromAddr!);
        if (priList.first == null) {
          mypdebug("33-transactionUsdtTron-33");
          return _TransMsg(
              true, task..remark = priList.last ?? '转账usdt失败,获取地址信息失败',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-34");
        tronMgr.setConfig(task.fromAddr!, priList.first!);
        List<dynamic>? resultList =
            await tronMgr.transferUSDT(task.toAddr!, usdtVal, trxBalance);
        if (resultList == null) {
          mypdebug("33-transactionUsdtTron-35-1");
          return _TransMsg(
              true, task..remark = 'transactionUsdtTron error result is null',
              showMsg: true);
        }

        if (resultList.length < 4) {
          mypdebug("33-transactionUsdtTron-35-2");
          if (resultList.length == 2) {
            final result = resultList.first;
            if (result == true) {
              mypdebug("33-transactionUsdtTron-35-2-1");
              return _TransMsg(
                  true,
                  task
                    ..status = COLLECTION_STATUS_HEIGHT_ENERGY
                    ..remark =
                        'transactionUsdtTron error result ${resultList.last}');
            } else {
              mypdebug("33-transactionUsdtTron-35-2-2");
              return _TransMsg(
                  true,
                  task
                    ..remark =
                        'transactionUsdtTron error result ${resultList.last}');
            }
          }
          mypdebug("33-transactionUsdtTron-35-3");
          return _TransMsg(
              true,
              task
                ..remark =
                    'transactionUsdtTron error result length is ${resultList.length}');
        }

        mypdebug("33-transactionUsdtTron-36");
        String txid = resultList.removeAt(0);
        if (txid == null || txid.isEmpty) {
          mypdebug("33-transactionUsdtTron-37");
          return _TransMsg(
              true, task..remark = 'transactionUsdtTron txid is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-38");
        final count = await update_transcation_task(task..transactionId = txid);
        if (!count) {
          mypdebug("33-transactionUsdtTron-39");
          return _TransMsg(
              true,
              task
                ..remark = 'transactionUsdtTron update_collect_task txid fail',
              showMsg: true);
        }

        mypdebug("33-transactionUsdtTron-40");
        final fn = resultList.removeAt(0);
        final sub = resultList.first;
        final agrs = resultList.last;
        showToastTip('正在转账');
        final resultList2 = await fn.call(sub, agrs);
        if (resultList2 == null) {
          mypdebug("33-transactionUsdtTron-41");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark =
                    'transactionUsdtTron error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2 == null || resultList2.first == null) {
          mypdebug("33-transactionUsdtTron-41-1");
          return _TransMsg(
              true,
              task
                ..remark =
                    'transactionUsdtTron error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2.first != true) {
          mypdebug("33-transactionUsdtTron-41-2");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark =
                    'transactionUsdtTron error result:${resultList2.last}');
        }
        mypdebug("33-transactionUsdtTron-42");

        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_ING
              ..transactionId = txid
              ..remark = '');
      }
      mypdebug("33-transactionUsdtTron-43");
      if (nowUnixTimeSecond() - task.updateTime! > 60) {
        mypdebug("33-transactionUsdtTron-43-1");
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_NONE
              ..transactionId = ''
              ..remark =
                  'voss trx balance: $trxBalance, minTrxBalance: ${task.energyUsedMax}',
            showMsg: true);
      } else {
        mypdebug("33-transactionUsdtTron-43-2");
        return _TransMsg(
            false,
            task
              ..remark =
                  'voss trx balance: $trxBalance, minTrxBalance: ${task.energyUsedMax}',
            showMsg: true);
      }
    } else if (task.status == COLLECTION_STATUS_HEIGHT_ENERGY) {
      tronMgr.setConfig(task.fromAddr!, '');
      final double? energyUsed =
          await tronMgr.estimateenergy(task.toAddr!, task.usdtVal!);
      if (energyUsed == null) {
        return _TransMsg(false, task..remark = 'estimateenergy fail',
            showMsg: true);
      }
      if (energyUsed > tronGlobal.trx_fee_limit * 1.5) {
        return _TransMsg(
            false,
            task
              ..remark = '费用太高了继续等待'
              ..status = COLLECTION_STATUS_HEIGHT_ENERGY,
            showMsg: true);
      }
      double? trxBalance = await tronMgr.getBasicCurBalance();
      if (trxBalance == null) {
        mypdebug("33-transactionUsdtTron-48");
        return _TransMsg(false, task..remark = 'get trx trxBalance null',
            showMsg: true);
      }
      final double max_energy_used = energyUsed;
      final diff = max_energy_used - trxBalance;
      if (diff > 0) {
        if (tronGlobal.trx_cost_addr.isEmpty ||
            tronGlobal.trx_cost_pri_key.isEmpty) {
          mypdebug("33-transactionUsdtTron-48-1");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'trx_cost_addr is null',
              showMsg: true);
        }
        tronMgr.setConfig(
            tronGlobal.trx_cost_addr, tronGlobal.trx_cost_pri_key);
        List<dynamic>? resultList =
            await tronMgr.transferBasicCur(task.fromAddr!, diff);
        mypdebug("33-transactionUsdtTron-49");
        if (resultList == null || resultList.length < 4) {
          mypdebug("33-transactionUsdtTron-50");
          return _TransMsg(
              true, task..remark = 'transfer_trx error result is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-51");
        String txid = resultList.removeAt(0);
        if (txid == null || txid.isEmpty) {
          mypdebug("33-transactionUsdtTron-52");
          return _TransMsg(true, task..remark = 'transfer_trx txid is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-53");
        final count = await update_transcation_task(task..transactionId = txid);
        if (!count) {
          mypdebug("33-transactionUsdtTron-54");
          return _TransMsg(
              true, task..remark = 'transfer_trx update_collect_task txid fail',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtTron-55");
        final fn = resultList.removeAt(0);
        final sub = resultList.first;
        final agrs = resultList.last;
        final resultList2 = await fn.call(sub, agrs);
        if (resultList2 == null) {
          mypdebug("33-transactionUsdtTron-56");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_trx error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2 == null || resultList2.first == null) {
          mypdebug("33-transactionUsdtTron-57");
          return _TransMsg(true,
              task..remark = 'transfer_trx error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2.first != true) {
          mypdebug("33-transactionUsdtTron-58");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_trx error result:${resultList2.last}');
        }
      }
      mypdebug("33-transactionUsdtTron-59");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..energyUsedMax = max_energy_used
            ..status = COLLECTION_STATUS_COST
            ..remark = '');
    } else if (task.status == COLLECTION_STATUS_ING) {
      mypdebug("33-transactionUsdtTron-44");
      final result = await tronMgr.gettransactionbyid(task.transactionId!);
      if (result) {
        mypdebug("33-transactionUsdtTron-45");
        showToastTip('转账成功');
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_OK
              ..remark = '');
      }
    } else if (task.status == COLLECTION_STATUS_OK) {
      mypdebug("33-transactionUsdtTron-46");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_OK
            ..remark = '');
    }
    mypdebug("33-transactionUsdtTron-47");
    return _TransMsg(
        true,
        task
          ..status = COLLECTION_STATUS_FAIL
          ..remark = '未知错误',
        showMsg: true);
  }

  Future<_TransMsg> transactionUsdtEth(TranscationLogData task) async {
    mypdebug("33-transactionUsdtEth");
    if (task == null || task.fromAddr == null || task.toAddr == null) {
      mypdebug("33-transactionUsdtEth-1");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_FAIL
            ..remark = '无效的task');
    }
    mypdebug("33-transactionUsdtEth-2");
    if (task.status == COLLECTION_STATUS_NONE) {
      mypdebug("33-transactionUsdtEth-3");
      if (task.transactionId != null && task.transactionId!.isNotEmpty) {
        mypdebug(
            "33-transactionUsdtEth-3-1 ${nowUnixTimeSecond() - task.updateTime!}");
        if (nowUnixTimeSecond() - task.updateTime! > 60) {
          mypdebug("33-transactionUsdtEth-3-1-1");
          final result = await ethMgr.gettransactionbyid(task.transactionId!);
          if (result == null) {
            return _TransMsg(true, task..remark = '等待确认中');
          } else if (result) {
            mypdebug("33-transactionUsdtEth-3-1-1-1");
            return _TransMsg(
                true,
                task
                  ..status = COLLECTION_STATUS_COST
                  ..transactionId = ''
                  ..remark = '');
          } else {
            mypdebug("33-transactionUsdtEth-3-1-1-2");
            return _TransMsg(
                true,
                task
                  ..transactionId = ''
                  ..remark = '');
          }
        } else {
          mypdebug("33-transactionUsdtEth-3-1-2");
          return _TransMsg(false,
              task..remark = 'transaction_eth waitting transactionId result');
        }
      }
      mypdebug("33-transactionUsdtEth-4");
      ethMgr.setConfig(task.fromAddr!, '');
      double? usdtBalance = await ethMgr.getUsdtBalance();
      if (usdtBalance == -1) {
        mypdebug("33-transactionUsdtEth-5");
        return _TransMsg(true, task..remark = '转账usdt失败,获取余额失败');
      }
      mypdebug("33-transactionUsdtEth-6 usdtBalance: $usdtBalance");
      double usdtVal = task.usdtVal!;
      if (usdtVal < 1) {
        mypdebug("33-transactionUsdtEth-31");
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_FAIL
              ..remark = 'usdt_balance: $usdtBalance, min_collection_val: 1',
            showMsg: true);
      }
      if (usdtBalance! < usdtVal) {
        mypdebug("33-transactionUsdtEth-7");
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_FAIL
              ..remark = 'usdt_balance: $usdtBalance, transfer_val: $usdtVal');
      }
      mypdebug("33-transactionUsdtEth-8");
      ethMgr.setConfig(task.fromAddr!, '');
      final double? energyUsed =
          await ethMgr.estimateenergy(task.toAddr!, task.usdtVal!);
      if (energyUsed == null) {
        return _TransMsg(false, task..remark = 'estimateenergy fail',
            showMsg: true);
      }
      if (energyUsed > ethGlobal.eth_gas_limit * 1.5) {
        return _TransMsg(
            false,
            task
              ..remark = '费用太高了继续等待'
              ..status = COLLECTION_STATUS_HEIGHT_ENERGY,
            showMsg: true);
      }
      double? ethBalance = await ethMgr.getBasicCurBalance();
      if (ethBalance == null) {
        mypdebug("33-transactionUsdtEth-9");
        return _TransMsg(false, task..remark = 'get eth ethBalance null');
      }

      mypdebug("33-transactionUsdtEth-10 ethBalance:$ethBalance");
      final double max_energy_used = energyUsed;
      final diff = max_energy_used - ethBalance;
      if (diff > 0) {
        mypdebug("33-transactionUsdtEth-11 diff: $diff");
        if (ethGlobal.eth_cost_addr.isEmpty ||
            ethGlobal.eth_cost_pri_key.isEmpty) {
          mypdebug("33-transactionUsdtEth-12");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'eth_cost_addr is null');
        }
        mypdebug("33-transactionUsdtEth-13");
        ethMgr.setConfig(ethGlobal.eth_cost_addr, ethGlobal.eth_cost_pri_key);
        List<dynamic>? resultList =
            await ethMgr.transferBasicCur(task.fromAddr!, diff);
        mypdebug("33-transactionUsdtEth-14");
        if (resultList == null || resultList.length < 4) {
          mypdebug("33-transactionUsdtEth-15");
          return _TransMsg(
              true, task..remark = 'transfer_eth error result is null');
        }
        mypdebug("33-transactionUsdtEth-16");
        String txid = resultList.removeAt(0);
        if (txid == null || txid.isEmpty) {
          mypdebug("33-transactionUsdtEth-17");
          return _TransMsg(true, task..remark = 'transfer_eth txid is null');
        }
        mypdebug("33-transactionUsdtEth-18");
        final count = await update_transcation_task(task..transactionId = txid);
        if (!count) {
          mypdebug("33-transactionUsdtEth-19");
          return _TransMsg(true,
              task..remark = 'transfer_eth update_collect_task txid fail');
        }

        mypdebug("33-transactionUsdtEth-20");
        final fn = resultList.removeAt(0);
        final sub = resultList.first;
        final agrs = resultList.last;
        showToastTip('正在转账');
        final resultList2 = await fn.call(sub, agrs);
        if (resultList2 == null) {
          mypdebug("33-transactionUsdtEth-21");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_eth error result:${resultList2.last}');
        }
        if (resultList2.first == null) {
          mypdebug("33-transactionUsdtEth-21-1");
          return _TransMsg(true,
              task..remark = 'transfer_eth error result:${resultList2.last}');
        }
        if (resultList2.first != true) {
          mypdebug("33-transactionUsdtEth-21-2");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_eth error result:${resultList2.last}');
        }
      }
      mypdebug("33-transactionUsdtEth-22");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..energyUsedMax = max_energy_used
            ..status = COLLECTION_STATUS_COST
            ..remark = '');
    } else if (task.status == COLLECTION_STATUS_COST) {
      mypdebug("33-transactionUsdtEth-23");
      if (task.transactionId != null && task.transactionId!.isNotEmpty) {
        mypdebug(
            "33-transactionUsdtEth-24 ${task.transactionId} ${nowUnixTimeSecond() - task.updateTime!}");
        if (nowUnixTimeSecond() - task.updateTime! >
            ethGlobal.eth_confirm_time) {
          mypdebug("33-transactionUsdtEth-24-1");
          final result = await ethMgr.gettransactionbyid(task.transactionId!);
          if (result) {
            mypdebug("33-transactionUsdtEth-24-1-1");
            return _TransMsg(
                true,
                task
                  ..status = COLLECTION_STATUS_ING
                  ..remark = '');
          } else {
            mypdebug("33-transactionUsdtEth-24-1-2");
            return _TransMsg(
                true,
                task
                  ..status = COLLECTION_STATUS_NONE
                  ..transactionId = ''
                  ..remark = '');
          }
        } else {
          mypdebug("33-transactionUsdtEth-24-2");
          return _TransMsg(false, task..remark = '等待确认中');
        }
      }
      mypdebug("33-transactionUsdtEth-25");
      ethMgr.setConfig(task.fromAddr!, '');
      double? ethBalance = await ethMgr.getBasicCurBalance();
      if (ethBalance == null) {
        mypdebug("33-transactionUsdtEth-26");
        return _TransMsg(false, task..remark = 'get eth ethBalance null');
      }
      mypdebug("33-transactionUsdtEth-27 ethBalance:$ethBalance");
      if (ethBalance >= task.energyUsedMax!) {
        mypdebug("33-transactionUsdtEth-28");
        double? usdtBalance = await ethMgr.getUsdtBalance();
        if (usdtBalance == -1) {
          mypdebug("33-transactionUsdtEth-29");
          return _TransMsg(true, task..remark = '转账usdt失败,获取余额失败');
        }
        mypdebug("33-transactionUsdtEth-30 usdtBalance:$usdtBalance");
        double usdtVal = task.usdtVal!;
        if (usdtVal < 1) {
          mypdebug("33-transactionUsdtEth-31");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'usdt_balance: $usdtBalance, min_collection_val: 1',
              showMsg: true);
        }
        if (usdtBalance! < usdtVal) {
          mypdebug("33-transactionUsdtEth-31");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark =
                    'usdt_balance: $usdtBalance, transfer_val: $usdtVal');
        }
        mypdebug("33-transactionUsdtEth-32");
        final priList = await addrMgr.getPriByAdress(task.fromAddr!);
        if (priList.first == null) {
          mypdebug("33-transactionUsdtEth-33");
          return _TransMsg(
              true, task..remark = priList.last ?? '转账usdt失败,获取地址信息失败');
        }
        mypdebug("33-transactionUsdtEth-34");
        ethMgr.setConfig(task.fromAddr!, priList.first!);
        List<dynamic>? resultList =
            await ethMgr.transferUSDT(task.toAddr!, usdtVal, ethBalance);
        if (resultList == null) {
          mypdebug("33-transactionUsdtEth-35-1");
          return _TransMsg(
              true, task..remark = 'transactionUsdtEth error result is null',
              showMsg: true);
        }

        if (resultList.length < 4) {
          mypdebug("33-transactionUsdtEth-35-2");
          if (resultList.length == 2) {
            final result = resultList.first;
            if (result == true) {
              mypdebug("33-transactionUsdtEth-35-2-1");
              return _TransMsg(
                  true,
                  task
                    ..status = COLLECTION_STATUS_HEIGHT_ENERGY
                    ..remark =
                        'transactionUsdtEth error result ${resultList.last}');
            } else {
              mypdebug("33-transactionUsdtEth-35-2-2");
              return _TransMsg(
                  true,
                  task
                    ..remark =
                        'transactionUsdtEth error result ${resultList.last}');
            }
          }
          mypdebug("33-transactionUsdtEth-35-3");
          return _TransMsg(
              true,
              task
                ..remark =
                    'transactionUsdtEth error result length is ${resultList.length}');
        }
        mypdebug("33-transactionUsdtEth-36");
        String txid = resultList.removeAt(0);
        if (txid == null || txid.isEmpty) {
          mypdebug("33-transactionUsdtEth-37");
          return _TransMsg(
              true, task..remark = 'transactionUsdtEth txid is null');
        }
        mypdebug("33-transactionUsdtEth-38");
        final count = await update_transcation_task(task..transactionId = txid);
        if (!count) {
          mypdebug("33-transactionUsdtEth-39");
          return _TransMsg(
              true,
              task
                ..remark = 'transactionUsdtEth update_collect_task txid fail');
        }

        mypdebug("33-transactionUsdtEth-40");
        final fn = resultList.removeAt(0);
        final sub = resultList.first;
        final agrs = resultList.last;
        showToastTip('正在转账');
        final resultList2 = await fn.call(sub, agrs);
        if (resultList2 == null) {
          mypdebug("33-transactionUsdtEth-41");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark =
                    'transactionUsdtEth error result:${resultList2.last}');
        }
        if (resultList2.first == null) {
          mypdebug("33-transactionUsdtEth-41-1");
          return _TransMsg(
              true,
              task
                ..remark =
                    'transactionUsdtEth error result:${resultList2.last}');
        }
        if (resultList2.first != true) {
          mypdebug("33-transactionUsdtEth-41-2");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark =
                    'transactionUsdtEth error result:${resultList2.last}');
        }
        mypdebug("33-transactionUsdtEth-42");

        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_ING
              ..transactionId = txid
              ..remark = '');
      }
      mypdebug("33-transactionUsdtEth-43");
      if (nowUnixTimeSecond() - task.updateTime! > 60) {
        mypdebug("33-transactionUsdtEth-43-1");
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_NONE
              ..transactionId = ''
              ..remark =
                  'voss eth balance: $ethBalance, minethBalance: ${task.energyUsedMax}');
      } else {
        mypdebug("33-transactionUsdtEth-43-2");
        return _TransMsg(
            false,
            task
              ..remark =
                  'voss eth balance: $ethBalance, minethBalance: ${task.energyUsedMax}');
      }
    } else if (task.status == COLLECTION_STATUS_HEIGHT_ENERGY) {
      ethMgr.setConfig(task.fromAddr!, '');
      final double? energyUsed =
          await ethMgr.estimateenergy(task.toAddr!, task.usdtVal!);
      if (energyUsed == null) {
        return _TransMsg(false, task..remark = 'estimateenergy fail',
            showMsg: true);
      }
      if (energyUsed > ethGlobal.eth_gas_limit * 1.5) {
        return _TransMsg(
            false,
            task
              ..remark = '费用太高了继续等待'
              ..status = COLLECTION_STATUS_HEIGHT_ENERGY,
            showMsg: true);
      }
      double? ethBalance = await ethMgr.getBasicCurBalance();
      if (ethBalance == null) {
        mypdebug("33-transactionUsdtEth-48");
        return _TransMsg(false, task..remark = 'get eth ethBalance null',
            showMsg: true);
      }
      final double max_energy_used = energyUsed;
      final diff = max_energy_used - ethBalance;
      if (diff > 0) {
        if (ethGlobal.eth_cost_addr.isEmpty ||
            ethGlobal.eth_cost_pri_key.isEmpty) {
          mypdebug("33-transactionUsdtEth-48-1");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_FAIL
                ..remark = 'eth_cost_addr is null',
              showMsg: true);
        }
        ethMgr.setConfig(ethGlobal.eth_cost_addr, ethGlobal.eth_cost_pri_key);
        List<dynamic>? resultList =
            await ethMgr.transferBasicCur(task.fromAddr!, diff);
        mypdebug("33-transactionUsdtEth-49");
        if (resultList == null || resultList.length < 4) {
          mypdebug("33-transactionUsdtEth-50");
          return _TransMsg(
              true, task..remark = 'transfer_eth error result is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtEth-51");
        String txid = resultList.removeAt(0);
        if (txid == null || txid.isEmpty) {
          mypdebug("33-transactionUsdtEth-52");
          return _TransMsg(true, task..remark = 'transfer_eth txid is null',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtEth-53");
        final count = await update_transcation_task(task..transactionId = txid);
        if (!count) {
          mypdebug("33-transactionUsdtEth-54");
          return _TransMsg(
              true, task..remark = 'transfer_eth update_collect_task txid fail',
              showMsg: true);
        }
        mypdebug("33-transactionUsdtEth-55");
        final fn = resultList.removeAt(0);
        final sub = resultList.first;
        final agrs = resultList.last;
        final resultList2 = await fn.call(sub, agrs);
        if (resultList2 == null) {
          mypdebug("33-transactionUsdtEth-56");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_eth error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2 == null || resultList2.first == null) {
          mypdebug("33-transactionUsdtEth-57");
          return _TransMsg(true,
              task..remark = 'transfer_eth error result:${resultList2.last}',
              showMsg: true);
        }
        if (resultList2.first != true) {
          mypdebug("33-transactionUsdtEth-58");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = 'transfer_eth error result:${resultList2.last}');
        }
      }
      mypdebug("33-transactionUsdtEth-59");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..energyUsedMax = max_energy_used
            ..status = COLLECTION_STATUS_COST
            ..remark = '');
    } else if (task.status == COLLECTION_STATUS_ING) {
      mypdebug("33-transactionUsdtEth-44");
      final result = await ethMgr.gettransactionbyid(task.transactionId!);
      if (result == null) {
        return _TransMsg(true, task..remark = '等待确认中');
      } else if (result) {
        mypdebug("33-transactionUsdtEth-45");
        showToastTip('转账成功');
        return _TransMsg(
            true,
            task
              ..status = COLLECTION_STATUS_OK
              ..remark = '');
      }
    } else if (task.status == COLLECTION_STATUS_OK) {
      mypdebug("33-transactionUsdtEth-46");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_OK
            ..remark = '');
    }
    mypdebug("33-transactionUsdtEth-47");
    return _TransMsg(
        true,
        task
          ..status = COLLECTION_STATUS_FAIL
          ..remark = '未知错误');
  }

  bool _isRunning = false;
  Future update() async {
    if (_isRunning) return;
    _isRunning = true;
    mypdebug("11");
    final List notOkList = await get_not_ok_data();
    final len = notOkList.length;
    if (len <= 0) {
      mypdebug("11-1");
      delayUpdate(ms: 10);
      return;
    }
    mypdebug("22");
    final task = TranscationLogData.fromJson(notOkList.first);
    if (task == null) {
      mypdebug("transaction_mgr:update task is nil");
      delayUpdate();
      mypdebug("22-1");
      return;
    }
    mypdebug("33");
    _TransMsg? transMsg;
    if (task.walletType == 'wallet_eth') {
      transMsg = await transactionUsdtEth(task);
    } else {
      transMsg = await transactionUsdtTron(task);
    }
    if (transMsg != null && transMsg.result) {
      mypdebug("33-1");
      if (task.status == COLLECTION_STATUS_FAIL &&
          task.transactionId != null &&
          task.transactionId!.isNotEmpty) {
        mypdebug("33-1-1");
        task.status = COLLECTION_STATUS_COST;
      }
      showToastTip(task.remark!);
      mypdebug("33-1-2");
      final result = await update_transcation_task(transMsg.task);
      if (!result) {
        delayUpdate();
        return;
      }
      delayUpdate(ms: 3);
      return;
    }
    mypdebug("44");
    delayUpdate(ms: 1);
  }

  Future<bool> update_transcation_task(TranscationLogData task) async {
    await dbMgr.open();
    task.updateTime = nowUnixTimeSecond();
    final count = await dbMgr
        .updateByHelper(tbName, Map.from(task.toJson()), 'id = ?', [task.id]);
    await dbMgr.close();

    return count > 0;
  }

  Future<List<Map>> get_not_ok_data() async {
    await dbMgr.open();
    final sql1 =
        "select * from $tbName where status<$COLLECTION_STATUS_OK or (status == $COLLECTION_STATUS_FAIL and transaction_id != '') ";
    List<Map> list1 = await dbMgr.queryList(sql1);
    mypdebug('transaction_mgr get_not_ok_data list1：$list1');
    if (list1 != null && list1.isNotEmpty) {
      return list1;
    }
    final sql2 =
        "select * from $tbName where status=$COLLECTION_STATUS_HEIGHT_ENERGY";
    List<Map> list2 = await dbMgr.queryList(sql2);
    mypdebug('transaction_mgr get_not_ok_data list2：$list2');
    await dbMgr.close();
    return list2;
  }

  Future<bool> add_transaction_log(List<TranscationLogData> logs) async {
    if (logs == null || logs.isEmpty) return false;
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    final createTime = nowUnixTimeSecond();
    for (TranscationLogData element in logs) {
      element.createTime = element.updateTime = createTime;
      Map map = element.toJson();
      map.remove('id');
      batch.insert(tbName, Map.from(map));
    }
    List<Object?> results = await batch.commit();

    await dbMgr.close();
    if (results != null && results.length == logs.length) {
      return true;
    }
    return false;
  }

  Future<MsgResult> get_transaction_log(int taskId) async {
    await dbMgr.open();
    List list = await dbMgr
        .queryList("SELECT * FROM $tbName where task_id = '$taskId';");
    final count = await dbMgr.queryList(
        "SELECT sum(usdt_val) as count FROM $tbName where task_id = '$taskId';");
    final code =
        list != null && list.isNotEmpty && count != null && count.isNotEmpty;
    await dbMgr.close();
    return MsgResult(code: code, result: [list, count.first['count']]);
  }

  Future<List<TranscationLogData>> get_transaction_log_list(
      int page, int page_size,
      {int? begin_time, int? end_time}) async {
    await dbMgr.open();
    final time_str = begin_time != null && end_time != null
        ? "create_time >= '$begin_time' and  create_time < '$end_time'"
        : '';
    final where_str = time_str.isNotEmpty ? 'where' : '';
    final sql =
        "select * from $tbName $where_str $time_str order by create_time desc limit ${(page - 1) * page_size},$page_size;";
    List<Map> data = await dbMgr.queryList(sql);
    mypdebug('transaction_mgr books_name：$data');
    final List<TranscationLogData> list = [];
    await dbMgr.close();
    for (var element in data) {
      list.add(TranscationLogData.fromJson(element as Map<String, dynamic>));
    }
    return list;
  }

  bool _cleanIsRunning = false;
  Future<int> cleanDB() async {
    if (_cleanIsRunning) return -1;
    _cleanIsRunning = true;
    await dbMgr.open();
    final del_tm = DateTime.now()
            .subtract(const Duration(days: 7))
            .millisecondsSinceEpoch ~/
        1000;
    final count =
        await dbMgr.deleteByHelper(tbName, ' create_time < ? ', [del_tm]);

    await dbMgr.close();
    mypdebug('transaction_mgr $tbName cleanDB $count');
    _cleanSeconds =
        DateTime.now().add(const Duration(seconds: 60)).millisecondsSinceEpoch;
    _cleanIsRunning = false;
    return count;
  }

  Future dropTable() async {
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    batch.execute("DROP TABLE IF EXISTS $tbName");
    await batch.commit(noResult: true);
    await dbMgr.close();
  }
}
