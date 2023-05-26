import 'package:bobi_pay_out/model/constant.dart';

class PayOutTask {
  late int taskId;
  late String fromAddr;
  late String toAddr;
  late double amount;
  late String walletType;
  late String transactionId;
  late PayOutStatus status;
  late String remark;
  late int updateTime;
  late int createTime;

  PayOutTask(
      {this.taskId = 0,
      this.fromAddr = '',
      this.toAddr = '',
      this.amount = 0,
      this.transactionId = '',
      this.status = PayOutStatus.payOutStatusNone,
      this.remark = '',
      this.updateTime = 0,
      this.createTime = 0});

  PayOutTask.fromJson(Map<String, dynamic> json) {
    assert(json["status"] is int);
    status = PayOutStatus.values[json["status"]];

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
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
