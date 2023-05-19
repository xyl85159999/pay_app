import 'package:sqflite/sqlite_api.dart';
import 'package:bobi_pay_out/model/sql/dbUtil.dart';

///数据表定义

// ignore_for_file: file_names

class CreateTableSqls {
  //系统配置表
  static const String createTableSqlConfig = '''
      CREATE TABLE IF NOT EXISTS tb_config (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
        config_key VARCHAR(20)  NOT NULL,  
        config_value VARCHAR(64) NOT NULL, 
        config_desc VARCHAR(20) NOT NULL
      );
      CREATE UNIQUE INDEX idx_config_key
        on tb_config (config_key);
    ''';

  //出款表
  static const String createTableSqlPayOut = '''
    CREATE TABLE IF NOT EXISTS tb_pay_out (
      id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
      task_id INT NOT NULL UNIQUE,
      to_addr VARCHAR(128) NOT NULL,
      amount DOUBLE NOT NULL,
      transaction_id VARCHAR(255) NOT NULL,
      status INT NOT NULL UNIQUE,
      remark VARCHAR(255) NULL,
      update_time INT NOT NULL,
      create_time INT NOT NULL,
    );
  ''';
  //商户地址表
  static const String createTableSqlBooksName = '''
    CREATE TABLE IF NOT EXISTS tb_books_name (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    books_name VARCHAR(64) NOT NULL, 
    wallet_type VARCHAR(64) DEFAULT NULL,
    addr VARCHAR(128) NOT NULL UNIQUE, 
    pri VARCHAR(256) NOT NULL UNIQUE, 
    type_addr TINYINT DEFAULT 0);
    ''';

  static const String createTableSqlTransferTask = '''
    CREATE TABLE IF NOT EXISTS tb_transfer_task (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    wallet_type VARCHAR(64) DEFAULT NULL,
    from_bag_name VARCHAR(64) NOT NULL,
    to_addr VARCHAR(255) NOT NULL,
    amount DOUBLE NOT NULL,
    tarning_amount DOUBLE NOT NULL DEFAULT '0',
    finish_amount DOUBLE NOT NULL DEFAULT '0',
    status INT DEFAULT NULL,
    remark VARCHAR(255) DEFAULT NULL,
    create_time INT DEFAULT NULL,
    update_time INT DEFAULT NULL);
    ''';

  static const String createTableSqlTransactionLog = '''
    CREATE TABLE IF NOT EXISTS tb_transaction_log (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    task_id INT NOT NULL,
    from_bag_name VARCHAR(64) NOT NULL,
    from_addr VARCHAR(255) NOT NULL,
    to_addr VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) DEFAULT NULL,
    wallet_type VARCHAR(64) DEFAULT NULL,
    energy_used_max DOUBLE DEFAULT 0,
    usdt_val DOUBLE NOT NULL,
    status tinyint NOT NULL DEFAULT '0',
    create_time INT unsigned NOT NULL,
    update_time INT unsigned NOT NULL,
    remark VARCHAR(1024) DEFAULT NULL);
    ''';

  static const String createTableSqlCollectTask = '''
    CREATE TABLE IF NOT EXISTS tb_collection_task (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
    task_id INT NOT NULL,
    status tinyint NOT NULL DEFAULT '0',
    has_callback tinyint NOT NULL DEFAULT '0',
    addr VARCHAR(255) NOT NULL,
    to_addr VARCHAR(255) NOT NULL,
    amount DOUBLE NOT NULL,
    energy_used_max DOUBLE DEFAULT 0,
    transaction_id VARCHAR(255) DEFAULT NULL,
    wallet_type VARCHAR(64) DEFAULT NULL,
    create_time INT unsigned NOT NULL,
    update_time INT unsigned NOT NULL,
    remark VARCHAR(1024) DEFAULT NULL);
    ''';

  Map<String, String> getAllTables() {
    Map<String, String> map = <String, String>{};
    map['tb_config'] = createTableSqlConfig;
    map['tb_pay_out'] = createTableSqlPayOut;
    map['tb_books_name'] = createTableSqlBooksName;
    map['tb_transfer_task'] = createTableSqlTransferTask;
    map['tb_transaction_log'] = createTableSqlTransactionLog;
    map['tb_collection_task'] = createTableSqlCollectTask;
    return map;
  }

  Map<String, String> getAllDropTables() {
    Map<String, String> map = <String, String>{};
    map['tb_config'] = createTableSqlConfig;
    map['tb_pay_out'] = createTableSqlPayOut;
    map['tb_books_name'] = createTableSqlBooksName;
    map['tb_transfer_task'] = createTableSqlTransferTask;
    map['tb_transaction_log'] = createTableSqlTransactionLog;
    map['tb_collection_task'] = createTableSqlCollectTask;
    return map;
  }

  Future dropAllTable() async {
    Map<String, String> list = getAllDropTables();
    await dbMgr.open();
    Batch batch = await dbMgr.getBatch();
    for (var tbName in list.keys) {
      batch.execute("DROP TABLE IF EXISTS $tbName");
    }
    await batch.commit(noResult: true);
    await dbMgr.close();
  }
}
