import 'package:bobi_pay_out/model/constant.dart';

class PayOutTask {
  ///任务id
  late int taskId;

  ///状态
  late PayOutStatusEnum status;

  ///钱包类型
  late String walletType;

  ///出款地址
  late String fromAddr;

  ///首款地址
  late String toAddr;

  ///金额
  late double amount;

  ///交易id
  late String transactionId;

  ///备注
  late String remark;

  ///更新时间
  late int updateTime;

  ///创建时间
  late int createTime;

  PayOutTask(
      {this.taskId = 0,
      this.walletType = '',
      this.fromAddr = '',
      this.toAddr = '',
      this.amount = 0,
      this.transactionId = '',
      this.status = PayOutStatusEnum.payOutStatusNone,
      this.remark = '',
      this.updateTime = 0,
      this.createTime = 0});

  PayOutTask.fromJson(Map<String, dynamic> json) {
    assert(json["status"] is int);
    status = PayOutStatusEnum.values[json["status"]];

    if (json["task_id"] is int) {
      taskId = json["task_id"];
    }
    if (json["from_addr"] is String) {
      fromAddr = json["from_addr"];
    }
    if (json["to_addr"] is String) {
      toAddr = json["to_addr"];
    }
    if (json["update_time"] is int) {
      updateTime = json["update_time"];
    }

    amount = (json["amount"] ?? 0.0) * 1.0;

    if (json["wallet_type"] is String) {
      walletType = json["wallet_type"];
    }

    if (json["create_time"] is int) {
      createTime = json["create_time"];
    }
  }

  Map<String, Object> toJson() {
    final Map<String, Object> data = <String, Object>{};
    data["task_id"] = taskId;
    data["from_addr"] = fromAddr;
    data["to_addr"] = toAddr;
    data["remark"] = remark;
    data["update_time"] = updateTime;
    data["amount"] = amount;
    data["transaction_id"] = transactionId;
    data["wallet_type"] = walletType;
    data["status"] = status.index;
    data["create_time"] = createTime;
    return data;
  }
}
