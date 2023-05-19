class LocalBooksNameData {
  String? pri;
  String? vossEncryKey;
  double? trxBalance;
  String? addr;
  String? encodePri;
  int? updateTime;
  double? usdtBalance;
  String? booksName;
  String? walletType;
  int? typeAddr;
  String? hex;

  LocalBooksNameData(
      {this.pri,
      this.vossEncryKey,
      this.trxBalance,
      this.addr,
      this.encodePri,
      this.updateTime,
      this.usdtBalance,
      this.booksName,
      this.typeAddr,
      this.hex});

  LocalBooksNameData.fromJson(Map<String, dynamic> json) {
    booksName = json["bag_name"];
    addr = json["addr"];
    pri = json["pri"];
    typeAddr = json["type_addr"];
    walletType = json["wallet_type"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["books_name"] = booksName;
    data["wallet_type"] = walletType ?? 'wallet_trx';
    data["addr"] = addr;

    data["pri"] = pri;
    data["type_addr"] = typeAddr ?? 0;

    return data;
  }
}
