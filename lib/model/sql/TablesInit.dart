// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import 'package:bobi_pay_out/model/sql/DBUtil.dart';
import 'package:bobi_pay_out/utils/debug_info.dart';
import 'createTableSqls.dart';

CreateTableSqls sqlTables = CreateTableSqls();

class TablesInit {
  Future<List<String>> initDB() async {
    //所有的sql语句
    Map<String, String> allTableSqls = sqlTables.getAllTables();
    //检查需要生成的表
    List<String> noCreateTables = await getNoCreateTables(allTableSqls);
    mypdebug('noCreateTables:$noCreateTables');
    if (noCreateTables.isNotEmpty) {
      //创建新表
      // 关闭上面打开的db，否则无法执行open
      await dbMgr.open(version: 1);
      Batch batch = await dbMgr.getBatch();
      for (var sql in noCreateTables) {
        batch.execute(allTableSqls[sql]!);
      }
      await batch.commit(noResult: true);
      await dbMgr.close();
      mypdebug('db补完表已打开');
    } else {
      mypdebug("表都存在，db已打开");
    }
    await dbMgr.open();
    List tableMaps = await dbMgr
        .queryList('SELECT name FROM sqlite_master WHERE type = "table"');
    mypdebug('所有表:$tableMaps');
    await dbMgr.close();
    mypdebug("db已关闭");
    return noCreateTables;
  }

  // 检查数据库中是否有所有有表,返回需要创建的表
  Future<List<String>> getNoCreateTables(Map<String, String> tableSqls) async {
    Iterable<String> tableNames = tableSqls.keys;
    //已经存在的表
    List<String> existingTables = <String>[];
    //要创建的表
    List<String> createTables = <String>[];
    await dbMgr.open();
    List tableMaps = await dbMgr
        .queryList('SELECT name FROM sqlite_master WHERE type = "table"');
    mypdebug('tableMaps:$tableMaps');
    await dbMgr.close();
    for (var item in tableMaps) {
      existingTables.add(item['name']);
    }
    for (var tableName in tableNames) {
      if (!existingTables.contains(tableName)) {
        createTables.add(tableName);
      }
    }
    return createTables;
  }
}
