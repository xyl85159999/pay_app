class PayOutTask {
  int? taskId;
  String? toAddr;
  double? amount;
  String? walletType;
  String? transactionId;
  int? status;
  String? remark;
  int? updateTime;
  int? createTime;

  PayOutTask(
      {this.taskId,
      this.toAddr,
      this.amount,
      this.transactionId,
      this.status,
      this.remark,
      this.updateTime,
      this.createTime});

  PayOutTask.fromJson(Map<String, dynamic> json) {
    if (json["task_id"] is int) {
      taskId = json["task_id"];
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
    if (json["status"] is int) {
      status = json["status"];
    }
    if (json["create_time"] is int) {
      createTime = json["create_time"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["task_id"] = taskId;
    data["to_addr"] = toAddr;
    data["remark"] = remark ?? '';
    data["update_time"] = updateTime;
    data["amount"] = amount;
    data["transaction_id"] = transactionId ?? '';
    data["wallet_type"] = walletType;
    data["status"] = status;
    data["create_time"] = createTime;
    return data;
  }
}
