// ignore_for_file: use_function_type_syntax_for_parameters

import 'dart:convert';

import 'package:bobi_pay_out/utils/code_define.dart';

class HttpResponseBean {
  //这个包的原始信息
  late String _uri;
  String get uri => _uri;
  late Map<dynamic, dynamic> _params;
  Map<dynamic, dynamic> get params => _params;

  //源数据
  late Map<dynamic, dynamic> _json;

  //返回的代码
  int get code => _json['code'];
  bool get success => code == 0;
  //返回的提示消息
  String get msg => _json['msg'];

  //data是map
  dynamic get data => _json['data'];
  //result是数组
  List get result => _json['result'] is List ? _json['result'] : [];
  //val是单个的值
  dynamic get val => _json['val'];

  int get hasNext => _json['has_next'];

  //记录总数
  int get totalRecord => _json['total_record'];

  HttpResponseBean(
      Map<dynamic, dynamic> json, String uri, Map<dynamic, dynamic> params) {
    _json = json;
    _uri = uri;
    _params = params;
  }

  dynamic getList(String k) {
    return _json[k] is List ? _json[k] : [];
  }

  dynamic getMap(String k) {
    return _json[k] is Map ? _json[k] : {};
  }

  dynamic getValue(String k) {
    return _json[k];
  }

  int getInt(String k) {
    var v = _json[k];
    if (v == null) {
      return 0;
    } else if (v is String) {
      return int.parse(v);
    } else {
      return v;
    }
  }

  /// 增加一个子节点遍历功能
  forEach(String k, void f(element)) {
    List ls = _json[k];
    ls.forEach(f);
  }

  @override
  String toString() {
    return '[$runtimeType] res:$_json, uri:$_uri, params:$_params';
  }
}

class HttpUpdateBlockBean {
  late int random;
  late int status;
  late Map<String, dynamic> body;
  late Map<String, dynamic> _json;
  late String errStr;

  _checkBody(body) {
    if (body == null) return {'code': CodeDefine.codeBodyNull};
    if (body == 'nil') return {'code': CodeDefine.codeBodyNil};
    if (body is String && body.trim().isEmpty) {
      return {'code': CodeDefine.codeBodyNullString};
    }
    if (!(body is Map || body is String)) {
      return {'code': CodeDefine.codeBodyTypeErr};
    }

    Map mapBody;
    if (body is String) {
      try {
        mapBody = jsonDecode(body);
      } catch (e) {
        return {'code': CodeDefine.codeBodyDecodeErr};
      }
    } else {
      mapBody = body;
    }

    if (mapBody['code'] == null) return {'code': CodeDefine.codeBodyNotCode};
    if (mapBody['code'] is! int) {
      try {
        mapBody['code'] = int.parse(mapBody['code']);
      } catch (e) {
        return {'code': CodeDefine.codeBodyCodeNotInt};
      }
    }
    return mapBody;
  }

  HttpUpdateBlockBean.fromJson(Map<String, dynamic> json) {
    _json = json;
    random = json['random'];
    status = json['status'];
    if (status == 500) {
      errStr = json['body'];
    } else {
      body = _checkBody(json['body']);
    }
  }

  @override
  String toString() {
    return _json.toString();
  }
}

/// 对象更新块信息
class UpdateBlockBean {
  /// 相关的操作 r/u/d/http
  static String getOpt(json) => json['opt'];

  /// 相关的控制器/表名/对象名
  static String getCtl(json) => json["ctl"];

  /// 相关的新数据
  static dynamic getData(json) => json['data'];

  static String printString(json) {
    return 'opt:${getOpt(json)}, ctl:${getCtl(json)}, data:${getData(json)}, json:$json';
  }
}
