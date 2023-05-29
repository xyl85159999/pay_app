// ignore_for_file: file_names, non_constant_identifier_names

import 'dart:convert';

import 'package:otp/otp.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:bobi_pay_out/main.dart';
import 'package:bobi_pay_out/model/sql/dbUtil.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/platform_utils.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/config_model.dart';

final ConfMgr confMgr = ConfMgr();
final ConfigModel configModel = ConfigModel();

class ConfMgr {
  String google_key = '';
  List<ConfData> _list = [];
  final tbName = "tb_config";
  Future init() async {
    await queryList();
  }

  Future<String?> getValueByKey(String key) async {
    if (key.isEmpty || _list.isEmpty) return null;
    for (var i = 0; i < _list.length; i++) {
      if (_list[i].config_key == key) {
        return _list[i].config_value;
      }
    }
    return "";
  }

  Future queryList() async {
    _secretListKey.clear();
    _listKey.clear();
    for (var i = 0; i < confList.length; i++) {
      if (confList[i]['is_secret'] == true) {
        _secretListKey.add(confList[i]['config_key']);
      }
      _listKey.add(confList[i]['config_key']);
    }
    await dbMgr.open();
    List<Map<String, dynamic>> data =
        await dbMgr.queryList("SELECT * FROM $tbName");
    mypdebug('$tbName data：$data');
    _list = [];
    if (data.isNotEmpty) {
      for (var element in data) {
        ConfData confData = ConfData.fromJson(element);
        confData.is_secret = secretListKey.contains(confData.config_key);
        _list.add(confData);
      }
    }

    await dbMgr.close();
    configModel.list = _list;
    mainUpdateConf();
  }

  Future edit(ConfData confData) async {
    if (confData.isEmpty) return;
    await dbMgr.open();
    final parmas = confData.toSqlJson(hasid: true);
    if (parmas.keys.isEmpty) return;
    await dbMgr
        .updateByHelper(tbName, Map.from(parmas), 'id = ?', [confData.id]);
    await dbMgr.close();
    await queryList();
  }

  Future<bool> updateGoogleKey(String secret) async {
    if (secret.isEmpty) return false;
    await dbMgr.open();
    final b = await dbMgr.updateByHelper(
        tbName, {'config_value': secret}, 'config_key=?', ['google_key']);
    await dbMgr.close();
    await queryList();
    return b == 1;
  }

  Future<bool> delete(ConfData confData) async {
    if (confData.idEmpty) {
      mypdebug(confData.toString());
      return false;
    }

    await dbMgr.open();
    int flag = await dbMgr.deleteByHelper(tbName, 'id = ?', [confData.id]);
    mypdebug('flag:$flag');
    await dbMgr.close();
    await queryList();
    return true;
  }

  Future add(ConfData confData) async {
    if (confData.isEmpty) return;
    await dbMgr.open();
    final parmas = confData.toSqlJson();
    if (parmas.keys.isEmpty) return;
    int flag = await dbMgr.insertByHelper(tbName, Map.from(parmas));
    mypdebug('flag:$flag');
    await dbMgr.close();
    await queryList();
  }

  Future dropTable() async {
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    batch.execute("DROP TABLE IF EXISTS $tbName");
    await batch.commit(noResult: true);
    await dbMgr.close();
  }

  List<String> get listKey => _listKey;
  List<String> get secretListKey => _secretListKey;
  final List confList = [
    {
      'config_key': 'remote_url',
      'config_desc': '远程地址',
      'config_value': 'http://...'
    },
    {
      'config_key': 'remote_salt',
      'config_desc': '远程地址加密串',
      'config_value': '...'
    },
    {'config_key': 'eth_addr', 'config_desc': 'eth出款地址', 'config_value': '...'},
    {
      'config_key': 'eth_pri_key',
      'config_desc': 'eth出款私钥',
      'is_secret': true,
      'config_value': ''
    },
    {'config_key': 'trx_addr', 'config_desc': 'trx出款地址', 'config_value': '...'},
    {
      'config_key': 'trx_pri_key',
      'config_desc': 'trx出款私钥',
      'is_secret': true,
      'config_value': ''
    }
  ];
  final List<String> _listKey = [];
  final List<String> _secretListKey = [];
  Future initData(List<String> list) async {
    if (!list.contains(tbName)) return;
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();

    for (var i = 0; i < confList.length; i++) {
      ConfData confData = ConfData.fromJson(confList[i]);
      batch.insert(tbName, confData.toSqlJson());
    }
    await batch.commit(noResult: true);
    await dbMgr.close();
  }

