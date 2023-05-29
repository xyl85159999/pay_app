import 'dart:async';

import 'package:bobi_pay_out/manager/connectivity_mgr.dart';
import 'package:bobi_pay_out/manager/data/pay_out_task.dart';
import 'package:bobi_pay_out/model/constant.dart';
import 'package:bobi_pay_out/model/update_block_bean.dart';
import 'package:bobi_pay_out/service/base_service.dart';
import 'package:bobi_pay_out/utils/code_define.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final ServiceRemote serviceRemote = ServiceRemote();

class ServiceRemote extends BaseService {
  ServiceRemote() : super();

  @override
  Future<HttpResponseBean> httpPost(String path, String info) async {
    if (connectivityMgr.connectivityResult == ConnectivityResult.none) {
      String temp = '似乎已断开与互联网的连接';
      dynamic rep = HttpResponseBean(
          {'code': CodeDefine.codeNotNet, 'msg': temp}, path, {'param': info});
      return Future.value(rep);
    }
    return super.httpPost(path, info);
  }

  @override
  Future<void> updateTick(int diff) {
    throw UnimplementedError();
  }

  Future<List> getPayOutTask() async {
    Map<String, dynamic> params = {};
    String info = makeSign(params);
    if (info.isEmpty) return [];
    HttpResponseBean res = await httpPost('/open_api/list_wait_pay', info);
    if (res.code == 0) {
      return res.result;
    }
    return [];
  }

  Future<bool> updateCollectionTask(PayOutTask task) async {
    Map<String, dynamic> params = {
      "reason": task.remark,
      "transactionId": task.transactionId,
      "taskId": task.taskId,
      "amount": task.amount,
      "succes": task.status == PayOutStatusEnum.payOutStatusSucceed ||
              task.status == PayOutStatusEnum.payOutStatusCallback
          ? 1
          : 0
    };
    // Map.from(task.toJson());
    String info = makeSign(params);
    if (info.isEmpty) return false;
    HttpResponseBean res = await httpPost('/open_api/fish_finish_pay', info);
    if (res.code == 0) {
      return true;
    }
    return false;
  }

  Future<bool> isWhiteAddress(PayOutTask task) async {
    Map<String, dynamic> params = {"addr": task.toAddr};
    String info = makeSign(params);
    if (info.isEmpty) return false;
    HttpResponseBean res = await httpPost('/open_api/is_white_address', info);
    if (res.code == 0) {
      return true;
    }
    return false;
  }
}
