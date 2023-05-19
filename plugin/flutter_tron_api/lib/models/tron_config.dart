import 'package:flutter_tron_api/models/enviroment.dart';

class TronConfig{
  final Environment env;
  final String contractAddress;
  final int maxAmount;
  final int minAmount;
  String _ownerAddress;
  String _privateKey;

  TronConfig(this._ownerAddress,this._privateKey,{
    this.env = Environment.prod,
    this.maxAmount = 99999999,
    this.minAmount = 1,
    this.contractAddress = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
  });
  
  set ownerAddress(String ownerAddress){
    _ownerAddress = ownerAddress;
  }
  String get ownerAddress{
    return _ownerAddress;
  }

  set privateKey(String privateKey){
    _privateKey = privateKey;
  }
  String get privateKey{
    assert(_privateKey !=null);
    assert(_privateKey !='');
    return _privateKey;
  }
}

