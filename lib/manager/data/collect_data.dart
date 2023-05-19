
class CollectData {
  String? addr;
  int? hasCallback;
  int? id;
  int? taskId;
  String? toAddr;
  String? remark;
  int? updateTime;
  double? amount;
  double? energyUsedMax;
  String? walletType;
  String? transactionId = '';
  int? status;
  int? createTime;

  CollectData({this.addr, this.hasCallback, this.taskId, this.toAddr, this.remark, this.updateTime, this.amount, this.transactionId, this.status, this.createTime});

  CollectData.fromJson(Map<String, dynamic> json) {
    if(json["addr"] is String) {
      addr = json["addr"];
    }
    if(json["has_callback"] is int) {
      hasCallback = json["has_callback"];
    }
    if(json["id"] is int) {
      id = json["id"];
    }
    if(json["task_id"] is int) {
      taskId = json["task_id"];
    }
    if(json["to_addr"] is String) {
      toAddr = json["to_addr"];
    }
    if(json["remark"] is String) {
      remark = json["remark"];
    }
    if(json["update_time"] is int) {
      updateTime = json["update_time"];
    }
    
    amount = (json["amount"] ?? 0.0) * 1.0;

    energyUsedMax = (json["energy_used_max"] ?? 0.0) * 1.0;
    
    if(json["transaction_id"] is String) {
      transactionId = json["transaction_id"];
    }
    if(json["wallet_type"] is String) {
      walletType = json["wallet_type"];
    }
    if(json["status"] is int) {
      status = json["status"];
    }
    if(json["create_time"] is int) {
      createTime = json["create_time"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["addr"] = addr;
    data["has_callback"] = hasCallback;
    data["id"] = id;
    data["task_id"] = taskId;
    data["to_addr"] = toAddr;
    data["remark"] = remark ?? '';
    data["update_time"] = updateTime;
    data["amount"] = amount;
    data["energy_used_max"] = energyUsedMax;
    data["transaction_id"] = transactionId ?? '';
    data["wallet_type"] = walletType;
    data["status"] = status;
    data["create_time"] = createTime;
    return data;
  }
}