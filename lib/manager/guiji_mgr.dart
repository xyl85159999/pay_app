// ignore_for_file: non_constant_identifier_names, library_private_types_in_public_api, unnecessary_null_comparison

import 'dart:async';

import 'package:flutter_tron_api/eth_global.dart';
import 'package:flutter_tron_api/eth_mgr.dart';
import 'package:flutter_tron_api/models/eth_config.dart';
import 'package:flutter_tron_api/models/tron_config.dart';
import 'package:flutter_tron_api/tron_mgr.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:bobi_pay_out/manager/addr_mgr.dart';
import 'package:bobi_pay_out/manager/data/collect_data.dart';
import 'package:bobi_pay_out/manager/timer_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/model/sql/dbUtil.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';
import 'package:bobi_pay_out/utils/utility.dart';

final GuiJiMgr guiJiMgr = GuiJiMgr();

class _TransMsg {
  bool result;
  bool showMsg;
  CollectData task;
  _TransMsg(this.result, this.task, {this.showMsg = false});
}

class GuiJiMgr extends OnUpdateActor {
  final tbName = "tb_collection_task";

  bool guiji_switch = false;
  int _timeoutSeconds = 0;
  int _cleanSeconds = 0;
  final TronManager tron_mgr = TronManager(TronConfig('', ''));
  final EthManager eth_mgr = EthManager(EthConfig('', ''));

  GuiJiMgr() {
    timer_mgr.add(this, ms: 1000);
  }

