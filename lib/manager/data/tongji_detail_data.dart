
class TongjiDetailData {
  double? chukuan;
  double? rukuan;
  String? fromAddr;
  String? toAddr;
  String? transactionId;
  String? walletType;
  int? updateTime;

  TongjiDetailData({this.chukuan, this.rukuan, this.fromAddr, this.toAddr, this.transactionId, this.updateTime});

  TongjiDetailData.fromJson(Map<String, dynamic> json) {
    chukuan = (json["chukuan"] == null || json["chukuan"] == '' ? 0 : json["chukuan"]) *1.0;
    rukuan = (json["rukuan"] == null || json["rukuan"] == '' ? 0 : json["rukuan"]) *1.0;
    fromAddr = json["from_addr"];
    toAddr = json["to_addr"];
    transactionId = json["transaction_id"];
    walletType = json["wallet_type"];
    updateTime = json["update_time"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["chukuan"] = chukuan;
    data["rukuan"] = rukuan;
    data["from_addr"] = fromAddr;
    data["to_addr"] = toAddr;
    data["transaction_id"] = transactionId;
    data["wallet_type"] = walletType;
    data["update_time"] = updateTime;
    return data;
  }
}