import 'package:json_annotation/json_annotation.dart';

part 'tron_transaction_history.g.dart';

@JsonSerializable()
class TronTransactionHistory {
  int? total;
  int? rangeTotal;
  List<Data>? data;
  int? wholeChainTxCount;
  Map<String, bool>? contractMap;
  Map<String, Map<String, dynamic>>? contractInfo;

  TronTransactionHistory();

  factory TronTransactionHistory.fromJson(Map<String, dynamic> json) =>
      _$TronTransactionHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$TronTransactionHistoryToJson(this);
}

@JsonSerializable()
class Data {
  int? block;
  String? hash;
  int? timestamp;
  String? ownerAddress;
  List<String>? toAddressList;
  String? toAddress;
  int? contractType;
  bool? confirmed;
  bool? revert;
  ContractData? contractData;

  @JsonKey(name: 'SmartCalls')
  String? smartCalls;
  @JsonKey(name: 'Events')
  String? events;
  String? id;
  String? data;
  String? fee;
  String? contractRet;
  String? result;
  String? amount;
  Cost? cost;

  TokenInfo? tokenInfo;

  @JsonKey(name: 'trigger_info')
  TriggerInfo? triggerInfo;

  Data();

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}

@JsonSerializable()
class ContractData {
  String? data;
  @JsonKey(name: 'owner_address')
  String? ownerAddress;
  @JsonKey(name: 'contract_address')
  String? contractAddress;

  ContractData();

  factory ContractData.fromJson(Map<String, dynamic> json) =>
      _$ContractDataFromJson(json);
  Map<String, dynamic> toJson() => _$ContractDataToJson(this);
}

@JsonSerializable()
class Cost {
  @JsonKey(name: 'net_usage')
  int? netUsage;
  @JsonKey(name: 'net_fee')
  int? netFee;
  @JsonKey(name: 'energy_usage')
  int? energyUsage;
  @JsonKey(name: 'energy_fee')
  int? energyFee;
  @JsonKey(name: 'energy_usage_total')
  int? energyUsageTotal;
  int? fee;
  @JsonKey(name: 'origin_energy_usage')
  int? originEnergyUsage;

  Cost();

  factory Cost.fromJson(Map<String, dynamic> json) => _$CostFromJson(json);
  Map<String, dynamic> toJson() => _$CostToJson(this);
}

@JsonSerializable()
class TokenInfo {
  String? tokenId;
  String? tokenName;
  int? tokenDecimal;
  int? tokenCanShow;
  String? tokenType;
  String? tokenLevel;
  bool? vip;

  TokenInfo();

  factory TokenInfo.fromJson(Map<String, dynamic> json) =>
      _$TokenInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TokenInfoToJson(this);
}

@JsonSerializable()
class TriggerInfo {
  String? data;
  Map<String, dynamic>? parameter;
  String? methodName;
  @JsonKey(name: 'contract_address')
  String? contractAddress;
  @JsonKey(name: 'call_value')
  int? callValue;

  TriggerInfo();

  factory TriggerInfo.fromJson(Map<String, dynamic> json) =>
      _$TriggerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TriggerInfoToJson(this);
}
