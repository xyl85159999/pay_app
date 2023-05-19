
class TranscationLogData {
  int? id;
  int? taskId;
  String? fromBagName;
  String? fromAddr;
  String? toAddr;
  String? transactionId;
  String? walletType;
  double? usdtVal;
  double? energyUsedMax;
  int? status;
  int? createTime;
  int? updateTime;
  String? remark;

  TranscationLogData(
      {this.id,
      this.taskId,
      this.walletType,
      this.fromBagName,
      this.fromAddr,
      this.toAddr,
      this.transactionId,
      this.usdtVal,
      this.status,
      this.createTime,
      this.updateTime,
      this.remark});

  TranscationLogData.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    taskId = json["task_id"];
    fromBagName = json["from_bag_name"];
    fromAddr = json["from_addr"];
    toAddr = json["to_addr"];
    transactionId = json["transaction_id"];
    walletType = json["wallet_type"];
    usdtVal = (json["usdt_val"] ?? 0.0) * 1.0;
    energyUsedMax = (json["energy_used_max"] ?? 0.0) * 1.0;
    status = json["status"];
    createTime = json["create_time"];
    updateTime = json["update_time"];
    remark = json["remark"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["task_id"] = taskId;
    data["from_bag_name"] = fromBagName;
    data["from_addr"] = fromAddr;
    data["to_addr"] = toAddr;
    data["transaction_id"] = transactionId ?? '';
    data["wallet_type"] = walletType;
    data["usdt_val"] = usdtVal;
    data["energy_used_max"] = energyUsedMax;
    data["status"] = status;
    data["create_time"] = createTime;
    data["update_time"] = updateTime;
    data["remark"] = remark ?? '';
    return data;
  }
}