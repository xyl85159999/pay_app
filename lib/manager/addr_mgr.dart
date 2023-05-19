// ignore_for_file: file_names, non_constant_identifier_names, unnecessary_null_comparison
import 'package:sqflite/sqlite_api.dart';
import 'package:bobi_pay_out/manager/config_mgr.dart';
import 'package:bobi_pay_out/manager/data/local_books_name_data.dart';
import 'package:bobi_pay_out/model/sql/dbUtil.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'package:bobi_pay_out/utils/encrypt_util.dart';
import 'package:bobi_pay_out/utils/utility.dart';
import 'package:bobi_pay_out/view_model/dizhi_bagname_model.dart';

final AddrMgr addrMgr = AddrMgr();
final DiZhiBagNameModel dizhi_bagname_model = DiZhiBagNameModel();

class AddrMgr {
  final Map<String, dynamic> _list = {};
  final tbName = "tb_books_name";
  final voss_encry_key = "voss_encry_key";
  late String encry_key;
  Future init() async {
    await updateConf();
  }

  Future updateConf() async {
    encry_key = (await confMgr.getValueByKey(voss_encry_key))!;
    if (encry_key != null && encry_key.isNotEmpty) {
      encry_key = encryptUtil.xorBase64Encode(encry_key, voss_encry_key);
    }
    await queryList();
  }

  Future queryList() async {
    await dbMgr.open();
    List<Map<String, dynamic>> data =
        await dbMgr.queryList("SELECT * FROM $tbName");
    mypdebug('tb_books_name data：$data');
    _list.clear();
    if (data.isNotEmpty) {
      for (var element in data) {
        _list[element['addr']] = LocalBooksNameData.fromJson(element).toJson();
      }
    }

    await dbMgr.close();
  }

  Future<LocalBooksNameData?> getAddrDataByAddr(String addr) async {
    return _list[addr];
  }

  // 获取所有包名
  Future<List<Map>> getBagNameList(Map<String, dynamic> params) async {
    await dbMgr.open();
    final type_addr = params['type_addr'];
    final type_addr_str =
        type_addr != null ? "where type_addr = '$type_addr' " : '';
    List<Map> data = await dbMgr.queryList(
        "select books_name from $tbName $type_addr_str group by books_name");
    mypdebug('tb_books_name books_name：$data');
    await dbMgr.close();
    return data;
  }

  Future<List<Map>?> getAddressList(Map<String, dynamic> params) async {
    final books_name = params['books_name'] ?? '';
    final page = params['page'] ?? 1;
    final page_size = params['page_size'] ?? 200;
    if (books_name.isEmpty) {
      return null;
    }
    final type_addr = params['type_addr'];
    final type_addr_str =
        type_addr != null ? "type_addr = '$type_addr' and " : '';
    await dbMgr.open();
    final sql =
        "select * from $tbName where $type_addr_str books_name = '$books_name' order by create_time desc limit ${(page - 1) * page_size},$page_size;";
    List<Map> list = await dbMgr.queryList(sql);
    mypdebug('tb_books_name books_name：$list');
    await dbMgr.close();
    return list;
  }

  final Map<String, String> _listPri = {};
  Future<List<String?>> getPriByAdress(String address) async {
    if (address == null) return [null, 'address is null'];
    String? decodePri = _listPri[address];
    if (decodePri != null) return [decodePri];
    dynamic first = _list[address];
    if (first == null) {
      await dbMgr.open();
      final sql =
          "select * from $tbName where addr = '$address' COLLATE NOCASE;";
      List<Map> list = await dbMgr.queryList(sql);
      mypdebug('tb_books_name books_name：$list');
      await dbMgr.close();
      first = list.isNotEmpty ? list.first : null;
    }

    final pri = first != null && first.isNotEmpty ? first['pri'] : null;
    if (pri == null || pri.isEmpty) return [null, 'not find pri key'];
    decodePri = encryptUtil.xorBase64Decode(pri, encry_key);
    if (decodePri == null || decodePri.isEmpty) {
      return [null, 'not find decodePri key'];
    }
    _listPri[address] = decodePri;
    return [decodePri];
  }

  final Map<String, bool> _listGuiji = {};
  Future<bool> checkAddrIsGuiJi(String address) async {
    bool? guijiAddr = _listGuiji[address];
    if (guijiAddr != null && guijiAddr) return true;
    await dbMgr.open();
    final sql = "select * from $tbName where addr = '$address' COLLATE NOCASE;";
    List<Map> list = await dbMgr.queryList(sql);
    mypdebug('tb_books_name books_name：$list');
    await dbMgr.close();
    final b = list != null && list.isNotEmpty;
    if (!b) {
      return false;
    }
    _listGuiji[address] = true;
    return true;
  }

  Future dropTable() async {
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    batch.execute("DROP TABLE IF EXISTS $tbName");
    await batch.commit(noResult: true);
    await dbMgr.close();
  }

  Future initData(List? list) async {
    if (list == null) return;
    if (list.isEmpty) {
      await showToastTip('请初始化local地址包');
      return;
    }
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    batch.delete(tbName);
    for (var element in list) {
      batch.insert(tbName, LocalBooksNameData.fromJson(element).toJson());
    }
    await batch.commit(noResult: true);
    await dbMgr.close();
    await queryList();
    await showToastTip('同步私钥到本地完成');
  }
}
