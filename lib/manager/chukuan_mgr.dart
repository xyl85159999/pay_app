// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison

import 'package:sqflite/sqlite_api.dart';
import 'package:bobi_pay_out/manager/data/books_name_data.dart';
import 'package:bobi_pay_out/manager/data/chu_kuan_data.dart';
import 'package:bobi_pay_out/manager/data/transcation_log_data.dart';
import 'package:bobi_pay_out/manager/timer_mgr.dart';
import 'package:bobi_pay_out/manager/transcation_mgr.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/model/sql/DBUtil.dart';
import 'package:bobi_pay_out/service/service_voss_tj.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/chukuan_model.dart';
import 'package:bobi_pay_out/view_model/dizhi_balance_model.dart';

final ChukuanMgr chukuanMgr = ChukuanMgr();

class ChukuanMgr extends OnUpdateActor {
  final tbName = "tb_transfer_task";

  int _cleanSeconds = 0;
  int _timeoutSeconds = 0;
  ChukuanMgr() {
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

  delayUpdate({int? ms}) {
    _timeoutSeconds =
        DateTime.now().add(Duration(seconds: ms ?? 5)).millisecondsSinceEpoch;
    _isRunning = false;
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
    final task = ChuKuanData.fromJson(notOkList.first);
    if (task == null) {
      mypdebug("transfer_task:update task is nil");
      delayUpdate();
      mypdebug("22-1");
      return;
    }
    mypdebug("33");
    if (task.status == TRANSFER_TASK_STATUS_ACCEPT) {
      mypdebug("44");
      final addrs = await serviceVossTj.get_addrs_by_amount(
          task.fromBagName!, task.amount!);
      if (addrs == null || addrs.isEmpty) {
        mypdebug("44-1");
        await update_transfer_task(
            task..status = TRANSFER_TASK_STATUS_NOT_USDT);
        delayUpdate();
        return;
      }
      mypdebug("44-2");
      double? amount = task.amount! * 1.0;
      final List<TranscationLogData> logs = [];
      for (var i = 0; i < addrs.length; i++) {
        final addr = BooksNameData.fromJson(addrs[i]);
        if (addr == null) continue;
        if (amount! < 1) continue;
        double? tran_amount = addr.usdtBalance! * 1.0;
        if (tran_amount > amount) {
          tran_amount = amount;
        } else {
          amount = amount - tran_amount;
        }

        logs.add(TranscationLogData(
            taskId: task.id,
            fromBagName: task.fromBagName,
            fromAddr: addr.addr,
            toAddr: task.toAddr,
            walletType: task.walletType,
            usdtVal: tran_amount,
            status: COLLECTION_STATUS_NONE));

        if (amount == 0) break;
      }
      mypdebug("44-3");
      final result = await transactionMgr.add_transaction_log(logs);
      if (!result) {
        mypdebug("44-4");
        delayUpdate();
        return;
      }
      mypdebug("44-5");
      final result1 =
          await update_transfer_task(task..status = TRANSFER_TASK_STATUS_ING);
      if (!result1) {
        mypdebug("44-6");
        delayUpdate();
        return;
      }
    } else if (task.status == TRANSFER_TASK_STATUS_ING) {
      mypdebug("55");
      final list = await transactionMgr.get_transaction_log(task.id!);
      if (list == null || !list.code) {
        mypdebug("55-1");
        delayUpdate();
        return;
      }
      mypdebug("55-2");
      final logs = list.result.first as List;
      final amount = list.result.last;
      assert(logs.isNotEmpty);
      assert((amount - task.amount).abs() < 1);
      task.tarningAmount = 0;
      task.finishAmount = 0;
      int notSure = 0;
      for (var element in logs) {
        TranscationLogData transcationLog =
            TranscationLogData.fromJson(element);
        if (transcationLog.status == COLLECTION_STATUS_OK) {
          mypdebug("55-2-1");
          task.finishAmount = task.finishAmount! + transcationLog.usdtVal!;
        } else if (transcationLog.status != COLLECTION_STATUS_FAIL &&
            (transcationLog.transactionId == null ||
                transcationLog.transactionId!.isEmpty)) {
          task.tarningAmount = task.tarningAmount! + transcationLog.usdtVal!;
          mypdebug("55-2-2");
        } else {
          if (transcationLog.transactionId != null &&
              transcationLog.transactionId!.isNotEmpty) {
            mypdebug("55-2-3");
            notSure++;
          }
        }
      }
      mypdebug("55-3");
      if ((task.finishAmount! - task.amount!).abs() < 1) {
        await update_transfer_task(task..status = TRANSFER_TASK_STATUS_OK);
        delayUpdate();
        mypdebug("55-4");
        return;
      }

      mypdebug("55-5");
      if (notSure == 0 && task.tarningAmount == 0) {
        await update_transfer_task(task
          ..status = TRANSFER_TASK_STATUS_FAIL
          ..remark = 'finishAmount:${task.finishAmount} amount:${task.amount}');
        delayUpdate();
        mypdebug("55-6");
        return;
      }

      mypdebug("55-7");
      final result = await update_transfer_task(task);
      if (!result) {
        delayUpdate();
        mypdebug("55-8");
        return;
      }
      delayUpdate(ms: 5);
      return;
    }
    mypdebug("55-9");
    delayUpdate(ms: 3);
  }

  Future<bool> new_transfer_task(
      String from_bag_name, String to_addr, double amount, String wallet_type,
      {String? remark}) async {
    await dizhi_balance_model.query_balance();
    final count = dizhi_balance_model.usdt_balance;
    if (count == null) {
      return false;
    }
    if (count < amount) {
      showToastTip("余额不足");
      return false;
    }

    await dbMgr.open();
    final createTime = nowUnixTimeSecond();

    ChuKuanData chuKuanData = ChuKuanData(
        amount: amount,
        fromBagName: from_bag_name,
        toAddr: to_addr,
        walletType: wallet_type,
        remark: remark ?? '',
        createTime: createTime,
        updateTime: createTime);
    Map map = chuKuanData.toJson();
    map.remove('id');
    final result = await dbMgr.insertByHelper(tbName, Map.from(map));
    await dbMgr.close();
    bool isSucess = result > 0;
    if (isSucess) {
      showToastTip("新增出款任务成功");
      chukuan_model.debounceRefresh();
    }
    return isSucess;
  }

  Future<List<Map>> get_not_ok_data() async {
    await dbMgr.open();
    final sql =
        "select * from $tbName where status<$TRANSFER_TASK_STATUS_OK and status<>$TRANSFER_TASK_STATUS_NONE  ORDER BY status desc,id LIMIT 1;";
    List<Map> list = await dbMgr.queryList(sql);
    mypdebug('transfer_task get_not_ok_data：$list');
    await dbMgr.close();
    return list;
  }

  Future<bool> update_transfer_task(ChuKuanData task) async {
    await dbMgr.open();
    task.updateTime = nowUnixTimeSecond();
    final count = await dbMgr
        .updateByHelper(tbName, Map.from(task.toJson()), 'id = ?', [task.id]);
    await dbMgr.close();

    return count > 0;
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
    final count = await dbMgr.deleteByHelper(tbName,
        ' status>=? and create_time <? ', [TRANSFER_TASK_STATUS_OK, del_tm]);
    await dbMgr.close();
    mypdebug('transfer_task $tbName cleanDB $count');
    _cleanSeconds =
        DateTime.now().add(const Duration(seconds: 60)).millisecondsSinceEpoch;
    _cleanIsRunning = false;
    return count;
  }

  Future<bool> begin_tran(ChuKuanData task) async {
    task.status = TRANSFER_TASK_STATUS_ACCEPT;
    return await update_transfer_task(task);
  }

  Future<bool> reject_tran(ChuKuanData task) async {
    task.status = TRANSFER_TASK_STATUS_REJECT;
    return await update_transfer_task(task);
  }

  Future<bool> invalid_tran(ChuKuanData task) async {
    task.status = TRANSFER_TASK_STATUS_INVALID;
    return await update_transfer_task(task);
  }

  Future<List<ChuKuanData>> get_transfer_task(int page, int page_size,
      {String? books_name, int? begin_time, int? end_time}) async {
    final books_name_str =
        books_name != null ? " books_name = '$books_name' " : '';
    final time_str = begin_time != null && end_time != null
        ? " create_time >= '$begin_time' and  create_time < '$end_time'"
        : '';
    final where_str =
        books_name_str.isNotEmpty || time_str.isNotEmpty ? 'where' : '';
    final and_str = books_name_str.isNotEmpty ? 'and' : '';
    await dbMgr.open();
    final sql =
        "select * from $tbName $where_str $books_name_str $and_str $time_str order by create_time desc limit ${(page - 1) * page_size},$page_size;";
    List<Map> data = await dbMgr.queryList(sql);
    mypdebug('transfer_task books_name：$data');
    final List<ChuKuanData> list = [];
    await dbMgr.close();
    for (var element in data) {
      list.add(ChuKuanData.fromJson(element as Map<String, dynamic>));
    }
    return list;
  }

  Future initData(List<String> list) async {
    if (!list.contains(tbName)) return;
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    batch.insert(tbName, {
      "create_time": 1666077476,
      "to_addr": "TYe6871E7uBeSgjLEXeJT4MeiebXjx6Knu",
      "amount": 1,
      "wallet_type": 'wallet_trx',
      "tarning_amount": 0,
      "finish_amount": 0,
      "status": 14,
      "update_time": 1672216043,
      "remark": "1111",
      "from_bag_name": "qwer"
    });
    batch.insert(tbName, {
      "create_time": 1666077476,
      "to_addr": "TYe6871E7uBeSgjLEXeJT4MeiebXjx6Knu",
      "amount": 1,
      "wallet_type": 'wallet_trx',
      "tarning_amount": 0,
      "finish_amount": 0,
      "status": 14,
      "update_time": 1672216043,
      "remark": "1111",
      "from_bag_name": "qwer"
    });
    batch.insert(tbName, {
      "create_time": 1666077476,
      "to_addr": "TYe6871E7uBeSgjLEXeJT4MeiebXjx6Knu",
      "amount": 1,
      "wallet_type": 'wallet_trx',
      "tarning_amount": 0,
      "finish_amount": 0,
      "status": 14,
      "update_time": 1672216043,
      "remark": "1111",
      "from_bag_name": "qwer"
    });
    await batch.commit(noResult: true);
    await dbMgr.close();
  }

  Future dropTable() async {
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    batch.execute("DROP TABLE IF EXISTS $tbName");
    await batch.commit(noResult: true);
    await dbMgr.close();
  }
}