  Future<bool> importConf(String str) async {
    if (str.isEmpty) return false;
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    try {
      str = str.replaceAll('”', '"');
      str = str.replaceAll('‘', '"');
      str = str.replaceAll('“', '"');
      str = str.replaceAll('’', '"');
      str = str.replaceAll('，', ',');
      str = str.replaceAll("'", '"');
      str = str.replaceAll('：', ':');
      final List<dynamic> confList = jsonDecode(str);
      if (confList.isEmpty) return false;
      int count = 0;
      for (var i = 0; i < confList.length; i++) {
        ConfData confData = ConfData.fromJson(confList[i]);
        if (!_listKey.contains(confData.config_key)) {
          continue;
        }
        count++;
        batch.update(tbName, {'config_value': confData.config_value},
            where: 'config_key = ?', whereArgs: [confData.config_key]);
      }
      if (count == 0) {
        await dbMgr.close();
        return false;
      }
      await batch.commit(noResult: true);
      await dbMgr.close();
      await queryList();
    } catch (e) {
      await dbMgr.close();
      return false;
    }
    return true;
  }

  Future<bool> outportConf() async {
    if (_list.isEmpty) return false;
    try {
      String str = jsonEncode(_list);
      copyStr(str);
      showToastTip('复制成功 $str');
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> googleCodeVerification(String code, {String? secret}) async {
    if (code.isEmpty) return false;
    secret = secret ?? google_key;
    if (secret.isEmpty) return false;
    if (!inProduction && code == '1') return true;
    // if (code == (inProduction ? '9527' : '1')) return true;
    return OTP.generateTOTPCodeString(
            secret, DateTime.now().millisecondsSinceEpoch,
            interval: 30, algorithm: Algorithm.SHA1, isGoogle: true) ==
        code;
  }
}

class ConfData {
  String? config_value;
  String? config_desc;
  String? config_key;
  bool? is_secret = false;
  int? id;

  ConfData(
      {this.config_value,
      this.config_desc,
      this.config_key,
      this.id,
      this.is_secret});

  bool get isEmpty {
    return config_value!.isEmpty && config_desc!.isEmpty && config_key!.isEmpty;
  }

  bool get idEmpty {
    return id == null;
  }

  String get secretValue {
    if (is_secret == true && config_value!.isNotEmpty) {
      final len = config_value!.length;
      if (len > 8) {
        final s =
            "${config_value!.substring(0, 4)}***${config_value!.substring(len - 4)}";
        return s;
      }
    }
    return config_value!;
  }

  ConfData.fromJson(Map<String, dynamic> json) {
    config_value = json["config_value"];
    config_desc = json["config_desc"];
    config_key = json["config_key"];
    id = json["id"];
    is_secret = json["is_secret"] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["config_value"] = config_value;
    data["config_desc"] = config_desc;
    data["config_key"] = config_key;
    data["id"] = id;
    data["is_secret"] = is_secret;
    return data;
  }

  Map<String, dynamic> toSqlJson({bool hasid = false}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["config_value"] = config_value;
    data["config_desc"] = config_desc;
    data["config_key"] = config_key;
    if (hasid) {
      data["id"] = id;
    }
    return data;
  }

  Map<String, dynamic> toSqlJson2() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["config_value"] = config_value;
    data["config_key"] = config_key;
    return data;
  }
}
