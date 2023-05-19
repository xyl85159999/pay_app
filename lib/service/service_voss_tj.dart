// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bobi_pay_out/manager/connectivity_mgr.dart';
import 'package:bobi_pay_out/manager/data/collect_data.dart';
import 'package:bobi_pay_out/model/update_block_bean.dart';
import 'package:bobi_pay_out/service/base_service.dart';
import 'package:bobi_pay_out/utils/code_define.dart';

final ServiceVossTj serviceVossTj = ServiceVossTj();

class ServiceVossTj extends BaseService {
  ServiceVossTj() : super();

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

  // 获取交易记录
  // 参数
  // begin_time  开始时间
  // end_time    结束时间
  // page        分页 （必填）
  // page_size   每月数量 （必填）
  // books_name  包名
  getTransactionLogList(int page, int ps,
      {String? bn, int? bt, int? et}) async {
    Map<String, dynamic> params = {};
    if (bn != null) params['books_name'] = bn;
    if (bt != null) params['begin_time'] = bt;
    if (et != null) params['end_time'] = et;
    params['page'] = page;
    params['page_size'] = ps;
    var info = makeSign(params);
    HttpResponseBean res =
        await httpPost('/open_address_api/get_transaction_log_list', info);
    if (res.code == 0) {
      return res.result;
    }
    return null;
  }

  /// 获取交易记录详情
  // /open_address_api/get_transaction_detail_log_list
  // 参数
  // begin_time  开始时间
  // end_time    结束时间
  // page        分页 （必填）
  // page_size   每月数量 （必填）
  // books_name  包名 （必填）
  getTransactionDetailLogList(int page, int ps, String bn,
      {int? bt, int? et}) async {
    Map<String, dynamic> params = {};
    if (bt != null) params['begin_time'] = bt;
    if (et != null) params['end_time'] = et;
    if (bn.isEmpty) return [];
    params['books_name'] = bn;
    params['page'] = page;
    params['page_size'] = ps;
    var info = makeSign(params);
    HttpResponseBean res = await httpPost(
        '/open_address_api/get_transaction_detail_log_list', info);
    if (res.code == 0) {
      return res.result;
    }
    return null;
  }

// 地址 url：voss_tj
//   获取地址列表
//   /open_address_api/get_addr_list
//   参数
//   bag_names 包名 （必填）
//   page        分页 （必填）
//   page_size   每月数量 （必填）
//   key 排序key（可选值 字段名）
//   order 排序方式（可选值 asc desc）
//   type_addr 地址类型（0:归集1:商户）
  getAddressList(int page, int ps, String bn,
      {String? key, String order = 'desc', int? type}) async {
    Map<String, dynamic> params = {};
    if (key != null) params['key'] = key;
    if (type != null) params['type_addr'] = type;
    params['key'] = 'usdt_balance';
    params['order'] = order;
    params['bag_names'] = bn;
    params['page'] = page;
    params['page_size'] = ps;
    // return await addrMgr.getAddressList(params);
    final info = makeSign(params);
    HttpResponseBean res =
        await httpPost('/open_address_api/get_addr_list', info);
    if (res.code == 0) {
      return res.result;
    }
    return null;
  }

  getBagNameList({int? type_addr = 0, String? wallet_type}) async {
    Map<String, dynamic> params = {};
    if (type_addr != null) {
      params['type_addr'] = type_addr;
    }
    if (wallet_type != null) {
      params['wallet_type'] = wallet_type;
    }
    // return await addrMgr.getBagNameList(params);
    final info = makeSign(params);
    return await httpPost('/open_address_api/get_all_books_name', info);
  }

  Future<dynamic> get_collection_task_list(
      {int? begin_time,
      int? end_time,
      int? page,
      required int? page_size}) async {
    Map<String, dynamic> params = {};
    if (begin_time != null) {
      params['begin_time'] = begin_time;
    }
    if (end_time != null) {
      params['end_time'] = end_time;
    }
    params['page'] = page ?? 1;
    params['page_size'] = page_size ?? 20;
    final info = makeSign(params);
    HttpResponseBean res =
        await httpPost('/open_address_api/get_collection_task_list', info);
    if (res.code == 0) {
      return res.result;
    }
    return null;
  }

  Future<List?> get_collection_task_need_sign_task() async {
    Map<String, dynamic> params = {};
    final info = makeSign(params);
    HttpResponseBean res = await httpPost(
        '/open_address_api/get_collection_task_need_sign_task', info);
    if (res.code == 0) {
      return res.result;
    }
    return null;
  }

  Future<bool> update_collection_task(CollectData task) async {
    Map<String, dynamic> params = Map.from(task.toJson());
    final info = makeSign(params);
    HttpResponseBean res =
        await httpPost('/open_address_api/update_collection_task', info);
    if (res.code == 0) {
      return true;
    }
    return false;
  }

  Future<List?> get_addrs_by_amount(String booksName, double amount) async {
    Map<String, dynamic> params = {"books_name": booksName, 'amount': amount};
    final info = makeSign(params);
    HttpResponseBean res =
        await httpPost('/open_address_api/get_addrs_by_amount', info);
    if (res.code == 0) {
      return res.result;
    }
    return null;
  }

  Future<dynamic> get_amount(String booksName) async {
    Map<String, dynamic> params = {"books_name": booksName};
    final info = makeSign(params);
    HttpResponseBean res = await httpPost('/open_address_api/get_amount', info);
    if (res.code == 0) {
      return res.val;
    }
    return null;
  }
}
