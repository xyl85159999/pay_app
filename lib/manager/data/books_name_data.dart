
class BooksNameData {
  int? typeAddr;
  int? updateTime;
  double? trxBalance;
  String? booksName;
  double? usdtBalance;
  String? addr;

  BooksNameData({this.typeAddr, this.updateTime, this.trxBalance, this.booksName, this.usdtBalance, this.addr});

  BooksNameData.fromJson(Map<String, dynamic> json) {
    typeAddr = json["type_addr"];
    updateTime = json["update_time"]; 
   
    trxBalance = (json["trx_balance"] ?? 0.0) * 1.0;
    booksName = json["books_name"];
    usdtBalance =  (json["usdt_balance"] ?? 0.0) * 1.0;
    addr = json["addr"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["type_addr"] = typeAddr;
    data["update_time"] = updateTime;
    data["trx_balance"] = trxBalance;
    data["books_name"] = booksName;
    data["usdt_balance"] = usdtBalance;
    data["addr"] = addr;
    return data;
  }
}