  dispose() {
    timer_mgr.del(this);
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

  Future<_TransMsg> transactionUsdtTron(CollectData task) async {
    mypdebug("transactionUsdtTron 44-1");
    if (task.addr == null || task.toAddr == null || task.amount == null) {
      mypdebug("transactionUsdtTron 44-2");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_FAIL
            ..remark = '无效的task',
          showMsg: true);
    }
    final isValid = await addrMgr.checkAddrIsGuiJi(task.toAddr!);
    if (!isValid) {
      return _TransMsg(true, task..remark = '归集包不存在', showMsg: true);
    }

    mypdebug("transactionUsdtTron 44-3");
    if (task.transactionId != null && task.transactionId!.isNotEmpty) {
      mypdebug("transactionUsdtTron 44-4");
      if (nowUnixTimeSecond() - task.updateTime! > 60) {
        mypdebug("transactionUsdtTron 44-5");
        final result = await tron_mgr.gettransactionbyid(task.transactionId!);
        if (result) {
          mypdebug("transactionUsdtTron 44-5-1");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_ING
                ..remark = '');
        } else {
          mypdebug("transactionUsdtTron 44-5-2");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = '');
        }
      } else {
        mypdebug("transactionUsdtTron 44-6");
        return _TransMsg(false,
            task..remark = 'transaction_usdt waitting transactionId result');
      }
    }

    mypdebug("transactionUsdtTron 44-7");
    final priList = await addrMgr.getPriByAdress(task.addr!);
    if (priList.first == null) {
      mypdebug("transactionUsdtTron 44-8");
      return _TransMsg(true, task..remark = priList.last ?? '转账usdt失败,获取地址信息失败',
          showMsg: true);
    }
    mypdebug("transactionUsdtTron 44-9");
    tron_mgr.setConfig(task.addr!, priList.first!);
    double? usdtBalance = await tron_mgr.getTrc20Balance();
    if (usdtBalance == -1) {
      mypdebug("transactionUsdtTron 44-10");
      return _TransMsg(true, task..remark = '转账usdt失败,获取余额失败', showMsg: true);
    }
    mypdebug("transactionUsdtTron 44-11");
    const minCollectionVal = 1;
    if (usdtBalance! < minCollectionVal) {
      mypdebug("transactionUsdtTron 44-12");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_PASS
            ..remark =
                'usdt_balance: $usdtBalance, min_collection_val: $minCollectionVal',
          showMsg: true);
    }
    if (task.amount! > usdtBalance) {
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_NONE
            ..remark =
                'voss usdt balance: $usdtBalance,is less task.amount: ${task.amount}',
          showMsg: true);
    }
    mypdebug("transactionUsdtTron 44-13");

    double? trxBalance = await tron_mgr.getTrxBalance();
    if (trxBalance == null) {
      mypdebug("transactionUsdtTron 44-14");
      return _TransMsg(false, task..remark = 'get trx trxBalance null');
    }
    mypdebug("transactionUsdtTron 44-15");
    if (task.energyUsedMax == null ||
        task.energyUsedMax == 0 ||
        trxBalance < task.energyUsedMax!) {
      mypdebug("transactionUsdtTron 44-16");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_COST
            ..remark =
                'voss trx balance: $trxBalance, minTrxBalance: ${task.energyUsedMax}',
          showMsg: true);
    }

    mypdebug("transactionUsdtTron 44-17");
    showToastTip('开始转账');
    List<dynamic>? resultList =
        await tron_mgr.transferUSDT(task.toAddr!, task.amount!, trxBalance);
    if (resultList == null) {
      mypdebug("transactionUsdtTron 44-18-1");
      return _TransMsg(
          true, task..remark = 'transaction_usdt error result is null');
    }
    if (resultList.length < 4) {
      mypdebug("transactionUsdtTron 44-18-2");
      if (resultList.length == 2) {
        final result = resultList.first;
        if (result == true) {
          mypdebug("transactionUsdtTron 44-18-2-1");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_HEIGHT_ENERGY
                ..remark = 'transaction_usdt error result ${resultList.last}');
        } else {
          mypdebug("transactionUsdtTron 44-18-2-2");
          return _TransMsg(
              true,
              task
                ..remark = 'transaction_usdt error result ${resultList.last}');
        }
      }
      mypdebug("transactionUsdtTron 44-18-3");
      return _TransMsg(
          true,
          task
            ..remark =
                'transaction_usdt error result length is ${resultList.length}');
    }
    mypdebug("transactionUsdtTron 44-19");
    String txid = resultList.removeAt(0);
    if (txid.isEmpty) {
      mypdebug("transactionUsdtTron 44-20");
      return _TransMsg(true, task..remark = 'transaction_usdt txid is null',
          showMsg: true);
    }
    mypdebug("transactionUsdtTron 44-21");
    final count = await update_collect_task(task..transactionId = txid);
    if (!count) {
      mypdebug("transactionUsdtTron 44-22");
      return _TransMsg(
          true, task..remark = 'transaction_usdt update_collect_task txid fail',
          showMsg: true);
    }

    mypdebug("transactionUsdtTron 44-23");
    final fn = resultList.removeAt(0);
    final sub = resultList.first;
    final agrs = resultList.last;
    showToastTip('正在转账');
    final resultList2 = await fn.call(sub, agrs);
    if (resultList2 == null) {
      mypdebug("transactionUsdtTron 44-24");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..remark = 'transaction_usdt error1 result:${resultList2.last}');
    }
    if (resultList2.first == null) {
      mypdebug("transactionUsdtTron 44-24-1");
      return _TransMsg(true,
          task..remark = 'transaction_usdt error1 result:${resultList2.last}',
          showMsg: true);
    }
    if (resultList2.first != true) {
      mypdebug("transactionUsdtTron 44-24-2");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..remark = 'transaction_usdt error2 result:${resultList2.last}');
    }

    showToastTip('转账成功');

    mypdebug("transactionUsdtTron 44-25");
    return _TransMsg(
        true,
        task
          ..status = COLLECTION_STATUS_ING
          ..transactionId = txid
          ..remark = '');
  }

  Future<_TransMsg> transactionUsdtEth(CollectData task) async {
    mypdebug("transactionUsdtEth 44-1");
    if (task.addr == null || task.toAddr == null || task.amount == null) {
      mypdebug("transactionUsdtEth 44-2");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_FAIL
            ..remark = '无效的task',
          showMsg: true);
    }
    final isValid = await addrMgr.checkAddrIsGuiJi(task.toAddr!);
    if (!isValid) {
      return _TransMsg(true, task..remark = '归集包不存在', showMsg: true);
    }

    mypdebug("transactionUsdtEth 44-3");
    if (task.transactionId != null && task.transactionId!.isNotEmpty) {
      mypdebug("transactionUsdtEth 44-4");
      if (nowUnixTimeSecond() - task.updateTime! > ethGlobal.eth_confirm_time) {
        mypdebug("transactionUsdtEth 44-5");
        final result = await eth_mgr.gettransactionbyid(task.transactionId!);
        if (result) {
          mypdebug("transactionUsdtEth 44-5-1");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_ING
                ..remark = '');
        } else {
          mypdebug("transactionUsdtEth 44-5-2");
          return _TransMsg(
              true,
              task
                ..transactionId = ''
                ..remark = '');
        }
      } else {
        mypdebug("transactionUsdtEth 44-6");
        return _TransMsg(false, task..remark = '等待确认中', showMsg: true);
      }
    }

    mypdebug("transactionUsdtEth 44-7");
    final priList = await addrMgr.getPriByAdress(task.addr!);
    if (priList.first == null) {
      mypdebug("transactionUsdtEth 44-8");
      return _TransMsg(true, task..remark = priList.last ?? '转账usdt失败,获取地址信息失败',
          showMsg: true);
    }
    mypdebug("transactionUsdtEth 44-9");
    eth_mgr.setConfig(task.addr!, priList.first!);
    double? usdtBalance = await eth_mgr.getErc20Balance();
    if (usdtBalance == -1) {
      mypdebug("transactionUsdtEth 44-10");
      return _TransMsg(true, task..remark = '转账usdt失败,获取余额失败', showMsg: true);
    }
    mypdebug("transactionUsdtEth 44-11");
    const minCollectionVal = 1;
    if (usdtBalance! < minCollectionVal) {
      mypdebug("transactionUsdtEth 44-12");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_PASS
            ..remark =
                'usdt_balance: $usdtBalance, min_collection_val: $minCollectionVal',
          showMsg: true);
    }
    if (task.amount! > usdtBalance) {
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_NONE
            ..remark =
                'voss usdt balance: $usdtBalance,is less task.amount: ${task.amount}',
          showMsg: true);
    }
    mypdebug("transactionUsdtEth 44-13");

    double? ethBalance = await eth_mgr.getEthBalance();
    if (ethBalance == null) {
      mypdebug("transactionUsdtEth 44-14");
      return _TransMsg(false, task..remark = 'get eth ethBalance null',
          showMsg: true);
    }
    mypdebug("transactionUsdtEth 44-15");
    if (task.energyUsedMax == null ||
        task.energyUsedMax == 0 ||
        ethBalance < task.energyUsedMax!) {
      mypdebug("transactionUsdtEth 44-16");
      return _TransMsg(
          true,
          task
            ..status = COLLECTION_STATUS_COST
            ..remark =
                'voss eth balance: $ethBalance, minEthBalance: ${task.energyUsedMax}',
          showMsg: true);
    }

    mypdebug("transactionUsdtEth 44-17");
    showToastTip('开始转账');
    List<dynamic>? resultList =
        await eth_mgr.transferUSDT(task.toAddr!, task.amount!, ethBalance);
    if (resultList == null) {
      mypdebug("transactionUsdtEth 44-18-1");
      return _TransMsg(
          true, task..remark = 'transaction_usdt error result is null');
    }
    if (resultList.length < 4) {
      mypdebug("transactionUsdtEth 44-18-2");
      if (resultList.length == 2) {
        final result = resultList.first;
        if (result == true) {
          mypdebug("transactionUsdtEth 44-18-2-1");
          return _TransMsg(
              true,
              task
                ..status = COLLECTION_STATUS_HEIGHT_ENERGY
                ..remark = 'transaction_usdt error result ${resultList.last}');
        } else {
          mypdebug("transactionUsdtEth 44-18-2-2");
          return _TransMsg(
              true,
              task
                ..remark = 'transaction_usdt error result ${resultList.last}');
        }
      }
      mypdebug("transactionUsdtEth 44-18-3");
      return _TransMsg(
          true,
          task
            ..remark =
                'transaction_usdt error result length is ${resultList.length}');
    }
    mypdebug("transactionUsdtEth 44-19");
    String txid = resultList.removeAt(0);
    if (txid.isEmpty) {
      mypdebug("transactionUsdtEth 44-20");
      return _TransMsg(true, task..remark = 'transaction_usdt txid is null',
          showMsg: true);
    }
    mypdebug("transactionUsdtEth 44-21");
    final count = await update_collect_task(task..transactionId = txid);
    if (!count) {
      mypdebug("transactionUsdtEth 44-22");
      return _TransMsg(
          true, task..remark = 'transaction_usdt update_collect_task txid fail',
          showMsg: true);
    }

    mypdebug("transactionUsdtEth 44-23");
    final fn = resultList.removeAt(0);
    final sub = resultList.first;
    final agrs = resultList.last;
    showToastTip('正在转账');
    final resultList2 = await fn.call(sub, agrs);
    if (resultList2 == null) {
      mypdebug("transactionUsdtEth 44-24");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..remark = 'transaction_usdt error1 result:${resultList2.last}');
    }
    if (resultList2.first == null) {
      mypdebug("transactionUsdtEth 44-24-1");
      return _TransMsg(true,
          task..remark = 'transaction_usdt error1 result:${resultList2.last}',
          showMsg: true);
    }
    if (resultList2.first != true) {
      mypdebug("transactionUsdtEth 44-24-2");
      return _TransMsg(
          true,
          task
            ..transactionId = ''
            ..remark = 'transaction_usdt error2 result:${resultList2.last}');
    }

    showToastTip('转账成功');

    mypdebug("transactionUsdtEth 44-25");
    return _TransMsg(
        true,
        task
          ..status = COLLECTION_STATUS_ING
          ..transactionId = txid
          ..remark = '');
  }

  delayUpdate({int? ms}) {
    _timeoutSeconds =
        DateTime.now().add(Duration(seconds: ms ?? 3)).millisecondsSinceEpoch;
    _isRunning = false;
  }

  bool _isRunning = false;
  Future update() async {
    // if (!guiji_switch) return;
    if (_isRunning) return;
    _isRunning = true;
    mypdebug("11");
    final List notOkList = await get_not_ok_data();
    final len = notOkList.length;
    if (len > 0) {
      mypdebug("22");
      final task = CollectData.fromJson(notOkList.first);
      if (task == null) {
        mypdebug("33");
        mypdebug("collection_task:update task is nil");
        delayUpdate();
        return;
      }
      showToastTip('正在归集');
      mypdebug("44");
      if (task.status == COLLECTION_STATUS_WAITING_SIGIN) {
        mypdebug("44-1");
        _TransMsg transMsg;
        if (task.walletType == 'wallet_eth') {
          transMsg = await transactionUsdtEth(task);
        } else {
          transMsg = await transactionUsdtTron(task);
        }

        if (transMsg.result) {
          mypdebug("44-2");

          final result = await update_collect_task(transMsg.task);
          if (!result) {
            mypdebug("44-3");
            delayUpdate();
            return;
          }
        }
        mypdebug("44-4");
        if (task.status == COLLECTION_STATUS_WAITING_SIGIN) {
          mypdebug("44-5");
          mypdebug("collection_task:update task err ${task.remark}");
          if (transMsg.showMsg) {
            showToastTip(task.remark!);
          }
          delayUpdate();
          return;
        }
      }
      mypdebug("55");
      showToastTip('开始推送');
      final result = await serviceVossTj.update_collection_task(task);
      if (result) {
        mypdebug("55-1");
        final result = await update_collect_task(task..hasCallback = 1);
        if (!result) {
          delayUpdate();
          return;
        }
      } else {
        mypdebug("55-2");
        showToastTip('推送失败，正在重试');
        mypdebug(
            "collection_task:update open_address_api:update_collection_task");
      }
    } else {
      mypdebug("66");
      List? list = await serviceVossTj.get_collection_task_need_sign_task();
      if (list != null && list.isNotEmpty) {
        mypdebug("66-1");
        showToastTip('收到归集');
        await add_collection_task(list);
      } else {
        mypdebug("66-2");
        delayUpdate(ms: 30);
        showToastTip('正在获取归集');
        return;
      }
    }

    mypdebug("77");
    delayUpdate(ms: 5);
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

    final count = await dbMgr.deleteByHelper(
        tbName, ' has_callback > ? and create_time < ? ', [0, del_tm]);
    await dbMgr.close();
    mypdebug('tb_collection_task $tbName cleanDB $count');
    _cleanSeconds =
        DateTime.now().add(const Duration(seconds: 60)).millisecondsSinceEpoch;
    _cleanIsRunning = false;
    return count;
  }

  Future<List<Map>> get_not_ok_data() async {
    await dbMgr.open();
    final sql =
        "select * from $tbName where has_callback = 0 ORDER BY status DESC LIMIT 1;";
    List<Map> list = await dbMgr.queryList(sql);
    mypdebug('tb_collection_task get_not_ok_data：$list');
    await dbMgr.close();
    return list;
  }

  Future<bool> update_collect_task(CollectData task) async {
    await dbMgr.open();
    task.updateTime = nowUnixTimeSecond();
    final count = await dbMgr
        .updateByHelper(tbName, Map.from(task.toJson()), 'id = ?', [task.id]);
    await dbMgr.close();

    return count > 0;
  }

  Future<bool> add_collection_task(List<dynamic> list) async {
    if (list.isEmpty) return false;
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    int count = 0;
    for (var i = 0; i < list.length; i++) {
      list[i]['has_callback'] = 0;
      list[i]['create_time'] = nowUnixTimeSecond();
      list[i]['update_time'] = nowUnixTimeSecond();
      list[i]['task_id'] = list[i]['id'];
      CollectData collectData = CollectData.fromJson(list[i]);
      if (collectData == null) {
        continue;
      }
      if (collectData.addr == null || collectData.addr!.isEmpty) {
        continue;
      }
      if (collectData.toAddr == null || collectData.toAddr!.isEmpty) {
        continue;
      }
      if (collectData.amount == null || collectData.amount! <= 0) {
        continue;
      }
      Map<String, dynamic> map = collectData.toJson();
      map.remove('id');
      batch.insert(tbName, map);
      count++;
    }
    if (count == 0) {
      await dbMgr.close();
      return false;
    }
    List<Object?> results = await batch.commit();
    await dbMgr.close();

    return results.length == list.length;
  }
}
