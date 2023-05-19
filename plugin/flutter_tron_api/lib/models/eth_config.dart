import 'package:flutter_tron_api/models/enviroment.dart';

class EthConfig{
  final Environment env;
  final String contractAddress;
  final int maxAmount;
  final int minAmount;
  final double minEthAmount;
  final double maxEthAmount;
  String _ownerAddress;
  String _privateKey;

  EthConfig(this._ownerAddress,this._privateKey,{
    this.env = Environment.prod,
    this.maxAmount = 99999999,
    this.minAmount = 1,
    this.maxEthAmount = 99999999,
    this.minEthAmount = 0.000001,
    this.contractAddress = '0xdAC17F958D2ee523a2206206994597C13D831ec7',
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
    return _privateKey;
  }
}

