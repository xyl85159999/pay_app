
class TongjiData {
  String? booksName;
  int? updateTime;
  int? addrNum;
  String? rukuanB;
  String? chukuanB;
  double? amout;
  String? walletType;

  TongjiData({this.booksName, this.updateTime, this.addrNum, this.rukuanB, this.chukuanB, this.amout});

  TongjiData.fromJson(Map<String, dynamic> json) {
    booksName = json["books_name"];
    updateTime = json["update_time"];
    addrNum = json["addr_num"];
    rukuanB = json["rukuan_b"];
    chukuanB = json["chukuan_b"];
    walletType = json["wallet_type"];
    amout = json["amout"] * 1.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["books_name"] = booksName;
    data["update_time"] = updateTime;
    data["addr_num"] = addrNum;
    data["rukuan_b"] = rukuanB;
    data["chukuan_b"] = chukuanB;
    data["wallet_type"] = walletType;
    data["amout"] = amout;
    return data;
  }
}