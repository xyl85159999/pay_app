import 'package:bobi_pay_out/model/constant.dart';

class ChuKuanData {
  int? createTime;
  String? toAddr;
  String? walletType;
  double? amount;
  double? tarningAmount;
  double? finishAmount;
  int? status;
  int? updateTime;
  String? remark;
  String? fromBagName;
  int? id;

  ChuKuanData(
      {this.createTime,
      this.toAddr,
      this.walletType,
      this.amount,
      this.tarningAmount,
      this.finishAmount,
      this.status,
      this.updateTime,
      this.remark,
      this.fromBagName});

  ChuKuanData.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    createTime = json["create_time"];
    toAddr = json["to_addr"];
    amount = json["amount"];
    tarningAmount = json["tarning_amount"];
    finishAmount = json["finish_amount"];
    status = json["status"];
    updateTime = json["update_time"];
    remark = json["remark"];
    fromBagName = json["from_bag_name"];
    walletType = json["wallet_type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["create_time"] = createTime;
    data["to_addr"] = toAddr;
    data["wallet_type"] = walletType;
    data["amount"] = amount ?? 0;
    data["tarning_amount"] = tarningAmount ?? 0;
    data["finish_amount"] = finishAmount ?? 0;
    data["status"] = status ?? TRANSFER_TASK_STATUS_NONE;
    data["update_time"] = updateTime;
    data["remark"] = remark ?? '';
    data["from_bag_name"] = fromBagName;
    return data;
  }
}
